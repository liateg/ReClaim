import { type Request, type Response } from "express";
import { pool } from "../../config/db.js";
import { type AuthTokenPayload } from "../../types/auth.js";

type AuthedRequest = Request & {
  auth?: AuthTokenPayload;
};

const allowedStatuses = new Set([
  "pending",
  "approved",
  "rejected",
  "withdrawn",
]);

const claimSelect = `
  c.id,
  c.item_id AS "itemId",
  c.claimant_id AS "claimantId",
  c.answer_attempt AS "answerAttempt",
  c.status,
  c.review_note AS "reviewNote",
  c.created_at AS "createdAt",
  c.updated_at AS "updatedAt",
  i.title,
  i.description,
  i.image_url AS "imageUrl",
  i.location,
  i.category_id AS "categoryId"
`;

const toClaimResponse = (claim: Record<string, unknown>) => ({
  id: claim.id,
  itemId: claim.itemId,
  claimantId: claim.claimantId,
  answerAttempt: claim.answerAttempt,
  status: claim.status,
  reviewNote: claim.reviewNote,
  createdAt: claim.createdAt,
  updatedAt: claim.updatedAt,
  title: claim.title,
  description: claim.description,
  imageUrl: claim.imageUrl,
  location: claim.location,
  categoryId: claim.categoryId,
});

const getAuth = (req: Request) => (req as AuthedRequest).auth;

const normalizeParamValue = (value: string | string[] | undefined) => {
  if (Array.isArray(value)) {
    return value[0];
  }

  return value;
};

const normalizeAnswer = (value: unknown) =>
  typeof value === "string" ? value.trim().toLowerCase() : "";

const loadClaimAccess = async (claimId: string | string[] | undefined) => {
  const normalizedClaimId = normalizeParamValue(claimId);

  if (!normalizedClaimId) {
    return { status: 400, message: "Claim ID is required" } as const;
  }

  const result = await pool.query(
    `SELECT id, claimant_id AS "claimantId"
     FROM claims
     WHERE id = $1`,
    [normalizedClaimId],
  );

  if (result.rows.length === 0) {
    return { status: 404, message: "Claim not found" } as const;
  }

  return {
    status: 200,
    claimId: result.rows[0].id as number,
    claimantId: result.rows[0].claimantId as number,
  } as const;
};

export const createClaim = async (req: Request, res: Response) => {
  const auth = getAuth(req);
  const { itemId, claimantId, answerAttempt, status = "pending" } = req.body;

  try {
    if (!auth) {
      return res.status(401).json({ message: "Authentication required" });
    }

    if (!itemId || !answerAttempt) {
      return res.status(400).json({ message: "Missing required claim fields" });
    }

    if (claimantId !== undefined && String(claimantId) !== String(auth.id)) {
      return res
        .status(403)
        .json({ message: "You can only create claims for yourself" });
    }

    if (!allowedStatuses.has(status)) {
      return res.status(400).json({ message: "Invalid claim status" });
    }

    if (status !== "pending") {
      return res
        .status(400)
        .json({ message: "New claims must start as pending" });
    }

    const insertResult = await pool.query(
      `INSERT INTO claims (item_id, claimant_id, answer_attempt, status, review_note)
       VALUES ($1, $2, $3, $4, $5)
       RETURNING id`,
      [itemId, auth.id, answerAttempt, status, null],
    );

    const createdClaim = await pool.query(
      `SELECT ${claimSelect} FROM claims c
       JOIN items i ON c.item_id = i.id
       WHERE c.id = $1`,
      [insertResult.rows[0].id],
    );

    return res.status(201).json({
      message: "Claim created successfully",
      claim: toClaimResponse(createdClaim.rows[0]),
    });
  } catch (error) {
    console.error("Error creating claim:", error);

    if ((error as { code?: string }).code === "23503") {
      return res.status(400).json({ message: "Invalid foreign key reference" });
    }

    return res.status(500).json({ message: "Internal server error" });
  }
};

