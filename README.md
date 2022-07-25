# terraform-ecs

Sets up an ECS cluster with Fargate containers
## Setup

### Remote State

Ensure using [S3 remote state](https://github.com/lantrix/terraform-remote-state-s3)

```shell
export accountId=$(aws sts get-caller-identity --query Account --output text)
terraform init
```

### Deploy

```shell
terraform plan
terraform apply
```
