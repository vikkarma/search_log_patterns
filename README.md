# search_log_patterns
awk search log patterns
Assumes logs directory containing all the logs to parse in home directory

# Example 1
sh ./search_log_patterns.sh -f ./hbase_exception_patterns -ho true

# Example 2
sh ./search_log_patterns.sh -f ./hbase_exception_patterns -d true

# Example 3
sh ./search_log_patterns.sh -f ./hbase_exception_patterns 

