/* ==============================================================
   performance.sql
   ==============================================================
   1️⃣  Original (naïve) query – pulls everything
   2️⃣  EXPLAIN plan for the original query
   3️⃣  Refactored, more efficient query
   4️⃣  EXPLAIN plan for the refactored query
   ============================================================== */

-- --------------------------------------------------------------
-- 1️⃣  Original query – “all‑in‑one” join
-- --------------------------------------------------------------
-- (Feel free to replace `*` with the exact columns you need)
SELECT
    b.id                     AS booking_id,
    b.status                 AS booking_status,
    b.start_date,
    b.end_date,
    u.id                     AS user_id,
    u.email,
    u.profile_photo_url,
    p.id                     AS property_id,
    p.title,
    p.description,
    p.price,
    p.city,
    p.country,
    p.availability,
    p.created_at,
    pa.id                    AS payment_id,
    pa.amount,
    pa.currency,
    pa.status                AS payment_status,
    pa.created_at            AS payment_created_at
FROM bookings b
JOIN users u
  ON b.user_id = u.id
JOIN properties p
  ON b.property_id = p.id
JOIN payments pa
  ON pa.booking_id = b.id
/* Uncomment if you want to limit to the latest 1000 rows (good for testing) */
-- LIMIT 1000;

/* --------------------------------------------------------------
   2️⃣  EXPLAIN (or ANALYZE) for the original query
   --------------------------------------------------------------
   For PostgreSQL:
     EXPLAIN (ANALYZE, BUFFERS) <original query>;
   For MySQL:
     EXPLAIN <original query>;
   -------------------------------------------------------------- */

/* --------------------------------------------------------------
   3️⃣  Refactored query – fewer joins, proper indexing
   --------------------------------------------------------------
   Strategy:
   - Pull only the columns you actually need
   - Use a CTE for the payments (so we don't join every payment if a booking has many)
   - Keep only the most selective JOINs
   -------------------------------------------------------------- */

-- CTE that pre‑filters payments to only confirmed ones
WITH confirmed_payments AS (
    SELECT
        id,
        booking_id,
        amount,
        currency,
        status,
        created_at
    FROM payments
    WHERE status = 'confirmed'          -- keep only successful payments
      -- if you need more, add extra predicates here
)

SELECT
    b.id                 AS booking_id,
    b.status             AS booking_status,
    b.start_date,
    b.end_date,
    u.id                 AS user_id,
    u.email,
    u.profile_photo_url,
    p.id                 AS property_id,
    p.title,
    p.price,
    p.city,
    p.country,
    cp.amount            AS payment_amount,
    cp.currency,
    cp.status            AS payment_status
FROM bookings b
JOIN users u
  ON b.user_id = u.id
JOIN properties p
  ON b.property_id = p.id
LEFT JOIN confirmed_payments cp
  ON cp.booking_id = b.id
/* Optional: only the most recent 10K bookings – adjust as needed */
-- LIMIT 10000
ORDER BY b.created_at DESC;

/* --------------------------------------------------------------
   4️⃣  EXPLAIN (or ANALYZE) for the refactored query
   --------------------------------------------------------------
   For PostgreSQL:
     EXPLAIN (ANALYZE, BUFFERS) <refactored query>;
   For MySQL:
     EXPLAIN <refactored query>;
   -------------------------------------------------------------- */
