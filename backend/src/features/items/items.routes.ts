import { Router } from "express";
import {
  createItem,
  deleteItem,
  getAdminItems,
  getItemById,
  getItems,
  updateItem,
  uploadItemImage,
} from "./items.controller.js";
import { uploadItemImageMiddleware } from "./items.upload.js";
import { authenticateToken } from "../../middleware/authentication.middleware.js";
import { requireAdmin } from "../../middleware/authorization.middleware.js";

const router = Router();

router.get("/", authenticateToken, getItems);
router.get("/admin", authenticateToken, requireAdmin, getAdminItems);
router.post(
  "/upload",
  authenticateToken,
  uploadItemImageMiddleware,
  uploadItemImage,
);
router.post("/", authenticateToken, createItem);
router.get("/:id", authenticateToken, getItemById);
router.put("/:id", authenticateToken, updateItem);
router.delete("/:id", authenticateToken, deleteItem);

export default router;
