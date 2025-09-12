# AirBnB Database Sample Data

This project provides **sample SQL INSERT scripts** for populating the AirBnB-style database described in the ERD.

## Entities Covered

- **User**: Guests, hosts, admins
- **Property**: Listings managed by hosts
- **Booking**: Reservations made by guests
- **Payment**: Financial transactions linked to bookings
- **Review**: Ratings and comments for properties
- **Message**: Direct messages between users

## Sample Data Highlights

- Multiple **users** with roles (guest, host, admin)
- **Properties** listed by different hosts
- **Bookings** showing real reservation periods
- **Payments** linked to confirmed bookings
- **Reviews** with realistic ratings and comments
- **Messages** simulating user communication

## Usage

1. Ensure the database schema is created (tables for User, Property, Booking, Payment, Review, Message).
2. Run the script:

   ```bash
   psql -U your_user -d your_db -f sample_data.sql
   ```
