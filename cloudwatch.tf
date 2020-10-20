module "cloudwatch-alarms" {
  source  = "clouddrove/cloudwatch-alarms/aws"
  version = "0.12.4"
  
  alarm_name = "Publate API - no healthy hosts"
  comparison_operator = "LessThanThreshold"
  evaluation_periods = 1
  alarm_actions = [var.sns_alarm_arn]
  period = 5*60
  
  namespace = "AWS/ApplicationELB"
  metric_name = "HealthyHostCount"
  threshold = "1"
  dimensions = {
    LoadBalancer = aws_alb.main.arn_suffix
    TargetGroup = aws_alb_target_group.main.arn_suffix
  }
}
