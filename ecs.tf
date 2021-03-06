﻿data "aws_iam_policy_document" "ecs_agent" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "ecs_agent" {
  name               = "ecs-agent"
  assume_role_policy = data.aws_iam_policy_document.ecs_agent.json
}

resource "aws_iam_role_policy_attachment" "ecs_agent" {
  role       = aws_iam_role.ecs_agent.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}
resource "aws_iam_instance_profile" "ecs_agent" {
  name = "ecs-agent"
  role = aws_iam_role.ecs_agent.name
}

resource "aws_launch_configuration" "ecs_launch_config" {
  image_id             = "ami-04f10c2331981345c"
  iam_instance_profile = aws_iam_instance_profile.ecs_agent.name
  security_groups      = [aws_security_group.ecs_sg.id]
  user_data            = "#!/bin/bash\necho ECS_CLUSTER=publate-cluster >> /etc/ecs/ecs.config"
  instance_type        = "t3.nano"
  key_name = "patch"
  associate_public_ip_address = true
}

resource "aws_autoscaling_group" "failure_analysis_ecs_asg" {
  name                      = "asg"
  vpc_zone_identifier       = [
    aws_subnet.pub_subnet[0].id,
    aws_subnet.pub_subnet[1].id,
    aws_subnet.pub_subnet[2].id
  ]
  launch_configuration      = aws_launch_configuration.ecs_launch_config.name

  desired_capacity          = 1
  min_size                  = 1
  max_size                  = 2
  health_check_grace_period = 300
  health_check_type         = "EC2"
}

resource "aws_ecr_repository" "api" {
  name  = "api"
}

resource "aws_ecs_cluster" "ecs_cluster" {
  name  = "publate-cluster"
}

data "template_file" "task_definition_template" {
  template = file("ecs-task-definition.json")
  vars = {
    REPOSITORY_URL = replace(aws_ecr_repository.api.repository_url, "https://", "")
  }
}

resource "aws_ecs_service" "api" {
  name            = "api"
  cluster         = aws_ecs_cluster.ecs_cluster.id
  desired_count   = 1
  deployment_minimum_healthy_percent = 0
  deployment_maximum_percent = 100

  load_balancer {
    target_group_arn = aws_alb_target_group.main.id
    container_name   = "api"
    container_port   = 80
  }
}

output "ecr_repository_api_endpoint" {
  value = aws_ecr_repository.api.repository_url
}