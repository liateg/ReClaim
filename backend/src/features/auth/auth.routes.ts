import { 
  registerUser, 
  logInUser, 
  refreshToken, 
  getUserById, 
  updateUser, 
  deleteUser, 
  getCurrentUser, 
  logoutUser 
} from "./auth.controller.js";
import { Router } from "express";
import { authenticateToken } from "../../middleware/authentication.middleware.js";
import { requireAdmin, requireOwnerOrRoles } from "../../middleware/authorization.middleware.js";

const router = Router();

// Public routes
router.post("/user", registerUser);
router.post("/login", logInUser);
router.post("/refresh", refreshToken);

// Protected routes
router.get("/me", authenticateToken, getCurrentUser);

router.get(
  "/user/:id",
  authenticateToken,
  requireOwnerOrRoles((req) => req.params.id, "admin"),
  getUserById
);

router.put(
  "/user/:id",
  authenticateToken,
  requireOwnerOrRoles((req) => req.params.id, "admin"),
  updateUser
);

router.delete(
  "/user/:id",
  authenticateToken,
  requireAdmin,
  deleteUser
);

router.post("/logout", authenticateToken, logoutUser);

export default router;