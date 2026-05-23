import pg from "pg";
import dotenv from "dotenv";
dotenv.config();

const pool = new pg.Pool({
  user: process.env.DB_USER || "postgres",
  host: process.env.DB_HOST,
  database: process.env.DB_NAME,
  port: Number(process.env.DB_PORT),
  password: String(process.env.DB_PASSWORD),
});

async function createTable() {
  try {
    await pool.query(`
      CREATE TABLE IF NOT EXISTS reports (
        id SERIAL PRIMARY KEY,
        reporter_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
        item_id INTEGER REFERENCES items(id) ON DELETE SET NULL,
        claim_id INTEGER REFERENCES claims(id) ON DELETE SET NULL,
        reason TEXT NOT NULL,
        description TEXT,
        status TEXT NOT NULL DEFAULT 'pending',
        admin_note TEXT,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      );
    `);
    console.log("Reports table created successfully.");
    await pool.end();
  } catch (err) {
    console.error("Error creating reports table:", err);
    process.exit(1);
  }
}
createTable();
