# Apache Spark Practice Guide

This guide contains Spark commands, examples, and practice exercises for RDD, DataFrame, and Spark SQL.

## Introduction to Spark

Apache Spark is a unified analytics engine for large-scale data processing with built-in modules for SQL, streaming, machine learning, and graph processing.

## Starting Spark

### Spark Shell
```bash
# Start Spark shell (Scala)
spark-shell

# Start PySpark (Python)
pyspark

# Start with specific configuration
spark-shell --master yarn --deploy-mode client --executor-memory 2G --num-executors 4

# Start with packages
pyspark --packages org.apache.spark:spark-sql-kafka-0-10_2.12:3.0.0
```

### Submit Spark Application
```bash
# Submit Scala/Java application
spark-submit --class com.example.MyApp \
    --master yarn \
    --deploy-mode cluster \
    --executor-memory 2G \
    --num-executors 4 \
    myapp.jar

# Submit Python application
spark-submit --master yarn \
    --deploy-mode client \
    myapp.py

# With additional JARs
spark-submit --jars dependency1.jar,dependency2.jar myapp.jar
```

## RDD Operations (PySpark)

### Creating RDDs
```python
# From collection
rdd = sc.parallelize([1, 2, 3, 4, 5])

# From text file
rdd = sc.textFile("hdfs:///user/hadoop/input.txt")

# From multiple files
rdd = sc.textFile("hdfs:///user/hadoop/data/*.txt")

# With specific number of partitions
rdd = sc.parallelize(range(1000), 10)

# From sequence file
rdd = sc.sequenceFile("hdfs:///user/hadoop/sequence")
```

### Transformations

#### Basic Transformations
```python
# map - Transform each element
squared = rdd.map(lambda x: x * x)

# filter - Keep elements matching condition
evens = rdd.filter(lambda x: x % 2 == 0)

# flatMap - Map and flatten
words = lines.flatMap(lambda line: line.split())

# distinct - Remove duplicates
unique = rdd.distinct()

# sample - Random sample
sample = rdd.sample(False, 0.1)
```

#### Pair RDD Transformations
```python
# mapValues - Transform values in key-value pairs
transformed = pair_rdd.mapValues(lambda x: x * 2)

# groupByKey - Group values by key
grouped = pair_rdd.groupByKey()

# reduceByKey - Reduce values by key
sums = pair_rdd.reduceByKey(lambda a, b: a + b)

# sortByKey - Sort by key
sorted_rdd = pair_rdd.sortByKey()

# join - Join two RDDs
joined = rdd1.join(rdd2)

# leftOuterJoin
left_joined = rdd1.leftOuterJoin(rdd2)

# cogroup - Group from multiple RDDs
cogrouped = rdd1.cogroup(rdd2)
```

#### Set Operations
```python
# union - Combine RDDs
combined = rdd1.union(rdd2)

# intersection - Common elements
common = rdd1.intersection(rdd2)

# subtract - Elements in first but not second
diff = rdd1.subtract(rdd2)

# cartesian - Cartesian product
product = rdd1.cartesian(rdd2)
```

### Actions

```python
# collect - Retrieve all elements
data = rdd.collect()

# count - Count elements
num_elements = rdd.count()

# first - Get first element
first_elem = rdd.first()

# take - Get first n elements
top5 = rdd.take(5)

# top - Get top n elements
top10 = rdd.top(10)

# reduce - Aggregate elements
total = rdd.reduce(lambda a, b: a + b)

# countByKey - Count occurrences of each key
counts = pair_rdd.countByKey()

# foreach - Apply function to each element
rdd.foreach(lambda x: print(x))

# saveAsTextFile - Save to HDFS
rdd.saveAsTextFile("hdfs:///user/hadoop/output")
```

## DataFrame Operations (PySpark)

### Creating DataFrames
```python
from pyspark.sql import SparkSession

# Initialize Spark session
spark = SparkSession.builder.appName("MyApp").getOrCreate()

# From list of tuples
data = [("Alice", 25), ("Bob", 30), ("Charlie", 35)]
df = spark.createDataFrame(data, ["name", "age"])

# From RDD
rdd = sc.parallelize(data)
df = spark.createDataFrame(rdd, ["name", "age"])

# Read from CSV
df = spark.read.csv("hdfs:///user/hadoop/data.csv", header=True, inferSchema=True)

# Read from JSON
df = spark.read.json("hdfs:///user/hadoop/data.json")

# Read from Parquet
df = spark.read.parquet("hdfs:///user/hadoop/data.parquet")

# With options
df = spark.read.format("csv") \
    .option("header", "true") \
    .option("inferSchema", "true") \
    .option("delimiter", ",") \
    .load("hdfs:///user/hadoop/data.csv")
```

