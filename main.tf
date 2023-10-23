terraform {
  required_version = ">= 0.13.1"

  required_providers {
    shoreline = {
      source  = "shorelinesoftware/shoreline"
      version = ">= 1.11.0"
    }
  }
}

provider "shoreline" {
  retries = 2
  debug = true
}

module "elastic_search_caching_issue" {
  source    = "./modules/elastic_search_caching_issue"

  providers = {
    shoreline = shoreline
  }
}