import pg from "pg";
import dotenv from "dotenv";

dotenv.config();
console.log(`DB Password: ${process.env.DB_PASSWORD}`);
export const pool = new pg.Pool({
  user: process.env.DB_USER || "postgres",
  host: process.env.DB_HOST,
  database: process.env.DB_NAME,
  port: Number(process.env.DB_PORT),
  password: String(process.env.DB_PASSWORD),
});
