variable "vpc_cidr" {
  type = string
}

variable "subnet_cidrs" {
  type = list(string)
}

variable "aws_region" {
  type = string
}

variable "project_name" {
  type = string
}
