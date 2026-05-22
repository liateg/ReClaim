import { Router } from "express";
import {
  getCurrentUser,
  getUserById,
  logInUser,
  refreshToken,
  registerUser,
  updateUser,
} from "./auth.controller.js";
import { authenticateToken } from "../../middleware/authentication.middleware.js";

const router = Router();

router.post("/register", registerUser);
router.post("/user", registerUser);
router.post("/login", logInUser);
router.post("/refresh", refreshToken);
router.get("/me", authenticateToken, getCurrentUser);
router.get("/user/:id", getUserById);
router.put("/user/:id", updateUser);

export default router;
