import { type NextFunction, type Request, type Response } from "express";
import jwt from "jsonwebtoken";
import { type AuthTokenPayload } from "../types/auth.js";

const JWT_SECRET = process.env.JWT_SECRET || "loa-test";

type AuthedRequest = Request & {
  auth?: AuthTokenPayload;
};

const isAuthTokenPayload = (value: unknown): value is AuthTokenPayload => {
  if (!value || typeof value !== "object") {
    return false;
  }

  const candidate = value as Partial<AuthTokenPayload>;

  return (
    typeof candidate.id === "number" &&
    typeof candidate.full_name === "string" &&
    typeof candidate.email === "string" &&
    (candidate.role === "user" || candidate.role === "admin")
  );
};

const extractAccessToken = (req: Request) => {
  const authorization = req.header("authorization");

  if (authorization?.startsWith("Bearer ")) {
    return authorization.slice(7);
  }

  const headerToken = req.header("x-access-token");

  if (headerToken) {
    return headerToken;
  }

  const cookieToken = req.cookies?.accessToken;

  if (typeof cookieToken === "string") {
    return cookieToken;
  }

  return null;
};

export const authenticateToken = (req: Request, res: Response, next: NextFunction) => {
  const token = extractAccessToken(req);

  if (!token) {
    return res.status(401).json({ message: "Access token not found" });
  }

  try {
    const decoded = jwt.verify(token, JWT_SECRET);

    if (!isAuthTokenPayload(decoded)) {
      return res.status(401).json({ message: "Invalid access token" });
    }

    (req as AuthedRequest).auth = decoded;
    return next();
  } catch (error) {
    console.error("Error authenticating token:", error);
    return res.status(401).json({ message: "Invalid access token" });
  }
};