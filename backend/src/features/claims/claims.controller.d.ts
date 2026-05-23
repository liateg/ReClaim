import { type Request, type Response } from "express";
export declare const createClaim: (req: Request, res: Response) => Promise<Response<any, Record<string, any>>>;
export declare const getClaims: (req: Request, res: Response) => Promise<Response<any, Record<string, any>>>;
export declare const getClaimById: (req: Request, res: Response) => Promise<Response<any, Record<string, any>>>;
export declare const updateClaim: (req: Request, res: Response) => Promise<Response<any, Record<string, any>>>;
export declare const approveClaim: (req: Request, res: Response) => Promise<Response<any, Record<string, any>>>;
export declare const deleteClaim: (req: Request, res: Response) => Promise<Response<any, Record<string, any>>>;
//# sourceMappingURL=claims.controller.d.ts.map