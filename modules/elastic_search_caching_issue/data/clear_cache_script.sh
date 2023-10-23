#!/bin/bash

# Set the Elastic Search URL
ELASTICSEARCH_URL=${ES_URL}

# Set the Elastic Search index
ELASTICSEARCH_INDEX=${ES_INDEX}

# Clear the cache
curl  -XPOST  "$ELASTICSEARCH_URL/$ELASTICSEARCH_INDEX/_cache/clear"