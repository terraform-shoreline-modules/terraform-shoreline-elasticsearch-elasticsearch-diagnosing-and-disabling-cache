resource "shoreline_notebook" "elastic_search_caching_issue" {
  name       = "elastic_search_caching_issue"
  data       = file("${path.module}/data/elastic_search_caching_issue.json")
  depends_on = [shoreline_action.invoke_elastic_search_diagnosis,shoreline_action.invoke_clear_cache_script]
}

resource "shoreline_file" "elastic_search_diagnosis" {
  name             = "elastic_search_diagnosis"
  input_file       = "${path.module}/data/elastic_search_diagnosis.sh"
  md5              = filemd5("${path.module}/data/elastic_search_diagnosis.sh")
  description      = "The Elastic Search cluster might have been overloaded with requests, causing the caching mechanism to fail and leading to slow response times."
  destination_path = "/tmp/elastic_search_diagnosis.sh"
  resource_query   = "host"
  enabled          = true
}

resource "shoreline_file" "clear_cache_script" {
  name             = "clear_cache_script"
  input_file       = "${path.module}/data/clear_cache_script.sh"
  md5              = filemd5("${path.module}/data/clear_cache_script.sh")
  description      = "Clear the cache on Elastic Search manually or programmatically."
  destination_path = "/tmp/clear_cache_script.sh"
  resource_query   = "host"
  enabled          = true
}

resource "shoreline_action" "invoke_elastic_search_diagnosis" {
  name        = "invoke_elastic_search_diagnosis"
  description = "The Elastic Search cluster might have been overloaded with requests, causing the caching mechanism to fail and leading to slow response times."
  command     = "`chmod +x /tmp/elastic_search_diagnosis.sh && /tmp/elastic_search_diagnosis.sh`"
  params      = ["REQUESTS_PER_SECOND","ES_URL"]
  file_deps   = ["elastic_search_diagnosis"]
  enabled     = true
  depends_on  = [shoreline_file.elastic_search_diagnosis]
}

resource "shoreline_action" "invoke_clear_cache_script" {
  name        = "invoke_clear_cache_script"
  description = "Clear the cache on Elastic Search manually or programmatically."
  command     = "`chmod +x /tmp/clear_cache_script.sh && /tmp/clear_cache_script.sh`"
  params      = ["ES_INDEX","ES_URL"]
  file_deps   = ["clear_cache_script"]
  enabled     = true
  depends_on  = [shoreline_file.clear_cache_script]
}

