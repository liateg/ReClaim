import pg from "pg";
import dotenv from "dotenv";
import fs from "fs";
dotenv.config();

const pool = new pg.Pool({
  user: process.env.DB_USER || "postgres",
  host: process.env.DB_HOST,
  database: process.env.DB_NAME,
  port: Number(process.env.DB_PORT),
  password: String(process.env.DB_PASSWORD),
});

async function checkSchema() {
  let output = "";
  try {
    const res = await pool.query(`
      SELECT column_name, data_type 
      FROM information_schema.columns 
      WHERE table_name = 'users'
      ORDER BY ordinal_position;
    `);
    output += "USERS_SCHEMA_START\n";
    res.rows.forEach(r => {
      output += `${r.column_name}: ${r.data_type}\n`;
    });
    output += "USERS_SCHEMA_END\n";
    fs.writeFileSync("schema_output.txt", output);
    await pool.end();
  } catch (err: any) {
    fs.writeFileSync("schema_output.txt", "ERROR: " + err.message);
    process.exit(1);
  }
}
checkSchema();
