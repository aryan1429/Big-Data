# Apache Kafka Practice Guide

This guide contains Kafka commands, concepts, and practice exercises.

## Introduction to Kafka

Apache Kafka is a distributed streaming platform used for building real-time data pipelines and streaming applications.

## Kafka Core Concepts

- **Topic**: Category or feed name to which records are published
- **Partition**: Topics are split into partitions for scalability
- **Producer**: Publishes messages to topics
- **Consumer**: Subscribes to topics and processes messages
- **Consumer Group**: Group of consumers working together
- **Broker**: Kafka server that stores data
- **ZooKeeper**: Manages Kafka cluster metadata (Kafka 2.8+ can run without it)
- **Offset**: Unique identifier of a record within a partition

## Starting Kafka

### Start ZooKeeper
```bash
# Start ZooKeeper server
bin/zookeeper-server-start.sh config/zookeeper.properties

# Start ZooKeeper in background
nohup bin/zookeeper-server-start.sh config/zookeeper.properties > zookeeper.log 2>&1 &
```

### Start Kafka Broker
```bash
# Start Kafka server
bin/kafka-server-start.sh config/server.properties

# Start Kafka in background
nohup bin/kafka-server-start.sh config/server.properties > kafka.log 2>&1 &
```

### Stop Services
```bash
# Stop Kafka
bin/kafka-server-stop.sh

# Stop ZooKeeper
bin/zookeeper-server-stop.sh
```

## Topic Management

### Create Topics
```bash
# Create topic with default settings
kafka-topics.sh --create \
    --topic my-topic \
    --bootstrap-server localhost:9092

# Create topic with specific partitions and replication
kafka-topics.sh --create \
    --topic orders \
    --partitions 3 \
    --replication-factor 2 \
    --bootstrap-server localhost:9092

# Create topic with custom configuration
kafka-topics.sh --create \
    --topic events \
    --partitions 5 \
    --replication-factor 1 \
    --config retention.ms=604800000 \
    --config segment.ms=86400000 \
    --bootstrap-server localhost:9092
```

### List Topics
```bash
# List all topics
kafka-topics.sh --list \
    --bootstrap-server localhost:9092
```

### Describe Topics
```bash
# Describe a specific topic
kafka-topics.sh --describe \
    --topic my-topic \
    --bootstrap-server localhost:9092

# Describe all topics
kafka-topics.sh --describe \
    --bootstrap-server localhost:9092
```

### Modify Topics
```bash
# Add partitions (can't decrease)
kafka-topics.sh --alter \
    --topic my-topic \
    --partitions 5 \
    --bootstrap-server localhost:9092

# Modify topic configuration
kafka-configs.sh --alter \
    --entity-type topics \
    --entity-name my-topic \
    --add-config retention.ms=604800000 \
    --bootstrap-server localhost:9092

# Delete configuration
kafka-configs.sh --alter \
    --entity-type topics \
    --entity-name my-topic \
    --delete-config retention.ms \
    --bootstrap-server localhost:9092
```

### Delete Topics
```bash
# Delete a topic
kafka-topics.sh --delete \
    --topic my-topic \
    --bootstrap-server localhost:9092
```

## Producer Commands

### Console Producer
```bash
# Start console producer
kafka-console-producer.sh \
    --topic my-topic \
    --bootstrap-server localhost:9092

# Producer with key
kafka-console-producer.sh \
    --topic my-topic \
    --property "parse.key=true" \
    --property "key.separator=:" \
    --bootstrap-server localhost:9092

# Example input:
# key1:message1
# key2:message2

# Producer with properties
kafka-console-producer.sh \
    --topic my-topic \
    --producer-property acks=all \
    --producer-property compression.type=snappy \
    --bootstrap-server localhost:9092
```

### Performance Testing
```bash
# Producer performance test
kafka-producer-perf-test.sh \
    --topic test-topic \
    --num-records 1000000 \
    --record-size 1024 \
    --throughput 100000 \
    --producer-props bootstrap.servers=localhost:9092
```

## Consumer Commands

### Console Consumer
```bash
# Start console consumer (from latest)
kafka-console-consumer.sh \
    --topic my-topic \
    --bootstrap-server localhost:9092

# Consume from beginning
kafka-console-consumer.sh \
    --topic my-topic \
    --from-beginning \
    --bootstrap-server localhost:9092

# Consumer with key
kafka-console-consumer.sh \
    --topic my-topic \
    --property print.key=true \
    --property key.separator=":" \
    --from-beginning \
    --bootstrap-server localhost:9092

# Consumer with timestamp
kafka-console-consumer.sh \
    --topic my-topic \
    --property print.timestamp=true \
    --from-beginning \
    --bootstrap-server localhost:9092

# Consumer group
kafka-console-consumer.sh \
    --topic my-topic \
    --group my-consumer-group \
    --bootstrap-server localhost:9092

# Consume specific partition
kafka-console-consumer.sh \
    --topic my-topic \
    --partition 0 \
    --offset earliest \
    --bootstrap-server localhost:9092

# Max messages
kafka-console-consumer.sh \
    --topic my-topic \
    --max-messages 10 \
    --from-beginning \
    --bootstrap-server localhost:9092
```

