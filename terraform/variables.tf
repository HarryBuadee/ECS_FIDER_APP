
variable "aws_region" {
  description = "AWS region for the Fider infrastructure"
  type        = string
  default     = "eu-west-2"
}

variable "project_name" {
  description = "Name used to identify Fider resources"
  type        = string
  default     = "fider"
}

variable "vpc_cidr" {
  description = "CIDR block for the Fider VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_1_cidr" {
  description = "CIDR block for public subnet 1"
  type        = string
  default     = "10.0.1.0/24"
}

variable "public_subnet_2_cidr" {
  description = "CIDR block for public subnet 2"
  type        = string
  default     = "10.0.2.0/24"
}

variable "availability_zone_1" {
  description = "First availability zone"
  type        = string
  default     = "eu-west-2a"
}

variable "availability_zone_2" {
  description = "Second availability zone"
  type        = string
  default     = "eu-west-2b"
}

variable "domain_name" {
  description = "Domain name for the Fider application"
  type        = string
  default     = "fider.harrydev.net"
}





variable "db_name" {
  description = "Name of the Fider PostgreSQL database"
  type        = string
  default     = "fider"
}

variable "db_username" {
  description = "Master username for PostgreSQL"
  type        = string
  default     = "postgres"
}

variable "db_instance_class" {
  description = "RDS instance class"
  type        = string
  default     = "db.t3.micro"
}
