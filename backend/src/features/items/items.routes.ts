import { Router } from "express";
import { createItem, deleteItem, getItemById, getItems, updateItem } from "./items.controller.js";

const router = Router();

router.get("/", getItems);
router.post("/", createItem);
router.get("/:id", getItemById);
router.put("/:id", updateItem);
router.delete("/:id", deleteItem);

export default router;