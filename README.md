# Big Data Lab Practice Repository

A comprehensive collection of practice materials for Big Data technologies including Hadoop, MapReduce, Pig Latin, Spark, Kafka, HBase, and Cassandra.

## 📚 Contents

This repository contains detailed guides, commands, examples, and practice exercises for the following Big Data technologies:

### 1. [Hadoop](./hadoop/README.md)
- HDFS commands and operations
- File system management
- Cluster administration
- YARN commands
- Job execution and monitoring
- **Practice exercises** for hands-on learning

### 2. [MapReduce](./mapreduce/README.md)
- MapReduce fundamentals and architecture
- WordCount and other classic examples
- Custom Mapper and Reducer implementations
- Advanced patterns (Partitioner, Combiner, Counters)
- Job compilation and execution
- **Practice exercises** with real-world scenarios

### 3. [Pig Latin](./pig/README.md)
- Pig Latin syntax and data types
- Data loading and transformation operations
- Aggregations and joins
- Built-in and User Defined Functions (UDFs)
- Complete script examples
- **Practice exercises** for data processing

### 4. [Apache Spark](./spark/README.md)
- RDD operations and transformations
- DataFrame and Dataset APIs
- Spark SQL queries
- Window functions and aggregations
- PySpark and Scala examples
- **Practice exercises** for distributed computing

### 5. [Apache Kafka](./kafka/README.md)
- Kafka architecture and core concepts
- Topic management
- Producer and Consumer APIs
- Consumer groups and offset management
- Kafka Streams
- **Practice exercises** for stream processing

### 6. [Apache HBase](./hbase/README.md)
- HBase shell commands
- Table management and operations
- Data CRUD operations
- Filters and scanning
- Bulk loading and Java API
- **Practice exercises** for NoSQL operations

### 7. [Apache Cassandra](./cassandra/README.md)
- CQL (Cassandra Query Language)
- Keyspace and table management
- Data modeling for Cassandra
- Collections and User-Defined Types
- Python driver examples
- **Practice exercises** for distributed databases

## 🎯 Quick Start

Each technology folder contains:
- **README.md**: Comprehensive guide with commands and examples
- **Syntax reference**: Quick reference for common operations
- **Code examples**: Ready-to-use code snippets
- **Practice exercises**: Hands-on tasks to reinforce learning
- **Best practices**: Tips for optimal usage

## 📖 How to Use This Repository

### For Lab Exam Preparation:
1. Navigate to the specific technology folder
2. Review the commands and syntax
3. Try out the examples in your environment
4. Complete the practice exercises
5. Review key concepts section before exam

### For Learning:
1. Start with fundamentals (Hadoop → MapReduce)
2. Progress to data processing (Pig → Spark)
3. Explore streaming (Kafka)
4. Learn NoSQL databases (HBase → Cassandra)

### For Quick Reference:
- Use the command examples as a cheat sheet
- Search for specific operations within each guide
- Refer to the "Key Concepts to Remember" sections

## 🛠️ Prerequisites

To practice these technologies, you'll need:
- Hadoop cluster (or pseudo-distributed mode)
- Java Development Kit (JDK 8 or later)
- Python 3.x (for PySpark and Python clients)
- Access to respective technology installations

### Setting Up Practice Environment:

**Option 1: Docker**
```bash
# Use official Docker images for quick setup
docker pull apache/hadoop
docker pull apache/spark
docker pull cassandra
```

**Option 2: Cloudera/Hortonworks Sandbox**
- Download and run pre-configured VM with all tools

**Option 3: Cloud Platforms**
- AWS EMR
- Google Cloud Dataproc
- Azure HDInsight

## 📝 Practice Exercise Guide

Each technology includes exercises at different levels:

- **Basic**: Fundamental operations and syntax
- **Intermediate**: Data processing and transformations
- **Advanced**: Complex queries, optimizations, and real-world scenarios

### Recommended Practice Flow:
1. Read the command documentation
2. Execute basic commands in your environment
3. Modify examples for your use case
4. Complete practice exercises in order
5. Challenge yourself with advanced exercises

## 🔍 Topics Covered

### Data Storage
- HDFS (Hadoop Distributed File System)
- HBase (Column-oriented database)
- Cassandra (Wide-column store)

### Data Processing
- MapReduce (Batch processing framework)
- Pig Latin (Data flow language)
- Spark (Unified analytics engine)

### Data Streaming
- Kafka (Distributed streaming platform)
- Spark Streaming (Micro-batch processing)

### Cluster Management
- YARN (Resource management)
- ZooKeeper (Coordination service)

## 💡 Tips for Effective Learning

1. **Start Small**: Begin with simple commands before complex operations
2. **Practice Regularly**: Consistency is key to mastering Big Data tools
3. **Experiment**: Try variations of examples to understand behavior
4. **Read Logs**: Learn to debug by reading error messages and logs
5. **Optimize**: After getting code to work, focus on optimization
6. **Document**: Keep notes on commands and patterns you use frequently

## 📚 Additional Resources

### Official Documentation:
- [Apache Hadoop](https://hadoop.apache.org/docs/)
- [Apache Spark](https://spark.apache.org/docs/latest/)
- [Apache Kafka](https://kafka.apache.org/documentation/)
- [Apache HBase](https://hbase.apache.org/book.html)
- [Apache Cassandra](https://cassandra.apache.org/doc/latest/)
- [Apache Pig](https://pig.apache.org/docs/latest/)

### Online Learning:
- Coursera Big Data Specialization
- edX Big Data courses
- Udemy Hadoop/Spark courses
- DataCamp Big Data tracks

## 🎓 Exam Preparation Checklist

- [ ] Review all HDFS commands
- [ ] Understand MapReduce lifecycle
- [ ] Practice Pig Latin transformations
- [ ] Master Spark DataFrame operations
- [ ] Learn Kafka producer/consumer patterns
- [ ] Understand HBase data model
- [ ] Practice CQL queries in Cassandra
- [ ] Complete all practice exercises
- [ ] Review key concepts in each section
- [ ] Test yourself with sample scenarios

## 🤝 Contributing

Feel free to contribute by:
- Adding more examples
- Creating additional practice exercises
- Improving documentation
- Fixing errors or typos
- Sharing use cases

## 📄 License

This repository is for educational purposes. Please refer to individual Apache project licenses for the respective technologies.

## 🌟 Features

- ✅ Comprehensive command reference
- ✅ Real-world examples
- ✅ Practice exercises with solutions approach
- ✅ Best practices and optimization tips
- ✅ Quick reference sections
- ✅ Code examples in multiple languages (Java, Python, Scala)
- ✅ Troubleshooting guides

## 📞 Support

For questions or issues:
- Review the FAQ sections in each guide
- Check official documentation
- Search for error messages in logs
- Practice debugging with provided examples

---

**Good luck with your lab exam preparation! 🚀**

Remember: Big Data mastery comes from hands-on practice. Don't just read the commands—execute them, experiment with them, and understand how they work!