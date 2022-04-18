variable "buddy_token" {}

variable "domain" {}


variable "profile" {}
variable "env" {}


# variable "vpc_cidr" {}
variable "vpc_id" {}
variable "private_subnets" {
  type = list(string)
}

# variable "vpc_public_subnets" {
#   type = list(string)
# }


variable "region" {
  default = "ap-south-1"
}
