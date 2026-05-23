import { Router } from "express";
import multer from "multer";
import path from "path";
import { uploadImage } from "./upload.controller.js";
import { authenticateToken } from "../../middleware/authentication.middleware.js";

const router = Router();

const storage = multer.diskStorage({
  destination: (req, file, cb) => {
    cb(null, "uploads/");
  },
  filename: (req, file, cb) => {
    const uniqueSuffix = Date.now() + "-" + Math.round(Math.random() * 1e9);
    cb(null, file.fieldname + "-" + uniqueSuffix + path.extname(file.originalname));
  },
});

const upload = multer({ storage: storage });

router.post("/", authenticateToken, upload.single("image"), uploadImage);

export default router;
