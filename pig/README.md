# Pig Latin Practice Guide

This guide contains Pig Latin scripts, commands, and practice exercises.

## Introduction to Pig

Apache Pig is a platform for analyzing large datasets using a high-level scripting language called Pig Latin. It provides an abstraction over MapReduce.

## Basic Pig Latin Syntax

### Starting Pig

```bash
# Start Pig in local mode
pig -x local

# Start Pig in MapReduce mode
pig -x mapreduce

# Execute Pig script
pig -x mapreduce myscript.pig

# Execute with parameters
pig -x mapreduce -param input=/data/input -param output=/data/output script.pig
```

## Data Types

### Scalar Types
```pig
-- int: 32-bit signed integer
-- long: 64-bit signed integer
-- float: 32-bit floating point
-- double: 64-bit floating point
-- chararray: String (UTF-8)
-- bytearray: Blob
-- boolean: true/false
-- datetime: Date and time
```

### Complex Types
```pig
-- tuple: Ordered set of fields (row)
-- bag: Collection of tuples (table)
-- map: Set of key-value pairs
```

## Loading and Storing Data

### LOAD Statement
```pig
-- Load CSV file
data = LOAD '/user/hadoop/input.csv' 
    USING PigStorage(',') 
    AS (id:int, name:chararray, age:int, salary:double);

-- Load with custom delimiter
data = LOAD '/user/hadoop/data.txt' 
    USING PigStorage('\t') 
    AS (field1, field2, field3);

-- Load without schema
rawdata = LOAD '/user/hadoop/raw.txt';

-- Load JSON
jsondata = LOAD '/user/hadoop/data.json' 
    USING JsonLoader('id:int, name:chararray, tags:{(tag:chararray)}');
```

### STORE Statement
```pig
-- Store data to HDFS
STORE result INTO '/user/hadoop/output' 
    USING PigStorage(',');

-- Store as plain text
STORE result INTO '/user/hadoop/output' 
    USING PigStorage('\t');

-- Store as JSON
STORE result INTO '/user/hadoop/output' 
    USING JsonStorage();
```

## Data Transformation Operations

### FILTER
```pig
-- Filter records
young_employees = FILTER employees BY age < 30;

-- Multiple conditions
filtered = FILTER data BY (age > 25 AND age < 40) OR salary > 50000;

-- NULL check
non_null = FILTER data BY name IS NOT NULL;

-- Pattern matching
matched = FILTER data BY name MATCHES '.*Smith.*';
```

### FOREACH
```pig
-- Project specific fields
names = FOREACH employees GENERATE name, age;

-- Add computed fields
transformed = FOREACH employees GENERATE 
    name, 
    age, 
    salary * 12 AS annual_salary;

-- Nested FOREACH
result = FOREACH grouped {
    sorted = ORDER group BY age DESC;
    top3 = LIMIT sorted 3;
    GENERATE group, top3;
};
```

### GROUP
```pig
-- Group by single field
by_dept = GROUP employees BY department;

-- Group by multiple fields
by_dept_age = GROUP employees BY (department, age);

-- Group all records
all_grouped = GROUP employees ALL;

-- Result structure after GROUP:
-- (group_key, {bag of original records})
```

### JOIN
```pig
-- Inner join
result = JOIN employees BY dept_id, departments BY id;

-- Left outer join
result = JOIN employees BY dept_id LEFT OUTER, departments BY id;

-- Right outer join
result = JOIN employees BY dept_id RIGHT OUTER, departments BY id;

-- Full outer join
result = JOIN employees BY dept_id FULL OUTER, departments BY id;

-- Self join
result = JOIN data1 BY key, data2 BY key;
```

### COGROUP
```pig
-- CoGroup two relations
cogrouped = COGROUP employees BY dept_id, departments BY id;

-- Result structure:
-- (group_key, {bag of employees}, {bag of departments})
```

### UNION
```pig
-- Combine two relations
combined = UNION relation1, relation2;

-- Union multiple relations
all_data = UNION data1, data2, data3;
```

### DISTINCT
```pig
-- Remove duplicates
unique_names = DISTINCT employees.name;

-- Remove duplicate records
unique_records = DISTINCT employees;
```

### ORDER BY
```pig
-- Sort ascending
sorted = ORDER employees BY age ASC;

-- Sort descending
sorted = ORDER employees BY salary DESC;

-- Sort by multiple fields
sorted = ORDER employees BY department ASC, salary DESC;
```

