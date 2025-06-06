# main.tf
terraform {
  required_version = ">= 1.3"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.50"
    }
  }

  backend "s3" {
    bucket         = "mlops-demo-tfstate-379478996241"
    key            = "infra/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "mlops-demo-tf-lock"   # ← delete this line if you skipped the lock table
  }
}


provider "aws" {
  region = var.aws_region
}

data "aws_caller_identity" "me" {}

# ── S3 bucket that will act as a very simple “model registry” ──
resource "aws_s3_bucket" "model_registry" {
  bucket        = "${var.project}-registry-${data.aws_caller_identity.me.account_id}"
  force_destroy = true          # allow ‘terraform destroy’ to delete objects too
}

output "registry_bucket" {
  value = aws_s3_bucket.model_registry.bucket
}
