-- Insert Users
INSERT INTO "User" (user_id, first_name, last_name, email, password_hash, phone_number, role, created_at) VALUES
('u1', 'Alice', 'Johnson', 'alice@example.com', 'hashed_pw1', '+212612345678', 'guest', NOW()),
('u2', 'Bob', 'Smith', 'bob@example.com', 'hashed_pw2', '+212623456789', 'host', NOW()),
('u3', 'Carla', 'Mendez', 'carla@example.com', 'hashed_pw3', '+212634567890', 'guest', NOW()),
('u4', 'David', 'Lee', 'david@example.com', 'hashed_pw4', '+212645678901', 'host', NOW()),
('u5', 'Emma', 'Wong', 'emma@example.com', 'hashed_pw5', '+212656789012', 'admin', NOW());

-- Insert Properties
INSERT INTO "Property" (property_id, host_id, name, description, location, price_per_night, created_at, updated_at) VALUES
('p1', 'u2', 'Ocean View Apartment', 'A cozy apartment with sea view.', 'Casablanca, Morocco', 80.00, NOW(), NOW()),
('p2', 'u2', 'City Center Studio', 'Small but modern studio downtown.', 'Rabat, Morocco', 50.00, NOW(), NOW()),
('p3', 'u4', 'Mountain Cabin', 'Rustic cabin perfect for hiking.', 'Ifrane, Morocco', 100.00, NOW(), NOW());

-- Insert Bookings
INSERT INTO "Booking" (booking_id, property_id, user_id, start_date, end_date, total_price, status, created_at) VALUES
('b1', 'p1', 'u1', '2025-07-01', '2025-07-05', 320.00, 'confirmed', NOW()),
('b2', 'p2', 'u3', '2025-08-10', '2025-08-12', 100.00, 'pending', NOW()),
('b3', 'p3', 'u1', '2025-09-15', '2025-09-20', 500.00, 'confirmed', NOW());

-- Insert Payments
INSERT INTO "Payment" (payment_id, booking_id, amount, payment_date, payment_method) VALUES
('pay1', 'b1', 320.00, '2025-06-20', 'credit_card'),
('pay2', 'b3', 500.00, '2025-09-01', 'paypal');

-- Insert Reviews
INSERT INTO "Review" (review_id, property_id, user_id, rating, comment, created_at) VALUES
('r1', 'p1', 'u1', 5, 'Amazing apartment, very clean and great view!', NOW()),
('r2', 'p3', 'u1', 4, 'Cozy cabin, but no Wi-Fi.', NOW()),
('r3', 'p2', 'u3', 3, 'Good location but a bit noisy.', NOW());

-- Insert Messages
INSERT INTO "Message" (message_id, sender_id, recipient_id, message_body, sent_at) VALUES
('m1', 'u1', 'u2', 'Hi, is your apartment available for July?', NOW()),
('m2', 'u2', 'u1', 'Yes, it’s available from July 1–5.', NOW()),
('m3', 'u3', 'u2', 'Can I check in earlier?', NOW()),
('m4', 'u2', 'u3', 'Sure, early check-in is possible.', NOW());
