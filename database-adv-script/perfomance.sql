-- ====================================================================
-- AirBnB Database - Query Performance Optimization
-- ====================================================================
-- File: performance.sql
-- Purpose: Demonstrate query optimization techniques
-- Focus: Booking details with user, property, and payment information
-- ====================================================================

-- ====================================================================
-- 1. INITIAL COMPLEX QUERY (UNOPTIMIZED)
-- ====================================================================

-- This query retrieves all bookings with complete details
-- Problem: Multiple JOINs without proper optimization
SELECT 
    -- Booking Information
    b.booking_id,
    b.start_date,
    b.end_date,
    b.total_price,
    b.status as booking_status,
    b.created_at as booking_created,
    
    -- Guest Information
    u_guest.user_id as guest_id,
    u_guest.first_name as guest_first_name,
    u_guest.last_name as guest_last_name,
    u_guest.email as guest_email,
    u_guest.phone_number as guest_phone,
    u_guest.created_at as guest_created,
    
    -- Property Information
    p.property_id,
    p.name as property_name,
    p.description as property_description,
    p.location as property_location,
    p.price_per_night,
    p.created_at as property_created,
    
    -- Host Information
    u_host.user_id as host_id,
    u_host.first_name as host_first_name,
    u_host.last_name as host_last_name,
    u_host.email as host_email,
    u_host.phone_number as host_phone,
    
    -- Payment Information
    pay.payment_id,
    pay.amount as payment_amount,
    pay.payment_date,
    pay.payment_method,
    pay.payment_status,
    pay.transaction_id,
    
    -- Calculated Fields
    DATEDIFF(b.end_date, b.start_date) as nights_stayed,
    (b.total_price / DATEDIFF(b.end_date, b.start_date)) as avg_price_per_night
    
FROM Booking b
    -- Join with Guest (User who made booking)
    INNER JOIN User u_guest ON b.user_id = u_guest.user_id
    
    -- Join with Property
    INNER JOIN Property p ON b.property_id = p.property_id
    
    -- Join with Host (User who owns property)
    INNER JOIN User u_host ON p.host_id = u_host.user_id
    
    -- Join with Payment
    LEFT JOIN Payment pay ON b.booking_id = pay.booking_id

-- Optional WHERE clause for filtering
-- WHERE b.status = 'confirmed'
--   AND b.start_date >= '2024-01-01'
--   AND b.end_date <= '2024-12-31'

ORDER BY b.created_at DESC;

-- ====================================================================
-- 2. PERFORMANCE ANALYSIS COMMANDS
-- ====================================================================

-- Run EXPLAIN to analyze query execution plan
EXPLAIN 
SELECT 
    b.booking_id,
    b.start_date,
    b.end_date,
    b.total_price,
    b.status as booking_status,
    u_guest.first_name as guest_first_name,
    u_guest.last_name as guest_last_name,
    u_guest.email as guest_email,
    p.name as property_name,
    p.location as property_location,
    p.price_per_night,
    u_host.first_name as host_first_name,
    u_host.last_name as host_last_name,
    pay.amount as payment_amount,
    pay.payment_method,
    pay.payment_status
FROM Booking b
    INNER JOIN User u_guest ON b.user_id = u_guest.user_id
    INNER JOIN Property p ON b.property_id = p.property_id
    INNER JOIN User u_host ON p.host_id = u_host.user_id
    LEFT JOIN Payment pay ON b.booking_id = pay.booking_id
WHERE b.status = 'confirmed'
  AND b.start_date >= '2024-01-01'
ORDER BY b.created_at DESC;

-- For MySQL: Use EXPLAIN ANALYZE for actual execution statistics
-- EXPLAIN ANALYZE SELECT ... (same query as above)

-- For PostgreSQL: Use EXPLAIN (ANALYZE, BUFFERS) for detailed analysis
-- EXPLAIN (ANALYZE, BUFFERS) SELECT ... (same query as above)

-- ====================================================================
-- 3. QUERY OPTIMIZATION TECHNIQUES
-- ====================================================================

-- Technique 1: Remove unnecessary columns from SELECT
-- Only select columns that are actually needed
SELECT 
    b.booking_id,
    b.start_date,
    b.end_date,
    b.total_price,
    b.status,
    CONCAT(u_guest.first_name, ' ', u_guest.last_name) as guest_name,
    u_guest.email as guest_email,
    p.name as property_name,
    p.location as property_location,
    CONCAT(u_host.first_name, ' ', u_host.last_name) as host_name,
    pay.amount as payment_amount,
    pay.payment_status
