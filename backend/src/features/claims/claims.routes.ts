import { Router } from "express";
import { createClaim, deleteClaim, getClaimById, getClaims, updateClaim } from "./claims.controller.js";

const router = Router();

router.get("/", getClaims);
router.post("/", createClaim);
router.get("/:id", getClaimById);
router.put("/:id", updateClaim);
router.delete("/:id", deleteClaim);

export default router;