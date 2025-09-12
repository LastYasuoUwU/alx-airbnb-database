# AirBnB Database Schema - DDL Implementation Documentation

## Overview

This document provides comprehensive documentation for the SQL Data Definition Language (DDL) implementation of the AirBnB database schema. The implementation focuses on creating a robust, scalable, and performance-optimized database structure.

## Table of Contents

1. [Database Architecture](#database-architecture)
2. [Table Specifications](#table-specifications)
3. [Constraints and Validation](#constraints-and-validation)
4. [Indexing Strategy](#indexing-strategy)
5. [Advanced Features](#advanced-features)
6. [Performance Considerations](#performance-considerations)
7. [Implementation Guide](#implementation-guide)
8. [Monitoring and Maintenance](#monitoring-and-maintenance)

## Database Architecture

### Schema Overview

```
User (1) -----> (M) Property (1) -----> (M) Booking (1) -----> (1) Payment
 |                   |                       |
 |                   |                       |
 v                   v                       v
(M) Message (M)     (M) Review (M)         (Enhanced with status tracking)
```

### Design Principles

- **Normalization**: All tables comply with Third Normal Form (3NF)
- **Referential Integrity**: Comprehensive foreign key relationships
- **Data Validation**: Business rule enforcement at database level
- **Performance**: Strategic indexing for optimal query performance
- **Scalability**: UUID-based primary keys for distributed systems
- **Audit Trail**: Timestamp tracking on all entities

## Table Specifications

### 1. User Table

```sql
User (
    user_id UUID PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    phone_number VARCHAR(20) NULL,
    role ENUM('guest', 'host', 'admin') NOT NULL,
    created_at TIMESTAMP,
    updated_at TIMESTAMP
)
```

**Key Features:**

- UUID primary key for global uniqueness
- Role-based access control (RBAC)
- Email uniqueness enforcement
- Phone number format validation
- Automatic timestamp management

### 2. Property Table

```sql
Property (
    property_id UUID PRIMARY KEY,
    host_id UUID NOT NULL REFERENCES User(user_id),
    name VARCHAR(255) NOT NULL,
    description TEXT NOT NULL,
    location VARCHAR(500) NOT NULL,
    price_per_night DECIMAL(10,2) NOT NULL,
    created_at TIMESTAMP,
    updated_at TIMESTAMP
)
```

**Key Features:**

- Foreign key relationship to User (host)
- Price validation (positive values only)
- Minimum description length requirement
- Location field for geographic data
- CASCADE delete/update operations

### 3. Booking Table

```sql
Booking (
    booking_id UUID PRIMARY KEY,
    property_id UUID NOT NULL REFERENCES Property(property_id),
    user_id UUID NOT NULL REFERENCES User(user_id),
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    total_price DECIMAL(10,2) NOT NULL,
    status ENUM('pending', 'confirmed', 'canceled') NOT NULL,
    created_at TIMESTAMP,
    updated_at TIMESTAMP
)
```

**Key Features:**

- Dual foreign key relationships (User + Property)
- Date range validation (end > start, future dates)
- Booking status workflow management
- Unique constraint preventing double booking
- Maximum duration limit (365 days)

### 4. Payment Table

```sql
Payment (
    payment_id UUID PRIMARY KEY,
    booking_id UUID NOT NULL UNIQUE REFERENCES Booking(booking_id),
    amount DECIMAL(10,2) NOT NULL,
    payment_date TIMESTAMP,
    payment_method ENUM('credit_card', 'paypal', 'stripe') NOT NULL,
    payment_status ENUM('pending', 'completed', 'failed', 'refunded') NOT NULL,
    transaction_id VARCHAR(255) NULL,
    created_at TIMESTAMP,
    updated_at TIMESTAMP
)
```

**Key Features:**

- One-to-one relationship with Booking
- Multiple payment method support
- Payment status tracking workflow
- Transaction ID for external system integration
- Amount validation (positive values)

### 5. Review Table

```sql
Review (
    review_id UUID PRIMARY KEY,
    property_id UUID NOT NULL REFERENCES Property(property_id),
    user_id UUID NOT NULL REFERENCES User(user_id),
    rating INTEGER NOT NULL CHECK (rating BETWEEN 1 AND 5),
    comment TEXT NOT NULL,
    created_at TIMESTAMP,
    updated_at TIMESTAMP
)
```

**Key Features:**

- Rating range validation (1-5 stars)
- One review per user per property constraint
- Minimum comment length requirement
- Foreign key relationships to User and Property

### 6. Message Table

```sql
Message (
    message_id UUID PRIMARY KEY,
    sender_id UUID NOT NULL REFERENCES User(user_id),
    recipient_id UUID NOT NULL REFERENCES User(user_id),
    message_body TEXT NOT NULL,
    sent_at TIMESTAMP,
    read_at TIMESTAMP NULL,
    message_type ENUM('inquiry', 'booking', 'general') NOT NULL,
    is_read BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP
)
```

**Key Features:**

- Self-referencing User table (sender/recipient)
- Message type categorization
- Read status tracking with timestamps
- Prevention of self-messaging
- Message length limits (10,000 characters)

## Constraints and Validation

### Business Logic Constraints

#### User Constraints

- **Email Format**: Must contain '@' and '.' characters
- **Name Validation**: Non-empty first and last names
- **Phone Format**: Optional 10-15 digit international format

#### Property Constraints

- **Price Validation**: Must be positive decimal value
- **Description Length**: Minimum 10 characters
- **Name Requirement**: Non-empty property name

#### Booking Constraints

- **Date Logic**: End date must be after start date
- **Future Bookings**: Start date must be today or future
- **Duration Limit**: Maximum 365-day booking period
- **Double Booking Prevention**: Unique property-date combinations

#### Payment Constraints

- **Amount Validation**: Must be positive value
- **Transaction ID**: Minimum 5 characters when provided
- **Status Workflow**: Proper payment status transitions

#### Review Constraints

- **Rating Range**: Integer between 1 and 5 inclusive
- **Comment Length**: Minimum 10 characters
- **Uniqueness**: One review per user-property combination

#### Message Constraints

- **Self-Message Prevention**: Sender cannot be recipient
- **Content Validation**: Non-empty message body
- **Length Limits**: Maximum 10,000 characters

## Indexing Strategy

### Primary Indexes

All tables use UUID primary keys with automatic indexing for:

- Unique identification
- Join operation optimization
- Referential integrity enforcement

### Secondary Indexes

#### User Table

```sql
CREATE INDEX idx_user_email ON User(email);
CREATE INDEX idx_user_role ON User(role);
CREATE INDEX idx_user_created_at ON User(created_at);
```

#### Property Table

```sql
CREATE INDEX idx_property_host_id ON Property(host_id);
CREATE INDEX idx_property_location ON Property(location);
CREATE INDEX idx_property_price_per_night ON Property(price_per_night);
CREATE INDEX idx_property_created_at ON Property(created_at);
```

#### Booking Table

```sql
CREATE INDEX idx_booking_property_id ON Booking(property_id);
CREATE INDEX idx_booking_user_id ON Booking(user_id);
CREATE INDEX idx_booking_start_date ON Booking(start_date);
CREATE INDEX idx_booking_end_date ON Booking(end_date);
CREATE INDEX idx_booking_status ON Booking(status);
CREATE INDEX idx_booking_dates_range ON Booking(start_date, end_date);
```

### Composite Indexes

```sql
-- Optimized for complex queries
CREATE INDEX idx_booking_user_status ON Booking(user_id, status);
CREATE INDEX idx_property_host_created ON Property(host_id, created_at);
CREATE INDEX idx_review_property_rating ON Review(property_id, rating);
CREATE INDEX idx_message_recipient_unread ON Message(recipient_id, is_read, sent_at);
```

### Index Benefits

- **Query Performance**: Faster SELECT operations
- **Join Optimization**: Efficient table joins
- **Sorting Speed**: ORDER BY clause optimization
- **Range Queries**: Date and price range searches
- **Uniqueness Enforcement**: Duplicate prevention

## Advanced Features

### 1. Automatic Timestamp Updates

```sql
-- Triggers for automatic updated_at timestamp management
CREATE TRIGGER trg_user_updated_at BEFORE UPDATE ON User
CREATE TRIGGER trg_property_updated_at BEFORE UPDATE ON Property
CREATE TRIGGER trg_booking_updated_at BEFORE UPDATE ON Booking
-- ... (additional triggers for other tables)
```

### 2. Database Views

```sql
-- Pre-built views for common queries
CREATE VIEW v_property_details -- Property with host information
CREATE VIEW v_booking_summary  -- Booking with user and property details
CREATE VIEW v_review_summary   -- Reviews with property and user details
```

### 3. Stored Procedures

```sql
-- Database statistics monitoring
CREATE PROCEDURE sp_get_table_stats() -- Returns row counts for all tables
```

### 4. Enhanced Data Types

- **UUID**: Globally unique identifiers
- **ENUM**: Controlled vocabulary fields
- **DECIMAL**: Precise monetary values
- **TEXT**: Variable-length content
- **TIMESTAMP**: Precise datetime tracking

## Performance Considerations

### Query Optimization

1. **Index Usage**: Strategic indexing on frequently queried columns
2. **Composite Indexes**: Multi-column indexes for complex queries
3. **Foreign Key Indexes**: Automatic indexing on foreign key columns
4. **View Materialization**: Pre-computed joins for common queries

### Scalability Features

1. **UUID Primary Keys**: Enable horizontal scaling and replication
2. **Normalized Design**: Minimal data redundancy
3. **Efficient Joins**: Proper foreign key relationships
4. **Partitioning Ready**: Date-based partitioning potential

### Memory and Storage

1. **Appropriate Data Types**: Right-sized columns for data
2. **Index Selectivity**: High-selectivity indexes for better performance
3. **Constraint Enforcement**: Database-level validation reduces application overhead

## Implementation Guide

### Prerequisites

- PostgreSQL 12+ or MySQL 8.0+
- Database administrator privileges
- Understanding of UUID generation functions

### Deployment Steps

#### 1. Database Creation

```sql
CREATE DATABASE airbnb_db;
USE airbnb_db;
```

#### 2. Schema Deployment

```bash
# Execute the DDL script
mysql -u username -p airbnb_db < airbnb_schema.sql
# or
psql -U username -d airbnb_db -f airbnb_schema.sql
```

#### 3. Verification

```sql
-- Check table creation
SHOW TABLES;

-- Verify constraints
SHOW CREATE TABLE User;
SHOW CREATE TABLE Booking;

-- Test indexes
EXPLAIN SELECT * FROM Property WHERE location LIKE '%New York%';
```

#### 4. Sample Data Loading

```sql
-- Insert test data to validate schema
INSERT INTO User (first_name, last_name, email, role)
VALUES ('John', 'Doe', 'john@example.com', 'guest');
```

### Database-Specific Adaptations

#### PostgreSQL

```sql
-- Use PostgreSQL-specific UUID generation
DEFAULT gen_random_uuid()

-- PostgreSQL ENUM syntax
CREATE TYPE user_role AS ENUM ('guest', 'host', 'admin');
```

#### MySQL

```sql
-- Use MySQL-specific UUID generation
DEFAULT (UUID())

-- MySQL ENUM syntax (as implemented)
role ENUM('guest', 'host', 'admin')
```

## Monitoring and Maintenance

### Performance Monitoring

```sql
-- Monitor table statistics
CALL sp_get_table_stats();

-- Check index usage
SHOW INDEX FROM Booking;

-- Query performance analysis
EXPLAIN ANALYZE SELECT * FROM v_booking_summary WHERE status = 'confirmed';
```

### Maintenance Tasks

#### Regular Maintenance

1. **Index Optimization**: Rebuild fragmented indexes
2. **Statistics Updates**: Update table statistics for query optimizer
3. **Constraint Validation**: Verify referential integrity
4. **Performance Monitoring**: Track query execution times

#### Backup Strategy

```sql
-- Full database backup
mysqldump -u username -p airbnb_db > airbnb_backup.sql

-- Table-specific backups
mysqldump -u username -p airbnb_db User > user_backup.sql
```

### Security Considerations

1. **Access Control**: Role-based permissions
2. **Data Encryption**: Encrypt sensitive fields (password_hash)
3. **Audit Logging**: Track data modifications
4. **Input Validation**: Database-level constraints prevent invalid data

## Troubleshooting

### Common Issues

#### Foreign Key Violations

```sql
-- Check orphaned records
SELECT * FROM Property p
LEFT JOIN User u ON p.host_id = u.user_id
WHERE u.user_id IS NULL;
```

#### Index Performance

```sql
-- Identify slow queries
SELECT * FROM information_schema.processlist
WHERE time > 10 AND command = 'Query';
```

#### Constraint Violations

```sql
-- Test constraint validation
INSERT INTO Review (property_id, user_id, rating, comment)
VALUES ('test-uuid', 'test-uuid', 6, 'Test'); -- Should fail (rating > 5)
```

## Conclusion

This DDL implementation provides a robust, scalable, and performance-optimized foundation for the AirBnB platform. The schema incorporates industry best practices including:

- **Data Integrity**: Comprehensive constraint validation
- **Performance Optimization**: Strategic indexing and views
- **Scalability**: UUID-based architecture
- **Maintainability**: Clear documentation and monitoring tools
- **Security**: Built-in validation and audit trails

The implementation is production-ready and can handle high-volume transactional workloads while maintaining data consistency and performance standards.
