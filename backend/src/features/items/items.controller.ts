import { type Request, type Response } from "express";
import { pool } from "../../config/db.js";

const allowedStatuses = new Set(["available", "claimed", "resolved"]);

const itemSelect = `
  id,
  title,
  description,
  category_id AS "categoryId",
  location,
  date_found AS "dateFound",
  image_url AS "imageUrl",
  verification_question AS "verificationQuestion",
  verification_answer AS "verificationAnswer",
  hidden_details AS "hiddenDetails",
  status,
  posted_by AS "postedBy",
  created_at AS "createdAt",
  updated_at AS "updatedAt"
`;

const toItemResponse = (item: Record<string, unknown>) => ({
  id: item.id,
  title: item.title,
  description: item.description,
  categoryId: item.categoryId,
  location: item.location,
  dateFound: item.dateFound,
  imageUrl: item.imageUrl,
  verificationQuestion: item.verificationQuestion,
  verificationAnswer: item.verificationAnswer,
  hiddenDetails: item.hiddenDetails,
  status: item.status,
  postedBy: item.postedBy,
  createdAt: item.createdAt,
  updatedAt: item.updatedAt,
});

export const createItem = async (req: Request, res: Response) => {
  const {
    title,
    description,
    categoryId = null,
    location,
    dateFound,
    imageUrl = null,
    verificationQuestion,
    verificationAnswer,
    hiddenDetails = null,
    status = "available",
    postedBy,
  } = req.body;

  try {
    if (
      !title ||
      !description ||
      !location ||
      !dateFound ||
      !verificationQuestion ||
      !verificationAnswer ||
      !postedBy
    ) {
      return res.status(400).json({ message: "Missing required item fields" });
    }

    if (!allowedStatuses.has(status)) {
      return res.status(400).json({ message: "Invalid item status" });
    }

    const createdItem = await pool.query(
      `INSERT INTO items (
        title,
        description,
        category_id,
        location,
        date_found,
        image_url,
        verification_question,
        verification_answer,
        hidden_details,
        status,
        posted_by
      ) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11)
      RETURNING ${itemSelect}`,
      [
        title,
        description,
        categoryId,
        location,
        dateFound,
        imageUrl,
        verificationQuestion,
        verificationAnswer,
        hiddenDetails,
        status,
        postedBy,
      ],
    );

    return res.status(201).json({
      message: "Item created successfully",
      item: toItemResponse(createdItem.rows[0]),
    });
  } catch (error) {
    console.error("Error creating item:", error);

    if ((error as { code?: string }).code === "23503") {
      return res.status(400).json({ message: "Invalid foreign key reference" });
    }

    return res.status(500).json({ message: "Internal server error" });
  }
};

export const getItems = async (_req: Request, res: Response) => {
  try {
    const result = await pool.query(
      `SELECT ${itemSelect} FROM items ORDER BY id DESC`,
    );

    return res.status(200).json({
      items: result.rows.map(toItemResponse),
    });
  } catch (error) {
    console.error("Error fetching items:", error);
    return res.status(500).json({ message: "Internal server error" });
  }
};

export const getItemById = async (req: Request, res: Response) => {
  const { id } = req.params;

  try {
    const result = await pool.query(
      `SELECT ${itemSelect} FROM items WHERE id = $1`,
      [id],
    );

    if (result.rows.length === 0) {
      return res.status(404).json({ message: "Item not found" });
    }

    return res.status(200).json({ item: toItemResponse(result.rows[0]) });
  } catch (error) {
    console.error("Error fetching item:", error);
    return res.status(500).json({ message: "Internal server error" });
  }
};

export const updateItem = async (req: Request, res: Response) => {
  const { id } = req.params;
  const {
    title,
    description,
    categoryId,
    location,
    dateFound,
    imageUrl,
    verificationQuestion,
    verificationAnswer,
    hiddenDetails,
    status,
    postedBy,
  } = req.body;

  try {
    if (status !== undefined && !allowedStatuses.has(status)) {
      return res.status(400).json({ message: "Invalid item status" });
    }

    const updateFragments: string[] = [];
    const values: unknown[] = [];

    if (title !== undefined) {
      updateFragments.push(`title = $${values.length + 1}`);
      values.push(title);
    }

    if (description !== undefined) {
      updateFragments.push(`description = $${values.length + 1}`);
      values.push(description);
    }

    if (categoryId !== undefined) {
      updateFragments.push(`category_id = $${values.length + 1}`);
      values.push(categoryId);
    }

    if (location !== undefined) {
      updateFragments.push(`location = $${values.length + 1}`);
      values.push(location);
    }

    if (dateFound !== undefined) {
      updateFragments.push(`date_found = $${values.length + 1}`);
      values.push(dateFound);
    }

    if (imageUrl !== undefined) {
      updateFragments.push(`image_url = $${values.length + 1}`);
      values.push(imageUrl);
    }

    if (verificationQuestion !== undefined) {
      updateFragments.push(`verification_question = $${values.length + 1}`);
      values.push(verificationQuestion);
    }

    if (verificationAnswer !== undefined) {
      updateFragments.push(`verification_answer = $${values.length + 1}`);
      values.push(verificationAnswer);
    }

    if (hiddenDetails !== undefined) {
      updateFragments.push(`hidden_details = $${values.length + 1}`);
      values.push(hiddenDetails);
    }

    if (status !== undefined) {
      updateFragments.push(`status = $${values.length + 1}`);
      values.push(status);
    }

    if (postedBy !== undefined) {
      updateFragments.push(`posted_by = $${values.length + 1}`);
      values.push(postedBy);
    }

    if (updateFragments.length === 0) {
      return res
        .status(400)
        .json({ message: "At least one field is required to update" });
    }

    values.push(Number(id));

    const result = await pool.query(
      `UPDATE items
       SET ${updateFragments.join(", ")}
       WHERE id = $${values.length}
       RETURNING ${itemSelect}`,
      values,
    );

    if (result.rows.length === 0) {
      return res.status(404).json({ message: "Item not found" });
    }

    return res.status(200).json({
      message: "Item updated successfully",
      item: toItemResponse(result.rows[0]),
    });
  } catch (error) {
    console.error("Error updating item:", error);

    if ((error as { code?: string }).code === "23503") {
      return res.status(400).json({ message: "Invalid foreign key reference" });
    }

    if (
      (error as Error).message === "At least one field is required to update"
    ) {
      return res
        .status(400)
        .json({ message: "At least one field is required to update" });
    }

    return res.status(500).json({ message: "Internal server error" });
  }
};

export const deleteItem = async (req: Request, res: Response) => {
  const { id } = req.params;

  try {
    const result = await pool.query(
      "DELETE FROM items WHERE id = $1 RETURNING id",
      [id],
    );

    if (result.rows.length === 0) {
      return res.status(404).json({ message: "Item not found" });
    }

    return res.status(200).json({ message: "Item deleted successfully" });
  } catch (error) {
    console.error("Error deleting item:", error);
    return res.status(500).json({ message: "Internal server error" });
  }
};
