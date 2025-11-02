-- Cassandra CQL (Cassandra Query Language) Examples

-- Keyspace management
CREATE KEYSPACE IF NOT EXISTS ecommerce
WITH replication = {
    'class': 'SimpleStrategy',
    'replication_factor': 3
};

-- For production with multiple data centers
CREATE KEYSPACE IF NOT EXISTS ecommerce_prod
WITH replication = {
    'class': 'NetworkTopologyStrategy',
    'datacenter1': 3,
    'datacenter2': 2
};

USE ecommerce;

-- Basic table creation
CREATE TABLE IF NOT EXISTS users (
    user_id UUID PRIMARY KEY,
    username TEXT,
    email TEXT,
    first_name TEXT,
    last_name TEXT,
    created_at TIMESTAMP,
    last_login TIMESTAMP,
    is_active BOOLEAN
);

-- Table with clustering columns for time-series data
CREATE TABLE IF NOT EXISTS user_sessions (
    user_id UUID,
    session_id UUID,
    start_time TIMESTAMP,
    end_time TIMESTAMP,
    ip_address INET,
    user_agent TEXT,
    page_views COUNTER,
    PRIMARY KEY (user_id, start_time)
) WITH CLUSTERING ORDER BY (start_time DESC);

-- Table with composite partition key
CREATE TABLE IF NOT EXISTS orders (
    user_id UUID,
    order_date DATE,
    order_id UUID,
    status TEXT,
    total_amount DECIMAL,
    items LIST<TEXT>,
    shipping_address MAP<TEXT, TEXT>,
    tags SET<TEXT>,
    PRIMARY KEY ((user_id, order_date), order_id)
) WITH CLUSTERING ORDER BY (order_id DESC);

-- Product catalog with collections
CREATE TABLE IF NOT EXISTS products (
    product_id UUID PRIMARY KEY,
    name TEXT,
    description TEXT,
    price DECIMAL,
    category TEXT,
    tags SET<TEXT>,
    specifications MAP<TEXT, TEXT>,
    images LIST<TEXT>,
    created_at TIMESTAMP,
    updated_at TIMESTAMP
);

-- Time-series data for analytics
CREATE TABLE IF NOT EXISTS user_events (
    user_id UUID,
    event_time TIMESTAMP,
    event_id UUID,
    event_type TEXT,
    event_data MAP<TEXT, TEXT>,
    PRIMARY KEY (user_id, event_time, event_id)
) WITH CLUSTERING ORDER BY (event_time DESC, event_id ASC);

-- Insert operations
INSERT INTO users (user_id, username, email, first_name, last_name, created_at, is_active)
VALUES (uuid(), 'john_doe', 'john@example.com', 'John', 'Doe', toTimestamp(now()), true);

INSERT INTO users (user_id, username, email, first_name, last_name, created_at, is_active)
VALUES (550e8400-e29b-41d4-a716-446655440000, 'jane_smith', 'jane@example.com', 'Jane', 'Smith', '2023-01-15 10:30:00', true);

-- Insert with TTL (Time To Live)
INSERT INTO user_sessions (user_id, session_id, start_time, ip_address, user_agent)
VALUES (550e8400-e29b-41d4-a716-446655440000, uuid(), toTimestamp(now()), '192.168.1.100', 'Mozilla/5.0')
USING TTL 86400; -- 24 hours

-- Update operations
UPDATE users SET last_login = toTimestamp(now()) 
WHERE user_id = 550e8400-e29b-41d4-a716-446655440000;

-- Update collections
UPDATE products SET tags = tags + {'electronics', 'smartphone'} 
WHERE product_id = 123e4567-e89b-12d3-a456-426614174000;

UPDATE products SET specifications['color'] = 'black' 
WHERE product_id = 123e4567-e89b-12d3-a456-426614174000;

-- Counter updates
UPDATE user_sessions SET page_views = page_views + 1 
WHERE user_id = 550e8400-e29b-41d4-a716-446655440000 
AND start_time = '2023-12-01 10:00:00';

