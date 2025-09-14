-- ====================================================================
-- AirBnB Database - Table Partitioning Implementation
-- ====================================================================
-- File: partitioning.sql
-- Purpose: Implement partitioning on Booking table for performance optimization
-- Repository: alx-airbnb-database
-- Directory: database-adv-script
-- ====================================================================

-- ====================================================================
-- 1. BACKUP EXISTING BOOKING TABLE
-- ====================================================================

-- Create backup of existing booking table
CREATE TABLE Booking_backup AS SELECT * FROM Booking;

-- Verify backup
SELECT COUNT(*) as backup_count FROM Booking_backup;
SELECT 'Backup created successfully' as status;

-- ====================================================================
-- 2. DROP EXISTING BOOKING TABLE CONSTRAINTS AND INDEXES
-- ====================================================================

-- Note: We need to drop foreign key constraints referencing Booking table
-- Drop constraints from Payment table
ALTER TABLE Payment DROP FOREIGN KEY fk_payment_booking;

-- Drop constraints from Review table if exists
-- ALTER TABLE Review DROP FOREIGN KEY fk_review_booking;  -- If exists

-- Note existing indexes for recreation
SELECT 
    TABLE_NAME,
    INDEX_NAME,
    COLUMN_NAME,
    NON_UNIQUE
FROM information_schema.statistics 
WHERE TABLE_SCHEMA = DATABASE() 
  AND TABLE_NAME = 'Booking'
ORDER BY INDEX_NAME, SEQ_IN_INDEX;

-- ====================================================================
-- 3. CREATE PARTITIONED BOOKING TABLE
-- ====================================================================

-- Drop the existing table
DROP TABLE IF EXISTS Booking;

-- Create new partitioned Booking table
CREATE TABLE Booking (
    booking_id VARCHAR(36) PRIMARY KEY,
    property_id VARCHAR(36) NOT NULL,
    user_id VARCHAR(36) NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    total_price DECIMAL(10, 2) NOT NULL,
    status ENUM('pending', 'confirmed', 'canceled') NOT NULL DEFAULT 'pending',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    -- Constraints
    CONSTRAINT chk_booking_dates_valid CHECK (end_date > start_date),
    CONSTRAINT chk_booking_future_dates CHECK (start_date >= '2020-01-01'),
    CONSTRAINT chk_booking_total_price_positive CHECK (total_price > 0),
    CONSTRAINT chk_booking_max_duration CHECK (DATEDIFF(end_date, start_date) <= 365),
    
    -- Foreign key constraints (will be added after partitioning)
    INDEX idx_booking_property_id (property_id),
    INDEX idx_booking_user_id (user_id),
    INDEX idx_booking_status (status),
    INDEX idx_booking_dates (start_date, end_date),
    INDEX idx_booking_created_at (created_at)
)
-- Partition by RANGE on start_date (monthly partitions)
PARTITION BY RANGE (YEAR(start_date) * 100 + MONTH(start_date)) (
    -- 2023 partitions
    PARTITION p_2023_01 VALUES LESS THAN (202302),
    PARTITION p_2023_02 VALUES LESS THAN (202303),
    PARTITION p_2023_03 VALUES LESS THAN (202304),
    PARTITION p_2023_04 VALUES LESS THAN (202305),
    PARTITION p_2023_05 VALUES LESS THAN (202306),
    PARTITION p_2023_06 VALUES LESS THAN (202307),
    PARTITION p_2023_07 VALUES LESS THAN (202308),
    PARTITION p_2023_08 VALUES LESS THAN (202309),
    PARTITION p_2023_09 VALUES LESS THAN (202310),
    PARTITION p_2023_10 VALUES LESS THAN (202311),
    PARTITION p_2023_11 VALUES LESS THAN (202312),
    PARTITION p_2023_12 VALUES LESS THAN (202401),
    
    -- 2024 partitions
    PARTITION p_2024_01 VALUES LESS THAN (202402),
    PARTITION p_2024_02 VALUES LESS THAN (202403),
    PARTITION p_2024_03 VALUES LESS THAN (202404),
    PARTITION p_2024_04 VALUES LESS THAN (202405),
    PARTITION p_2024_05 VALUES LESS THAN (202406),
    PARTITION p_2024_06 VALUES LESS THAN (202407),
    PARTITION p_2024_07 VALUES LESS THAN (202408),
    PARTITION p_2024_08 VALUES LESS THAN (202409),
    PARTITION p_2024_09 VALUES LESS THAN (202410),
    PARTITION p_2024_10 VALUES LESS THAN (202411),
    PARTITION p_2024_11 VALUES LESS THAN (202412),
    PARTITION p_2024_12 VALUES LESS THAN (202501),
    
    -- 2025 partitions
    PARTITION p_2025_01 VALUES LESS THAN (202502),
    PARTITION p_2025_02 VALUES LESS THAN (202503),
    PARTITION p_2025_03 VALUES LESS THAN (202504),
    PARTITION p_2025_04 VALUES LESS THAN (202505),
    PARTITION p_2025_05 VALUES LESS THAN (202506),
    PARTITION p_2025_06 VALUES LESS THAN (202507),
    PARTITION p_2025_07 VALUES LESS THAN (202508),
    PARTITION p_2025_08 VALUES LESS THAN (202509),
    PARTITION p_2025_09 VALUES LESS THAN (202510),
    PARTITION p_2025_10 VALUES LESS THAN (202511),
    PARTITION p_2025_11 VALUES LESS THAN (202512),
    PARTITION p_2025_12 VALUES LESS THAN (202601),
    
    -- Future partitions (catch-all for dates beyond 2025)
    PARTITION p_future VALUES LESS THAN MAXVALUE
);