### DataFrame Operations

#### Basic Operations
```python
# Show data
df.show()
df.show(20, truncate=False)

# Print schema
df.printSchema()

# Get columns
df.columns

# Get count
df.count()

# Describe statistics
df.describe().show()

# Select columns
df.select("name", "age").show()

# Select with expressions
df.select(df["name"], df["age"] + 1).show()

# Filter rows
df.filter(df["age"] > 25).show()
df.where(df["age"] > 25).show()

# Multiple conditions
df.filter((df["age"] > 25) & (df["salary"] > 50000)).show()
```

#### Aggregations
```python
# Group by
df.groupBy("department").count().show()

# Multiple aggregations
from pyspark.sql import functions as F

df.groupBy("department").agg(
    F.count("*").alias("count"),
    F.avg("salary").alias("avg_salary"),
    F.max("salary").alias("max_salary"),
    F.min("salary").alias("min_salary")
).show()

# Global aggregations
df.agg(
    F.count("*"),
    F.avg("salary"),
    F.sum("salary")
).show()
```

#### Column Operations
```python
from pyspark.sql import functions as F

# Add column
df_with_bonus = df.withColumn("bonus", df["salary"] * 0.1)

# Rename column
df_renamed = df.withColumnRenamed("old_name", "new_name")

# Drop column
df_dropped = df.drop("column_to_drop")

# Cast column type
df_casted = df.withColumn("age", df["age"].cast("integer"))

# String functions
df.withColumn("upper_name", F.upper(df["name"])).show()
df.withColumn("name_length", F.length(df["name"])).show()

# Date functions
df.withColumn("year", F.year(df["date"])).show()
df.withColumn("month", F.month(df["date"])).show()
```

#### Joins
```python
# Inner join
joined = df1.join(df2, df1["id"] == df2["id"], "inner")

# Left join
left_joined = df1.join(df2, df1["id"] == df2["id"], "left")

# Right join
right_joined = df1.join(df2, df1["id"] == df2["id"], "right")

# Full outer join
full_joined = df1.join(df2, df1["id"] == df2["id"], "outer")

# Join on multiple columns
joined = df1.join(df2, ["id", "date"], "inner")
```

#### Sorting and Ordering
```python
# Sort ascending
df.orderBy("age").show()
df.sort("age").show()

# Sort descending
df.orderBy(df["age"].desc()).show()

# Sort by multiple columns
df.orderBy(["department", "age"], ascending=[True, False]).show()
```

#### Window Functions
```python
from pyspark.sql.window import Window
from pyspark.sql import functions as F

# Define window
window = Window.partitionBy("department").orderBy("salary")

# Ranking
df.withColumn("rank", F.rank().over(window)).show()
df.withColumn("dense_rank", F.dense_rank().over(window)).show()
df.withColumn("row_number", F.row_number().over(window)).show()

# Running totals
df.withColumn("running_total", F.sum("salary").over(window)).show()

# Moving average
window_frame = Window.partitionBy("department") \
    .orderBy("date") \
    .rowsBetween(-2, 0)
df.withColumn("moving_avg", F.avg("value").over(window_frame)).show()
```

## Spark SQL

### Register and Query
```python
# Register DataFrame as temp view
df.createOrReplaceTempView("employees")

# SQL query
result = spark.sql("""
    SELECT department, AVG(salary) as avg_salary
    FROM employees
    WHERE age > 25
    GROUP BY department
    ORDER BY avg_salary DESC
""")
result.show()

# Complex query with joins
result = spark.sql("""
    SELECT e.name, e.salary, d.dept_name
    FROM employees e
    JOIN departments d ON e.dept_id = d.id
    WHERE e.salary > 50000
""")
```

## Complete Examples

### Example 1: Word Count (RDD)
```python
# Read file
lines = sc.textFile("hdfs:///user/hadoop/input.txt")

# Split into words
words = lines.flatMap(lambda line: line.split())

# Map to pairs
pairs = words.map(lambda word: (word.lower(), 1))

# Count by key
word_counts = pairs.reduceByKey(lambda a, b: a + b)

# Sort by count
sorted_counts = word_counts.sortBy(lambda x: x[1], ascending=False)

# Save result
sorted_counts.saveAsTextFile("hdfs:///user/hadoop/wordcount_output")
```

### Example 2: Word Count (DataFrame)
```python
from pyspark.sql import functions as F

# Read file
df = spark.read.text("hdfs:///user/hadoop/input.txt")

# Split into words
words_df = df.select(F.explode(F.split(df.value, " ")).alias("word"))

# Count words
word_counts = words_df.groupBy("word").count()

# Sort by count
sorted_counts = word_counts.orderBy("count", ascending=False)

# Show results
sorted_counts.show()

# Save
sorted_counts.write.csv("hdfs:///user/hadoop/wordcount_output")
```