export const getClaims = async (req: Request, res: Response) => {
  try {
    const auth = getAuth(req);

    if (!auth) {
      return res.status(401).json({ message: "Authentication required" });
    }

    const whereClause = auth.role === "admin" ? "" : "WHERE c.claimant_id = $1";
    const result = await pool.query(
      `SELECT ${claimSelect} FROM claims c
       JOIN items i ON c.item_id = i.id
       ${whereClause}
       ORDER BY c.id DESC`,
      auth.role === "admin" ? [] : [auth.id],
    );

    return res.status(200).json({
      claims: result.rows.map(toClaimResponse),
    });
  } catch (error) {
    console.error("Error fetching claims:", error);
    return res.status(500).json({ message: "Internal server error" });
  }
};

export const getClaimById = async (req: Request, res: Response) => {
  const { id } = req.params;
  const auth = getAuth(req);

  try {
    if (!auth) {
      return res.status(401).json({ message: "Authentication required" });
    }

    const result = await pool.query(
      `SELECT ${claimSelect} FROM claims c
       JOIN items i ON c.item_id = i.id
       WHERE c.id = $1`,
      [id],
    );

    if (result.rows.length === 0) {
      return res.status(404).json({ message: "Claim not found" });
    }

    const claimantId = result.rows[0].claimantId as number;

    if (auth.role !== "admin" && Number(claimantId) !== Number(auth.id)) {
      return res
        .status(403)
        .json({ message: "You do not have permission to perform this action" });
    }

    return res.status(200).json({ claim: toClaimResponse(result.rows[0]) });
  } catch (error) {
    console.error("Error fetching claim:", error);
    return res.status(500).json({ message: "Internal server error" });
  }
};

export const updateClaim = async (req: Request, res: Response) => {
  const { id } = req.params;
  const { itemId, claimantId, answerAttempt, status, reviewNote } = req.body;
  const auth = getAuth(req);

  try {
    if (!auth) {
      return res.status(401).json({ message: "Authentication required" });
    }

    if (status !== undefined && !allowedStatuses.has(status)) {
      return res.status(400).json({ message: "Invalid claim status" });
    }

    const access = await loadClaimAccess(id);

    if (access.status !== 200) {
      return res.status(access.status).json({ message: access.message });
    }

    const isAdmin = auth.role === "admin";
    const isOwner = Number(access.claimantId) === Number(auth.id);

    if (!isAdmin && !isOwner) {
      return res
        .status(403)
        .json({ message: "You do not have permission to perform this action" });
    }

    if (!isAdmin) {
      if (
        itemId !== undefined ||
        claimantId !== undefined ||
        reviewNote !== undefined
      ) {
        return res.status(403).json({
          message: "You can only update your own claim details",
        });
      }

      if (status !== undefined && status !== "withdrawn") {
        return res.status(403).json({
          message: "You can only withdraw your own claim",
        });
      }
    }

    const updateFragments: string[] = [];
    const values: unknown[] = [];

    if (itemId !== undefined) {
      updateFragments.push(`item_id = $${values.length + 1}`);
      values.push(itemId);
    }

    if (claimantId !== undefined) {
      updateFragments.push(`claimant_id = $${values.length + 1}`);
      values.push(claimantId);
    }

    if (answerAttempt !== undefined) {
      updateFragments.push(`answer_attempt = $${values.length + 1}`);
      values.push(answerAttempt);
    }

    if (status !== undefined) {
      updateFragments.push(`status = $${values.length + 1}`);
      values.push(status);
    }

    if (reviewNote !== undefined) {
      updateFragments.push(`review_note = $${values.length + 1}`);
      values.push(reviewNote);
    }

    if (updateFragments.length === 0) {
      return res
        .status(400)
        .json({ message: "At least one field is required to update" });
    }

    values.push(Number(id));

    const updateResult = await pool.query(
      `UPDATE claims
       SET ${updateFragments.join(", ")}
       WHERE id = $${values.length}
       RETURNING id`,
      values,
    );

    if (updateResult.rows.length === 0) {
      return res.status(404).json({ message: "Claim not found" });
    }

    if (status === "approved") {
      await pool.query(
        "UPDATE items SET status = 'claimed' WHERE id = (SELECT item_id FROM claims WHERE id = $1)",
        [Number(id)],
      );
    }

    const result = await pool.query(
      `SELECT ${claimSelect} FROM claims c
       JOIN items i ON c.item_id = i.id
       WHERE c.id = $1`,
      [updateResult.rows[0].id],
    );

    return res.status(200).json({
      message: "Claim updated successfully",
      claim: toClaimResponse(result.rows[0]),
    });
  } catch (error) {
    console.error("Error updating claim:", error);

    if ((error as { code?: string }).code === "23503") {
      return res.status(400).json({ message: "Invalid foreign key reference" });
    }

    if (
      (error as Error).message === "At least one field is required to update"
    ) {
      return res
        .status(400)
        .json({ message: "At least one field is required to update" });
    }

    return res.status(500).json({ message: "Internal server error" });
  }
};

