<<<<<<< HEAD
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
=======
import {registerUser,logInUser,refreshToken,getUserById,updateUser} from "./auth.controller.js"
import {Router} from "express";

const router=Router();

router.post("/user",registerUser);
router.post("/login",logInUser);
router.post("/refresh",refreshToken);
router.get("/user/:id",getUserById);
router.put("/user/:id",updateUser);

export default router;
>>>>>>> a9d134576855e13cb29d8e52d41f23f37bf46afc