### LIMIT
```pig
-- Get first N records
top10 = LIMIT employees 10;

-- After sorting
top_earners = ORDER employees BY salary DESC;
top5 = LIMIT top_earners 5;
```

### SAMPLE
```pig
-- Random sample (10%)
sample_data = SAMPLE employees 0.1;
```

### SPLIT
```pig
-- Split into multiple relations
SPLIT employees INTO 
    young IF age < 30,
    middle IF age >= 30 AND age < 50,
    senior IF age >= 50;
```

## Aggregate Functions

### Common Aggregates
```pig
-- Group and aggregate
dept_stats = GROUP employees BY department;
result = FOREACH dept_stats GENERATE 
    group AS department,
    COUNT(employees) AS emp_count,
    AVG(employees.salary) AS avg_salary,
    SUM(employees.salary) AS total_salary,
    MIN(employees.salary) AS min_salary,
    MAX(employees.salary) AS max_salary;
```

### Other Aggregate Functions
```pig
-- String concatenation
concat_result = FOREACH grouped GENERATE 
    BagToString(employees.name, ',');

-- Count distinct
unique_count = FOREACH grouped GENERATE 
    COUNT(DISTINCT employees.department);
```

## User Defined Functions (UDFs)

### Built-in Functions

#### String Functions
```pig
-- Upper/Lower case
upper_names = FOREACH employees GENERATE UPPER(name);
lower_names = FOREACH employees GENERATE LOWER(name);

-- Substring
sub = FOREACH data GENERATE SUBSTRING(name, 0, 3);

-- Trim
trimmed = FOREACH data GENERATE TRIM(name);

-- String length
lengths = FOREACH data GENERATE SIZE(name);

-- Replace
replaced = FOREACH data GENERATE REPLACE(name, 'old', 'new');

-- Split string
tokens = FOREACH data GENERATE STRSPLIT(name, ' ');
```

#### Math Functions
```pig
-- Basic math
result = FOREACH data GENERATE 
    ABS(value),
    CEIL(value),
    FLOOR(value),
    ROUND(value),
    SQRT(value);
```

#### Date Functions
```pig
-- Current time
current = FOREACH data GENERATE CurrentTime();

-- Date operations
formatted = FOREACH data GENERATE 
    ToString(date, 'yyyy-MM-dd');
```

### Register and Use Custom UDF
```pig
-- Register JAR
REGISTER '/path/to/myudf.jar';

-- Define alias for UDF
DEFINE MyUDF com.example.MyUDF();

-- Use UDF
result = FOREACH data GENERATE MyUDF(field1, field2);
```

## Complete Examples

### Example 1: Word Count
```pig
-- Load text file
lines = LOAD '/user/hadoop/input.txt' AS (line:chararray);

-- Tokenize
words = FOREACH lines GENERATE FLATTEN(TOKENIZE(line)) AS word;

-- Group by word
grouped = GROUP words BY word;

-- Count
word_count = FOREACH grouped GENERATE 
    group AS word, 
    COUNT(words) AS count;

-- Sort by count
sorted = ORDER word_count BY count DESC;

-- Store result
STORE sorted INTO '/user/hadoop/wordcount_output' USING PigStorage('\t');
```

### Example 2: Log Analysis
```pig
-- Load log data
logs = LOAD '/user/hadoop/logs/*.log' 
    USING PigStorage(' ') 
    AS (ip:chararray, timestamp:chararray, method:chararray, 
        url:chararray, status:int, size:int);

-- Filter successful requests
success = FILTER logs BY status == 200;

-- Group by IP
by_ip = GROUP success BY ip;

-- Count requests per IP
ip_counts = FOREACH by_ip GENERATE 
    group AS ip, 
    COUNT(success) AS request_count,
    SUM(success.size) AS total_bytes;

-- Sort by request count
sorted = ORDER ip_counts BY request_count DESC;

-- Get top 10
top10 = LIMIT sorted 10;

-- Store result
STORE top10 INTO '/user/hadoop/top_ips';
```

### Example 3: Sales Analysis
```pig
-- Load sales data
sales = LOAD '/user/hadoop/sales.csv' 
    USING PigStorage(',') 
    AS (order_id:int, product:chararray, category:chararray, 
        quantity:int, price:double, date:chararray);

-- Calculate revenue
sales_revenue = FOREACH sales GENERATE 
    product, 
    category, 
    quantity, 
    price, 
    quantity * price AS revenue;

-- Group by category
by_category = GROUP sales_revenue BY category;

-- Aggregate by category
category_stats = FOREACH by_category GENERATE 
    group AS category,
    COUNT(sales_revenue) AS num_orders,
    SUM(sales_revenue.quantity) AS total_quantity,
    SUM(sales_revenue.revenue) AS total_revenue,
    AVG(sales_revenue.revenue) AS avg_order_value;

-- Sort by revenue
sorted = ORDER category_stats BY total_revenue DESC;

-- Store result
STORE sorted INTO '/user/hadoop/category_analysis';
```