FROM Booking b
    INNER JOIN User u_guest ON b.user_id = u_guest.user_id
    INNER JOIN Property p ON b.property_id = p.property_id
    INNER JOIN User u_host ON p.host_id = u_host.user_id
    LEFT JOIN Payment pay ON b.booking_id = pay.booking_id
WHERE b.status = 'confirmed'
  AND b.start_date >= '2024-01-01'
ORDER BY b.created_at DESC
LIMIT 50; -- Add LIMIT for pagination

-- ====================================================================
-- 4. OPTIMIZED QUERY VERSION 1: Using Subqueries
-- ====================================================================

-- Break complex query into smaller parts using subqueries
SELECT 
    booking_info.*,
    guest_info.guest_name,
    guest_info.guest_email,
    property_info.property_name,
    property_info.property_location,
    property_info.host_name,
    payment_info.payment_amount,
    payment_info.payment_status
FROM (
    -- Core booking information
    SELECT 
        booking_id,
        user_id,
        property_id,
        start_date,
        end_date,
        total_price,
        status,
        created_at
    FROM Booking 
    WHERE status = 'confirmed'
      AND start_date >= '2024-01-01'
) booking_info

LEFT JOIN (
    -- Guest information
    SELECT 
        user_id,
        CONCAT(first_name, ' ', last_name) as guest_name,
        email as guest_email
    FROM User
) guest_info ON booking_info.user_id = guest_info.user_id

LEFT JOIN (
    -- Property and host information
    SELECT 
        p.property_id,
        p.name as property_name,
        p.location as property_location,
        CONCAT(u.first_name, ' ', u.last_name) as host_name
    FROM Property p
    INNER JOIN User u ON p.host_id = u.user_id
) property_info ON booking_info.property_id = property_info.property_id

LEFT JOIN (
    -- Payment information
    SELECT 
        booking_id,
        amount as payment_amount,
        payment_status
    FROM Payment
) payment_info ON booking_info.booking_id = payment_info.booking_id

ORDER BY booking_info.created_at DESC
LIMIT 50;

-- ====================================================================
-- 5. OPTIMIZED QUERY VERSION 2: Using CTEs (Common Table Expressions)
-- ====================================================================

WITH booking_filtered AS (
    -- Filter bookings first to reduce dataset
    SELECT 
        booking_id,
        user_id,
        property_id,
        start_date,
        end_date,
        total_price,
        status,
        created_at
    FROM Booking 
    WHERE status = 'confirmed'
      AND start_date >= '2024-01-01'
      AND start_date <= '2024-12-31'
),
guest_details AS (
    -- Get guest information for filtered bookings only
    SELECT 
        u.user_id,
        CONCAT(u.first_name, ' ', u.last_name) as guest_name,
        u.email as guest_email
    FROM User u
    WHERE u.user_id IN (SELECT DISTINCT user_id FROM booking_filtered)
),
property_host_details AS (
    -- Get property and host information for filtered bookings only
    SELECT 
        p.property_id,
        p.name as property_name,
        p.location as property_location,
        p.price_per_night,
        CONCAT(u.first_name, ' ', u.last_name) as host_name,
        u.email as host_email
    FROM Property p
    INNER JOIN User u ON p.host_id = u.user_id
    WHERE p.property_id IN (SELECT DISTINCT property_id FROM booking_filtered)
),
payment_details AS (
    -- Get payment information for filtered bookings only
    SELECT 
        booking_id,
        amount as payment_amount,
        payment_method,
        payment_status,
        payment_date
    FROM Payment
    WHERE booking_id IN (SELECT booking_id FROM booking_filtered)
)

-- Final optimized query
SELECT 
    bf.booking_id,
    bf.start_date,
    bf.end_date,
    bf.total_price,
    bf.status as booking_status,
    gd.guest_name,
    gd.guest_email,
    phd.property_name,
    phd.property_location,
    phd.price_per_night,
    phd.host_name,
    pd.payment_amount,
    pd.payment_method,
    pd.payment_status,
    
    -- Calculated fields
    DATEDIFF(bf.end_date, bf.start_date) as nights_stayed,
    ROUND((bf.total_price / DATEDIFF(bf.end_date, bf.start_date)), 2) as avg_price_per_night
    
FROM booking_filtered bf
LEFT JOIN guest_details gd ON bf.user_id = gd.user_id
LEFT JOIN property_host_details phd ON bf.property_id = phd.property_id
LEFT JOIN payment_details pd ON bf.booking_id = pd.booking_id

ORDER BY bf.created_at DESC
LIMIT 50;

