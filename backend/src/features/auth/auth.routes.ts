// import {registerUser,logInUser,refreshToken,getUserById,updateUser} from "./auth.controller.js"
// import {Router} from "express";

// const router=Router();

// router.post("/user",registerUser);
// router.post("/login",logInUser);
// router.post("/refresh",refreshToken);
// router.get("/user/:id",getUserById);
// router.put("/user/:id",updateUser);

// export default router;
import { registerUser, logInUser, refreshToken, getUserById, updateUser, deleteUser, getCurrentUser } from "./auth.controller.js";
import { Router } from "express";
import { authenticateToken } from "../../middleware/authentication.middleware.js";
import { requireAdmin, requireOwnerOrRoles } from "../../middleware/authorization.middleware.js";

const router = Router();

// Public routes (no auth required)
router.post("/user", registerUser);
router.post("/login", logInUser);
router.post("/refresh", refreshToken);

// Protected routes (auth required)
router.get("/me", authenticateToken, getCurrentUser);
router.get("/user/:id", authenticateToken, requireOwnerOrRoles((req) => req.params.id, "admin"), getUserById);
router.put("/user/:id", authenticateToken, requireOwnerOrRoles((req) => req.params.id, "admin"), updateUser);
router.delete("/user/:id", authenticateToken, requireAdmin, deleteUser);

export default router;