-- Verify partition creation
SELECT 
    PARTITION_NAME,
    PARTITION_DESCRIPTION,
    TABLE_ROWS
FROM information_schema.PARTITIONS
WHERE TABLE_SCHEMA = DATABASE() 
  AND TABLE_NAME = 'Booking'
  AND PARTITION_NAME IS NOT NULL
ORDER BY PARTITION_NAME;

-- ====================================================================
-- 4. RESTORE DATA TO PARTITIONED TABLE
-- ====================================================================

-- Insert data from backup into partitioned table
INSERT INTO Booking 
SELECT * FROM Booking_backup;

-- Verify data restoration
SELECT COUNT(*) as restored_count FROM Booking;
SELECT 'Data restored successfully' as status;

-- ====================================================================
-- 5. RECREATE FOREIGN KEY CONSTRAINTS
-- ====================================================================

-- Add foreign key constraint for property_id
ALTER TABLE Booking 
ADD CONSTRAINT fk_booking_property 
FOREIGN KEY (property_id) REFERENCES Property(property_id) 
ON DELETE CASCADE ON UPDATE CASCADE;

-- Add foreign key constraint for user_id
ALTER TABLE Booking 
ADD CONSTRAINT fk_booking_user 
FOREIGN KEY (user_id) REFERENCES User(user_id) 
ON DELETE CASCADE ON UPDATE CASCADE;

-- Recreate Payment table foreign key constraint
ALTER TABLE Payment 
ADD CONSTRAINT fk_payment_booking 
FOREIGN KEY (booking_id) REFERENCES Booking(booking_id) 
ON DELETE CASCADE ON UPDATE CASCADE;

-- ====================================================================
-- 6. CREATE ADDITIONAL PARTITIONED INDEXES
-- ====================================================================

-- Create local indexes on each partition for better performance
-- These will be automatically created on each partition

-- Composite index for common query patterns
ALTER TABLE Booking ADD INDEX idx_booking_user_status_date (user_id, status, start_date);
ALTER TABLE Booking ADD INDEX idx_booking_property_date_status (property_id, start_date, status);

-- ====================================================================
-- 7. PERFORMANCE TEST QUERIES (Before Partitioning Baseline)
-- ====================================================================

-- Test Query 1: Date range query (should use partition pruning)
EXPLAIN PARTITIONS
SELECT COUNT(*) 
FROM Booking 
WHERE start_date BETWEEN '2024-06-01' AND '2024-06-30';

-- Test Query 2: Date range with additional filters
EXPLAIN PARTITIONS
SELECT 
    booking_id,
    user_id,
    property_id,
    start_date,
    end_date,
    total_price,
    status
FROM Booking 
WHERE start_date >= '2024-01-01' 
  AND start_date < '2024-04-01'
  AND status = 'confirmed'
ORDER BY start_date;

