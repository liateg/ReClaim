import { type Request, type Response } from "express";
import { type AuthTokenPayload } from "../../types/auth.js";
import { memoryStore } from "../../utils/memory-store.js";

type AuthedRequest = Request & {
  auth?: AuthTokenPayload;
};

const allowedStatuses = new Set(["available", "claimed", "resolved"]);

const getAuth = (req: Request) => (req as AuthedRequest).auth;
const isAdmin = (req: Request) => getAuth(req)?.role === "admin";

export const createItem = async (req: Request, res: Response) => {
  const {
    title,
    description,
    category = "Other",
    location,
    dateFound,
    imageUrl = null,
    verificationQuestion,
    verificationAnswer,
    hiddenDetails = null,
    status = "available",
  } = req.body;
  const auth = getAuth(req);

  if (!auth) {
    return res.status(401).json({ message: "Authentication required" });
  }

  if (!title || !description || !location || !dateFound || !verificationQuestion || !verificationAnswer) {
    return res.status(400).json({ message: "Missing required item fields" });
  }

  if (!allowedStatuses.has(status)) {
    return res.status(400).json({ message: "Invalid item status" });
  }

  const newItem = memoryStore.createItem({
    title,
    description,
    category,
    location,
    dateFound,
    imageUrl,
    verificationQuestion,
    verificationAnswer,
    hiddenDetails,
    status: status as any,
    postedBy: auth.id,
  });

  return res.status(201).json({
    message: "Item created successfully",
    item: newItem,
  });
};

export const getItems = async (_req: Request, res: Response) => {
  const items = memoryStore.getItems();
  return res.status(200).json({ items });
};

export const getItemById = async (req: Request, res: Response) => {
  const { id } = req.params;
  const item = memoryStore.getItemById(Number(id));

  if (!item) {
    return res.status(404).json({ message: "Item not found" });
  }

  return res.status(200).json({ item });
};

export const updateItem = async (req: Request, res: Response) => {
  const { id } = req.params;
  const auth = getAuth(req);

  if (!auth) {
    return res.status(401).json({ message: "Authentication required" });
  }

  const item = memoryStore.getItemById(Number(id));
  if (!item) {
    return res.status(404).json({ message: "Item not found" });
  }

  if (auth.role !== "admin" && item.postedBy !== auth.id) {
    return res.status(403).json({ message: "You do not have permission to update this item" });
  }

  const updatedItem = memoryStore.updateItem(Number(id), req.body);
  return res.status(200).json({
    message: "Item updated successfully",
    item: updatedItem,
  });
};

export const deleteItem = async (req: Request, res: Response) => {
  const { id } = req.params;
  const auth = getAuth(req);

  if (!auth) {
    return res.status(401).json({ message: "Authentication required" });
  }

  const item = memoryStore.getItemById(Number(id));
  if (!item) {
    return res.status(404).json({ message: "Item not found" });
  }

  if (auth.role !== "admin" && item.postedBy !== auth.id) {
    return res.status(403).json({ message: "You do not have permission to delete this item" });
  }

  memoryStore.deleteItem(Number(id));
  return res.status(200).json({ message: "Item deleted successfully" });
};

export const getAdminItems = async (_req: Request, res: Response) => {
  const items = memoryStore.getItems();
  return res.status(200).json({ items });
};
