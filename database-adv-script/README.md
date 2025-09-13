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

# SQL Subqueries Practice – Airbnb Clone Backend

## 🎯 Objective

This exercise demonstrates the use of **non-correlated** and **correlated subqueries** in SQL, applied to the Airbnb Clone database schema.

---

## 🧩 Queries

### 1. Non-Correlated Subquery

Find all properties where the **average rating** is greater than 4.0.

```sql
SELECT property_id, name, location
FROM Property
WHERE property_id IN (
    SELECT property_id
    FROM Review
    GROUP BY property_id
    HAVING AVG(rating) > 4.0
);
```

# SQL Aggregations & Window Functions – Airbnb Clone Backend

## 🎯 Objective

This exercise demonstrates how to use **SQL aggregation** and **window functions** to analyze data in the Airbnb Clone database.

---

## 🧩 Queries

### 1. Aggregation – Total Bookings per User

Count the total number of bookings made by each user.

```sql
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
```
