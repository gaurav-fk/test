resource "buddy_integration" "aws" {
  domain     = var.domain
  name       = "ecr access"
  type       = "AMAZON"
  scope      = "ADMIN"
  access_key = "AKIAYC6C772XTY2YTU76"
  secret_key = "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"
}