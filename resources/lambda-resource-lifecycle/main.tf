locals {
  env = yamldecode(file("${path.module}/../../environments/sentinel.yaml"))
}

terraform {
  required_version = ">= 1.10.5"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  backend "s3" {
    bucket         = "development-sentinel-sandbox-tf-state"
    key            = "sentinel/lambda-resource-lifecycle/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "development-sentinel-sandbox-tf-state-lock"
  }
}

module "lambda-resource-lifecycle" {
  source  = "../../modules/lambda-resource-lifecycle"
  tags    = local.env.tags
  aws_region_main = local.env.lambda_function.aws_region_main

  ec2_lifecycle_config = {
    lambda_timeout_ec2     = local.env.lambda_function.lambda_timeout_ec2
    lambda_timeout_logger  = local.env.lambda_function.lambda_timeout_logger
    cost_threshold         = local.env.lambda_function.cost_threshold
    micro_max_age_days     = local.env.lambda_function.micro_max_age_days
    default_max_age_days   = local.env.lambda_function.default_max_age_days
    mattermost_webhook_url = local.env.lambda_function.mattermost_webhook_url
  }
}
