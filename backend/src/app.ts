import express from "express";
import cookieParser from "cookie-parser";
import authRoutes from "./features/auth/auth.routes.js";
import usersRoutes from "./features/users/users.routes.js";
import itemsRoutes from "./features/items/items.routes.js";
import claimsRoutes from "./features/claims/claims.routes.js";
import uploadRoutes from "./features/upload/upload.routes.js";
import notificationsRoutes from "./features/notifications/notifications.routes.js";
import path from "path";

const app = express();

// 1. MANUALLY FORCE CORS HEADERS (Must be first!)
app.use((req, res, next) => {
  res.header("Access-Control-Allow-Origin", "*");
  res.header("Access-Control-Allow-Methods", "GET,PUT,POST,DELETE,PATCH,OPTIONS");
  res.header("Access-Control-Allow-Headers", "Origin, X-Requested-With, Content-Type, Accept, Authorization");
  res.header("Access-Control-Allow-Credentials", "true");
  
  if (req.method === "OPTIONS") {
    return res.status(200).end();
  }
  next();
});

// 2. LOGGING (To track if requests arrive)
app.use((req, res, next) => {
  console.log(`[${new Date().toISOString()}] ${req.method} ${req.url}`);
  next();
});

// 3. PARSERS
app.use(express.json());
app.use(express.urlencoded({ extended: true }));
app.use(cookieParser());

// 4. ROUTES
app.use("/uploads", express.static("uploads"));
app.use("/auth", authRoutes);
app.use("/users", usersRoutes);
app.use("/items", itemsRoutes);
app.use("/claims", claimsRoutes);
app.use("/upload", uploadRoutes);
app.use("/notifications", notificationsRoutes);

export default app;
