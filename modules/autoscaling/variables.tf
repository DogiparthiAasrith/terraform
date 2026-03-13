variable "project_name" {
  description = "Project name used for naming resources"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "private_subnets" {
  description = "Private subnet IDs where EC2 instances will run"
  type        = list(string)
}

variable "target_group_arn" {
  description = "Target group ARN for the ALB"
  type        = string
}