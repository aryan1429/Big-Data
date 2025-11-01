# MapReduce Practice Guide

This guide contains MapReduce concepts, examples, and practice exercises.

## MapReduce Fundamentals

### Architecture Components
- **Job**: A full program with Mapper, Reducer, and configuration
- **Task**: Execution of a Mapper or Reducer on a data slice
- **Task Attempt**: Specific instance of a task on a machine

### Data Flow
1. Input → InputFormat → RecordReader
2. Map Phase → Mapper
3. Shuffle & Sort → Partitioner → Combiner
4. Reduce Phase → Reducer
5. OutputFormat → Output

## WordCount Example

### WordCount Mapper (Java)
```java
import java.io.IOException;
import org.apache.hadoop.io.IntWritable;
import org.apache.hadoop.io.LongWritable;
import org.apache.hadoop.io.Text;
import org.apache.hadoop.mapreduce.Mapper;

public class WordCountMapper extends Mapper<LongWritable, Text, Text, IntWritable> {
    
    private final static IntWritable one = new IntWritable(1);
    private Text word = new Text();
    
    @Override
    public void map(LongWritable key, Text value, Context context) 
            throws IOException, InterruptedException {
        
        String line = value.toString();
        String[] words = line.split("\\s+");
        
        for (String w : words) {
            word.set(w.toLowerCase());
            context.write(word, one);
        }
    }
}
```

### WordCount Reducer (Java)
```java
import java.io.IOException;
import org.apache.hadoop.io.IntWritable;
import org.apache.hadoop.io.Text;
import org.apache.hadoop.mapreduce.Reducer;

public class WordCountReducer extends Reducer<Text, IntWritable, Text, IntWritable> {
    
    @Override
    public void reduce(Text key, Iterable<IntWritable> values, Context context)
            throws IOException, InterruptedException {
        
        int sum = 0;
        for (IntWritable val : values) {
            sum += val.get();
        }
        
        context.write(key, new IntWritable(sum));
    }
}
```

### WordCount Driver (Java)
```java
import org.apache.hadoop.conf.Configuration;
import org.apache.hadoop.fs.Path;
import org.apache.hadoop.io.IntWritable;
import org.apache.hadoop.io.Text;
import org.apache.hadoop.mapreduce.Job;
import org.apache.hadoop.mapreduce.lib.input.FileInputFormat;
import org.apache.hadoop.mapreduce.lib.output.FileOutputFormat;

public class WordCount {
    
    public static void main(String[] args) throws Exception {
        
        if (args.length != 2) {
            System.err.println("Usage: WordCount <input path> <output path>");
            System.exit(-1);
        }
        
        Configuration conf = new Configuration();
        Job job = Job.getInstance(conf, "Word Count");
        
        job.setJarByClass(WordCount.class);
        job.setMapperClass(WordCountMapper.class);
        job.setCombinerClass(WordCountReducer.class);
        job.setReducerClass(WordCountReducer.class);
        
        job.setOutputKeyClass(Text.class);
        job.setOutputValueClass(IntWritable.class);
        
        FileInputFormat.addInputPath(job, new Path(args[0]));
        FileOutputFormat.setOutputPath(job, new Path(args[1]));
        
        System.exit(job.waitForCompletion(true) ? 0 : 1);
    }
}
```

## More MapReduce Examples

### Temperature Analysis

#### TemperatureMapper
```java
import java.io.IOException;
import org.apache.hadoop.io.IntWritable;
import org.apache.hadoop.io.LongWritable;
import org.apache.hadoop.io.Text;
import org.apache.hadoop.mapreduce.Mapper;

public class MaxTemperatureMapper extends Mapper<LongWritable, Text, Text, IntWritable> {
    
    private static final int MISSING = 9999;
    
    @Override
    public void map(LongWritable key, Text value, Context context)
            throws IOException, InterruptedException {
        
        String line = value.toString();
        String year = line.substring(15, 19);
        int airTemperature;
        
        if (line.charAt(87) == '+') {
            airTemperature = Integer.parseInt(line.substring(88, 92));
        } else {
            airTemperature = Integer.parseInt(line.substring(87, 92));
        }
        
        String quality = line.substring(92, 93);
        
        if (airTemperature != MISSING && quality.matches("[01459]")) {
            context.write(new Text(year), new IntWritable(airTemperature));
        }
    }
}
```

#### TemperatureReducer
```java
import java.io.IOException;
import org.apache.hadoop.io.IntWritable;
import org.apache.hadoop.io.Text;
import org.apache.hadoop.mapreduce.Reducer;

public class MaxTemperatureReducer extends Reducer<Text, IntWritable, Text, IntWritable> {
    
    @Override
    public void reduce(Text key, Iterable<IntWritable> values, Context context)
            throws IOException, InterruptedException {
        
        int maxValue = Integer.MIN_VALUE;
        
        for (IntWritable value : values) {
            maxValue = Math.max(maxValue, value.get());
        }
        
        context.write(key, new IntWritable(maxValue));
    }
}
```

### Log Analysis

#### LogMapper
```java
import java.io.IOException;
import org.apache.hadoop.io.IntWritable;
import org.apache.hadoop.io.LongWritable;
import org.apache.hadoop.io.Text;
import org.apache.hadoop.mapreduce.Mapper;

public class LogAnalysisMapper extends Mapper<LongWritable, Text, Text, IntWritable> {
    
    private final static IntWritable one = new IntWritable(1);
    private Text ipAddress = new Text();
    
    @Override
    public void map(LongWritable key, Text value, Context context)
            throws IOException, InterruptedException {
        
        String line = value.toString();
        String[] parts = line.split(" ");
        
        if (parts.length > 0) {
            ipAddress.set(parts[0]);
            context.write(ipAddress, one);
        }
    }
}
```

