variable "region" {
  description = "AWS region"
  default     = "us-east-1"
}

variable "vpc_name" {
  default = "main"
}

variable "env_prefix" {

}

variable "cidrvpc" {
  default = "10.0.0.0/16"
}

variable "default_tags" {
  default = {
    Owner = "sonlh"
  }
}

variable "create_s3_bucket" {
  default = true
}

variable "cluster_endpoint_public_access" {

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