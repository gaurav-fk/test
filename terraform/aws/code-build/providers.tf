terraform {
  required_providers {
    buddy = {
      source  = "buddy/buddy"
      version = "~> 1.4.0"
    }
    aws        = ">= 3.22.0"
  }
}


provider "buddy" {
  token = var.buddy_token
}

provider "aws" {
  region = var.region
  profile = var.profile
}
