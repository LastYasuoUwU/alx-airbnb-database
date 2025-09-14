# Database Performance Monitoring – Airbnb Clone Backend

## 🎯 Objective

Continuously monitor and refine database performance by analyzing execution plans and making schema adjustments.

---

## 🔍 Step 1: Monitoring Tools

We used the following SQL commands to analyze query performance:

- **EXPLAIN / EXPLAIN ANALYZE** → shows query execution plans and timing.
- **SHOW PROFILE** (MySQL) → provides profiling details (CPU, I/O, memory).
- **pg_stat_statements** (PostgreSQL) → tracks slow queries and execution statistics.

---

## 📊 Step 2: Queries Monitored

### Query 1 – Retrieve Bookings with User and Property

```sql
EXPLAIN ANALYZE
SELECT
    b.booking_id,
    b.start_date,
    b.end_date,
    u.first_name,
    p.name AS property_name
FROM Booking b
JOIN "User" u ON b.user_id = u.user_id
JOIN Property p ON b.property_id = p.property_id
WHERE b.status = 'confirmed'
ORDER BY b.created_at DESC;
```