### Performance Testing
```bash
# Consumer performance test
kafka-consumer-perf-test.sh \
    --topic test-topic \
    --messages 1000000 \
    --threads 1 \
    --bootstrap-server localhost:9092
```

## Consumer Group Management

### List Consumer Groups
```bash
# List all consumer groups
kafka-consumer-groups.sh --list \
    --bootstrap-server localhost:9092
```

### Describe Consumer Group
```bash
# Describe consumer group
kafka-consumer-groups.sh --describe \
    --group my-consumer-group \
    --bootstrap-server localhost:9092

# Show members
kafka-consumer-groups.sh --describe \
    --group my-consumer-group \
    --members \
    --bootstrap-server localhost:9092

# Show state
kafka-consumer-groups.sh --describe \
    --group my-consumer-group \
    --state \
    --bootstrap-server localhost:9092
```

### Reset Consumer Group Offsets
```bash
# Reset to earliest
kafka-consumer-groups.sh --reset-offsets \
    --group my-consumer-group \
    --topic my-topic \
    --to-earliest \
    --execute \
    --bootstrap-server localhost:9092

# Reset to latest
kafka-consumer-groups.sh --reset-offsets \
    --group my-consumer-group \
    --topic my-topic \
    --to-latest \
    --execute \
    --bootstrap-server localhost:9092

# Reset to specific offset
kafka-consumer-groups.sh --reset-offsets \
    --group my-consumer-group \
    --topic my-topic:0 \
    --to-offset 100 \
    --execute \
    --bootstrap-server localhost:9092

# Reset to datetime
kafka-consumer-groups.sh --reset-offsets \
    --group my-consumer-group \
    --topic my-topic \
    --to-datetime 2024-01-01T00:00:00.000 \
    --execute \
    --bootstrap-server localhost:9092

# Shift offset by N
kafka-consumer-groups.sh --reset-offsets \
    --group my-consumer-group \
    --topic my-topic \
    --shift-by -10 \
    --execute \
    --bootstrap-server localhost:9092
```

### Delete Consumer Group
```bash
# Delete consumer group
kafka-consumer-groups.sh --delete \
    --group my-consumer-group \
    --bootstrap-server localhost:9092
```

## Kafka Configuration

### Important Producer Configurations
```properties
# Acknowledgments (0, 1, all)
acks=all

# Retries
retries=3

# Batch size (bytes)
batch.size=16384

# Linger time (ms)
linger.ms=10

# Compression (none, gzip, snappy, lz4, zstd)
compression.type=snappy

# Max request size (bytes)
max.request.size=1048576

# Idempotence
enable.idempotence=true
```

### Important Consumer Configurations
```properties
# Auto offset reset (earliest, latest, none)
auto.offset.reset=earliest

# Enable auto commit
enable.auto.commit=true

# Auto commit interval
auto.commit.interval.ms=5000

# Max poll records
max.poll.records=500

# Session timeout
session.timeout.ms=10000

# Heartbeat interval
heartbeat.interval.ms=3000

# Fetch min bytes
fetch.min.bytes=1

# Fetch max wait
fetch.max.wait.ms=500
```

## Producer API (Python - kafka-python)

### Simple Producer
```python
from kafka import KafkaProducer
import json

# Create producer
producer = KafkaProducer(
    bootstrap_servers=['localhost:9092'],
    value_serializer=lambda v: json.dumps(v).encode('utf-8')
)

# Send message
producer.send('my-topic', {'key': 'value'})

# Send with key
producer.send('my-topic', key=b'key1', value={'data': 'value1'})

# Flush and close
producer.flush()
producer.close()
```

### Producer with Callback
```python
from kafka import KafkaProducer

def on_send_success(record_metadata):
    print(f"Topic: {record_metadata.topic}")
    print(f"Partition: {record_metadata.partition}")
    print(f"Offset: {record_metadata.offset}")

def on_send_error(excp):
    print(f"Error: {excp}")

producer = KafkaProducer(bootstrap_servers=['localhost:9092'])

# Asynchronous send
future = producer.send('my-topic', b'message')
future.add_callback(on_send_success)
future.add_errback(on_send_error)

# Synchronous send
metadata = producer.send('my-topic', b'message').get(timeout=10)
```

## Consumer API (Python - kafka-python)