### Example 3: Log Analysis
```python
from pyspark.sql import functions as F

# Read logs
logs = spark.read.text("hdfs:///user/hadoop/logs/*.log")

# Parse log lines (assuming space-delimited)
parsed = logs.select(
    F.split(logs.value, " ")[0].alias("ip"),
    F.split(logs.value, " ")[3].alias("timestamp"),
    F.split(logs.value, " ")[5].alias("method"),
    F.split(logs.value, " ")[6].alias("url"),
    F.split(logs.value, " ")[8].cast("int").alias("status"),
    F.split(logs.value, " ")[9].cast("int").alias("size")
)

# Filter successful requests
success = parsed.filter(parsed.status == 200)

# Aggregate by IP
ip_stats = success.groupBy("ip").agg(
    F.count("*").alias("request_count"),
    F.sum("size").alias("total_bytes")
)

# Top 10 IPs
top_ips = ip_stats.orderBy("request_count", ascending=False).limit(10)

top_ips.show()
```

### Example 4: Sales Analysis
```python
from pyspark.sql import functions as F

# Read sales data
sales = spark.read.csv("hdfs:///user/hadoop/sales.csv", header=True, inferSchema=True)

# Calculate revenue
sales_with_revenue = sales.withColumn("revenue", 
    F.col("quantity") * F.col("price"))

# Aggregate by category
category_stats = sales_with_revenue.groupBy("category").agg(
    F.count("*").alias("num_orders"),
    F.sum("quantity").alias("total_quantity"),
    F.sum("revenue").alias("total_revenue"),
    F.avg("revenue").alias("avg_order_value")
)

# Sort by revenue
sorted_stats = category_stats.orderBy("total_revenue", ascending=False)

sorted_stats.show()

# Save as Parquet
sorted_stats.write.parquet("hdfs:///user/hadoop/category_analysis")
```

## Saving Data

```python
# Save as text
rdd.saveAsTextFile("hdfs:///output")

# Save DataFrame as CSV
df.write.csv("hdfs:///output", header=True)

# Save as Parquet
df.write.parquet("hdfs:///output")

# Save as JSON
df.write.json("hdfs:///output")

# Save with mode
df.write.mode("overwrite").parquet("hdfs:///output")

# Partition by column
df.write.partitionBy("year", "month").parquet("hdfs:///output")

# Save to single file (coalesce)
df.coalesce(1).write.csv("hdfs:///output")
```

## Practice Exercises

### Exercise 1: Basic RDD Operations
1. Create an RDD from a range of numbers (1-100)
2. Filter even numbers
3. Square each number
4. Sum all values
5. Count the elements

### Exercise 2: DataFrame Transformations
1. Load a CSV file with employee data
2. Filter employees with salary > 50000
3. Add a bonus column (10% of salary)
4. Group by department and calculate average salary
5. Sort by average salary descending

### Exercise 3: Joins
1. Load employees and departments DataFrames
2. Perform inner join on dept_id
3. Select employee name, salary, and department name
4. Calculate total salary by department

### Exercise 4: Window Functions
1. Load sales data with date and amount
2. Calculate running total by date
3. Calculate 7-day moving average
4. Rank products by sales within each category

### Exercise 5: Spark SQL
1. Register employee DataFrame as table
2. Write SQL query to find top 10 highest paid employees
3. Find average salary by department using SQL
4. Join with departments table using SQL

## Performance Tips

```python
# Cache frequently used DataFrames
df.cache()
df.persist()

# Repartition for better parallelism
df = df.repartition(10)

# Coalesce to reduce partitions
df = df.coalesce(2)

# Broadcast small DataFrames in joins
from pyspark.sql.functions import broadcast
result = large_df.join(broadcast(small_df), "key")

# Use column pruning
df.select("col1", "col2")  # Instead of df.select("*")

# Predicate pushdown
df.filter("age > 25")  # Push filter to data source
```

## Key Concepts to Remember

1. **RDD**: Resilient Distributed Dataset - immutable distributed collection
2. **Transformations are lazy**: Not executed until an action is called
3. **Actions trigger execution**: collect(), count(), save(), etc.
4. **DataFrames**: Distributed collection with schema (like SQL tables)
5. **Spark SQL**: Query DataFrames using SQL syntax
6. **Cache/Persist**: Store intermediate results for reuse
7. **Broadcast**: Optimize joins with small datasets
8. **Partitioning**: Control data distribution for performance
