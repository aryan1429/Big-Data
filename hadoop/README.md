# Hadoop Commands Practice Guide

This guide contains essential Hadoop commands for practice and lab exam preparation.

## HDFS Commands

### File System Operations

#### Listing Files
```bash
# List files in HDFS root directory
hdfs dfs -ls /

# List files with details
hdfs dfs -ls -R /user

# List files in a specific directory
hdfs dfs -ls /user/hadoop
```

#### Creating Directories
```bash
# Create a directory
hdfs dfs -mkdir /user/hadoop/data

# Create directory with parent directories
hdfs dfs -mkdir -p /user/hadoop/input/data
```

#### File Upload/Download
```bash
# Upload file from local to HDFS
hdfs dfs -put localfile.txt /user/hadoop/

# Upload and overwrite if exists
hdfs dfs -put -f localfile.txt /user/hadoop/

# Download file from HDFS to local
hdfs dfs -get /user/hadoop/file.txt /local/path/

# Copy from local to HDFS (alternative to put)
hdfs dfs -copyFromLocal localfile.txt /user/hadoop/

# Copy from HDFS to local (alternative to get)
hdfs dfs -copyToLocal /user/hadoop/file.txt /local/path/
```

#### File Operations
```bash
# Copy files within HDFS
hdfs dfs -cp /user/hadoop/file1.txt /user/hadoop/backup/

# Move files within HDFS
hdfs dfs -mv /user/hadoop/old.txt /user/hadoop/new.txt

# Delete files
hdfs dfs -rm /user/hadoop/file.txt

# Delete directory recursively
hdfs dfs -rm -r /user/hadoop/olddata/

# Delete directory (skip trash)
hdfs dfs -rm -r -skipTrash /user/hadoop/temp/
```

#### Viewing File Contents
```bash
# Display file contents
hdfs dfs -cat /user/hadoop/file.txt

# Display last 1KB of file
hdfs dfs -tail /user/hadoop/logfile.txt

# View file in human-readable format
hdfs dfs -text /user/hadoop/sequencefile.seq
```

#### File Information
```bash
# Check file size
hdfs dfs -du /user/hadoop/

# Check disk usage with human-readable sizes
hdfs dfs -du -h /user/hadoop/

# Check total space usage
hdfs dfs -df -h /

# Check file statistics
hdfs dfs -stat "%b %o %r %u %n" /user/hadoop/file.txt

# Count directories, files, and bytes
hdfs dfs -count /user/hadoop/
```

#### File Permissions
```bash
# Change file permissions
hdfs dfs -chmod 755 /user/hadoop/file.txt

# Change file permissions recursively
hdfs dfs -chmod -R 644 /user/hadoop/data/

# Change file owner
hdfs dfs -chown hadoop:hadoop /user/hadoop/file.txt

# Change file owner recursively
hdfs dfs -chown -R hadoop:hadoop /user/hadoop/data/

# Change group
hdfs dfs -chgrp hadoop /user/hadoop/file.txt
```

### Advanced HDFS Operations

#### File Replication
```bash
# Set replication factor
hdfs dfs -setrep 3 /user/hadoop/file.txt

# Set replication factor recursively
hdfs dfs -setrep -R 2 /user/hadoop/data/
```

#### Testing Files
```bash
# Test if file exists
hdfs dfs -test -e /user/hadoop/file.txt && echo "File exists"

# Test if directory
hdfs dfs -test -d /user/hadoop/data && echo "Is directory"

# Test if file is zero length
hdfs dfs -test -z /user/hadoop/file.txt && echo "File is empty"
```

#### File Checksum
```bash
# Get file checksum
hdfs dfs -checksum /user/hadoop/file.txt
```

## Hadoop Administration Commands

### Cluster Management
```bash
# Check HDFS health
hdfs dfsadmin -report

# Safe mode operations
hdfs dfsadmin -safemode get
hdfs dfsadmin -safemode enter
hdfs dfsadmin -safemode leave

# Check filesystem
hdfs fsck /

# Check filesystem with detailed info
hdfs fsck / -files -blocks -locations

# Balance cluster
hdfs balancer -threshold 10
```

### DataNode Operations
```bash
# List all DataNodes
hdfs dfsadmin -printTopology

# Decommission DataNode
hdfs dfsadmin -refreshNodes
```

## YARN Commands

### Application Management
```bash
# List all applications
yarn application -list

# List running applications
yarn application -list -appStates RUNNING

# Kill application
yarn application -kill <application_id>

# Get application status
yarn application -status <application_id>

# Get application logs
yarn logs -applicationId <application_id>
```

### Node Management
```bash
# List cluster nodes
yarn node -list

# Get node status
yarn node -status <node_id>
```

### Queue Management
```bash
# List queues
yarn queue -status <queue_name>
```

## Hadoop Job Commands

### Running MapReduce Jobs
```bash
# Run a MapReduce job
hadoop jar /path/to/hadoop-examples.jar wordcount /input /output

# Run with specific configuration
hadoop jar myapp.jar com.example.MyJob -D mapred.reduce.tasks=10 /input /output

# View job history
mapred job -history /user/hadoop/job-history/

# List jobs
mapred job -list

# Kill job
mapred job -kill <job_id>

# Get job status
mapred job -status <job_id>

# Get job counters
mapred job -counter <job_id> <group> <counter>
```

## Practice Exercises

### Exercise 1: Basic File Operations
1. Create a directory `/user/practice/input`
2. Upload a text file to this directory
3. List the contents and check file size
4. Copy the file to `/user/practice/backup`
5. Delete the original file

### Exercise 2: File Permissions
1. Create a file and set permissions to 644
2. Change owner to a specific user
3. Verify the changes using `-ls`

### Exercise 3: Replication
1. Upload a file with default replication
2. Change replication factor to 2
3. Verify using `fsck` command

### Exercise 4: Running MapReduce
1. Prepare input data in HDFS
2. Run the WordCount example
3. View the output
4. Check job logs

## Common Issues and Solutions

### Permission Denied
```bash
# Solution: Check and fix permissions
hdfs dfs -chmod 755 /user/hadoop/
```

### Safe Mode Stuck
```bash
# Solution: Manually leave safe mode
hdfs dfsadmin -safemode leave
```

### Disk Full
```bash
# Check disk usage
hdfs dfs -df -h
# Clean up unnecessary files
hdfs dfs -rm -r /user/hadoop/temp/
```

## Useful Tips

1. Always use `-p` flag when creating nested directories
2. Use `-f` flag to force overwrite when uploading files
3. Check replication factor for important files
4. Regularly monitor cluster health with `dfsadmin -report`
5. Use `-skipTrash` only when absolutely sure about deletion