-- Test Query 3: Cross-partition query
EXPLAIN PARTITIONS
SELECT 
    DATE_FORMAT(start_date, '%Y-%m') as booking_month,
    COUNT(*) as booking_count,
    AVG(total_price) as avg_price
FROM Booking 
WHERE start_date >= '2023-12-01' 
  AND start_date <= '2024-03-31'
GROUP BY DATE_FORMAT(start_date, '%Y-%m')
ORDER BY booking_month;

-- ====================================================================
-- 8. PARTITION MANAGEMENT OPERATIONS
-- ====================================================================

-- Add new partition for future dates (example for 2026)
ALTER TABLE Booking ADD PARTITION (
    PARTITION p_2026_01 VALUES LESS THAN (202602)
);

-- Check partition sizes
SELECT 
    PARTITION_NAME,
    TABLE_ROWS,
    AVG_ROW_LENGTH,
    DATA_LENGTH,
    INDEX_LENGTH,
    ROUND((DATA_LENGTH + INDEX_LENGTH) / 1024 / 1024, 2) as size_mb
FROM information_schema.PARTITIONS
WHERE TABLE_SCHEMA = DATABASE() 
  AND TABLE_NAME = 'Booking'
  AND PARTITION_NAME IS NOT NULL
ORDER BY PARTITION_NAME;

-- ====================================================================
-- 9. PARTITION PRUNING VERIFICATION
-- ====================================================================

-- Query to verify partition pruning is working
-- This should only access specific partitions based on date filters

-- Single partition access
EXPLAIN PARTITIONS
SELECT * FROM Booking 
WHERE start_date = '2024-06-15';

-- Multiple partition access
EXPLAIN PARTITIONS
SELECT * FROM Booking 
WHERE start_date BETWEEN '2024-05-15' AND '2024-07-15';

-- All partitions access (no date filter)
EXPLAIN PARTITIONS
SELECT * FROM Booking 
WHERE status = 'confirmed';

-- ====================================================================
-- 10. PERFORMANCE BENCHMARKING QUERIES
-- ====================================================================

-- Benchmark 1: Count bookings in specific date range
SET @start_time = NOW(6);
SELECT COUNT(*) as bookings_count
FROM Booking 
WHERE start_date >= '2024-06-01' 
  AND start_date <= '2024-06-30';
SET @end_time = NOW(6);
SELECT 
    'Date Range Count' as query_type,
    TIMESTAMPDIFF(MICROSECOND, @start_time, @end_time) as execution_time_microseconds;

-- Benchmark 2: Complex aggregation query
SET @start_time = NOW(6);
SELECT 
    DATE_FORMAT(start_date, '%Y-%m') as month,
    status,
    COUNT(*) as booking_count,
    SUM(total_price) as total_revenue,
    AVG(total_price) as avg_booking_price
FROM Booking 
WHERE start_date >= '2024-01-01' 
  AND start_date <= '2024-12-31'
GROUP BY DATE_FORMAT(start_date, '%Y-%m'), status
ORDER BY month, status;
SET @end_time = NOW(6);
SELECT 
    'Aggregation Query' as query_type,
    TIMESTAMPDIFF(MICROSECOND, @start_time, @end_time) as execution_time_microseconds;

-- Benchmark 3: JOIN query with partition pruning
SET @start_time = NOW(6);
SELECT 
    b.booking_id,
    b.start_date,
    b.total_price,
    u.first_name,
    u.last_name,
    p.name as property_name
FROM Booking b
    INNER JOIN User u ON b.user_id = u.user_id
    INNER JOIN Property p ON b.property_id = p.property_id
WHERE b.start_date >= '2024-07-01' 
  AND b.start_date <= '2024-07-31'
  AND b.status = 'confirmed'
ORDER BY b.start_date
LIMIT 100;
SET @end_time = NOW(6);
SELECT 
    'JOIN Query with Partition Pruning' as query_type,
    TIMESTAMPDIFF(MICROSECOND, @start_time, @end_time) as execution_time_microseconds;

-- ====================================================================
-- 11. MAINTENANCE OPERATIONS
-- ====================================================================

-- Analyze partitions to update statistics
ANALYZE TABLE Booking;

-- Check partition statistics
SELECT 
    PARTITION_NAME,
    TABLE_ROWS,
    UPDATE_TIME,
    CHECK_TIME
