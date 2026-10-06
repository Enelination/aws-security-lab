variable "aws_region" {
  description = "AWS region for the lab"
  type        = string
  default     = "us-east-1"
}

variable "name" {
  description = "Name prefix"
  type        = string
  default     = "security-agent-lab"
}

variable "vpc_cidr" {
  type    = string
  default = "10.60.0.0/16"
}

variable "azs" {
  description = "Availability zones"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b"]
}

variable "db_name" {
  type    = string
  default = "securitylab"
}

variable "db_username" {
  type    = string
  default = "securitylab"
}

variable "db_password" {
  description = "Lab-only database password. Use a strong random value."
  type        = string
  sensitive   = true
}

variable "eks_version" {
  type    = string
  default = "1.33"
}

variable "node_instance_type" {
  type    = string
  default = "t3.medium"
}
