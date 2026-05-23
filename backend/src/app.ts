import express from "express";
import cors from "cors";
import cookieParser from "cookie-parser";
import path from "path";
import authRoutes from "./features/auth/auth.routes.js";
import usersRoutes from "./features/users/users.routes.js";
import itemsRoutes from "./features/items/items.routes.js";
import claimsRoutes from "./features/claims/claims.routes.js";
import reportsRoutes from "./features/reports/reports.routes.js";

const app = express();

app.use(cors());
app.use(express.json());
app.use(cookieParser());
app.use("/uploads", express.static(path.join(process.cwd(), "uploads")));
app.use("/auth", authRoutes);
app.use("/users", usersRoutes);
app.use("/items", itemsRoutes);
app.use("/claims", claimsRoutes);
app.use("/reports", reportsRoutes);

export default app;
