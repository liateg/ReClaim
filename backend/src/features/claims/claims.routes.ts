import { Router } from "express";
import {
  approveClaim,
  createClaim,
  deleteClaim,
  getClaimById,
  getClaims,
  updateClaim,
} from "./claims.controller.js";
import { authenticateToken } from "../../middleware/authentication.middleware.js";
import { requireAdmin } from "../../middleware/authorization.middleware.js";

const router = Router();

router.get("/", authenticateToken, getClaims);
router.post("/", authenticateToken, createClaim);
router.get("/:id", authenticateToken, getClaimById);
router.put("/:id", authenticateToken, updateClaim);
router.patch("/:id/approve", authenticateToken, requireAdmin, approveClaim);
router.patch("/:id/review", authenticateToken, requireAdmin, approveClaim);
router.delete("/:id", authenticateToken, deleteClaim);

export default router;
