# Apache Cassandra Practice Guide

This guide contains Cassandra commands, CQL queries, and practice exercises.

## Introduction to Cassandra

Apache Cassandra is a highly scalable, distributed NoSQL database designed to handle large amounts of data across many commodity servers with no single point of failure.

## Cassandra Architecture

- **Node**: Single instance of Cassandra
- **Cluster**: Collection of nodes
- **Datacenter**: Group of related nodes
- **Keyspace**: Top-level namespace (similar to database)
- **Table**: Collection of rows
- **Partition Key**: Determines data distribution
- **Clustering Column**: Determines data ordering within partition
- **Replication Factor**: Number of copies of data

## Starting Cassandra

### Start/Stop Services
```bash
# Start Cassandra
cassandra

# Start in foreground
cassandra -f

# Stop Cassandra
pkill -f CassandraDaemon

# Check status
nodetool status

# Start CQL shell
cqlsh

# Connect to specific host
cqlsh 192.168.1.100 9042

# Exit CQL shell
exit
```

## Keyspace Management

### Create Keyspace
```sql
-- Simple strategy (for single datacenter)
CREATE KEYSPACE my_keyspace
WITH replication = {
    'class': 'SimpleStrategy',
    'replication_factor': 3
};

-- Network topology strategy (for multiple datacenters)
CREATE KEYSPACE production
WITH replication = {
    'class': 'NetworkTopologyStrategy',
    'datacenter1': 3,
    'datacenter2': 2
};

-- With durable writes
CREATE KEYSPACE my_keyspace
WITH replication = {
    'class': 'SimpleStrategy',
    'replication_factor': 3
}
AND durable_writes = true;
```

### Alter Keyspace
```sql
-- Change replication factor
ALTER KEYSPACE my_keyspace
WITH replication = {
    'class': 'SimpleStrategy',
    'replication_factor': 2
};

-- Disable durable writes (not recommended for production)
ALTER KEYSPACE my_keyspace
WITH durable_writes = false;
```

### Drop Keyspace
```sql
-- Drop keyspace (deletes all data)
DROP KEYSPACE my_keyspace;

-- Drop if exists
DROP KEYSPACE IF EXISTS my_keyspace;
```

### List and Describe
```sql
-- List all keyspaces
DESCRIBE KEYSPACES;

-- Describe specific keyspace
DESCRIBE KEYSPACE my_keyspace;

-- Use keyspace
USE my_keyspace;
```

## Table Management

### Create Table
```sql
-- Basic table
CREATE TABLE users (
    user_id UUID PRIMARY KEY,
    username TEXT,
    email TEXT,
    created_at TIMESTAMP
);

-- Composite primary key
CREATE TABLE posts (
    user_id UUID,
    post_id TIMEUUID,
    title TEXT,
    content TEXT,
    PRIMARY KEY (user_id, post_id)
);

-- Multiple clustering columns
CREATE TABLE events (
    sensor_id INT,
    year INT,
    month INT,
    day INT,
    event_time TIMESTAMP,
    temperature FLOAT,
    PRIMARY KEY ((sensor_id), year, month, day, event_time)
);

-- With clustering order
CREATE TABLE messages (
    user_id UUID,
    message_id TIMEUUID,
    message TEXT,
    PRIMARY KEY (user_id, message_id)
) WITH CLUSTERING ORDER BY (message_id DESC);

-- With table properties
CREATE TABLE logs (
    id UUID PRIMARY KEY,
    log_level TEXT,
    message TEXT,
    timestamp TIMESTAMP
) WITH gc_grace_seconds = 86400
AND compaction = {
    'class': 'LeveledCompactionStrategy'
};
```

### Alter Table
```sql
-- Add column
ALTER TABLE users ADD phone TEXT;

-- Drop column
ALTER TABLE users DROP phone;

-- Rename column
ALTER TABLE users RENAME username TO user_name;

-- Change table properties
ALTER TABLE users WITH gc_grace_seconds = 172800;
```

### Drop Table
```sql
-- Drop table
DROP TABLE users;

-- Drop if exists
DROP TABLE IF EXISTS users;
```

### Describe Table
```sql
-- Describe table structure
DESCRIBE TABLE users;

-- List all tables
DESCRIBE TABLES;
```

## Data Operations

### Insert
```sql
-- Insert row
INSERT INTO users (user_id, username, email, created_at)
VALUES (uuid(), 'john_doe', 'john@example.com', toTimestamp(now()));

-- Insert with TTL (Time To Live in seconds)
INSERT INTO users (user_id, username, email)
VALUES (uuid(), 'jane_smith', 'jane@example.com')
USING TTL 86400;

-- Insert with timestamp
INSERT INTO users (user_id, username)
VALUES (uuid(), 'bob')
USING TIMESTAMP 1234567890;
```

