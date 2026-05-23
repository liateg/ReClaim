import pg from 'pg';
import dotenv from 'dotenv';
dotenv.config();
async function createDb() {
    const pool = new pg.Pool({
        user: process.env.DB_USER,
        host: process.env.DB_HOST,
        database: 'postgres', // Connect to default
        port: Number(process.env.DB_PORT),
        password: String(process.env.DB_PASSWORD || ""),
    });
    try {
        console.log("Checking if database 'reclaim' exists...");
        const res = await pool.query("SELECT 1 FROM pg_database WHERE datname = 'reclaim'");
        if (res.rows.length === 0) {
            console.log("Creating database 'reclaim'...");
            await pool.query("CREATE DATABASE reclaim");
            console.log("Database 'reclaim' created successfully.");
        }
        else {
            console.log("Database 'reclaim' already exists.");
        }
    }
    catch (err) {
        console.error("Error creating database", err);
    }
    finally {
        await pool.end();
    }
}
createDb();
//# sourceMappingURL=ensure-db.js.map