## Advanced MapReduce Patterns

### Custom Partitioner
```java
import org.apache.hadoop.io.IntWritable;
import org.apache.hadoop.io.Text;
import org.apache.hadoop.mapreduce.Partitioner;

public class CustomPartitioner extends Partitioner<Text, IntWritable> {
    
    @Override
    public int getPartition(Text key, IntWritable value, int numPartitions) {
        String keyStr = key.toString();
        
        if (keyStr.startsWith("A") || keyStr.startsWith("a")) {
            return 0 % numPartitions;
        } else if (keyStr.startsWith("B") || keyStr.startsWith("b")) {
            return 1 % numPartitions;
        } else {
            return 2 % numPartitions;
        }
    }
}
```

### Custom Combiner
```java
import java.io.IOException;
import org.apache.hadoop.io.IntWritable;
import org.apache.hadoop.io.Text;
import org.apache.hadoop.mapreduce.Reducer;

public class SumCombiner extends Reducer<Text, IntWritable, Text, IntWritable> {
    
    @Override
    public void reduce(Text key, Iterable<IntWritable> values, Context context)
            throws IOException, InterruptedException {
        
        int sum = 0;
        for (IntWritable val : values) {
            sum += val.get();
        }
        
        context.write(key, new IntWritable(sum));
    }
}
```

### Using Counters
```java
public enum TemperatureQuality {
    MISSING,
    MALFORMED,
    VALID
}

// In Mapper
if (airTemperature == MISSING) {
    context.getCounter(TemperatureQuality.MISSING).increment(1);
    return;
}

if (!quality.matches("[01459]")) {
    context.getCounter(TemperatureQuality.MALFORMED).increment(1);
    return;
}

context.getCounter(TemperatureQuality.VALID).increment(1);
```

## MapReduce Job Configuration

### Setting Configuration Parameters
```java
Configuration conf = new Configuration();

// Set number of reducers
conf.setInt("mapreduce.job.reduces", 5);

// Set mapper memory
conf.set("mapreduce.map.memory.mb", "2048");

// Set reducer memory
conf.set("mapreduce.reduce.memory.mb", "4096");

// Set custom properties
conf.set("my.custom.property", "value");

Job job = Job.getInstance(conf, "My Job");
```

### Using DistributedCache
```java
import org.apache.hadoop.fs.Path;
import org.apache.hadoop.mapreduce.Job;

// Add file to distributed cache
job.addCacheFile(new Path("/user/hadoop/lookup.txt").toUri());

// In Mapper setup
@Override
protected void setup(Context context) throws IOException, InterruptedException {
    URI[] cacheFiles = context.getCacheFiles();
    if (cacheFiles != null && cacheFiles.length > 0) {
        BufferedReader reader = new BufferedReader(
            new FileReader(new File("lookup.txt")));
        // Read and process file
    }
}
```

## Compilation and Execution

### Compile MapReduce Job
```bash
# Create directory structure
mkdir -p wordcount/classes

# Compile Java files
javac -classpath $(hadoop classpath) -d wordcount/classes \
    WordCount.java WordCountMapper.java WordCountReducer.java

# Create JAR file
jar -cvf wordcount.jar -C wordcount/classes/ .
```

### Run MapReduce Job
```bash
# Basic execution
hadoop jar wordcount.jar WordCount /input /output

# With custom configuration
hadoop jar wordcount.jar WordCount \
    -D mapreduce.job.reduces=5 \
    -D mapreduce.map.memory.mb=2048 \
    /input /output

# With specific queue
hadoop jar wordcount.jar WordCount \
    -D mapreduce.job.queuename=production \
    /input /output
```

## Practice Exercises

### Exercise 1: Word Count
1. Create a text file with sample content
2. Upload to HDFS
3. Implement WordCount MapReduce job
4. Run the job and verify output

### Exercise 2: Average Calculation
1. Create CSV data with numeric values
2. Implement Mapper to parse and emit values
3. Implement Reducer to calculate averages
4. Test with sample data

### Exercise 3: Join Operation
1. Create two datasets (e.g., students and grades)
2. Implement Map-side join using DistributedCache
3. Implement Reduce-side join using composite keys
4. Compare both approaches

### Exercise 4: Custom Partitioner
1. Implement custom partitioner based on key ranges
2. Test with multiple reducers
3. Verify output distribution

### Exercise 5: Secondary Sort
1. Create composite key (two fields)
2. Implement custom comparator
3. Use grouping comparator
4. Test sorting behavior

## Debugging Tips

### View Job Logs
```bash
# Get application logs
yarn logs -applicationId <app_id>

# View specific container logs
yarn logs -applicationId <app_id> -containerId <container_id>

# View job history
mapred job -history output
```

### Common Issues

#### OutOfMemory Error
```java
// Increase memory in configuration
conf.set("mapreduce.map.memory.mb", "4096");
conf.set("mapreduce.reduce.memory.mb", "8192");
conf.set("mapreduce.map.java.opts", "-Xmx3072m");
conf.set("mapreduce.reduce.java.opts", "-Xmx6144m");
```

#### Too Many Small Files
```java
// Use CombineFileInputFormat
job.setInputFormatClass(CombineTextInputFormat.class);
CombineTextInputFormat.setMaxInputSplitSize(job, 134217728); // 128MB
```

## Key Concepts to Remember

1. **Mapper** emits key-value pairs
2. **Shuffle and Sort** groups values by key
3. **Reducer** processes grouped values
4. **Combiner** is a mini-reducer on mapper side
5. **Partitioner** determines which reducer gets which keys
6. Use **Counters** for debugging and monitoring
7. **DistributedCache** for sharing small files
8. **Configuration** for job parameters
