import { Router } from "express";
import * as reportsController from "./reports.controller.js";
import { authenticateToken } from "../../middleware/authentication.middleware.js";

const router = Router();

// All report routes require authentication
router.use(authenticateToken);

router.post("/", reportsController.createReport);
router.get("/", reportsController.getReports);
router.get("/my", reportsController.getReports); // For now same as GET / (handled in controller by role)
router.get("/:id", reportsController.getReportById);
router.put("/:id/status", reportsController.updateReportStatus);
router.delete("/:id", reportsController.deleteReport);

export default router;
