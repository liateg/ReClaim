import pg from "pg";
import dotenv from "dotenv";
import path from "path";

dotenv.config({ path: path.resolve(process.cwd(), '.env') });

const pool = new pg.Pool({
  user: process.env.DB_USER || "postgres",
  host: process.env.DB_HOST,
  database: 'postgres', // Connect to default db first to check if 'Reclaim' exists
  port: Number(process.env.DB_PORT),
  password: String(process.env.DB_PASSWORD),
});

async function verify() {
  try {
    console.log("Checking connection to postgres...");
    const client = await pool.connect();
    console.log("Connected to postgres.");

    const dbCheck = await client.query("SELECT 1 FROM pg_database WHERE datname = 'Reclaim'");
    if (dbCheck.rows.length === 0) {
      console.error("Database 'Reclaim' DOES NOT EXIST.");
    } else {
      console.log("Database 'Reclaim' exists.");
    }
    client.release();
    await pool.end();

    console.log("Checking 'Reclaim' database content...");
    const reclaimPool = new pg.Pool({
      user: process.env.DB_USER || "postgres",
      host: process.env.DB_HOST,
      database: process.env.DB_NAME,
      port: Number(process.env.DB_PORT),
      password: String(process.env.DB_PASSWORD),
    });

    const reclaimClient = await reclaimPool.connect();
    console.log("Connected to 'Reclaim'.");

    const tableCheck = await reclaimClient.query("SELECT 1 FROM information_schema.tables WHERE table_name = 'users'");
    if (tableCheck.rows.length === 0) {
      console.error("Table 'users' DOES NOT EXIST.");
    } else {
      console.log("Table 'users' exists.");
      const columns = await reclaimClient.query(`
        SELECT column_name, data_type 
        FROM information_schema.columns 
        WHERE table_name = 'users'
      `);
      console.log("Columns in 'users':");
      columns.rows.forEach(row => console.log(`- ${row.column_name}: ${row.data_type}`));
    }
    reclaimClient.release();
    await reclaimPool.end();
  } catch (err) {
    console.error("Verification failed:", err);
  }
}

verify();
