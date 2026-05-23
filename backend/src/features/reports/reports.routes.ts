import { Router } from "express";
import {
  createReport,
  deleteReport,
  getReportById,
  getReports,
  updateReport,
} from "./reports.controller.js";
import { authenticateToken } from "../../middleware/authentication.middleware.js";
import { requireAdmin } from "../../middleware/authorization.middleware.js";

const router = Router();

router.get("/", authenticateToken, getReports);
router.post("/", authenticateToken, createReport);
router.get("/:id", authenticateToken, getReportById);
router.put("/:id", authenticateToken, updateReport);
router.delete("/:id", authenticateToken, deleteReport);

export default router;
