variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "vpc_cidr" {
  type    = string
  default = "10.0.0.0/16"
}

variable "public_subnets" {
  type    = list(string)
  default = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnets" {
  type    = list(string)
  default = ["10.0.10.0/24", "10.0.11.0/24"]
}

variable "instance_type" {
  type    = string
  default = "t3.micro"
}

variable "min_instances" {
  type    = number
  default = 2
}

variable "max_instances" {
  type    = number
  default = 4
}

variable "desired_instances" {
  type    = number
  default = 2
}

variable "db_identifier" {
  type    = string
  default = "app-db"
}

variable "db_instance_type" {
  type    = string
  default = "db.t3.micro"
}

variable "use_localstack" {
  type    = bool
  default = true
}
