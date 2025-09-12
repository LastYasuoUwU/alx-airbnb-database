-- ====================================================================
-- AirBnB Database Schema - Complete DDL Implementation
-- ====================================================================
-- Version: 1.0
-- Database: PostgreSQL/MySQL Compatible
-- Created: 2025
-- ====================================================================

-- Drop existing tables if they exist (in reverse dependency order)
DROP TABLE IF EXISTS Message;
DROP TABLE IF EXISTS Review;
DROP TABLE IF EXISTS Payment;
DROP TABLE IF EXISTS Booking;
DROP TABLE IF EXISTS Property;
DROP TABLE IF EXISTS User;

-- ====================================================================
-- 1. USER TABLE
-- ====================================================================
CREATE TABLE User (
    user_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    phone_number VARCHAR(20) NULL,
    role ENUM('guest', 'host', 'admin') NOT NULL DEFAULT 'guest',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    -- Constraints
    CONSTRAINT chk_user_email_format CHECK (email LIKE '%@%.%'),
    CONSTRAINT chk_user_names_not_empty CHECK (
        LENGTH(TRIM(first_name)) > 0 AND 
        LENGTH(TRIM(last_name)) > 0
    ),
    CONSTRAINT chk_user_phone_format CHECK (
        phone_number IS NULL OR 
        phone_number REGEXP '^[+]?[0-9]{10,15}$'
    )
);

-- ====================================================================
-- 2. PROPERTY TABLE
-- ====================================================================
CREATE TABLE Property (
    property_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    host_id UUID NOT NULL,
    name VARCHAR(255) NOT NULL,
    description TEXT NOT NULL,
    location VARCHAR(500) NOT NULL,
    price_per_night DECIMAL(10, 2) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    -- Foreign Key Constraints
    CONSTRAINT fk_property_host 
        FOREIGN KEY (host_id) REFERENCES User(user_id) 
        ON DELETE CASCADE 
        ON UPDATE CASCADE,
    
    -- Business Logic Constraints
    CONSTRAINT chk_property_price_positive 
        CHECK (price_per_night > 0),
    CONSTRAINT chk_property_name_not_empty 
        CHECK (LENGTH(TRIM(name)) > 0),
    CONSTRAINT chk_property_description_min_length 
        CHECK (LENGTH(TRIM(description)) >= 10),
    CONSTRAINT chk_property_location_not_empty 
        CHECK (LENGTH(TRIM(location)) > 0)
);

-- ====================================================================
-- 3. BOOKING TABLE
-- ====================================================================
CREATE TABLE Booking (
    booking_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    property_id UUID NOT NULL,
    user_id UUID NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    total_price DECIMAL(10, 2) NOT NULL,
    status ENUM('pending', 'confirmed', 'canceled') NOT NULL DEFAULT 'pending',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    -- Foreign Key Constraints
    CONSTRAINT fk_booking_property 
        FOREIGN KEY (property_id) REFERENCES Property(property_id) 
        ON DELETE CASCADE 
        ON UPDATE CASCADE,
    CONSTRAINT fk_booking_user 
        FOREIGN KEY (user_id) REFERENCES User(user_id) 
        ON DELETE CASCADE 
        ON UPDATE CASCADE,
    
    -- Business Logic Constraints
    CONSTRAINT chk_booking_dates_valid 
        CHECK (end_date > start_date),
    CONSTRAINT chk_booking_future_dates 
        CHECK (start_date >= CURRENT_DATE),
    CONSTRAINT chk_booking_total_price_positive 
        CHECK (total_price > 0),
    CONSTRAINT chk_booking_max_duration 
        CHECK (DATEDIFF(end_date, start_date) <= 365),
    
    -- Unique constraint to prevent double booking
    CONSTRAINT uk_booking_property_dates 
        UNIQUE (property_id, start_date, end_date)
);

-- ====================================================================
-- 4. PAYMENT TABLE
-- ====================================================================
CREATE TABLE Payment (
    payment_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    booking_id UUID NOT NULL UNIQUE,
    amount DECIMAL(10, 2) NOT NULL,
    payment_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    payment_method ENUM('credit_card', 'paypal', 'stripe') NOT NULL,
    payment_status ENUM('pending', 'completed', 'failed', 'refunded') NOT NULL DEFAULT 'pending',
    transaction_id VARCHAR(255) NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    -- Foreign Key Constraints
    CONSTRAINT fk_payment_booking 
        FOREIGN KEY (booking_id) REFERENCES Booking(booking_id) 
        ON DELETE CASCADE 
        ON UPDATE CASCADE,
    
    -- Business Logic Constraints
    CONSTRAINT chk_payment_amount_positive 
        CHECK (amount > 0),
    CONSTRAINT chk_payment_transaction_id_format 
        CHECK (
            transaction_id IS NULL OR 
            LENGTH(TRIM(transaction_id)) >= 5
        )
);

