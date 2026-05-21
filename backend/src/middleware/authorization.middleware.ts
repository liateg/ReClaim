import { type NextFunction, type Request, type Response } from "express";
import { type UserRole } from "../types/auth.js";

const respondForbidden = (res: Response, message: string) => {
  return res.status(403).json({ message });
};

type AuthedRequest = Request & {
  auth?: {
    id: number;
    full_name: string;
    email: string;
    role: UserRole;
  };
};

export const requireRoles = (...allowedRoles: UserRole[]) => {
  return (req: Request, res: Response, next: NextFunction) => {
    const authReq = req as AuthedRequest;

    if (!authReq.auth) {
      return res.status(401).json({ message: "Authentication required" });
    }

    if (!allowedRoles.includes(authReq.auth.role)) {
      return respondForbidden(res, "You do not have permission to perform this action");
    }

    return next();
  };
};

export const requireAdmin = requireRoles("admin");

export const requireFieldMatchesAuthId = (fieldName: string) => {
  return (req: Request, res: Response, next: NextFunction) => {
    const authReq = req as AuthedRequest;

    if (!authReq.auth) {
      return res.status(401).json({ message: "Authentication required" });
    }

    const fieldValue = req.body?.[fieldName];

    if (fieldValue === undefined || fieldValue === null) {
      return res.status(400).json({ message: `${fieldName} is required` });
    }

    if (String(fieldValue) !== String(authReq.auth.id)) {
      return respondForbidden(res, "You can only act on your own resource");
    }

    return next();
  };
};

export const requireParamMatchesAuthId = (paramName: string) => {
  return (req: Request, res: Response, next: NextFunction) => {
    const authReq = req as AuthedRequest;

    if (!authReq.auth) {
      return res.status(401).json({ message: "Authentication required" });
    }

    const paramValue = req.params?.[paramName];

    if (!paramValue) {
      return res.status(400).json({ message: `${paramName} is required` });
    }

    if (String(paramValue) !== String(authReq.auth.id)) {
      return respondForbidden(res, "You can only act on your own resource");
    }

    return next();
  };
};

export const requireOwnerOrRoles = (
  getOwnerId: (req: Request) => unknown,
  ...allowedRoles: UserRole[]
) => {
  return (req: Request, res: Response, next: NextFunction) => {
    const authReq = req as AuthedRequest;

    if (!authReq.auth) {
      return res.status(401).json({ message: "Authentication required" });
    }

    const ownerId = getOwnerId(req);

    if (ownerId === undefined || ownerId === null) {
      return res.status(400).json({ message: "Owner identity is required" });
    }

    if (allowedRoles.includes(authReq.auth.role) || String(ownerId) === String(authReq.auth.id)) {
      return next();
    }

    return respondForbidden(res, "You do not have permission to perform this action");
  };
};