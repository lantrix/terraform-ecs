locals {
  name   = "ecs-${replace(basename(path.cwd), "_", "-")}"
  tags = {
    Name       = local.name
  }
}

resource "aws_cloudwatch_log_group" "techdebug" {
  name              = "/aws/ecs/${local.name}"
  retention_in_days = 7
}