### Update
```sql
-- Update row
UPDATE users
SET email = 'newemail@example.com'
WHERE user_id = 550e8400-e29b-41d4-a716-446655440000;

-- Update with TTL
UPDATE users USING TTL 3600
SET email = 'temp@example.com'
WHERE user_id = 550e8400-e29b-41d4-a716-446655440000;

-- Update multiple columns
UPDATE users
SET email = 'new@example.com', username = 'new_name'
WHERE user_id = 550e8400-e29b-41d4-a716-446655440000;

-- Increment counter
UPDATE page_views
SET views = views + 1
WHERE page_id = 'homepage';
```

### Select
```sql
-- Select all
SELECT * FROM users;

-- Select specific columns
SELECT user_id, username FROM users;

-- Select with WHERE clause
SELECT * FROM users
WHERE user_id = 550e8400-e29b-41d4-a716-446655440000;

-- Select with multiple conditions (partition + clustering)
SELECT * FROM posts
WHERE user_id = 550e8400-e29b-41d4-a716-446655440000
AND post_id > minTimeuuid('2024-01-01 00:00:00+0000');

-- Select with LIMIT
SELECT * FROM users LIMIT 10;

-- Select with ORDER BY (only on clustering columns)
SELECT * FROM posts
WHERE user_id = 550e8400-e29b-41d4-a716-446655440000
ORDER BY post_id DESC;

-- Select with ALLOW FILTERING (use cautiously)
SELECT * FROM users
WHERE email = 'john@example.com'
ALLOW FILTERING;
```

### Delete
```sql
-- Delete entire row
DELETE FROM users
WHERE user_id = 550e8400-e29b-41d4-a716-446655440000;

-- Delete specific column
DELETE email FROM users
WHERE user_id = 550e8400-e29b-41d4-a716-446655440000;

-- Delete with timestamp
DELETE FROM users
USING TIMESTAMP 1234567890
WHERE user_id = 550e8400-e29b-41d4-a716-446655440000;

-- Delete rows matching clustering key
DELETE FROM posts
WHERE user_id = 550e8400-e29b-41d4-a716-446655440000
AND post_id < minTimeuuid('2024-01-01 00:00:00+0000');
```

### Batch Operations
```sql
-- Batch insert/update
BEGIN BATCH
    INSERT INTO users (user_id, username, email)
    VALUES (uuid(), 'user1', 'user1@example.com');
    
    INSERT INTO users (user_id, username, email)
    VALUES (uuid(), 'user2', 'user2@example.com');
    
    UPDATE users SET email = 'updated@example.com'
    WHERE user_id = 550e8400-e29b-41d4-a716-446655440000;
APPLY BATCH;

-- Batch with timestamp
BEGIN BATCH USING TIMESTAMP 1234567890
    INSERT INTO users (user_id, username) VALUES (uuid(), 'user1');
    INSERT INTO users (user_id, username) VALUES (uuid(), 'user2');
APPLY BATCH;
```

## Data Types

### Primitive Types
```sql
-- Common data types
CREATE TABLE data_types (
    id UUID PRIMARY KEY,
    text_col TEXT,
    varchar_col VARCHAR,
    int_col INT,
    bigint_col BIGINT,
    float_col FLOAT,
    double_col DOUBLE,
    decimal_col DECIMAL,
    boolean_col BOOLEAN,
    timestamp_col TIMESTAMP,
    date_col DATE,
    time_col TIME,
    uuid_col UUID,
    timeuuid_col TIMEUUID,
    blob_col BLOB,
    inet_col INET
);
```

### Collection Types
```sql
-- List (ordered)
CREATE TABLE users_with_list (
    user_id UUID PRIMARY KEY,
    emails LIST<TEXT>,
    phone_numbers LIST<TEXT>
);

INSERT INTO users_with_list (user_id, emails)
VALUES (uuid(), ['email1@example.com', 'email2@example.com']);

-- Update list
UPDATE users_with_list
SET emails = emails + ['newemail@example.com']
WHERE user_id = 550e8400-e29b-41d4-a716-446655440000;

-- Set (unordered, unique)
CREATE TABLE users_with_set (
    user_id UUID PRIMARY KEY,
    tags SET<TEXT>
);

INSERT INTO users_with_set (user_id, tags)
VALUES (uuid(), {'tag1', 'tag2', 'tag3'});

-- Map (key-value pairs)
CREATE TABLE users_with_map (
    user_id UUID PRIMARY KEY,
    settings MAP<TEXT, TEXT>
);

INSERT INTO users_with_map (user_id, settings)
VALUES (uuid(), {'theme': 'dark', 'language': 'en'});

-- Update map
UPDATE users_with_map
SET settings['notifications'] = 'enabled'
WHERE user_id = 550e8400-e29b-41d4-a716-446655440000;
```

