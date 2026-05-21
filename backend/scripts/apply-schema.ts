import fs from "fs/promises";
import dotenv from "dotenv";
import pg from "pg";

dotenv.config();

async function applySchema() {
  const sqlPath = new URL("../db/schema.sql", import.meta.url);
  try {
    const sql = await fs.readFile(sqlPath, "utf8");
    const pool = new pg.Pool({
      user: process.env.DB_USER,
      host: process.env.DB_HOST,
      database: process.env.DB_NAME,
      port: Number(process.env.DB_PORT),
      password: String(process.env.DB_PASSWORD || ""),
    });

    console.log("Applying schema to", process.env.DB_NAME);
    await pool.query(sql);
    console.log("Schema applied successfully");
    await pool.end();
    process.exit(0);
  } catch (err) {
    console.error("Error applying schema", err);
    process.exit(1);
  }
}

applySchema();
