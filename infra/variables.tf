variable "project_name" {

}

variable "region" {

}

variable "vpc_name" {

}

variable "env_prefix" {

}

variable "cidrvpc" {

}

variable "default_tags" {
  default = {
    Owner = "sonlh"
  }
}

variable "create_s3_bucket" {
  default = true
}

variable "single_nat_gateway" {

}
variable "enable_nat_gateway" {

}
variable "enable_dns_hostnames" {

}
variable "create_database_subnet_group" {

}
variable "create_database_subnet_route_table" {

}
variable "create_database_internet_gateway_route" {

}
variable "enable_flow_log" {

}
variable "create_flow_log_cloudwatch_iam_role" {

}

variable "create_flow_log_cloudwatch_log_group" {

}
variable "eks_config" {

}

variable "rds_config" {

}