### Simple Consumer
```python
from kafka import KafkaConsumer
import json

# Create consumer
consumer = KafkaConsumer(
    'my-topic',
    bootstrap_servers=['localhost:9092'],
    auto_offset_reset='earliest',
    enable_auto_commit=True,
    group_id='my-group',
    value_deserializer=lambda m: json.loads(m.decode('utf-8'))
)

# Consume messages
for message in consumer:
    print(f"Topic: {message.topic}")
    print(f"Partition: {message.partition}")
    print(f"Offset: {message.offset}")
    print(f"Key: {message.key}")
    print(f"Value: {message.value}")
```

### Consumer with Manual Commit
```python
from kafka import KafkaConsumer

consumer = KafkaConsumer(
    'my-topic',
    bootstrap_servers=['localhost:9092'],
    enable_auto_commit=False,
    group_id='my-group'
)

for message in consumer:
    # Process message
    print(message.value)
    
    # Commit offset
    consumer.commit()
```

### Consumer with Partition Assignment
```python
from kafka import KafkaConsumer, TopicPartition

consumer = KafkaConsumer(bootstrap_servers=['localhost:9092'])

# Assign specific partitions
partition = TopicPartition('my-topic', 0)
consumer.assign([partition])

# Seek to specific offset
consumer.seek(partition, 100)

# Consume messages
for message in consumer:
    print(message.value)
```

## Kafka Streams

### Stream Processing Concepts
- **KStream**: Unbounded stream of records
- **KTable**: Changelog stream (latest value per key)
- **GlobalKTable**: Fully replicated KTable

### Kafka Streams Example (Java)
```java
Properties props = new Properties();
props.put(StreamsConfig.APPLICATION_ID_CONFIG, "wordcount-app");
props.put(StreamsConfig.BOOTSTRAP_SERVERS_CONFIG, "localhost:9092");

StreamsBuilder builder = new StreamsBuilder();

KStream<String, String> textLines = builder.stream("input-topic");

KTable<String, Long> wordCounts = textLines
    .flatMapValues(line -> Arrays.asList(line.toLowerCase().split("\\W+")))
    .groupBy((key, word) -> word)
    .count();

wordCounts.toStream().to("output-topic");

KafkaStreams streams = new KafkaStreams(builder.build(), props);
streams.start();
```

## Practice Exercises

### Exercise 1: Basic Producer-Consumer
1. Create a topic called "test-topic"
2. Start a console producer and send 10 messages
3. Start a console consumer and verify messages
4. Delete the topic

### Exercise 2: Partitioned Topic
1. Create a topic with 3 partitions
2. Send messages with keys to distribute across partitions
3. Consume from specific partitions
4. Describe the topic to see partition distribution

### Exercise 3: Consumer Group
1. Create a topic with multiple partitions
2. Start 3 consumers in the same consumer group
3. Send messages and observe load balancing
4. Describe the consumer group to see partition assignment

### Exercise 4: Offset Management
1. Create a consumer group and consume messages
2. Stop the consumer
3. Reset offsets to beginning
4. Restart consumer and verify re-consumption

### Exercise 5: Python Producer-Consumer
1. Write a Python producer to send JSON messages
2. Write a Python consumer to process messages
3. Implement error handling and logging
4. Test with various message volumes

## Monitoring and Debugging

### Check Kafka Logs
```bash
# Server logs
tail -f kafka/logs/server.log

# Controller logs
tail -f kafka/logs/controller.log
```

### Get Offsets
```bash
# Get earliest offset
kafka-run-class.sh kafka.tools.GetOffsetShell \
    --broker-list localhost:9092 \
    --topic my-topic \
    --time -2

# Get latest offset
kafka-run-class.sh kafka.tools.GetOffsetShell \
    --broker-list localhost:9092 \
    --topic my-topic \
    --time -1
```

### Verify Consumer Lag
```bash
# Check consumer lag
kafka-consumer-groups.sh --describe \
    --group my-consumer-group \
    --bootstrap-server localhost:9092
```

## Common Issues and Solutions

### Issue: Consumer Lag
```bash
# Solution: Increase consumers or optimize processing
# Check lag
kafka-consumer-groups.sh --describe --group my-group \
    --bootstrap-server localhost:9092
```

### Issue: Message Loss
```bash
# Solution: Set acks=all for producer
# Enable idempotence
enable.idempotence=true
acks=all
```

### Issue: Duplicate Messages
```bash
# Solution: Enable idempotence and implement idempotent consumer
enable.idempotence=true
```

## Key Concepts to Remember

1. **Topics are append-only logs** - Messages are never modified
2. **Partitions enable parallelism** - More partitions = more parallelism
3. **Consumer groups enable scalability** - Partitions distributed among consumers
4. **Offset management** - Track where consumers are in the log
5. **Replication for fault tolerance** - Replicas ensure data durability
6. **Producer acks** - Control durability vs. throughput tradeoff
7. **Retention policies** - Messages retained by time or size
8. **Compaction** - Keep only latest value per key for log-compacted topics