-- Basic select queries
SELECT * FROM users;

SELECT username, email, last_login FROM users 
WHERE user_id = 550e8400-e29b-41d4-a716-446655440000;

-- Time-based queries (efficient with clustering)
SELECT * FROM user_sessions 
WHERE user_id = 550e8400-e29b-41d4-a716-446655440000 
AND start_time >= '2023-12-01' 
AND start_time < '2023-12-02';

-- Range queries on clustering columns
SELECT * FROM orders 
WHERE user_id = 550e8400-e29b-41d4-a716-446655440000 
AND order_date = '2023-12-01'
AND order_id > 123e4567-e89b-12d3-a456-426614174000;

-- Collection operations
SELECT name, tags FROM products 
WHERE product_id = 123e4567-e89b-12d3-a456-426614174000;

-- Filtering (requires ALLOW FILTERING - use carefully)
SELECT * FROM users WHERE is_active = true ALLOW FILTERING;

-- Pagination with token
SELECT * FROM users WHERE TOKEN(user_id) > TOKEN(550e8400-e29b-41d4-a716-446655440000);

-- Aggregation functions (limited support)
SELECT COUNT(*) FROM users;

-- Batch operations
BEGIN BATCH
    INSERT INTO users (user_id, username, email, created_at, is_active)
    VALUES (uuid(), 'user1', 'user1@example.com', toTimestamp(now()), true);
    
    INSERT INTO products (product_id, name, price, created_at)
    VALUES (uuid(), 'Product 1', 99.99, toTimestamp(now()));
    
    UPDATE users SET last_login = toTimestamp(now()) 
    WHERE user_id = 550e8400-e29b-41d4-a716-446655440000;
APPLY BATCH;

-- Conditional updates (Lightweight Transactions)
UPDATE users SET email = 'newemail@example.com' 
WHERE user_id = 550e8400-e29b-41d4-a716-446655440000 
IF email = 'oldemail@example.com';

INSERT INTO users (user_id, username, email, created_at, is_active)
VALUES (uuid(), 'unique_user', 'unique@example.com', toTimestamp(now()), true)
IF NOT EXISTS;

-- Delete operations
DELETE FROM users WHERE user_id = 550e8400-e29b-41d4-a716-446655440000;

DELETE email FROM users WHERE user_id = 550e8400-e29b-41d4-a716-446655440000;

-- Delete from collections
UPDATE products SET tags = tags - {'old_tag'} 
WHERE product_id = 123e4567-e89b-12d3-a456-426614174000;

-- Schema modifications
ALTER TABLE users ADD phone TEXT;
ALTER TABLE users DROP phone;

-- Secondary indexes (use sparingly)
CREATE INDEX ON users (email);
CREATE INDEX ON products (category);

-- Drop index
DROP INDEX users_email_idx;

-- Materialized views (Cassandra 3.0+)
CREATE MATERIALIZED VIEW users_by_email AS
    SELECT user_id, username, email, created_at
    FROM users
    WHERE email IS NOT NULL AND user_id IS NOT NULL
    PRIMARY KEY (email, user_id);

-- User-defined types
CREATE TYPE address (
    street TEXT,
    city TEXT,
    state TEXT,
    zip_code TEXT,
    country TEXT
);

CREATE TABLE user_profiles (
    user_id UUID PRIMARY KEY,
    home_address address,
    work_address address
);

-- Working with JSON (Cassandra 2.2+)
CREATE TABLE user_preferences (
    user_id UUID PRIMARY KEY,
    settings TEXT -- JSON data
);

INSERT INTO user_preferences (user_id, settings)
VALUES (uuid(), '{"theme": "dark", "notifications": {"email": true, "sms": false}}');

-- Table and keyspace information
DESCRIBE KEYSPACE ecommerce;
DESCRIBE TABLE users;
DESCRIBE MATERIALIZED VIEW users_by_email;

-- Cleanup
DROP MATERIALIZED VIEW IF EXISTS users_by_email;
DROP TABLE IF EXISTS users;
DROP KEYSPACE IF EXISTS ecommerce;