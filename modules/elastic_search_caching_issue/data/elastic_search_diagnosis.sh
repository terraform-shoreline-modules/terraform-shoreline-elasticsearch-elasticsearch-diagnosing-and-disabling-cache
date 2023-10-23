#!/bin/bash

# Set variables
ELASTICSEARCH_URL=${ES_URL}
REQUESTS_PER_SECOND=${REQUESTS_PER_SECOND}

# Check if Elastic Search is responding
curl  -s  -o /dev/null -w  "%{http_code}\n"  $ELASTICSEARCH_URL
if [ $?  -ne  0 ]; then
echo  "Error: Elastic Search is not responding."
exit  1
fi

# Check if there are any network issues
ping  -c  4  $ELASTICSEARCH_URL
if [ $?  -ne  0 ]; then
echo  "Error: There are network issues between the server and Elastic Search."
exit  1
fi

# Check the current load on the server
load=$(uptime | awk -F'[a-z]:' '{ print $2 }' | awk '{ print $1 }')
if [ $(echo "$load > 2" | bc)  -ne  0 ]; then
echo  "Warning: The server load is high."
fi

# Check the current number of requests per second to Elastic Search
requests=$(curl -s $ELASTICSEARCH_URL/_nodes/stats/indices/search | grep -oP "query_total\"\:\K\d+")
if [ $requests  -gt  $REQUESTS_PER_SECOND ]; then
echo  "Warning: The current number of requests per second to Elastic Search is high."
fi

# Check if Elastic Search is using the caching mechanism
cache_enabled=$(curl -s $ELASTICSEARCH_URL/_nodes/stats/indices/search | grep -oP "cache\:\s*\{.*\}" | grep -oP "memory_cache\:\s*\{.*\}" | grep -oP "enabled\"\:\s*\K.*?(?=\,)")
if [ "$cache_enabled" = "false" ]; then
echo "Error: Caching is not enabled in Elastic Search."
exit 1
fi

echo "Diagnosis complete. No issues found."
exit 0