import { type Request, type Response, Router } from "express";
import { type AuthTokenPayload } from "../../types/auth.js";
import { memoryStore } from "../../utils/memory-store.js";

type AuthedRequest = Request & {
  auth?: AuthTokenPayload;
};

const router = Router();

router.get("/", (req: Request, res: Response) => {
  const auth = (req as AuthedRequest).auth;
  if (!auth) return res.status(401).json({ message: "Authentication required" });

  const notifications = memoryStore.getNotificationsByUser(auth.id);
  res.json({ notifications });
});

router.patch("/:id/read", (req: Request, res: Response) => {
  const { id } = req.params;
  memoryStore.markNotificationRead(Number(id));
  res.json({ message: "Notification marked as read" });
});

export default router;
