# SQL Joins Practice – Airbnb Clone Backend

## 🎯 Objective

The goal of this exercise is to **master SQL joins** by writing queries that combine data from multiple tables in the Airbnb Clone database.  
We demonstrate three types of joins: **INNER JOIN**, **LEFT JOIN**, and **FULL OUTER JOIN**.

---

## 🧩 Queries

### 1. INNER JOIN – Bookings with Users

Retrieve all bookings and the respective users who made them.

```sql
SELECT
    b.booking_id,
    b.property_id,
    b.start_date,
    b.end_date,
    b.total_price,
    u.user_id,
    u.first_name,
    u.last_name,
    u.email
FROM Booking b
INNER JOIN "User" u
    ON b.user_id = u.user_id;
```
