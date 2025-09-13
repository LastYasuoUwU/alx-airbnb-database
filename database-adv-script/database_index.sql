/* ==============================================================
   1.  USER TABLE INDEXES
   ============================================================== */

-- Primary key already indexed by default (users.id)
-- Unique email – required for login & fast look‑ups
CREATE UNIQUE INDEX IF NOT EXISTS idx_users_email
    ON users (email);

-- Optional: index on profile photo URL if it is queried frequently
CREATE INDEX IF NOT EXISTS idx_users_profile_photo
    ON users (profile_photo_url);


/* ==============================================================
   2.  BOOKING TABLE INDEXES
   ============================================================== */

-- Index on the foreign key to users – used in JOIN & WHERE
CREATE INDEX IF NOT EXISTS idx_bookings_user_id
    ON bookings (user_id);

-- Index on the foreign key to properties – used in JOIN & WHERE
CREATE INDEX IF NOT EXISTS idx_bookings_property_id
    ON bookings (property_id);

-- Composite index on (property_id, status) – useful for counting bookings per property
CREATE INDEX IF NOT EXISTS idx_bookings_property_status
    ON bookings (property_id, status);

-- Composite index on (user_id, status) – useful for counting bookings per user
CREATE INDEX IF NOT EXISTS idx_bookings_user_status
    ON bookings (user_id, status);

-- Index on booking dates – used for availability checks & conflict detection
CREATE INDEX IF NOT EXISTS idx_bookings_start_end
    ON bookings (start_date, end_date);


/* ==============================================================
   3.  PROPERTY TABLE INDEXES
   ============================================================== */

-- Index on title – used for text search / autocomplete
CREATE INDEX IF NOT EXISTS idx_properties_title
    ON properties (title);

-- Index on location (city / country) – used in search filters
CREATE INDEX IF NOT NOT EXISTS idx_properties_location
    ON properties (city, country);

-- Index on price – used in price range filtering
CREATE INDEX IF NOT EXISTS idx_properties_price
    ON properties (price);

-- Composite index for multi‑column search: location + price
CREATE INDEX IF NOT EXISTS idx_properties_location_price
    ON properties (city, country, price);

-- Composite index for availability search (availability flag + price)
CREATE INDEX IF NOT EXISTS idx_properties_availability_price
    ON properties (availability, price);

-- 1️⃣  Count bookings per user
EXPLAIN (ANALYZE, BUFFERS)
SELECT u.id, u.email, COUNT(b.id) AS total_bookings
FROM users u
LEFT JOIN bookings b ON u.id = b.user_id
   AND b.status = 'confirmed'
GROUP BY u.id, u.email
ORDER BY total_bookings DESC;

-- 2️⃣  Rank properties by booking count
EXPLAIN (ANALYZE, BUFFERS)
WITH pb AS (
  SELECT p.id, p.title, COUNT(b.id) AS booking_count
  FROM properties p
  LEFT JOIN bookings b ON p.id = b.property_id
     AND b.status = 'confirmed'
  GROUP BY p.id, p.title
)
SELECT *, ROW_NUMBER() OVER (ORDER BY booking_count DESC) AS rank
FROM pb
ORDER BY rank;