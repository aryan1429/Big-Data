# Apache HBase Practice Guide

This guide contains HBase commands, concepts, and practice exercises.

## Introduction to HBase

Apache HBase is a distributed, scalable, NoSQL database built on top of Hadoop HDFS. It provides random, real-time read/write access to big data.

## HBase Architecture

- **Region**: Subset of table's rows (horizontal partition)
- **Region Server**: Serves one or more regions
- **Master**: Manages region servers and metadata
- **ZooKeeper**: Coordinates cluster, maintains configuration
- **Column Family**: Group of columns stored together
- **Row Key**: Unique identifier for each row

## Starting HBase

### Start HBase Services
```bash
# Start HBase
start-hbase.sh

# Stop HBase
stop-hbase.sh

# Start HBase shell
hbase shell

# Exit HBase shell
exit
```

## Table Management

### Create Table
```ruby
# Create table with one column family
create 'users', 'personal_info'

# Create table with multiple column families
create 'employees', 'personal', 'professional', 'contact'

# Create with specific properties
create 'logs', 
  {NAME => 'data', VERSIONS => 3, TTL => 604800}

# Create with splits (pre-split for better distribution)
create 'large_table', 'cf', 
  {SPLITS => ['row100', 'row200', 'row300']}

# Create with compression
create 'compressed_table',
  {NAME => 'cf', COMPRESSION => 'SNAPPY'}
```

### List Tables
```ruby
# List all tables
list

# List tables matching pattern
list 'user.*'
```

### Describe Table
```ruby
# Describe table structure
describe 'users'

# Get table status
status 'users'
```

### Disable/Enable Table
```ruby
# Disable table (required before some operations)
disable 'users'

# Enable table
enable 'users'

# Check if table is disabled
is_disabled 'users'

# Check if table is enabled
is_enabled 'users'
```

### Alter Table
```ruby
# Add column family
disable 'users'
alter 'users', 'address'
enable 'users'

# Modify column family properties
disable 'users'
alter 'users', {NAME => 'personal_info', VERSIONS => 5}
enable 'users'

# Delete column family
disable 'users'
alter 'users', {NAME => 'address', METHOD => 'delete'}
enable 'users'

# Set table properties
alter 'users', MAX_FILESIZE => '134217728'
```

### Drop Table
```ruby
# Drop table (must disable first)
disable 'users'
drop 'users'

# Drop all tables matching pattern
disable_all 'test.*'
drop_all 'test.*'
```

### Truncate Table
```ruby
# Truncate table (delete all data)
truncate 'users'

# Preserves splits
truncate_preserve 'users'
```

## Data Operations

### Put (Insert/Update)
```ruby
# Insert single cell
put 'users', 'row1', 'personal_info:name', 'John Doe'

# Insert multiple cells for same row
put 'users', 'row1', 'personal_info:age', '30'
put 'users', 'row1', 'personal_info:email', 'john@example.com'

# Insert with timestamp
put 'users', 'row1', 'personal_info:name', 'John Doe', 1234567890

# Batch puts (more efficient)
put 'users', 'row2', 'personal_info:name', 'Jane Smith'
put 'users', 'row2', 'personal_info:age', '25'
put 'users', 'row2', 'personal_info:email', 'jane@example.com'
```

### Get (Read)
```ruby
# Get entire row
get 'users', 'row1'

# Get specific column
get 'users', 'row1', 'personal_info:name'

# Get specific column family
get 'users', 'row1', {COLUMN => 'personal_info'}

# Get with timestamp
get 'users', 'row1', {COLUMN => 'personal_info:name', TIMESTAMP => 1234567890}

# Get specific versions
get 'users', 'row1', {COLUMN => 'personal_info:name', VERSIONS => 3}

# Get with time range
get 'users', 'row1', {TIMERANGE => [1234567890, 1234567900]}
```

