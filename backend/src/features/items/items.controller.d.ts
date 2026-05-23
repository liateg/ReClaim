import { type Request, type Response } from "express";
export declare const createItem: (req: Request, res: Response) => Promise<Response<any, Record<string, any>>>;
export declare const getItems: (_req: Request, res: Response) => Promise<Response<any, Record<string, any>>>;
export declare const getItemById: (req: Request, res: Response) => Promise<Response<any, Record<string, any>>>;
export declare const updateItem: (req: Request, res: Response) => Promise<Response<any, Record<string, any>>>;
export declare const deleteItem: (req: Request, res: Response) => Promise<Response<any, Record<string, any>>>;
export declare const getAdminItems: (_req: Request, res: Response) => Promise<Response<any, Record<string, any>>>;
//# sourceMappingURL=items.controller.d.ts.map