export const approveClaim = async (req: Request, res: Response) => {
  const { id } = req.params;
  const { reviewNote } = req.body;

  try {
    const reviewSource = await pool.query(
      `SELECT c.id,
              c.answer_attempt AS "answerAttempt",
              i.verification_answer AS "verificationAnswer"
       FROM claims c
       INNER JOIN items i ON i.id = c.item_id
       WHERE c.id = $1`,
      [id],
    );

    if (reviewSource.rows.length === 0) {
      return res.status(404).json({ message: "Claim not found" });
    }

    const claim = reviewSource.rows[0] as {
      id: number;
      answerAttempt: unknown;
      verificationAnswer: unknown;
    };

    const matched =
      normalizeAnswer(claim.answerAttempt) ===
      normalizeAnswer(claim.verificationAnswer);

    const finalStatus = matched ? "approved" : "rejected";
    const finalReviewNote =
      reviewNote ??
      (matched
        ? "Verification answer matched."
        : "Verification answer did not match.");

    const updateResult = await pool.query(
      `UPDATE claims
       SET status = $1,
           review_note = $2
       WHERE id = $3
       RETURNING id`,
      [finalStatus, finalReviewNote, Number(id)],
    );

    if (finalStatus === "approved") {
      await pool.query(
        "UPDATE items SET status = 'claimed' WHERE id = (SELECT item_id FROM claims WHERE id = $1)",
        [Number(id)],
      );
    }

    const result = await pool.query(
      `SELECT ${claimSelect} FROM claims c
       JOIN items i ON c.item_id = i.id
       WHERE c.id = $1`,
      [updateResult.rows[0].id],
    );

    return res.status(200).json({
      message: matched
        ? "Claim approved successfully"
        : "Claim rejected successfully",
      claim: toClaimResponse(result.rows[0]),
    });
  } catch (error) {
    console.error("Error approving claim:", error);
    return res.status(500).json({ message: "Internal server error" });
  }
};

export const deleteClaim = async (req: Request, res: Response) => {
  const { id } = req.params;
  const auth = getAuth(req);

  try {
    if (!auth) {
      return res.status(401).json({ message: "Authentication required" });
    }

    const access = await loadClaimAccess(id);

    if (access.status !== 200) {
      return res.status(access.status).json({ message: access.message });
    }

    if (
      auth.role !== "admin" &&
      Number(access.claimantId) !== Number(auth.id)
    ) {
      return res
        .status(403)
        .json({ message: "You do not have permission to perform this action" });
    }

    const result = await pool.query(
      "DELETE FROM claims WHERE id = $1 RETURNING id",
      [id],
    );

    if (result.rows.length === 0) {
      return res.status(404).json({ message: "Claim not found" });
    }

    return res.status(200).json({ message: "Claim deleted successfully" });
  } catch (error) {
    console.error("Error deleting claim:", error);
    return res.status(500).json({ message: "Internal server error" });
  }
};