### Scan (Read Multiple Rows)
```ruby
# Scan entire table
scan 'users'

# Scan with limit
scan 'users', {LIMIT => 10}

# Scan specific column family
scan 'users', {COLUMNS => 'personal_info'}

# Scan specific column
scan 'users', {COLUMNS => 'personal_info:name'}

# Scan with row key range
scan 'users', {STARTROW => 'row1', STOPROW => 'row5'}

# Scan with filter
scan 'users', {FILTER => "ValueFilter(=, 'binary:John')"}

# Scan with row prefix filter
scan 'users', {ROWPREFIXFILTER => 'row'}

# Scan with multiple versions
scan 'users', {VERSIONS => 3}

# Scan with time range
scan 'users', {TIMERANGE => [1234567890, 1234567900]}

# Reverse scan
scan 'users', {REVERSED => true}

# Scan with caching (performance)
scan 'users', {CACHE => 1000}
```

### Delete
```ruby
# Delete specific column
delete 'users', 'row1', 'personal_info:age'

# Delete specific column with timestamp
delete 'users', 'row1', 'personal_info:age', 1234567890

# Delete entire row
deleteall 'users', 'row1'

# Delete column family
delete 'users', 'row1', 'personal_info'
```

### Count
```ruby
# Count rows in table
count 'users'

# Count with interval (shows progress)
count 'users', INTERVAL => 1000

# Count with cache
count 'users', CACHE => 1000
```

## Filters

### SingleColumnValueFilter
```ruby
# Filter by column value
scan 'users', {FILTER => 
  "SingleColumnValueFilter('personal_info', 'age', >, 'binary:25')"}
```

### PrefixFilter
```ruby
# Filter by row key prefix
scan 'users', {FILTER => "PrefixFilter('row')"}
```

### RowFilter
```ruby
# Filter rows using comparator
scan 'users', {FILTER => "RowFilter(=, 'substring:row1')"}
```

### ColumnPrefixFilter
```ruby
# Filter columns by prefix
scan 'users', {FILTER => "ColumnPrefixFilter('name')"}
```

### ValueFilter
```ruby
# Filter by cell value
scan 'users', {FILTER => "ValueFilter(=, 'substring:John')"}
```

### FilterList
```ruby
# Combine multiple filters (AND)
scan 'users', {FILTER => 
  "FilterList(MUST_PASS_ALL, 
    SingleColumnValueFilter('personal_info', 'age', >, 'binary:25'),
    ValueFilter(=, 'substring:John'))"}

# Combine multiple filters (OR)
scan 'users', {FILTER => 
  "FilterList(MUST_PASS_ONE,
    PrefixFilter('row1'),
    PrefixFilter('row2'))"}
```

## Advanced Operations

### Versioning
```ruby
# Get all versions of a cell
get 'users', 'row1', {COLUMN => 'personal_info:name', VERSIONS => 10}

# Scan with versions
scan 'users', {VERSIONS => 3}
```

### Counters
```ruby
# Increment counter
incr 'users', 'row1', 'stats:visits', 1

# Get counter value
get_counter 'users', 'row1', 'stats:visits'

# Decrement (use negative value)
incr 'users', 'row1', 'stats:visits', -1
```

### Snapshots
```ruby
# Create snapshot
snapshot 'users', 'users_snapshot_20240101'

# List snapshots
list_snapshots

# Clone from snapshot
clone_snapshot 'users_snapshot_20240101', 'users_clone'

# Restore from snapshot
disable 'users'
restore_snapshot 'users_snapshot_20240101'
enable 'users'

# Delete snapshot
delete_snapshot 'users_snapshot_20240101'
```

## Bulk Loading

### Using ImportTsv
```bash
# Load CSV data into HBase
hbase org.apache.hadoop.hbase.mapreduce.ImportTsv \
  -Dimporttsv.separator=, \
  -Dimporttsv.columns=HBASE_ROW_KEY,personal_info:name,personal_info:age \
  users \
  hdfs:///user/hadoop/input.csv
```

### Using BulkLoad
```bash
# Generate HFiles
hbase org.apache.hadoop.hbase.mapreduce.ImportTsv \
  -Dimporttsv.separator=, \
  -Dimporttsv.columns=HBASE_ROW_KEY,cf:col1,cf:col2 \
  -Dimporttsv.bulk.output=hdfs:///user/hadoop/hfiles \
  tablename \
  hdfs:///user/hadoop/input

# Load HFiles into HBase
hbase org.apache.hadoop.hbase.mapreduce.LoadIncrementalHFiles \
  hdfs:///user/hadoop/hfiles \
  tablename
```

## HBase Java API Example

