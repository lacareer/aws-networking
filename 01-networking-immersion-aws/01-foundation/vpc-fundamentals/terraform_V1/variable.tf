variable "profile" {
  description = "AWS CLI profile to use."
  default     = "my-sandbox"
  type        = string
}

variable "region" {
  description = "AWS region to use."
  default     = "us-east-1"
  type        = string
}

variable "config_tags" {
  description = "A map of tags to apply to resources."
  type        = map(string)
  default = {
    Environment = "dev"
    Owner       = "Network Team"
    company     = "chukky.com"
  }
}

# variable "instances_required" {
#   description = "Number of EC2 instances to create."
#   default     = ["public", "private"]
#   type        = list(string)
# }