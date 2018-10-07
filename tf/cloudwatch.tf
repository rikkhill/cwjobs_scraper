resource "aws_cloudwatch_event_rule" "eleven-pm" {
    name = "11pm"
    description = "Fires at 11pm local time"
    schedule_expression = "cron(0 22 * * ? *)"
}

resource "aws_cloudwatch_event_target" "run_scraper_at_eleven_pm" {
    rule = "${aws_cloudwatch_event_rule.eleven-pm.name}"
    target_id = "check_foo"
    arn = "${aws_lambda_function.scraper_lambda.arn}"
}

resource "aws_lambda_permission" "allow_cloudwatch_to_call_check_foo" {
    statement_id = "AllowExecutionFromCloudWatch"
    action = "lambda:InvokeFunction"
    function_name = "${aws_lambda_function.scraper_lambda.function_name}"
    principal = "events.amazonaws.com"
    source_arn = "${aws_cloudwatch_event_rule.eleven-pm.arn}"
}