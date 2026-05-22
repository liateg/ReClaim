import { type Request, type Response } from "express";
import { pool } from "../../config/db.js";
import { type AuthTokenPayload } from "../../types/auth.js";

type AuthedRequest = Request & {
  auth?: AuthTokenPayload;
};

const reportSelect = `
  id,
  reporter_id AS "reporterId",
  item_id AS "itemId",
  claim_id AS "claimId",
  reason,
  description,
  status,
  admin_note AS "adminNote",
  created_at AS "createdAt",
  updated_at AS "updatedAt"
`;

const toReportResponse = (r: Record<string, unknown>) => ({
  id: r.id,
  reporterId: r.reporterId,
  itemId: r.itemId,
  claimId: r.claimId,
  reason: r.reason,
  description: r.description,
  status: r.status,
  adminNote: r.adminNote,
  createdAt: r.createdAt,
  updatedAt: r.updatedAt,
});

const getAuth = (req: Request) => (req as AuthedRequest).auth;

export const createReport = async (req: Request, res: Response) => {
  const auth = getAuth(req);
  const {
    itemId = null,
    claimId = null,
    reason,
    description = null,
  } = req.body;

  try {
    if (!auth)
      return res.status(401).json({ message: "Authentication required" });

    if (!reason) return res.status(400).json({ message: "Reason is required" });

    // Must reference either an item or a claim
    if (itemId === null && claimId === null) {
      return res
        .status(400)
        .json({ message: "Either itemId or claimId is required" });
    }

    const created = await pool.query(
      `INSERT INTO reports (reporter_id, item_id, claim_id, reason, description, status)
       VALUES ($1,$2,$3,$4,$5,$6)
       RETURNING ${reportSelect}`,
      [auth.id, itemId, claimId, reason, description, "pending"],
    );

    return res
      .status(201)
      .json({
        message: "Report created successfully",
        report: toReportResponse(created.rows[0]),
      });
  } catch (error) {
    console.error("Error creating report:", error);
    if ((error as { code?: string }).code === "23503") {
      return res.status(400).json({ message: "Invalid foreign key reference" });
    }
    return res.status(500).json({ message: "Internal server error" });
  }
};

export const getReports = async (req: Request, res: Response) => {
  try {
    const auth = getAuth(req);
    if (!auth)
      return res.status(401).json({ message: "Authentication required" });

    const where = auth.role === "admin" ? "" : "WHERE reporter_id = $1";
    const params = auth.role === "admin" ? [] : [auth.id];

    const result = await pool.query(
      `SELECT ${reportSelect} FROM reports ${where} ORDER BY id DESC`,
      params,
    );

    return res.status(200).json({ reports: result.rows.map(toReportResponse) });
  } catch (error) {
    console.error("Error fetching reports:", error);
    return res.status(500).json({ message: "Internal server error" });
  }
};

export const getReportById = async (req: Request, res: Response) => {
  const { id } = req.params;
  try {
    const auth = getAuth(req);
    if (!auth)
      return res.status(401).json({ message: "Authentication required" });

    const result = await pool.query(
      `SELECT ${reportSelect} FROM reports WHERE id = $1`,
      [id],
    );
    if (result.rows.length === 0)
      return res.status(404).json({ message: "Report not found" });

    const report = result.rows[0] as any;
    if (
      auth.role !== "admin" &&
      Number(report.reporterId) !== Number(auth.id)
    ) {
      return res
        .status(403)
        .json({ message: "You do not have permission to perform this action" });
    }

    return res.status(200).json({ report: toReportResponse(report) });
  } catch (error) {
    console.error("Error fetching report:", error);
    return res.status(500).json({ message: "Internal server error" });
  }
};

export const updateReport = async (req: Request, res: Response) => {
  const { id } = req.params;
  const { reason, description, status, adminNote } = req.body;
  try {
    const auth = getAuth(req);
    if (!auth)
      return res.status(401).json({ message: "Authentication required" });

    const existing = await pool.query(
      `SELECT reporter_id AS "reporterId" FROM reports WHERE id = $1`,
      [id],
    );
    if (existing.rows.length === 0)
      return res.status(404).json({ message: "Report not found" });

    const reporterId = existing.rows[0].reporterId as number;
    const isAdmin = auth.role === "admin";
    const isOwner = Number(reporterId) === Number(auth.id);

    // Owners can update their description/reason; admins can update status/adminNote
    if (!isAdmin && !isOwner)
      return res
        .status(403)
        .json({ message: "You do not have permission to perform this action" });

    const fragments: string[] = [];
    const values: unknown[] = [];

    if (reason !== undefined && isOwner) {
      fragments.push(`reason = $${values.length + 1}`);
      values.push(reason);
    }

    if (description !== undefined && isOwner) {
      fragments.push(`description = $${values.length + 1}`);
      values.push(description);
    }

    if (status !== undefined && isAdmin) {
      fragments.push(`status = $${values.length + 1}`);
      values.push(status);
    }

    if (adminNote !== undefined && isAdmin) {
      fragments.push(`admin_note = $${values.length + 1}`);
      values.push(adminNote);
    }

    if (fragments.length === 0)
      return res
        .status(400)
        .json({
          message: "No updatable fields provided or insufficient permissions",
        });

    values.push(Number(id));

    const result = await pool.query(
      `UPDATE reports SET ${fragments.join(", ")} WHERE id = $${values.length} RETURNING ${reportSelect}`,
      values,
    );

    return res
      .status(200)
      .json({
        message: "Report updated successfully",
        report: toReportResponse(result.rows[0]),
      });
  } catch (error) {
    console.error("Error updating report:", error);
    return res.status(500).json({ message: "Internal server error" });
  }
};

export const deleteReport = async (req: Request, res: Response) => {
  const { id } = req.params;
  try {
    const auth = getAuth(req);
    if (!auth)
      return res.status(401).json({ message: "Authentication required" });

    const existing = await pool.query(
      `SELECT reporter_id AS "reporterId" FROM reports WHERE id = $1`,
      [id],
    );
    if (existing.rows.length === 0)
      return res.status(404).json({ message: "Report not found" });

    const reporterId = existing.rows[0].reporterId as number;
    const isAdmin = auth.role === "admin";
    const isOwner = Number(reporterId) === Number(auth.id);

    if (!isAdmin && !isOwner)
      return res
        .status(403)
        .json({ message: "You do not have permission to perform this action" });

    const result = await pool.query(
      "DELETE FROM reports WHERE id = $1 RETURNING id",
      [id],
    );
    if (result.rows.length === 0)
      return res.status(404).json({ message: "Report not found" });

    return res.status(200).json({ message: "Report deleted successfully" });
  } catch (error) {
    console.error("Error deleting report:", error);
    return res.status(500).json({ message: "Internal server error" });
  }
};
