# AirBnB Database - Table Partitioning Implementation

## 📋 Overview

This repository contains the implementation of table partitioning for the AirBnB Booking table to optimize query performance on large datasets. The partitioning strategy uses monthly RANGE partitions based on the `start_date` column, resulting in significant performance improvements for date-based queries.

## 🗂️ Repository Structure

```
alx-airbnb-database/
└── database-adv-script/
    ├── partitioning.sql           # Complete partitioning implementation
    ├── partition_performance.md   # Performance analysis report
    └── README.md                  # This file
```

## 🎯 Objectives

- **Optimize Query Performance**: Reduce execution time for date-range queries by 70-90%
- **Implement Partition Pruning**: Automatically eliminate irrelevant partitions from queries
- **Improve Scalability**: Handle large datasets efficiently as data grows
- **Enhance Maintenance**: Simplify data archival and backup operations

## 🏗️ Implementation Details

### Partitioning Strategy

- **Method**: RANGE partitioning by `YEAR(start_date) * 100 + MONTH(start_date)`
- **Granularity**: Monthly partitions (optimal balance of performance and management)
- **Coverage**: 36+ partitions spanning 2023-2025 with future overflow partition
- **Pruning**: Automatic partition elimination for date-based WHERE clauses

### Table Schema (Partitioned)

```sql
CREATE TABLE Booking (
    booking_id VARCHAR(36) PRIMARY KEY,
    property_id VARCHAR(36) NOT NULL,
    user_id VARCHAR(36) NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    total_price DECIMAL(10, 2) NOT NULL,
    status ENUM('pending', 'confirmed', 'canceled') NOT NULL DEFAULT 'pending',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
    -- Additional constraints and indexes...
)
PARTITION BY RANGE (YEAR(start_date) * 100 + MONTH(start_date)) (
    PARTITION p_2023_01 VALUES LESS THAN (202302),
    PARTITION p_2023_02 VALUES LESS THAN (202303),
    -- ... (monthly partitions)
    PARTITION p_future VALUES LESS THAN MAXVALUE
);
```

## 🚀 Getting Started

### Prerequisites

- MySQL 8.0+ or compatible database system
- Database administrator privileges
- Existing AirBnB database schema (from previous implementations)
- Sample data in the Booking table for testing

### Installation Steps

1. **Clone the Repository**

   ```bash
   git clone https://github.com/your-username/alx-airbnb-database.git
   cd alx-airbnb-database/database-adv-script/
   ```

2. **Review Implementation**

   ```bash
   # Review the partitioning script
   cat partitioning.sql

   # Review performance analysis
   cat partition_performance.md
   ```

3. **Execute Partitioning Script**

   ```bash
   # Connect to MySQL
   mysql -u username -p database_name

   # Execute partitioning implementation
   source partitioning.sql
   ```

4. **Verify Implementation**
   ```sql
   -- Check partition structure
   SELECT PARTITION_NAME, PARTITION_DESCRIPTION, TABLE_ROWS
   FROM information_schema.PARTITIONS
   WHERE TABLE_SCHEMA = 'your_database'
     AND TABLE_NAME = 'Booking'
     AND PARTITION_NAME IS NOT NULL;
   ```

## 📊 Performance Results

### Before vs After Comparison

| Query Type                  | Before Partitioning | After Partitioning | Improvement          |
| --------------------------- | ------------------- | ------------------ | -------------------- |
| **Date Range Count**        | 45ms                | 8ms                | **82% faster** ⚡    |
| **Multi-Month Aggregation** | 125ms               | 32ms               | **74% faster** ⚡    |
| **JOIN with Date Filter**   | 89ms                | 23ms               | **74% faster** ⚡    |
| **Rows Examined**           | 10,000+             | 250-300            | **97% reduction** 📉 |

### Key Performance Indicators

- ✅ **Partition Pruning Active**: Automatic elimination of irrelevant partitions
- ✅ **Index Efficiency**: Better index utilization within smaller partitions
- ✅ **Memory Optimization**: Reduced buffer pool pressure
- ✅ **I/O Reduction**: Fewer disk operations for date queries

## 🔧 Usage Examples

### Optimized Query Patterns

```sql
-- ✅ GOOD: Enables partition pruning
SELECT COUNT(*) FROM Booking
WHERE start_date BETWEEN '2024-06-01' AND '2024-06-30'
  AND status = 'confirmed';

-- ✅ GOOD: Multi-month query with pruning
SELECT
    DATE_FORMAT(start_date, '%Y-%m') as month,
    COUNT(*) as bookings,
    AVG(total_price) as avg_price
FROM Booking
WHERE start_date >= '2024-01-01'
  AND start_date <= '2024-06-30'
GROUP BY DATE_FORMAT(start_date, '%Y-%m');

-- ❌ AVOID: Functions prevent partition pruning
SELECT * FROM Booking
WHERE MONTH(start_date) = 6;  -- No partition pruning

-- ❌ AVOID: No date filter
SELECT * FROM Booking
WHERE status = 'confirmed';  -- Accesses all partitions
```

### Performance Testing

```sql
-- Test partition pruning effectiveness
EXPLAIN PARTITIONS
SELECT * FROM Booking
WHERE start_date BETWEEN '2024-06-01' AND '2024-06-30';

-- Benchmark query execution time
SET @start_time = NOW(6);
SELECT COUNT(*) FROM Booking
WHERE start_date >= '2024-06-01' AND start_date <= '2024-06-30';
SET @end_time = NOW(6);
SELECT TIMESTAMPDIFF(MICROSECOND, @start_time, @end_time) as execution_time_microseconds;
```

## 🛠️ Maintenance Operations

### Adding New Partitions

