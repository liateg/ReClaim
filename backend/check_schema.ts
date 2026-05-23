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

async function checkSchema() {
  try {
    const res = await pool.query(`
      SELECT column_name, data_type 
      FROM information_schema.columns 
      WHERE table_name = 'users'
      ORDER BY ordinal_position;
    `);
    console.log("USERS_SCHEMA_START");
    res.rows.forEach(r => console.log(`${r.column_name}: ${r.data_type}`));
    console.log("USERS_SCHEMA_END");
    await pool.end();
  } catch (err) {
    console.error(err);
    process.exit(1);
  }
}
checkSchema();
