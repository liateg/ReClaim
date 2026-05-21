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

router.get("/", getClaims);
router.post("/", createClaim);
router.get("/:id", getClaimById);
router.put("/:id", updateClaim);
router.patch("/:id/approve", authenticateToken, requireAdmin, approveClaim);
router.delete("/:id", deleteClaim);

export default router;