### User-Defined Types (UDT)
```sql
-- Create UDT
CREATE TYPE address (
    street TEXT,
    city TEXT,
    state TEXT,
    zip_code TEXT
);

-- Use UDT in table
CREATE TABLE users_with_address (
    user_id UUID PRIMARY KEY,
    name TEXT,
    home_address FROZEN<address>
);

-- Insert with UDT
INSERT INTO users_with_address (user_id, name, home_address)
VALUES (uuid(), 'John Doe', {
    street: '123 Main St',
    city: 'New York',
    state: 'NY',
    zip_code: '10001'
});
```

## Indexing

### Secondary Index
```sql
-- Create secondary index
CREATE INDEX ON users (email);

-- Create index with name
CREATE INDEX user_email_idx ON users (email);

-- Create index on collection
CREATE INDEX ON users (VALUES(tags));

-- Drop index
DROP INDEX user_email_idx;
```

### Materialized View
```sql
-- Create materialized view
CREATE MATERIALIZED VIEW users_by_email AS
SELECT user_id, username, email
FROM users
WHERE email IS NOT NULL AND user_id IS NOT NULL
PRIMARY KEY (email, user_id);

-- Query materialized view
SELECT * FROM users_by_email
WHERE email = 'john@example.com';

-- Drop materialized view
DROP MATERIALIZED VIEW users_by_email;
```

## Counters

### Counter Table
```sql
-- Create counter table
CREATE TABLE page_views (
    page_id TEXT PRIMARY KEY,
    views COUNTER
);

-- Increment counter
UPDATE page_views
SET views = views + 1
WHERE page_id = 'homepage';

-- Decrement counter
UPDATE page_views
SET views = views - 1
WHERE page_id = 'homepage';

-- Read counter
SELECT * FROM page_views WHERE page_id = 'homepage';
```

## Time-To-Live (TTL)

```sql
-- Insert with TTL
INSERT INTO users (user_id, username, email)
VALUES (uuid(), 'temp_user', 'temp@example.com')
USING TTL 3600;  -- Expires in 1 hour

-- Update with TTL
UPDATE users USING TTL 86400
SET email = 'temp@example.com'
WHERE user_id = 550e8400-e29b-41d4-a716-446655440000;

-- Check TTL
SELECT TTL(email) FROM users
WHERE user_id = 550e8400-e29b-41d4-a716-446655440000;
```

## Functions

### Aggregate Functions
```sql
-- Count
SELECT COUNT(*) FROM users;

-- Min/Max (on clustering columns)
SELECT MIN(post_id), MAX(post_id) FROM posts
WHERE user_id = 550e8400-e29b-41d4-a716-446655440000;

-- Avg/Sum
SELECT AVG(temperature), SUM(temperature) FROM sensor_data
WHERE sensor_id = 1;
```

### UUID Functions
```sql
-- Generate UUID
INSERT INTO users (user_id, username)
VALUES (uuid(), 'new_user');

-- Generate TimeUUID
INSERT INTO events (event_id, description)
VALUES (now(), 'Event description');

-- Convert TimeUUID to timestamp
SELECT dateOf(event_id) FROM events;

-- Generate TimeUUID for specific time
SELECT minTimeuuid('2024-01-01 00:00:00+0000');
SELECT maxTimeuuid('2024-12-31 23:59:59+0000');
```

### Token Function
```sql
-- Query by token range
SELECT * FROM users
WHERE token(user_id) > token(550e8400-e29b-41d4-a716-446655440000);
```

## NodetTool Commands

### Cluster Management
```bash
# Check cluster status
nodetool status

# Get cluster info
nodetool info

# Get cluster ring information
nodetool ring

# Describe cluster
nodetool describecluster
```

### Data Management
```bash
# Flush memtables to disk
nodetool flush

# Repair data
nodetool repair

# Compact data
nodetool compact

# Cleanup after scaling
nodetool cleanup

# Scrub (validate and rebuild) data
nodetool scrub
```

