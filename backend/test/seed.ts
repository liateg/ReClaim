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

    const seedPassword = "TestPass123!";

    const seedUsers = [
      {
        fullName: "Admin User",
        email: "admin@example.com",
        password: "TestPass123!",
        role: "admin",
      },
      {
        fullName: "Alice Tester",
        email: "alice@example.com",
        password: "TestPass123!",
        role: "user",
      },
      {
        fullName: "Bob Finder",
        email: "bob@example.com",
        password: "TestPass123!",
        role: "user",
      },
    ] as const;

    console.log(
      "Seed user credentials:",
      seedUsers.map(({ fullName, email, password }) => ({
        fullName,
        email,
        password,
      })),
    );

    const hash = await bcrypt.hash(seedPassword, 10);

    // Insert users
    const usersRes = await pool.query(
      `INSERT INTO users (full_name, email, password_hash, role)
       VALUES
         ($1, $2, $3, $4),
         ($5, $6, $7, $8),
         ($9, $10, $11, $12)
       RETURNING id, full_name, email, role, created_at`,
      [
        seedUsers[0].fullName,
        seedUsers[0].email,
        hash,
        seedUsers[0].role,
        seedUsers[1].fullName,
        seedUsers[1].email,
        hash,
        seedUsers[1].role,
        seedUsers[2].fullName,
        seedUsers[2].email,
        hash,
        seedUsers[2].role,
      ],
    );

    console.log("Seeded users:", usersRes.rows);

    const adminId = usersRes.rows[0].id;
    const aliceId = usersRes.rows[1].id;
    const bobId = usersRes.rows[2].id;

    console.log("Seed login credentials:", {
      admin: {
        email: "admin@example.com",
        password: seedPassword,
        role: "admin",
      },
      alice: {
        email: "alice@example.com",
        password: seedPassword,
        role: "user",
      },
      bob: { email: "bob@example.com", password: seedPassword, role: "user" },
    });

    // Insert categories
    const catRes = await pool.query(
      `INSERT INTO categories (name, created_by)
       VALUES
         ($1,$2),
         ($3,$4),
         ($5,$6),
         ($7,$8),
         ($9,$10),
         ($11,$12)
       RETURNING id, name`,
      [
        "Electronics",
        adminId,
        "Accessories",
        aliceId,
        "Clothing",
        bobId,
        "Documents",
        adminId,
        "Keys",
        aliceId,
        "Bags",
        bobId,
      ],
    );

    console.log("Seeded categories:", catRes.rows);

    const categoryIds = Object.fromEntries(
      catRes.rows.map((row: { id: number; name: string }) => [
        row.name,
        row.id,
      ]),
    ) as Record<string, number>;

    // Insert items
    const itemsRes = await pool.query(
      `INSERT INTO items
       (title, description, category_id, location, date_found, image_url, verification_question, verification_answer, hidden_details, status, posted_by)
       VALUES
       ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11),
       ($12,$13,$14,$15,$16,$17,$18,$19,$20,$21,$22),
       ($23,$24,$25,$26,$27,$28,$29,$30,$31,$32,$33)
       ,($34,$35,$36,$37,$38,$39,$40,$41,$42,$43,$44)
       ,($45,$46,$47,$48,$49,$50,$51,$52,$53,$54,$55)
       ,($56,$57,$58,$59,$60,$61,$62,$63,$64,$65,$66)
       ,($67,$68,$69,$70,$71,$72,$73,$74,$75,$76,$77)
       ,($78,$79,$80,$81,$82,$83,$84,$85,$86,$87,$88)
       RETURNING *`,
      [
        // Item 1
        "Blue Wireless Headphones",
        "Over-ear Bluetooth headphones with noise cancellation. Found near the central library.",
        categoryIds.Electronics,
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
        categoryIds.Accessories,
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
        categoryIds.Clothing,
        "Campus Quad",
        "2026-05-19",
        "https://example.com/images/umbrella.jpg",
        "What color is the canopy?",
        "red",
        "Engraved initials: J.D.",
        "claimed",
        aliceId,

        // Item 4 (resolved)
        "Student ID Card",
        "AAU student ID card found near cafeteria entrance.",
        categoryIds.Documents,
        "Main Cafeteria",
        "2026-05-16",
        "https://example.com/images/student-id.jpg",
        "What is the first name on the card?",
        "Marta",
        "ID ends with 2041",
        "resolved",
        bobId,

        // Item 5
        "Office Key Set",
        "Set of 3 silver keys with a blue ring.",
        categoryIds.Keys,
        "Engineering Building",
        "2026-05-21",
        "https://example.com/images/keys.jpg",
        "What sticker is on the ring?",
        "blue-star",
        "One key marked LAB-3",
        "available",
        adminId,

        // Item 6 (claimed)
        "Black Backpack",
        "Laptop backpack with a side water bottle holder.",
        categoryIds.Bags,
        "Dormitory Gate",
        "2026-05-17",
        "https://example.com/images/backpack.jpg",
        "What brand logo is on the front pocket?",
        "nike",
        "Contains a calculus notebook",
        "claimed",
        bobId,

        // Item 7
        "Silver Smartwatch",
        "Smartwatch with cracked screen protector and gray strap.",
        categoryIds.Electronics,
        "Sports Complex",
        "2026-05-22",
        "https://example.com/images/smartwatch.jpg",
        "What app is pinned first on the home screen?",
        "weather",
        "Watch face set to 24-hour time",
        "available",
        aliceId,

        // Item 8 (resolved)
        "Blue Folder",
        "Blue document folder with course handouts.",
        categoryIds.Documents,
        "Registrar Office",
        "2026-05-15",
        "https://example.com/images/folder.jpg",
        "Which course code is on the first page?",
        "SE-302",
        "Contains tuition receipt copy",
        "resolved",
        adminId,
      ],
    );

    console.log("Seeded items:", itemsRes.rows);

    const itemByTitle = Object.fromEntries(
      itemsRes.rows.map((row: { id: number; title: string }) => [
        row.title,
        row.id,
      ]),
    ) as Record<string, number>;

    // Insert claims
    const claimsRes = await pool.query(
      `INSERT INTO claims (item_id, claimant_id, answer_attempt, status, review_note)
       VALUES
         ($1,$2,$3,$4,$5),
         ($6,$7,$8,$9,$10),
         ($11,$12,$13,$14,$15),
         ($16,$17,$18,$19,$20),
         ($21,$22,$23,$24,$25),
         ($26,$27,$28,$29,$30)
       RETURNING *`,
      [
        // Claim 1: pending claim by Bob
        itemByTitle["Blue Wireless Headphones"],
        bobId,
        "Blue",
        "pending",
        null,

        // Claim 2: approved claim by Bob
        itemByTitle["Red Umbrella"],
        bobId,
        "red",
        "approved",
        "Verified by matching normalized answer",

        // Claim 3: rejected claim by Alice
        itemByTitle["Leather Wallet"],
        aliceId,
        "Guess brand",
        "rejected",
        "Verification answer did not match",

        // Claim 4: withdrawn claim by Alice
        itemByTitle["Office Key Set"],
        aliceId,
        "blue-star",
        "withdrawn",
        "Claimant withdrew before review",

        // Claim 5: approved claim by admin user
        itemByTitle["Black Backpack"],
        adminId,
        "nike",
        "approved",
        "Admin test account approved claim",

        // Claim 6: pending claim by Alice
        itemByTitle["Silver Smartwatch"],
        aliceId,
        "weather",
        "pending",
        null,
      ],
    );

    console.log("Seeded claims:", claimsRes.rows);

    // Keep item statuses aligned with claim outcomes for realistic app flows
    await pool.query(
      `UPDATE items
       SET status = CASE
         WHEN id IN ($1, $2) THEN 'claimed'
         WHEN id IN ($3, $4) THEN 'resolved'
         ELSE status
       END`,
      [
        itemByTitle["Red Umbrella"],
        itemByTitle["Black Backpack"],
        itemByTitle["Student ID Card"],
        itemByTitle["Blue Folder"],
      ],
    );

    // Insert reports
    const reportsRes = await pool.query(
      `INSERT INTO reports (reporter_id, item_id, claim_id, reason, description, status, admin_note)
       VALUES
         ($1,$2,$3,$4,$5,$6,$7),
         ($8,$9,$10,$11,$12,$13,$14),
         ($15,$16,$17,$18,$19,$20,$21),
         ($22,$23,$24,$25,$26,$27,$28),
         ($29,$30,$31,$32,$33,$34,$35),
         ($36,$37,$38,$39,$40,$41,$42)
       RETURNING *`,
      [
        // Report 1: Alice reports an item (pending)
        aliceId,
        itemByTitle["Leather Wallet"],
        null,
        "fake",
        "Looks like a scam listing",
        "pending",
        null,

        // Report 2: Bob reports an item (under review)
        bobId,
        itemByTitle["Office Key Set"],
        null,
        "spam",
        "Duplicate key posts appeared multiple times",
        "under_review",
        "Admin reviewing repeated submissions",

        // Report 3: Admin reports a claim (resolved)
        adminId,
        null,
        claimsRes.rows[2].id,
        "wrong_owner",
        "Claim answer looks suspicious for this claimant",
        "resolved",
        "Validated and handled by admin",

        // Report 4: Alice reports a withdrawn claim (rejected)
        aliceId,
        null,
        claimsRes.rows[3].id,
        "other",
        "Claim was withdrawn but still appears in activity feed",
        "rejected",
        "Expected behavior after verification",

        // Report 5: Bob reports an item tied to an approved claim (resolved)
        bobId,
        itemByTitle["Black Backpack"],
        null,
        "fake",
        "Posting looked fake before claim approval",
        "resolved",
        "Ownership confirmed by approved claim",

        // Report 6: Bob reports pending claim flow item (pending)
        bobId,
        itemByTitle["Silver Smartwatch"],
        null,
        "other",
        "Pending claim has no reviewer note yet",
        "pending",
        null,
      ],
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