FROM information_schema.PARTITIONS
WHERE TABLE_SCHEMA = DATABASE() 
  AND TABLE_NAME = 'Booking'
  AND PARTITION_NAME IS NOT NULL
ORDER BY PARTITION_NAME;

-- ====================================================================
-- 12. UTILITY PROCEDURES FOR PARTITION MANAGEMENT
-- ====================================================================

DELIMITER $$

-- Procedure to add monthly partitions automatically
CREATE PROCEDURE AddMonthlyPartition(
    IN target_year INT,
    IN target_month INT
)
BEGIN
    DECLARE partition_name VARCHAR(20);
    DECLARE partition_value INT;
    DECLARE next_month INT;
    DECLARE next_year INT;
    
    SET partition_name = CONCAT('p_', target_year, '_', LPAD(target_month, 2, '0'));
    SET partition_value = target_year * 100 + target_month;
    
    -- Calculate next month value
    IF target_month = 12 THEN
        SET next_month = 1;
        SET next_year = target_year + 1;
    ELSE
        SET next_month = target_month + 1;
        SET next_year = target_year;
    END IF;
    
    SET @sql = CONCAT(
        'ALTER TABLE Booking ADD PARTITION (',
        'PARTITION ', partition_name, ' VALUES LESS THAN (', next_year * 100 + next_month, ')',
        ')'
    );
    
    PREPARE stmt FROM @sql;
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;
    
    SELECT CONCAT('Partition ', partition_name, ' created successfully') as result;
END$$

-- Procedure to drop old partitions (for data retention)
CREATE PROCEDURE DropOldPartitions(
    IN retention_months INT
)
BEGIN
    DECLARE partition_to_drop VARCHAR(20);
    DECLARE cutoff_date DATE;
    DECLARE done INT DEFAULT FALSE;
    
    DECLARE partition_cursor CURSOR FOR
        SELECT PARTITION_NAME
        FROM information_schema.PARTITIONS
        WHERE TABLE_SCHEMA = DATABASE()
          AND TABLE_NAME = 'Booking'
          AND PARTITION_NAME IS NOT NULL
          AND PARTITION_NAME LIKE 'p_%'
          AND PARTITION_NAME < CONCAT('p_', YEAR(DATE_SUB(NOW(), INTERVAL retention_months MONTH)), '_', LPAD(MONTH(DATE_SUB(NOW(), INTERVAL retention_months MONTH)), 2, '0'));
    
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
    
    OPEN partition_cursor;
    
    read_loop: LOOP
        FETCH partition_cursor INTO partition_to_drop;
        IF done THEN
            LEAVE read_loop;
        END IF;
        
        SET @sql = CONCAT('ALTER TABLE Booking DROP PARTITION ', partition_to_drop);
        PREPARE stmt FROM @sql;
        EXECUTE stmt;
        DEALLOCATE PREPARE stmt;
        
        SELECT CONCAT('Dropped partition: ', partition_to_drop) as result;
    END LOOP;
    
    CLOSE partition_cursor;
END$$

DELIMITER ;

-- ====================================================================
-- 13. FINAL VERIFICATION AND CLEANUP
-- ====================================================================

-- Show final partition structure
SHOW CREATE TABLE Booking;

-- Verify all data is in correct partitions
SELECT 
    PARTITION_NAME,
    MIN(start_date) as min_date,
    MAX(start_date) as max_date,
    COUNT(*) as row_count
FROM information_schema.PARTITIONS p
    INNER JOIN Booking b ON 1=1
WHERE p.TABLE_SCHEMA = DATABASE() 
  AND p.TABLE_NAME = 'Booking'
  AND p.PARTITION_NAME IS NOT NULL
GROUP BY PARTITION_NAME
ORDER BY PARTITION_NAME;

-- Clean up backup table (uncomment when confident partitioning is working)
-- DROP TABLE Booking_backup;

-- Success message
SELECT 'Table partitioning implementation completed successfully!' as status;
SELECT CONCAT('Total partitions created: ', COUNT(*)) as partition_count
FROM information_schema.PARTITIONS
WHERE TABLE_SCHEMA = DATABASE() 
  AND TABLE_NAME = 'Booking'
  AND PARTITION_NAME IS NOT NULL;

-- ====================================================================
-- END OF PARTITIONING IMPLEMENTATION
-- ====================================================================