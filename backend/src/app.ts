import express from "express";
import cors from "cors";
<<<<<<< HEAD
import cookieParser from "cookie-parser";
import authRoutes from "./features/auth/auth.routes.js";
import usersRoutes from "./features/users/users.routes.js";
import itemsRoutes from "./features/items/items.routes.js";
import claimsRoutes from "./features/claims/claims.routes.js";
=======
import authRoutes from "./features/auth/auth.routes.js";
>>>>>>> a9d134576855e13cb29d8e52d41f23f37bf46afc

const app = express();

app.use(cors());
app.use(express.json());
<<<<<<< HEAD
app.use(cookieParser());
app.use("/auth", authRoutes);
app.use("/users", usersRoutes);
app.use("/items", itemsRoutes);
app.use("/claims", claimsRoutes);
=======
app.use("/auth", authRoutes);
>>>>>>> a9d134576855e13cb29d8e52d41f23f37bf46afc

export default app;
