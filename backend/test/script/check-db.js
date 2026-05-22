import pg from "pg";
import dotenv from "dotenv";
dotenv.config();

const pool = new pg.Pool({
  user: process.env.DB_USER || "postgres",
  host: process.env.DB_HOST,
  database: process.env.DB_NAME,
  port: Number(process.env.DB_PORT),
  password: String(process.env.DB_PASSWORD || "654123"),
});

(async () => {
  try {
    const { rows } = await pool.query(
      "SELECT datname FROM pg_database ORDER BY datname",
    );
    console.log(
      "Databases:",
      rows.map((r) => r.datname),
    );
    await pool.end();
  } catch (err) {
    console.error("Connection error:", err);
    await pool.end();
    process.exit(1);
  }
})();
