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
    // Clear existing data and reset sequences so seed is idempotent
    await pool.query(
      "TRUNCATE TABLE reports, claims, items, categories, users RESTART IDENTITY CASCADE;",
    );

    const password = "TestPass123!";
    const hash = await bcrypt.hash(password, 10);

    // Insert users
    const usersRes = await pool.query(
      `INSERT INTO users (full_name, email, password_hash, role)
       VALUES
         ($1, $2, $3, $4),
         ($5, $6, $7, $8),
         ($9, $10, $11, $12)
       RETURNING id, full_name, email, role, created_at`,
      [
        "Admin User",
        "admin@example.com",
        hash,
        "admin",
        "Alice Tester",
        "alice@example.com",
        hash,
        "user",
        "Bob Finder",
        "bob@example.com",
        hash,
        "user",
      ],
    );

    console.log("Seeded users:", usersRes.rows);

    const adminId = usersRes.rows[0].id;
    const aliceId = usersRes.rows[1].id;
    const bobId = usersRes.rows[2].id;

    // Insert categories
    const catRes = await pool.query(
      `INSERT INTO categories (name, created_by)
       VALUES ($1,$2), ($3,$4), ($5,$6)
       RETURNING id, name`,
      ["Electronics", adminId, "Accessories", aliceId, "Clothing", bobId],
    );

    console.log("Seeded categories:", catRes.rows);

    const electronicsId = catRes.rows.find(
      (r: any) => r.name === "Electronics",
    ).id;
    const accessoriesId = catRes.rows.find(
      (r: any) => r.name === "Accessories",
    ).id;
    const clothingId = catRes.rows.find((r: any) => r.name === "Clothing").id;

    // Insert items
    const itemsRes = await pool.query(
      `INSERT INTO items
       (title, description, category_id, location, date_found, image_url, verification_question, verification_answer, hidden_details, status, posted_by)
       VALUES
       ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11),
       ($12,$13,$14,$15,$16,$17,$18,$19,$20,$21,$22),
       ($23,$24,$25,$26,$27,$28,$29,$30,$31,$32,$33)
       RETURNING *`,
      [
        // Item 1
        "Blue Wireless Headphones",
        "Over-ear Bluetooth headphones with noise cancellation. Found near the central library.",
        electronicsId,
        "Central Library",
        "2026-05-20",
        "https://example.com/images/headphones.jpg",
        "What color are the ear pads?",
        "blue",
        "Serial: ABC123",
        "available",
        aliceId,

        // Item 2
        "Leather Wallet",
        "Brown leather bifold wallet with several cards inside.",
        accessoriesId,
        "Bus Stop - 5th Ave",
        "2026-05-18",
        "https://example.com/images/wallet.jpg",
        "What brand is printed on the inner pocket?",
        "Fossil",
        "Contains a membership card for Cafe 42",
        "available",
        bobId,

        // Item 3 (claimed)
        "Red Umbrella",
        "Compact red umbrella with a wooden handle.",
        clothingId,
        "Campus Quad",
        "2026-05-19",
        "https://example.com/images/umbrella.jpg",
        "What color is the canopy?",
        "red",
        "Engraved initials: J.D.",
        "claimed",
        aliceId,
      ],
    );

    console.log("Seeded items:", itemsRes.rows);

    const item1 = itemsRes.rows[0];
    const item2 = itemsRes.rows[1];
    const item3 = itemsRes.rows[2];

    // Insert claims
    const claimsRes = await pool.query(
      `INSERT INTO claims (item_id, claimant_id, answer_attempt, status, review_note)
       VALUES
         ($1,$2,$3,$4,$5),
         ($6,$7,$8,$9,$10)
       RETURNING *`,
      [
        // Claim on item1 by Bob (case-different answer, pending)
        item1.id,
        bobId,
        "Blue",
        "pending",
        null,
        // Claim on item3 by Bob (correct answer, approved)
        item3.id,
        bobId,
        "red",
        "approved",
        "Verified by matching normalized answer",
      ],
    );

    console.log("Seeded claims:", claimsRes.rows);

    // Update item3 status to match claim
    await pool.query(`UPDATE items SET status = $1 WHERE id = $2`, [
      "claimed",
      item3.id,
    ]);

    // Insert reports
    const reportsRes = await pool.query(
      `INSERT INTO reports (reporter_id, item_id, reason, description, status)
       VALUES ($1,$2,$3,$4,$5)
       RETURNING *`,
      [aliceId, item2.id, "fake", "Looks like a scam listing", "pending"],
    );

    console.log("Seeded reports:", reportsRes.rows);

    await pool.end();
    process.exit(0);
  } catch (err) {
    console.error("Seeding error", err);
    await pool.end();
    process.exit(1);
  }
}

seed();
