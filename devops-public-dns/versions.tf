terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 2"
    }
  }
  required_version = ">= 0.13"
}