-- ====================================================================
-- 6. OPTIMIZED QUERY VERSION 3: Index-Optimized Query
-- ====================================================================

-- This version is designed to use indexes efficiently
SELECT /*+ USE_INDEX(b, idx_booking_status, idx_booking_start_date) */
    b.booking_id,
    b.start_date,
    b.end_date,
    b.total_price,
    b.status,
    
    -- Use CONCAT to reduce columns selected from User table
    CONCAT(ug.first_name, ' ', ug.last_name) as guest_name,
    ug.email as guest_email,
    
    p.name as property_name,
    p.location as property_location,
    
    CONCAT(uh.first_name, ' ', uh.last_name) as host_name,
    
    pay.amount as payment_amount,
    pay.payment_status

FROM Booking b FORCE INDEX (idx_booking_status, idx_booking_start_date)

-- Join order optimized based on selectivity
INNER JOIN User ug FORCE INDEX (PRIMARY) ON b.user_id = ug.user_id
INNER JOIN Property p FORCE INDEX (PRIMARY, idx_property_host_id) ON b.property_id = p.property_id
INNER JOIN User uh FORCE INDEX (PRIMARY) ON p.host_id = uh.user_id
LEFT JOIN Payment pay FORCE INDEX (idx_payment_booking_id) ON b.booking_id = pay.booking_id

-- Most selective conditions first
WHERE b.status = 'confirmed'  -- Uses idx_booking_status
  AND b.start_date >= '2024-01-01'  -- Uses idx_booking_start_date
  AND b.start_date <= '2024-12-31'

ORDER BY b.created_at DESC
LIMIT 50;

-- ====================================================================
-- 7. PERFORMANCE COMPARISON QUERIES
-- ====================================================================

-- Query to measure execution time
SET @start_time = NOW(6);

-- Run your query here (replace with actual query)
SELECT COUNT(*) as total_bookings FROM Booking b
INNER JOIN User u ON b.user_id = u.user_id
INNER JOIN Property p ON b.property_id = p.property_id
WHERE b.status = 'confirmed';

SET @end_time = NOW(6);
SELECT TIMESTAMPDIFF(MICROSECOND, @start_time, @end_time) as execution_time_microseconds;

-- ====================================================================
-- 8. ADDITIONAL OPTIMIZATION SUGGESTIONS
-- ====================================================================

-- Create covering indexes for frequently accessed columns
CREATE INDEX idx_booking_covering ON Booking(status, start_date, end_date, user_id, property_id, total_price, created_at);

-- Create materialized view for frequently accessed booking summaries
CREATE VIEW mv_booking_summary AS
SELECT 
    b.booking_id,
    b.start_date,
    b.end_date,
    b.total_price,
    b.status,
    CONCAT(u_guest.first_name, ' ', u_guest.last_name) as guest_name,
    u_guest.email as guest_email,
    p.name as property_name,
    p.location as property_location,
    CONCAT(u_host.first_name, ' ', u_host.last_name) as host_name,
    pay.amount as payment_amount,
    pay.payment_status,
    b.created_at as booking_date
FROM Booking b
INNER JOIN User u_guest ON b.user_id = u_guest.user_id
INNER JOIN Property p ON b.property_id = p.property_id
INNER JOIN User u_host ON p.host_id = u_host.user_id
LEFT JOIN Payment pay ON b.booking_id = pay.booking_id;

-- Query using the materialized view
SELECT * FROM mv_booking_summary 
WHERE status = 'confirmed' 
  AND start_date >= '2024-01-01'
ORDER BY booking_date DESC
LIMIT 50;

-- ====================================================================
-- 9. QUERY PERFORMANCE MONITORING
-- ====================================================================

-- Enable query logging (MySQL)
-- SET GLOBAL general_log = 'ON';
-- SET GLOBAL log_output = 'TABLE';

-- Enable slow query log
-- SET GLOBAL slow_query_log = 'ON';
-- SET GLOBAL long_query_time = 1; -- Log queries taking more than 1 second

-- Check query cache hit rate
SHOW STATUS LIKE 'Qcache%';

-- Check index usage
SELECT 
    table_name,
    index_name,
    cardinality,
    seq_in_index,
    column_name
FROM information_schema.statistics 
WHERE table_schema = 'airbnb_db' 
  AND table_name IN ('Booking', 'User', 'Property', 'Payment')
ORDER BY table_name, index_name, seq_in_index;

-- ====================================================================
-- END OF PERFORMANCE OPTIMIZATION QUERIES
-- ====================================================================