import { type Request, type Response } from "express";

export const uploadImage = async (req: Request, res: Response) => {
  if (!req.file) {
    return res.status(400).json({ message: "No image uploaded" });
  }

  const imageUrl = `/uploads/${req.file.filename}`;
  return res.status(200).json({
    message: "Image uploaded successfully",
    imageUrl,
  });
};
