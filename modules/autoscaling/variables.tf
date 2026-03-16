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

variable "vpc_id" {
  description = "VPC ID where the EC2 instances will run"
  type        = string
}

variable "alb_sg_id" {
  description = "Security Group ID of the Application Load Balancer"
  type        = string
}