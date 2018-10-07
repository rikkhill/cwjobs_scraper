# DynamoDB table for writing scraper results

resource "aws_dynamodb_table" "scraper_results_table" {
  name                        = "scraper_results"
  read_capacity               = "1"
  write_capacity              = "1"
  hash_key                    = "scraper_id"
  range_key                   = "date"

  attribute {
    name                      = "scraper_id"
    type                      = "S"
  }

  attribute {
    name                      = "date"
    type                      = "N"
  }

  ttl {
    attribute_name            = "TimeToExist"
    enabled                   = false
  }
}