-- ====================================================================
-- 5. REVIEW TABLE
-- ====================================================================
CREATE TABLE Review (
    review_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    property_id UUID NOT NULL,
    user_id UUID NOT NULL,
    rating INTEGER NOT NULL,
    comment TEXT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    -- Foreign Key Constraints
    CONSTRAINT fk_review_property 
        FOREIGN KEY (property_id) REFERENCES Property(property_id) 
        ON DELETE CASCADE 
        ON UPDATE CASCADE,
    CONSTRAINT fk_review_user 
        FOREIGN KEY (user_id) REFERENCES User(user_id) 
        ON DELETE CASCADE 
        ON UPDATE CASCADE,
    
    -- Business Logic Constraints
    CONSTRAINT chk_review_rating_range 
        CHECK (rating >= 1 AND rating <= 5),
    CONSTRAINT chk_review_comment_not_empty 
        CHECK (LENGTH(TRIM(comment)) > 0),
    CONSTRAINT chk_review_comment_min_length 
        CHECK (LENGTH(TRIM(comment)) >= 10),
    
    -- Unique constraint: one review per user per property
    CONSTRAINT uk_review_user_property 
        UNIQUE (user_id, property_id)
);

-- ====================================================================
-- 6. MESSAGE TABLE
-- ====================================================================
CREATE TABLE Message (
    message_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    sender_id UUID NOT NULL,
    recipient_id UUID NOT NULL,
    message_body TEXT NOT NULL,
    sent_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    read_at TIMESTAMP NULL,
    message_type ENUM('inquiry', 'booking', 'general') NOT NULL DEFAULT 'general',
    is_read BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    -- Foreign Key Constraints
    CONSTRAINT fk_message_sender 
        FOREIGN KEY (sender_id) REFERENCES User(user_id) 
        ON DELETE CASCADE 
        ON UPDATE CASCADE,
    CONSTRAINT fk_message_recipient 
        FOREIGN KEY (recipient_id) REFERENCES User(user_id) 
        ON DELETE CASCADE 
        ON UPDATE CASCADE,
    
    -- Business Logic Constraints
    CONSTRAINT chk_message_body_not_empty 
        CHECK (LENGTH(TRIM(message_body)) > 0),
    CONSTRAINT chk_message_different_users 
        CHECK (sender_id != recipient_id),
    CONSTRAINT chk_message_body_length 
        CHECK (LENGTH(message_body) <= 10000)
);

-- ====================================================================
-- INDEXES FOR PERFORMANCE OPTIMIZATION
-- ====================================================================

-- User Table Indexes
CREATE INDEX idx_user_email ON User(email);
CREATE INDEX idx_user_role ON User(role);
CREATE INDEX idx_user_created_at ON User(created_at);

-- Property Table Indexes
CREATE INDEX idx_property_host_id ON Property(host_id);
CREATE INDEX idx_property_location ON Property(location);
CREATE INDEX idx_property_price_per_night ON Property(price_per_night);
CREATE INDEX idx_property_created_at ON Property(created_at);

-- Booking Table Indexes
CREATE INDEX idx_booking_property_id ON Booking(property_id);
CREATE INDEX idx_booking_user_id ON Booking(user_id);
CREATE INDEX idx_booking_start_date ON Booking(start_date);
CREATE INDEX idx_booking_end_date ON Booking(end_date);
CREATE INDEX idx_booking_status ON Booking(status);
CREATE INDEX idx_booking_dates_range ON Booking(start_date, end_date);
CREATE INDEX idx_booking_created_at ON Booking(created_at);

-- Payment Table Indexes
CREATE INDEX idx_payment_booking_id ON Payment(booking_id);
CREATE INDEX idx_payment_date ON Payment(payment_date);
CREATE INDEX idx_payment_status ON Payment(payment_status);
CREATE INDEX idx_payment_method ON Payment(payment_method);

-- Review Table Indexes
CREATE INDEX idx_review_property_id ON Review(property_id);
CREATE INDEX idx_review_user_id ON Review(user_id);
CREATE INDEX idx_review_rating ON Review(rating);
CREATE INDEX idx_review_created_at ON Review(created_at);

-- Message Table Indexes
CREATE INDEX idx_message_sender_id ON Message(sender_id);
CREATE INDEX idx_message_recipient_id ON Message(recipient_id);
CREATE INDEX idx_message_sent_at ON Message(sent_at);
CREATE INDEX idx_message_is_read ON Message(is_read);
CREATE INDEX idx_message_type ON Message(message_type);

