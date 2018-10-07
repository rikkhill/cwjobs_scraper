# Role for scraper lambda
resource "aws_iam_role" "scraper_role" {
  name = "scraper-role"
  assume_role_policy = "${data.aws_iam_policy_document.scraper-assume-role.json}"
}

# AssumeRole policy document
data "aws_iam_policy_document" "scraper-assume-role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

# Logging policy
resource "aws_iam_role_policy" "scraper-cloudwatch-log-group" {
  name = "scraper-cloudwatch-log-group"
  role = "${aws_iam_role.scraper_role.name}"
  policy = "${data.aws_iam_policy_document.cloudwatch-log-group-scraper.json}"
}

# Logging policy document
data "aws_iam_policy_document" "cloudwatch-log-group-scraper" {
  statement {
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]

    resources = [
      "arn:aws:logs:::*",
    ]
  }
}

# DynamoDB policy
resource "aws_iam_role_policy" "scraper-results_table" {
  name = "scraper-dynamodb"
  role = "${aws_iam_role.scraper_role.name}"
  policy = "${data.aws_iam_policy_document.scraper_write_dynamodb.json}"
}

# DynamoDB policy document
data "aws_iam_policy_document" "scraper_write_dynamodb" {
  statement {
    effect = "Allow"

    actions = [
      "dynamodb:Query",
      "dynamodb:PutItem",
      "dynamodb:UpdateItem"
    ]

    resources = [
      "${aws_dynamodb_table.scraper_results_table.arn}",
      "${aws_dynamodb_table.scraper_results_table.arn}/index/*",

    ]
  }
}

# Archive package
data "archive_file" "scraper" {
  type = "zip"
  source_dir = "../scripts/project-dir"
  output_path = "output/scraper.zip"
}

# Contract lambda
resource "aws_lambda_function" "scraper_contract" {
  filename = "${data.archive_file.scraper.output_path}"
  function_name = "scraper_contract"
  role = "${aws_iam_role.scraper_role.arn}"
  handler = "scraper.handler"
  runtime = "python3.6"
  source_code_hash = "${base64sha256(file(data.archive_file.scraper.output_path))}"
  timeout = 4

  environment {
    variables = {
      SCRAPER_TERMS = "machine learning python",
      SCRAPER_TYPE = "contract"
    }
  }
}

# Permanent lambda
resource "aws_lambda_function" "scraper_permanent" {
  filename = "${data.archive_file.scraper.output_path}"
  function_name = "scraper_permanent"
  role = "${aws_iam_role.scraper_role.arn}"
  handler = "scraper.handler"
  runtime = "python3.6"
  source_code_hash = "${base64sha256(file(data.archive_file.scraper.output_path))}"
  timeout = 4

  environment {
    variables = {
      SCRAPER_TERMS = "machine learning python",
      SCRAPER_TYPE = "permanent"
    }
  }
}