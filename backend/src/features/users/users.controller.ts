import { type Request, type Response } from "express";
import bcrypt from "bcrypt";
import { pool } from "../../config/db.js";

const allowedRoles = new Set(["user", "admin"]);

const normalizeBodyValue = (value: unknown) => (Array.isArray(value) ? value[0] : value);

const isAllowedRole = (value: unknown): value is "user" | "admin" => {
  return typeof value === "string" && allowedRoles.has(value);
};

const userSelect = `
  id,
  full_name AS "fullName",
  email,
  role,
  created_at AS "createdAt"
`;

const toUserResponse = (user: Record<string, unknown>) => ({
  id: user.id,
  fullName: user.fullName,
  email: user.email,
  role: user.role,
  createdAt: user.createdAt,
});

export const createUser = async (req: Request, res: Response) => {
  const { fullName, email, password } = req.body;
  const role = normalizeBodyValue(req.body.role) ?? "user";

  try {
    if (!fullName || !email || !password) {
      return res.status(400).json({ message: "Full name, email and password are required" });
    }

    if (!isAllowedRole(role)) {
      return res.status(400).json({ message: "Invalid role" });
    }

    const existingUser = await pool.query("SELECT id FROM users WHERE email = $1", [email]);

    if (existingUser.rows.length > 0) {
      return res.status(400).json({ message: "User already exists" });
    }

    const passwordHash = await bcrypt.hash(password, 10);

    const createdUser = await pool.query(
      `INSERT INTO users (full_name, email, password_hash, role)
       VALUES ($1, $2, $3, $4)
       RETURNING ${userSelect}`,
      [fullName, email, passwordHash, role],
    );

    return res.status(201).json({
      message: "User created successfully",
      user: toUserResponse(createdUser.rows[0]),
    });
  } catch (error) {
    console.error("Error creating user:", error);

    if ((error as { code?: string }).code === "23505") {
      return res.status(400).json({ message: "User already exists" });
    }

    return res.status(500).json({ message: "Internal server error" });
  }
};

export const getUsers = async (_req: Request, res: Response) => {
  try {
    const result = await pool.query(`SELECT ${userSelect} FROM users ORDER BY id DESC`);

    return res.status(200).json({
      users: result.rows.map(toUserResponse),
    });
  } catch (error) {
    console.error("Error fetching users:", error);
    return res.status(500).json({ message: "Internal server error" });
  }
};

export const getUserById = async (req: Request, res: Response) => {
  const { id } = req.params;

  try {
    if (!id) {
      return res.status(400).json({ message: "User ID is required" });
    }

    const result = await pool.query(`SELECT ${userSelect} FROM users WHERE id = $1`, [id]);

    if (result.rows.length === 0) {
      return res.status(404).json({ message: "User not found" });
    }

    return res.status(200).json({ user: toUserResponse(result.rows[0]) });
  } catch (error) {
    console.error("Error fetching user:", error);
    return res.status(500).json({ message: "Internal server error" });
  }
};

export const updateUser = async (req: Request, res: Response) => {
  const { id } = req.params;
  const { fullName, email, password } = req.body;
  const role = normalizeBodyValue(req.body.role);

  try {
    if (!id) {
      return res.status(400).json({ message: "User ID is required" });
    }

    if (role !== undefined && !isAllowedRole(role)) {
      return res.status(400).json({ message: "Invalid role" });
    }

    const updateFragments: string[] = [];
    const values: Array<string | number> = [];

    if (fullName !== undefined) {
      updateFragments.push(`full_name = $${values.length + 1}`);
      values.push(fullName);
    }

    if (email !== undefined) {
      updateFragments.push(`email = $${values.length + 1}`);
      values.push(email);
    }

    if (role !== undefined) {
      updateFragments.push(`role = $${values.length + 1}`);
      values.push(role);
    }

    if (password !== undefined) {
      updateFragments.push(`password_hash = $${values.length + 1}`);
      values.push(await bcrypt.hash(password, 10));
    }

    if (updateFragments.length === 0) {
      return res.status(400).json({ message: "At least one field is required to update" });
    }

    values.push(Number(id));

    const result = await pool.query(
      `UPDATE users
       SET ${updateFragments.join(", ")}
       WHERE id = $${values.length}
       RETURNING ${userSelect}`,
      values,
    );

    if (result.rows.length === 0) {
      return res.status(404).json({ message: "User not found" });
    }

    return res.status(200).json({
      message: "User updated successfully",
      user: toUserResponse(result.rows[0]),
    });
  } catch (error) {
    console.error("Error updating user:", error);

    if ((error as { code?: string }).code === "23505") {
      return res.status(400).json({ message: "User already exists" });
    }

    if ((error as Error).message === "At least one field is required to update") {
      return res.status(400).json({ message: "At least one field is required to update" });
    }

    return res.status(500).json({ message: "Internal server error" });
  }
};

export const deleteUser = async (req: Request, res: Response) => {
  const { id } = req.params;

  try {
    if (!id) {
      return res.status(400).json({ message: "User ID is required" });
    }

    const result = await pool.query("DELETE FROM users WHERE id = $1 RETURNING id", [id]);

    if (result.rows.length === 0) {
      return res.status(404).json({ message: "User not found" });
    }

    return res.status(200).json({ message: "User deleted successfully" });
  } catch (error) {
    console.error("Error deleting user:", error);
    return res.status(500).json({ message: "Internal server error" });
  }
};