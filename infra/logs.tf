resource "aws_cloudwatch_log_group" "ecs" {
  name              = "/ecs/mlops-demo"
  retention_in_days = 7        # rotate weekly
}
