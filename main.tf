terraform {
  backend "s3" {
    key    = "ecs/terraform.tfstate"
    region = "ap-southeast-2"
    dynamodb_table = "terraform-state"
  }
}

provider "aws" {
  profile = "techdebug"
  region = "ap-southeast-2"
}

locals {
  name   = "ecs-${replace(basename(path.cwd), "_", "-")}"
  tags = {
    Name       = local.name
  }
}

module "ecs" {
  source  = "./modules/services/ecs"
  region  = var.region
}

