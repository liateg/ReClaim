import { type Request, type Response } from "express";
export declare const createUser: (req: Request, res: Response) => Promise<Response<any, Record<string, any>>>;
export declare const getUsers: (_req: Request, res: Response) => Promise<Response<any, Record<string, any>>>;
export declare const getUserById: (req: Request, res: Response) => Promise<Response<any, Record<string, any>>>;
export declare const updateUser: (req: Request, res: Response) => Promise<Response<any, Record<string, any>>>;
export declare const deleteUser: (req: Request, res: Response) => Promise<Response<any, Record<string, any>>>;
//# sourceMappingURL=users.controller.d.ts.map