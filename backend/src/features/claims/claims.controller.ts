import { type Request, type Response } from "express";
import { pool } from "../../config/db.js";

const allowedStatuses = new Set([
  "pending",
  "approved",
  "rejected",
  "withdrawn",
]);

const claimSelect = `
  id,
  item_id AS "itemId",
  claimant_id AS "claimantId",
  answer_attempt AS "answerAttempt",
  status,
  review_note AS "reviewNote",
  created_at AS "createdAt",
  updated_at AS "updatedAt"
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
});

export const createClaim = async (req: Request, res: Response) => {
  const {
    itemId,
    claimantId,
    answerAttempt,
    status = "pending",
    reviewNote = null,
  } = req.body;

  try {
    if (!itemId || !claimantId || !answerAttempt) {
      return res.status(400).json({ message: "Missing required claim fields" });
    }

    if (!allowedStatuses.has(status)) {
      return res.status(400).json({ message: "Invalid claim status" });
    }

    const createdClaim = await pool.query(
      `INSERT INTO claims (item_id, claimant_id, answer_attempt, status, review_note)
       VALUES ($1, $2, $3, $4, $5)
       RETURNING ${claimSelect}`,
      [itemId, claimantId, answerAttempt, status, reviewNote],
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

export const getClaims = async (_req: Request, res: Response) => {
  try {
    const result = await pool.query(
      `SELECT ${claimSelect} FROM claims ORDER BY id DESC`,
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

  try {
    const result = await pool.query(
      `SELECT ${claimSelect} FROM claims WHERE id = $1`,
      [id],
    );

    if (result.rows.length === 0) {
      return res.status(404).json({ message: "Claim not found" });
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

  try {
    if (status !== undefined && !allowedStatuses.has(status)) {
      return res.status(400).json({ message: "Invalid claim status" });
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

    const result = await pool.query(
      `UPDATE claims
       SET ${updateFragments.join(", ")}
       WHERE id = $${values.length}
       RETURNING ${claimSelect}`,
      values,
    );

    if (result.rows.length === 0) {
      return res.status(404).json({ message: "Claim not found" });
    }

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

export const deleteClaim = async (req: Request, res: Response) => {
  const { id } = req.params;

  try {
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
