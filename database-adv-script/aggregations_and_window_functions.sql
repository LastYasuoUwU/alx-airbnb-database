SELECT 
    u.user_id,
    u.first_name,
    u.last_name,
    COUNT(b.booking_id) AS total_bookings
FROM "User" u
LEFT JOIN Booking b 
    ON u.user_id = b.user_id
GROUP BY u.user_id, u.first_name, u.last_name
ORDER BY total_bookings DESC;

/*  Rank properties by booking volume  */
WITH property_bookings AS (
    SELECT
        p.id          AS property_id,
        p.title       AS property_title,
        COUNT(b.id)   AS booking_count
    FROM properties p
    LEFT JOIN bookings b
           ON p.id = b.property_id
          AND b.status = 'confirmed'          -- optional filter
    GROUP BY p.id, p.title
)
SELECT
    property_id,
    property_title,
    booking_count,
    /*  ROW_NUMBER gives a unique rank (1 is the most booked)   */
    ROW_NUMBER() OVER (ORDER BY booking_count DESC)          AS rank_row,
    /*  RANK gives the same rank for ties, but may leave gaps  */
    RANK()      OVER (ORDER BY booking_count DESC)          AS rank_rnk
FROM property_bookings
ORDER BY rank_row;