### Basic Operations
```java
import org.apache.hadoop.hbase.*;
import org.apache.hadoop.hbase.client.*;
import org.apache.hadoop.hbase.util.Bytes;

// Create connection
Configuration config = HBaseConfiguration.create();
Connection connection = ConnectionFactory.createConnection(config);

// Get table
Table table = connection.getTable(TableName.valueOf("users"));

// Put data
Put put = new Put(Bytes.toBytes("row1"));
put.addColumn(Bytes.toBytes("personal_info"), 
              Bytes.toBytes("name"), 
              Bytes.toBytes("John Doe"));
table.put(put);

// Get data
Get get = new Get(Bytes.toBytes("row1"));
Result result = table.get(get);
byte[] value = result.getValue(Bytes.toBytes("personal_info"), 
                               Bytes.toBytes("name"));
System.out.println("Name: " + Bytes.toString(value));

// Scan
Scan scan = new Scan();
ResultScanner scanner = table.getScanner(scan);
for (Result res : scanner) {
    System.out.println("Row: " + Bytes.toString(res.getRow()));
}
scanner.close();

// Delete
Delete delete = new Delete(Bytes.toBytes("row1"));
table.delete(delete);

// Close
table.close();
connection.close();
```

## Performance Tuning

### Table Design
```ruby
# Use short column family names
create 'table', 'd'  # Instead of 'data'

# Use appropriate block size
create 'table', {NAME => 'cf', BLOCKSIZE => '65536'}

# Enable bloom filters
create 'table', {NAME => 'cf', BLOOMFILTER => 'ROW'}

# Set compression
create 'table', {NAME => 'cf', COMPRESSION => 'SNAPPY'}
```

### Region Management
```ruby
# Split region manually
split 'tablename', 'split_point'

# Merge regions
merge_region 'encoded_region_name1', 'encoded_region_name2'

# Move region to different server
move 'encoded_region_name', 'server_name'

# Balance regions
balance_switch true
balancer
```

## Monitoring

### Cluster Status
```ruby
# Overall cluster status
status

# Detailed status
status 'detailed'

# Simple status
status 'simple'
```

### Region Information
```ruby
# List regions for table
list_regions 'tablename'
```

### Server Information
```ruby
# Show cluster servers
list_servers
```

## Practice Exercises

### Exercise 1: Basic CRUD Operations
1. Create a table 'students' with column families 'info' and 'grades'
2. Insert data for 5 students
3. Retrieve data for a specific student
4. Update a student's grade
5. Delete a student record

### Exercise 2: Scanning and Filtering
1. Create a table 'products' with sample data
2. Scan all products
3. Scan products with price > 100 using filter
4. Find products by name prefix
5. Get products in a specific row key range

### Exercise 3: Versioning
1. Create a table with version support
2. Insert multiple versions of the same cell
3. Retrieve all versions
4. Retrieve specific version by timestamp

### Exercise 4: Counters
1. Create a table for page views
2. Increment view counter for different pages
3. Get view counts
4. Reset a counter

### Exercise 5: Bulk Operations
1. Prepare CSV data with 1000+ rows
2. Use ImportTsv to load data
3. Verify data is loaded correctly
4. Create a snapshot of the table

## Common Operations Checklist

```ruby
# Table lifecycle
create 'table', 'cf'
describe 'table'
put 'table', 'row1', 'cf:col', 'value'
get 'table', 'row1'
scan 'table'
delete 'table', 'row1', 'cf:col'
disable 'table'
drop 'table'

# Data operations
put 'table', 'key', 'cf:col', 'value'
get 'table', 'key'
scan 'table', {LIMIT => 10}
deleteall 'table', 'key'
count 'table'
```

## Key Concepts to Remember

1. **Row Key Design** - Most important aspect; determines performance
2. **Column Families** - Group related columns; define early (expensive to change)
3. **Versioning** - HBase keeps multiple versions of each cell
4. **Sparse Storage** - Only stores non-null values efficiently
5. **No Joins** - Denormalize data; HBase doesn't support joins
6. **Sequential Writes** - Writes are fast; reads can be slower
7. **Region Splits** - Tables automatically split as they grow
8. **Filters** - Use server-side filtering to reduce network traffic
9. **Bulk Loading** - Use ImportTsv/BulkLoad for large datasets
10. **Snapshots** - Fast backup/restore mechanism