### Example 4: Join Example
```pig
-- Load employees
employees = LOAD '/user/hadoop/employees.csv' 
    USING PigStorage(',') 
    AS (emp_id:int, name:chararray, dept_id:int, salary:double);

-- Load departments
departments = LOAD '/user/hadoop/departments.csv' 
    USING PigStorage(',') 
    AS (dept_id:int, dept_name:chararray, location:chararray);

-- Join employees with departments
joined = JOIN employees BY dept_id, departments BY dept_id;

-- Select required fields
result = FOREACH joined GENERATE 
    employees::name AS employee_name,
    employees::salary AS salary,
    departments::dept_name AS department,
    departments::location AS location;

-- Store result
STORE result INTO '/user/hadoop/employee_details';
```

## Pig Debugging and Optimization

### Diagnostic Operators
```pig
-- Display schema
DESCRIBE employees;

-- Show sample data
ILLUSTRATE employees;

-- Explain execution plan
EXPLAIN result;

-- Dump data to console (use with LIMIT)
sample = LIMIT employees 10;
DUMP sample;
```

### Optimization Tips
```pig
-- Use FILTER early
filtered = FILTER data BY condition;  -- Do this early
processed = FOREACH filtered GENERATE ...;

-- Use projections early
projected = FOREACH data GENERATE field1, field2;  -- Keep only needed fields
filtered = FILTER projected BY ...;

-- Use PARALLEL for performance
result = GROUP data BY key PARALLEL 10;

-- Combine small files
data = LOAD '/user/hadoop/input' USING PigStorage() AS (fields);
```

## Practice Exercises

### Exercise 1: Data Filtering and Projection
1. Load a CSV file with customer data
2. Filter customers from a specific city
3. Project only name, email, and phone
4. Store the result

### Exercise 2: Aggregation
1. Load sales transaction data
2. Group by product category
3. Calculate total sales and average price per category
4. Sort by total sales descending

### Exercise 3: Join Operations
1. Load orders and customer tables
2. Perform inner join on customer_id
3. Calculate total order value per customer
4. Find top 10 customers by order value

### Exercise 4: Complex Transformation
1. Load web server logs
2. Extract hour from timestamp
3. Count requests per hour and status code
4. Identify peak traffic hours

### Exercise 5: Data Cleaning
1. Load raw data with potential nulls
2. Filter out records with null values
3. Remove duplicates
4. Standardize text fields (uppercase/trim)
5. Store cleaned data

## Pig Script Template
```pig
-- Register UDFs if needed
-- REGISTER '/path/to/myudf.jar';

-- Set job name
SET job.name 'My Pig Job';

-- Set parallel for better performance
SET default_parallel 5;

-- Load data
data = LOAD '$INPUT' USING PigStorage(',') AS (schema);

-- Transform data
transformed = FOREACH data GENERATE ...;
filtered = FILTER transformed BY condition;
grouped = GROUP filtered BY key;
aggregated = FOREACH grouped GENERATE ...;

-- Store result
STORE aggregated INTO '$OUTPUT' USING PigStorage('\t');
```

## Running Pig Scripts

```bash
# Execute script
pig -x mapreduce script.pig

# With parameters
pig -x mapreduce -param INPUT=/data/input -param OUTPUT=/data/output script.pig

# With parameter file
pig -x mapreduce -param_file params.txt script.pig

# In local mode for testing
pig -x local -param INPUT=local_input.txt script.pig

# Check script syntax
pig -x local -check script.pig
```

## Key Concepts to Remember

1. **Lazy Evaluation**: Pig uses lazy evaluation; transformations are not executed until STORE or DUMP
2. **Schema on Read**: Schema is applied when data is loaded
3. **Bags, Tuples, Maps**: Understanding complex data types is crucial
4. **GROUP creates bags**: GROUP BY creates a bag of tuples for each group
5. **COGROUP for joins**: COGROUP is more flexible than JOIN for outer joins
6. **Use PARALLEL**: Set parallel for better performance on large datasets
7. **Filter early**: Apply filters as early as possible to reduce data processing
