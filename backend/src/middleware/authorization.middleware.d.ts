import { type NextFunction, type Request, type Response } from "express";
import { type UserRole } from "../types/auth.js";
export declare const requireRoles: (...allowedRoles: UserRole[]) => (req: Request, res: Response, next: NextFunction) => void | Response<any, Record<string, any>>;
export declare const requireAdmin: (req: Request, res: Response, next: NextFunction) => void | Response<any, Record<string, any>>;
export declare const requireFieldMatchesAuthId: (fieldName: string) => (req: Request, res: Response, next: NextFunction) => void | Response<any, Record<string, any>>;
export declare const requireParamMatchesAuthId: (paramName: string) => (req: Request, res: Response, next: NextFunction) => void | Response<any, Record<string, any>>;
export declare const requireOwnerOrRoles: (getOwnerId: (req: Request) => unknown, ...allowedRoles: UserRole[]) => (req: Request, res: Response, next: NextFunction) => void | Response<any, Record<string, any>>;
//# sourceMappingURL=authorization.middleware.d.ts.map