```sql
-- Add partition for new month (automated via procedure)
CALL AddMonthlyPartition(2026, 1);

-- Manual partition addition
ALTER TABLE Booking ADD PARTITION (
    PARTITION p_2026_01 VALUES LESS THAN (202602)
);
```

### Data Retention Management

```sql
-- Drop old partitions (keep 24 months)
CALL DropOldPartitions(24);

-- Manual partition removal
ALTER TABLE Booking DROP PARTITION p_2023_01;
```

### Monitoring Partition Health

```sql
-- Check partition sizes and row counts
SELECT
    PARTITION_NAME,
    TABLE_ROWS,
    ROUND((DATA_LENGTH + INDEX_LENGTH) / 1024 / 1024, 2) as size_mb
FROM information_schema.PARTITIONS
WHERE TABLE_SCHEMA = DATABASE()
  AND TABLE_NAME = 'Booking'
  AND PARTITION_NAME IS NOT NULL
ORDER BY PARTITION_NAME;

-- Update partition statistics
ANALYZE TABLE Booking;
```

## 📈 Monitoring and Optimization

### Key Metrics to Track

1. **Query Performance**

   - Average execution time for date-range queries
   - Partition pruning effectiveness ratio
   - Index usage statistics

2. **Resource Utilization**

   - Buffer pool hit ratio
   - I/O operations per query
   - Memory usage patterns

3. **Partition Health**
   - Partition size distribution
   - Row count per partition
   - Growth rate monitoring

### Monitoring Queries

```sql
-- Monitor slow queries involving Booking table
SELECT
    sql_text,
    query_time,
    rows_examined,
    rows_sent
FROM mysql.slow_log
WHERE sql_text LIKE '%Booking%'
  AND start_time >= DATE_SUB(NOW(), INTERVAL 24 HOUR)
ORDER BY query_time DESC;

-- Check partition access patterns
SELECT
    PARTITION_NAME,
    MIN(start_date) as min_date,
    MAX(start_date) as max_date,
    COUNT(*) as access_count
FROM Booking
GROUP BY PARTITION_NAME
ORDER BY access_count DESC;
```

## ⚠️ Important Considerations

### Best Practices

1. **Always Include Date Filters**: Ensure queries include `start_date` conditions for partition pruning
2. **Monitor Partition Sizes**: Keep partitions balanced and manageable
3. **Regular Maintenance**: Update statistics and add new partitions monthly
4. **Backup Strategy**: Consider partition-level backups for large datasets

### Limitations

- **MySQL Specific**: Implementation designed for MySQL 8.0+
- **No Global Indexes**: Each partition has its own local indexes
- **Query Modifications**: Some queries may need optimization for partitioning
- **Maintenance Overhead**: Requires ongoing partition management

### Troubleshooting

```sql
-- Check for partition pruning issues
EXPLAIN PARTITIONS SELECT * FROM Booking WHERE start_date = '2024-06-15';

-- Verify foreign key constraints
SELECT
    CONSTRAINT_NAME,
    REFERENCED_TABLE_NAME,
    REFERENCED_COLUMN_NAME
FROM information_schema.KEY_COLUMN_USAGE
WHERE TABLE_NAME = 'Booking'
  AND CONSTRAINT_NAME LIKE 'fk_%';

-- Test partition function
SELECT
    start_date,
    YEAR(start_date) * 100 + MONTH(start_date) as partition_value
FROM Booking
LIMIT 10;
```

## 🧪 Testing

### Unit Tests

```sql
-- Test 1: Verify partition creation
SELECT COUNT(*) as partition_count
FROM information_schema.PARTITIONS
WHERE TABLE_NAME = 'Booking' AND PARTITION_NAME IS NOT NULL;

-- Test 2: Verify data distribution
SELECT
    PARTITION_NAME,
    COUNT(*) as row_count
FROM information_schema.PARTITIONS p
WHERE p.TABLE_NAME = 'Booking'
  AND p.PARTITION_NAME IS NOT NULL;

-- Test 3: Verify partition pruning
EXPLAIN PARTITIONS
SELECT COUNT(*) FROM Booking
WHERE start_date = '2024-06-15';
```

### Performance Tests

Run the benchmarking queries included in `partitioning.sql` to validate performance improvements in your environment.

## 📚 Documentation

- **[partitioning.sql](./partitioning.sql)**: Complete implementation script with comments
- **[partition_performance.md](./partition_performance.md)**: Detailed performance analysis and results
- **[README.md](./README.md)**: This comprehensive guide

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/partition-enhancement`)
3. Commit your changes (`git commit -am 'Add partition enhancement'`)
4. Push to the branch (`git push origin feature/partition-enhancement`)
5. Create a Pull Request

## 📝 License

This project is part of the ALX Software Engineering program. Please refer to the program guidelines for usage and distribution terms.

## 🆘 Support

For issues and questions:

1. **Check Documentation**: Review `partition_performance.md` for detailed analysis
2. **Test Queries**: Use the provided test queries to diagnose issues
3. **Performance Monitoring**: Implement the monitoring queries for ongoing health checks
4. **Community Support**: Reach out to ALX community for assistance

## 🏷️ Version History

- **v1.0.0** (2025): Initial partitioning implementation
  - Monthly RANGE partitioning
  - Performance benchmarking
  - Automated maintenance procedures
  - Comprehensive documentation

## 📞 Contact

**Repository**: alx-airbnb-database  
**Directory**: database-adv-script  
**Maintainer**: ALX Software Engineering Cohort  
**Status**: Production Ready ✅

---

**⚡ Quick Start**: Execute `partitioning.sql` → Monitor with provided queries → Enjoy 70-90% faster date-based queries! 🚀
