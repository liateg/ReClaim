import dotenv from "dotenv";
import pg from "pg";
import bcrypt from "bcrypt";

dotenv.config();

const pool = new pg.Pool({
  user: process.env.DB_USER,
  host: process.env.DB_HOST,
  database: process.env.DB_NAME,
  port: Number(process.env.DB_PORT),
  password: process.env.DB_PASSWORD,
});

async function seed() {
  try {
    await pool.query("DELETE FROM users WHERE email LIKE $1", ["test-%"]);

    const password = "TestPass123!";
    const hash = await bcrypt.hash(password, 10);

    const res = await pool.query(
      `INSERT INTO users (full_name, email, password_hash, role)
       VALUES ($1, $2, $3, $4)
       RETURNING id`,
      ["Test User", "test-user@example.com", hash, "user"],
    );

    console.log("Seeded user id:", res.rows[0].id);
    await pool.end();
    process.exit(0);
  } catch (err) {
    console.error("Seeding error", err);
    await pool.end();
    process.exit(1);
  }
}

seed();
