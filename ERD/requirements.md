# AirBnB Database Entity-Relationship Analysis

## Entities Identified

1. **User** - Central entity representing guests, hosts, and admins
2. **Property** - Rental properties managed by hosts
3. **Booking** - Reservation transactions
4. **Payment** - Financial transactions linked to bookings
5. **Review** - User feedback and ratings for properties
6. **Message** - Communication system between users

## Key Relationships

- **User → Property** (1:M): Hosts can own multiple properties
- **User → Booking** (1:M): Users can make multiple bookings
- **Property → Booking** (1:M): Properties can have multiple bookings
- **Booking → Payment** (1:1): Each booking has one payment
- **User → Review** (1:M): Users can write multiple reviews
- **Property → Review** (1:M): Properties can receive multiple reviews
- **User → Message** (M:M): Users can send/receive multiple messages

## Entity Details

### User
- **Primary Key**: user_id (UUID)
- **Attributes**: first_name, last_name, email, password_hash, phone_number, role, created_at
- **Role**: Central entity that can act as guest, host, or admin
- **Relationships**: Connected to Property, Booking, Review, and Message entities

### Property
- **Primary Key**: property_id (UUID)
- **Foreign Key**: host_id (references User)
- **Attributes**: name, description, location, price_per_night, created_at, updated_at
- **Role**: Represents rental listings managed by hosts
- **Relationships**: Connected to User (host), Booking, and Review entities

### Booking
- **Primary Key**: booking_id (UUID)
- **Foreign Keys**: property_id, user_id
- **Attributes**: start_date, end_date, total_price, status, created_at
- **Role**: Central transaction entity connecting users and properties
- **Relationships**: Connected to User, Property, and Payment entities

### Payment
- **Primary Key**: payment_id (UUID)
- **Foreign Key**: booking_id
- **Attributes**: amount, payment_date, payment_method
- **Role**: Financial transaction records for bookings
- **Relationships**: One-to-one relationship with Booking

### Review
- **Primary Key**: review_id (UUID)
- **Foreign Keys**: property_id, user_id
- **Attributes**: rating, comment, created_at
- **Role**: User feedback and rating system for properties
- **Relationships**: Connected to User and Property entities

### Message
- **Primary Key**: message_id (UUID)
- **Foreign Keys**: sender_id, recipient_id (both reference User)
- **Attributes**: message_body, sent_at
- **Role**: Communication system between platform users
- **Relationships**: Many-to-many relationship with User (as sender and recipient)

## Relationship Cardinalities

| Relationship | Type | Description |
|--------------|------|-------------|
| User → Property | 1:M | One host can own multiple properties |
| User → Booking | 1:M | One user can make multiple bookings |
| Property → Booking | 1:M | One property can have multiple bookings |
| Booking → Payment | 1:1 | Each booking has exactly one payment |
| User → Review | 1:M | One user can write multiple reviews |
| Property → Review | 1:M | One property can receive multiple reviews |
| User → Message | M:M | Users can send and receive multiple messages |

## Key Constraints

- **User**: Email must be unique
- **Booking**: Status must be one of 'pending', 'confirmed', or 'canceled'
- **Review**: Rating must be between 1 and 5
- **Payment**: Must be linked to a valid booking
- **Message**: Both sender and recipient must be valid users

## Indexing Strategy

- All primary keys are automatically indexed
- Additional indexes on frequently queried fields:
  - User.email
  - Property.property_id
  - Booking.property_id and booking_id
  - Foreign key relationships for optimal join performance