### Performance
```bash
# Get table statistics
nodetool tablestats my_keyspace.users

# Get compaction statistics
nodetool compactionstats

# Get cache statistics
nodetool info

# Set compaction throughput (MB/s)
nodetool setcompactionthroughput 16

# Set stream throughput (MB/s)
nodetool setstreamthroughput 200
```

### Snapshots
```bash
# Create snapshot
nodetool snapshot my_keyspace -t snapshot_name

# List snapshots
nodetool listsnapshots

# Clear snapshot
nodetool clearsnapshot -t snapshot_name my_keyspace
```

### Node Operations
```bash
# Drain node (stop writes, flush data)
nodetool drain

# Stop node
nodetool stopdaemon

# Decommission node
nodetool decommission

# Remove dead node
nodetool removenode <node_id>

# Rebuild node
nodetool rebuild
```

## Python Driver (cassandra-driver)

### Basic Operations
```python
from cassandra.cluster import Cluster
from cassandra.auth import PlainTextAuthProvider
import uuid

# Connect to cluster
cluster = Cluster(['127.0.0.1'])
session = cluster.connect()

# Use keyspace
session.set_keyspace('my_keyspace')

# Or connect directly to keyspace
session = cluster.connect('my_keyspace')

# Insert data
user_id = uuid.uuid4()
session.execute("""
    INSERT INTO users (user_id, username, email)
    VALUES (%s, %s, %s)
""", (user_id, 'john_doe', 'john@example.com'))

# Select data
rows = session.execute("SELECT * FROM users WHERE user_id = %s", (user_id,))
for row in rows:
    print(row.username, row.email)

# Prepared statements (better performance)
prepared = session.prepare("""
    INSERT INTO users (user_id, username, email)
    VALUES (?, ?, ?)
""")
session.execute(prepared, (uuid.uuid4(), 'jane', 'jane@example.com'))

# Close connection
cluster.shutdown()
```

### Async Operations
```python
from cassandra.cluster import Cluster

cluster = Cluster(['127.0.0.1'])
session = cluster.connect('my_keyspace')

# Async execute
future = session.execute_async("SELECT * FROM users")

# Add callbacks
def handle_success(rows):
    for row in rows:
        print(row)

def handle_error(exception):
    print(f"Error: {exception}")

future.add_callback(handle_success)
future.add_errback(handle_error)

# Or wait for result
rows = future.result()
```

## Practice Exercises

### Exercise 1: Basic Schema Design
1. Create a keyspace with replication factor 3
2. Create a users table with appropriate primary key
3. Insert 10 users
4. Query users by different criteria
5. Update and delete users

### Exercise 2: Time-Series Data
1. Design a table for sensor data (sensor_id, timestamp, temperature)
2. Use appropriate partition and clustering keys
3. Insert sample time-series data
4. Query data for specific sensor and time range
5. Calculate average temperature per sensor

### Exercise 3: Collections
1. Create a table with list, set, and map columns
2. Insert data with collections
3. Update collections (add/remove elements)
4. Query and display collection data

### Exercise 4: Counters
1. Create a counter table for page views
2. Increment counters for different pages
3. Query counter values
4. Demonstrate counter updates from multiple clients

### Exercise 5: Materialized Views
1. Create a base table for products
2. Create a materialized view to query by category
3. Insert products
4. Query both base table and materialized view
5. Observe automatic updates

## Best Practices

### Data Modeling
1. **Partition key**: Determines data distribution
2. **Clustering columns**: Determine sort order within partition
3. **Denormalization**: Duplicate data for query efficiency
4. **One query per table**: Design tables for specific queries
5. **Avoid ALLOW FILTERING**: Indicates poor data model

### Performance
1. **Limit partition size**: Keep partitions under 100MB
2. **Use prepared statements**: Better performance and security
3. **Batch wisely**: Only batch operations for same partition
4. **Set appropriate TTL**: Automatic data expiration
5. **Monitor with nodetool**: Regular cluster health checks

## Key Concepts to Remember

1. **No Joins**: Cassandra doesn't support joins - denormalize data
2. **Partition Key**: Critical for data distribution and query performance
3. **Clustering Columns**: Define sort order within partitions
4. **Eventual Consistency**: Writes succeed quickly; reads may lag
5. **Tunable Consistency**: Control consistency vs. performance trade-off
6. **Write Optimized**: Writes are very fast; reads can be slower
7. **No Foreign Keys**: No referential integrity constraints
8. **Collections**: Use for small sets of data only
9. **TTL**: Automatic data expiration
10. **Token Ring**: Data distributed based on token hash