-- Composite Indexes for Complex Queries
CREATE INDEX idx_booking_user_status ON Booking(user_id, status);
CREATE INDEX idx_property_host_created ON Property(host_id, created_at);
CREATE INDEX idx_review_property_rating ON Review(property_id, rating);
CREATE INDEX idx_message_recipient_unread ON Message(recipient_id, is_read, sent_at);

-- ====================================================================
-- ADDITIONAL CONSTRAINTS AND TRIGGERS
-- ====================================================================

-- Trigger to update updated_at timestamp automatically
DELIMITER $$

CREATE TRIGGER trg_user_updated_at
    BEFORE UPDATE ON User
    FOR EACH ROW
BEGIN
    SET NEW.updated_at = CURRENT_TIMESTAMP;
END$$

CREATE TRIGGER trg_property_updated_at
    BEFORE UPDATE ON Property
    FOR EACH ROW
BEGIN
    SET NEW.updated_at = CURRENT_TIMESTAMP;
END$$

CREATE TRIGGER trg_booking_updated_at
    BEFORE UPDATE ON Booking
    FOR EACH ROW
BEGIN
    SET NEW.updated_at = CURRENT_TIMESTAMP;
END$$

CREATE TRIGGER trg_payment_updated_at
    BEFORE UPDATE ON Payment
    FOR EACH ROW
BEGIN
    SET NEW.updated_at = CURRENT_TIMESTAMP;
END$$

CREATE TRIGGER trg_review_updated_at
    BEFORE UPDATE ON Review
    FOR EACH ROW
BEGIN
    SET NEW.updated_at = CURRENT_TIMESTAMP;
END$$

DELIMITER ;

-- ====================================================================
-- VIEWS FOR COMMON QUERIES
-- ====================================================================

-- View: Property details with host information
CREATE VIEW v_property_details AS
SELECT 
    p.property_id,
    p.name,
    p.description,
    p.location,
    p.price_per_night,
    CONCAT(u.first_name, ' ', u.last_name) AS host_name,
    u.email AS host_email,
    p.created_at,
    p.updated_at
FROM Property p
JOIN User u ON p.host_id = u.user_id
WHERE u.role IN ('host', 'admin');

-- View: Booking summary with user and property details
CREATE VIEW v_booking_summary AS
SELECT 
    b.booking_id,
    b.start_date,
    b.end_date,
    b.total_price,
    b.status,
    p.name AS property_name,
    p.location AS property_location,
    CONCAT(u.first_name, ' ', u.last_name) AS guest_name,
    u.email AS guest_email,
    b.created_at
FROM Booking b
JOIN Property p ON b.property_id = p.property_id
JOIN User u ON b.user_id = u.user_id;

-- View: Review summary with property and user details
CREATE VIEW v_review_summary AS
SELECT 
    r.review_id,
    r.rating,
    r.comment,
    p.name AS property_name,
    CONCAT(u.first_name, ' ', u.last_name) AS reviewer_name,
    r.created_at
FROM Review r
JOIN Property p ON r.property_id = p.property_id
JOIN User u ON r.user_id = u.user_id;

-- ====================================================================
-- SAMPLE DATA INSERTION (Optional - for testing)
-- ====================================================================

-- Sample Users
INSERT INTO User (first_name, last_name, email, role) VALUES
('John', 'Doe', 'john.doe@email.com', 'guest'),
('Jane', 'Smith', 'jane.smith@email.com', 'host'),
('Admin', 'User', 'admin@airbnb.com', 'admin');

-- ====================================================================
-- DATABASE STATISTICS AND MONITORING
-- ====================================================================

-- Create procedure to get table statistics
DELIMITER $$

CREATE PROCEDURE sp_get_table_stats()
BEGIN
    SELECT 
        'User' as table_name, COUNT(*) as row_count FROM User
    UNION ALL
    SELECT 
        'Property' as table_name, COUNT(*) as row_count FROM Property
    UNION ALL
    SELECT 
        'Booking' as table_name, COUNT(*) as row_count FROM Booking
    UNION ALL
    SELECT 
        'Payment' as table_name, COUNT(*) as row_count FROM Payment
    UNION ALL
    SELECT 
        'Review' as table_name, COUNT(*) as row_count FROM Review
    UNION ALL
    SELECT 
        'Message' as table_name, COUNT(*) as row_count FROM Message;
END$$

DELIMITER ;

-- ====================================================================
-- END OF SCHEMA DEFINITION
-- ====================================================================

-- Success message
SELECT 'AirBnB Database Schema Created Successfully!' as status;