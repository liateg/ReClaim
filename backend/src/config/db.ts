<<<<<<< HEAD
import pg from "pg";
import dotenv from "dotenv";

dotenv.config();
console.log(`DB Password: ${process.env.DB_PASSWORD}`);
export const pool = new pg.Pool({
  user: process.env.DB_USER || "postgres",
  host: process.env.DB_HOST,
  database: process.env.DB_NAME,
  port: Number(process.env.DB_PORT),
  password: String(process.env.DB_PASSWORD || "654123"),
});
=======
import pg from 'pg';

export const pool=new pg.Pool({
    user: process.env.DB_USER,
    host: process.env.DB_HOST,
    database: process.env.DB_NAME,
    port: Number(process.env.DB_PORT),
    password: process.env.DB_PASSWORD
})
>>>>>>> a9d134576855e13cb29d8e52d41f23f37bf46afc
