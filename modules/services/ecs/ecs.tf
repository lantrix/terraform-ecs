variable "region" {}

module "cwlogs" {
  source  = "../cwlogs"
}

module "vpc" {
  source  = "../vpc"
  region  = var.region
}

resource "aws_ecs_cluster" "techdebug" {
  name = "techdebug-cluster"
  configuration {
    execute_command_configuration {
      logging    = "OVERRIDE"
      log_configuration {
        cloud_watch_encryption_enabled = false
        cloud_watch_log_group_name = "${module.cwlogs.cwlogs_groupname}"
      }
    }
  }
}

resource "aws_ecs_cluster_capacity_providers" "techdebug" {
  cluster_name = aws_ecs_cluster.techdebug.name

  capacity_providers = ["FARGATE"]

  default_capacity_provider_strategy {
    base              = 1
    weight            = 100
    capacity_provider = "FARGATE"
  }
}

resource "aws_iam_role" "ecs_task_execution_role" {
  name = "role-name"

  assume_role_policy = <<EOF
{
 "Version": "2012-10-17",
 "Statement": [
   {
     "Action": "sts:AssumeRole",
     "Principal": {
       "Service": "ecs-tasks.amazonaws.com"
     },
     "Effect": "Allow",
     "Sid": ""
   }
 ]
}
EOF
}

resource "aws_iam_role" "ecs_task_role" {
  name = "techdebug-task"

  assume_role_policy = <<EOF
{
 "Version": "2012-10-17",
 "Statement": [
   {
     "Action": "sts:AssumeRole",
     "Principal": {
       "Service": "ecs-tasks.amazonaws.com"
     },
     "Effect": "Allow",
     "Sid": ""
   }
 ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "ecs-task-execution-role-policy-attachment" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_ecs_task_definition" "bogo-test" {
  family                   = "bogo-test"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = 1024
  memory                   = 2048
  container_definitions    = <<TASK_DEFINITION
[
  {
    "name": "bogo",
    "image": "dockerbogo/docker-nginx-hello-world",
    "cpu": 1024,
    "memory": 2048,
    "essential": true
  }
]
TASK_DEFINITION
}

resource "aws_iam_role_policy" "bogo_test_policy" {
  name = "bogo_test_policy"
  role = aws_iam_role.ecs_task_role.id

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "ec2:Describe*",
        ]
        Effect   = "Allow"
        Resource = "*"
      },
    ]
  })
}

resource "aws_lb_target_group" "techdebug" {
  name        = "techdebug-lb-alb-tg"
  target_type = "alb"
  port        = 80
  protocol    = "TCP"
  vpc_id      = "${module.vpc.vpc_id}"
}

resource "aws_ecs_service" "echo" {
  name            = "echo"
  cluster         = aws_ecs_cluster.techdebug.id
  task_definition = aws_ecs_task_definition.bogo-test.arn
  desired_count   = 1
  iam_role        = aws_iam_role.ecs_task_role.arn
  depends_on      = [aws_iam_role_policy.bogo_test_policy]

  load_balancer {
    target_group_arn = aws_lb_target_group.techdebug.arn
    container_name   = "bogo-test"
    container_port   = 80
  }
}
