
### About Shoreline
The Shoreline platform provides real-time monitoring, alerting, and incident automation for cloud operations. Use Shoreline to detect, debug, and automate repairs across your entire fleet in seconds with just a few lines of code.

Shoreline Agents are efficient and non-intrusive processes running in the background of all your monitored hosts. Agents act as the secure link between Shoreline and your environment's Resources, providing real-time monitoring and metric collection across your fleet. Agents can execute actions on your behalf -- everything from simple Linux commands to full remediation playbooks -- running simultaneously across all the targeted Resources.

Since Agents are distributed throughout your fleet and monitor your Resources in real time, when an issue occurs Shoreline automatically alerts your team before your operators notice something is wrong. Plus, when you're ready for it, Shoreline can automatically resolve these issues using Alarms, Actions, Bots, and other Shoreline tools that you configure. These objects work in tandem to monitor your fleet and dispatch the appropriate response if something goes wrong -- you can even receive notifications via the fully-customizable Slack integration.

Shoreline Notebooks let you convert your static runbooks into interactive, annotated, sharable web-based documents. Through a combination of Markdown-based notes and Shoreline's expressive Op language, you have one-click access to real-time, per-second debug data and powerful, fleetwide repair commands.

### What are Shoreline Op Packs?
Shoreline Op Packs are open-source collections of Terraform configurations and supporting scripts that use the Shoreline Terraform Provider and the Shoreline Platform to create turnkey incident automations for common operational issues. Each Op Pack comes with smart defaults and works out of the box with minimal setup, while also providing you and your team with the flexibility to customize, automate, codify, and commit your own Op Pack configurations.

# Elastic Search Caching Issue

---
The Elastic Search Caching Issue is a common incident type where the caching feature of Elastic Search is not functioning as expected. This can cause delays or errors in retrieving search results and can impact the performance of the entire system. The issue typically requires troubleshooting and configuration changes to resolve.
### Parameters
```shell
export ES_HOST="PLACEHOLDER"
export ES_INDEX="PLACEHOLDER"
export ES_URL="PLACEHOLDER"
export REQUESTS_PER_SECOND="PLACEHOLDER"
```
## Debug

### Check if Elastic Search is running
```shell
systemctl status elasticsearch
```

### Check the Elastic Search cluster health
```shell
curl  -XGET  '${ES_HOST}:9200/_cluster/health?pretty'
```

### Check the Elastic Search index settings
```shell
curl  -XGET  '${ES_HOST}:9200/${ES_INDEX}/_settings?pretty'
```

### Check the Elastic Search index mapping
```shell
curl  -XGET  '${ES_HOST}:9200/${ES_INDEX}/_mapping?pretty'
```

### Disable caching for a specific index if needed
```shell
curl  -XPUT  '${ES_HOST}:9200/${ES_INDEX}/_settings'  -H  'Content-Type: application/json'  -d  '{"index": {"cache": {"query": {"enabled": false}}}}'
```

### Clear the Elastic Search cache if needed
```shell
curl  -XPOST  '${ES_HOST}:9200/_cache/clear'
```

### Check the Elastic Search cache stats
```shell
curl  -XGET  '${ES_HOST}:9200/_nodes/stats/indices/query_cache?pretty'
```

### The Elastic Search cluster might have been overloaded with requests, causing the caching mechanism to fail and leading to slow response times.
```shell
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
```

## Repair

### Clear the cache on Elastic Search manually or programmatically.
```shell
#!/bin/bash

# Set the Elastic Search URL
ELASTICSEARCH_URL=${ES_URL}

# Set the Elastic Search index
ELASTICSEARCH_INDEX=${ES_INDEX}

# Clear the cache
curl  -XPOST  "$ELASTICSEARCH_URL/$ELASTICSEARCH_INDEX/_cache/clear"
```