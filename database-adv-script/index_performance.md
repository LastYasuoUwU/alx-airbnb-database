# Airbnb‑Clone – Database Indexing

This repository contains the SQL script used to create indexes on the key tables of the Airbnb‑Clone backend
(`users`, `bookings`, `properties`).  
Proper indexing is essential for fast reads in a high‑traffic rental marketplace.

## Files

| File                 | Purpose                                           |
| -------------------- | ------------------------------------------------- |
| `database_index.sql` | SQL commands that create the recommended indexes. |
| `README.md`          | This documentation.                               |

## How to Use

1. **Run the script** on your database.

   ```bash
   psql -d your_db_name -f database_index.sql
   ```
