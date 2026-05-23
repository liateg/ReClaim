import { type Request, type Response } from "express";
import { type AuthTokenPayload } from "../../types/auth.js";
import { memoryStore } from "../../utils/memory-store.js";

type AuthedRequest = Request & {
  auth?: AuthTokenPayload;
};

const getAuth = (req: Request) => (req as AuthedRequest).auth;

export const createReport = async (req: Request, res: Response) => {
  const auth = getAuth(req);
  const { itemId, claimId, reason, description } = req.body;

  if (!auth) {
    return res.status(401).json({ message: "Authentication required" });
  }

  if (!reason) {
    return res.status(400).json({ message: "Reason is required" });
  }

  const newReport = memoryStore.createReport({
    reporterId: auth.id,
    itemId: itemId ? Number(itemId) : undefined,
    claimId: claimId ? Number(claimId) : undefined,
    reason,
    description,
  });

  return res.status(201).json({
    message: "Report created successfully",
    report: newReport,
  });
};

export const getReports = async (req: Request, res: Response) => {
  const auth = getAuth(req);
  if (!auth) {
    return res.status(401).json({ message: "Authentication required" });
  }

  const reports = auth.role === "admin"
    ? memoryStore.getReports()
    : memoryStore.getReportsByUser(auth.id);

  return res.status(200).json({ reports });
};

export const getReportById = async (req: Request, res: Response) => {
  const { id } = req.params;
  const auth = getAuth(req);

  if (!auth) {
    return res.status(401).json({ message: "Authentication required" });
  }

  const report = memoryStore.getReportById(Number(id));
  if (!report) {
    return res.status(404).json({ message: "Report not found" });
  }

  if (auth.role !== "admin" && report.reporterId !== auth.id) {
    return res.status(403).json({ message: "Access denied" });
  }

  return res.status(200).json({ report });
};

export const updateReportStatus = async (req: Request, res: Response) => {
  const { id } = req.params;
  const { status, adminNote } = req.body;
  const auth = getAuth(req);

  if (!auth || auth.role !== "admin") {
    return res.status(403).json({ message: "Admin access required" });
  }

  const report = memoryStore.getReportById(Number(id));
  if (!report) {
    return res.status(404).json({ message: "Report not found" });
  }

  const updatedReport = memoryStore.updateReport(Number(id), {
    status,
    adminNote,
  });

  return res.status(200).json({
    message: "Report status updated successfully",
    report: updatedReport,
  });
};

export const deleteReport = async (req: Request, res: Response) => {
  const { id } = req.params;
  const auth = getAuth(req);

  if (!auth) {
    return res.status(401).json({ message: "Authentication required" });
  }

  const report = memoryStore.getReportById(Number(id));
  if (!report) {
    return res.status(404).json({ message: "Report not found" });
  }

  if (auth.role !== "admin" && report.reporterId !== auth.id) {
    return res.status(403).json({ message: "Access denied" });
  }

  memoryStore.deleteReport(Number(id));
  return res.status(200).json({ message: "Report deleted successfully" });
};
