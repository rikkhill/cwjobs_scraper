resource "aws_cloudwatch_event_rule" "eleven-pm" {
  name = "11pm"
  description = "Fires at 11pm local time"
  schedule_expression = "cron(0 23 * * ? *)"
}

# Contract scraper

resource "aws_cloudwatch_event_target" "run_contract_scraper_at_eleven_pm" {
  rule = "${aws_cloudwatch_event_rule.eleven-pm.name}"
  arn = "${aws_lambda_function.scraper_contract.arn}"
}

resource "aws_lambda_permission" "allow_cloudwatch_to_call_contract_scraper" {
  statement_id = "AllowExecutionFromCloudWatch"
  action = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.scraper_contract.function_name}"
  principal = "events.amazonaws.com"
  source_arn = "${aws_cloudwatch_event_rule.eleven-pm.arn}"
}

# Permanent scraper

resource "aws_cloudwatch_event_target" "run_permanent_scraper_at_eleven_pm" {
  rule = "${aws_cloudwatch_event_rule.eleven-pm.name}"
  arn = "${aws_lambda_function.scraper_permanent.arn}"
}

resource "aws_lambda_permission" "allow_cloudwatch_to_call_permanent_scraper" {
  statement_id = "AllowExecutionFromCloudWatch"
  action = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.scraper_permanent.function_name}"
  principal = "events.amazonaws.com"
  source_arn = "${aws_cloudwatch_event_rule.eleven-pm.arn}"
}