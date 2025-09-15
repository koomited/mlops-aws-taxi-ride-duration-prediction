terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.15"
    }
  }
}






provider "aws" {
    region = var.aws_region  
}

data "aws_caller_identity" "current_identity" {

  
}

locals {
  account_id = data.aws_caller_identity.current_identity.account_id
}


# ride-events
module "source_kinesis_stream" {
    source = "./modules/kinesis"
    stream_name = "${var.source_stream_name}-${var.project_id}"
    retention_period = 48
    shard_count = 2
    tags = var.project_id
  
}

# ride prediction

module "output_kinesis_stream" {
    source = "./modules/kinesis"
    stream_name = "${var.output_stream_name}-${var.project_id}"
    retention_period = 48
    shard_count = 2
    tags = var.project_id
  
}


# model bucket
module "s3_bucket" {
    source = "./modules/s3"
    bucket_name = "${var.model_bucket}-${var.project_id}"
}

module "ecr_image" {
    source = "./modules/ecr"
    ecr_repo_name = "${var.ecr_repo_name}_${var.project_id}"
    account_id =  local.account_id
    lambda_function_local_path = var.lambda_function_local_path
    docker_image_local_path = var.docker_image_local_path
  
}


module "lambda_function" {
    source = "./modules/lambda"
    image_uri = module.ecr_image.image_uri
    lambda_function_name = "${var.lambda_function_name}-${var.project_id}"
    model_bucket = module.s3_bucket.name
    output_stream_name = "${var.output_stream_name}-${var.project_id}"
    output_stream_arn = module.output_kinesis_stream.stream_arn
    source_stream_name = "${var.source_stream_name}-${var.project_id}"
    source_stream_arn = module.source_kinesis_stream.stream_arn
  
}

# for ci cd

# For CI/CD
output "lambda_function" {
  value     = "${var.lambda_function_name}_${var.project_id}"
}

output "model_bucket" {
  value = module.s3_bucket.name
}

output "predictions_stream_name" {
  value     = "${var.output_stream_name}-${var.project_id}"
}

output "ecr_repo" {
  value = "${var.ecr_repo_name}_${var.project_id}"
}