# SQL Query Performance Optimization – Airbnb Clone Backend

## 🎯 Objective
The goal of this exercise is to **refactor complex queries** in order to improve database performance.  
We analyze an initial query, identify inefficiencies, and optimize it using **better indexing, reduced joins, and column selection**.

---

## 📝 Initial Query
Retrieves all bookings with user details, property details, and payment details.

```sql
SELECT 
    b.booking_id,
    b.start_date,
    b.end_date,
    b.total_price,
    b.status,
    u.user_id,
    u.first_name,
    u.last_name,
    u.email,
    p.property_id,
    p.name AS property_name,
    p.location,
    pay.payment_id,
    pay.amount,
    pay.payment_date,
    pay.payment_method
FROM Booking b
JOIN "User" u ON b.user_id = u.user_id
JOIN Property p ON b.property_id = p.property_id
LEFT JOIN Payment pay ON b.booking_id = pay.booking_id
ORDER BY b.created_at DESC;
