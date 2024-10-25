

locals {
  azs        = length(data.aws_availability_zones.available.names)
  account_id = data.aws_caller_identity.current.account_id
}
resource "random_integer" "this" {
  min = 0
  max = 2
}

resource "random_string" "random" {
  length           = 16
  special          = true
  override_special = "!#$&*()-=+[]{}<>:?"
}

module "s3" {
  source       = "./_modules/s3"
  project_name = var.project_name
}

module "vpc" {
  source                                 = "./_modules/network"
  vpc_cidr                               = var.cidrvpc
  vpc_name                               = var.vpc_name
  enable_nat_gateway                     = var.enable_nat_gateway
  single_nat_gateway                     = var.single_nat_gateway
  enable_dns_hostnames                   = var.enable_dns_hostnames
  create_database_subnet_group           = var.create_database_subnet_group
  create_database_subnet_route_table     = var.create_database_subnet_route_table
  create_database_internet_gateway_route = var.create_database_internet_gateway_route
  enable_flow_log                        = var.enable_flow_log
  create_flow_log_cloudwatch_iam_role    = var.create_flow_log_cloudwatch_iam_role
  create_flow_log_cloudwatch_log_group   = var.create_flow_log_cloudwatch_log_group
  cluster_name                           = var.eks_config.cluster_name
  default_tags = merge(
    var.default_tags
  )
}

#CREATE THE EKS CLUSTER
module "eks" {
  depends_on = [
    module.vpc
  ]
  source                                         = "./_modules/eks"
  vpc_id                                         = module.vpc.vpc_id
  private_subnet_ids                             = module.vpc.vpc_private_subnet_ids
  intranet_subnet_ids                            = module.vpc.intra_subnet_ids
  env_prefix                                     = var.env_prefix
  cluster_name                                   = var.eks_config.cluster_name
  cluster_version                                = var.eks_config.cluster_version
  min_size                                       = var.eks_config.min_size
  max_size                                       = var.eks_config.max_size
  eks_managed_node_group_defaults_instance_types = var.eks_config.eks_managed_node_group_defaults_instance_types
  manage_aws_auth_configmap                      = var.eks_config.manage_aws_auth_configmap
  instance_types                                 = var.eks_config.instance_types
  endpoint_public_access                         = var.eks_config.endpoint_public_access
  cluster_endpoint_public_access_cidrs           = var.eks_config.cluster_endpoint_public_access_cidrs
  eks_cw_logging                                 = var.eks_config.eks_cw_logging
  default_tags                                   = var.default_tags
}

module "ecr" {
  source       = "./_modules/ecr"
  project_name = var.project_name
}

module "rds" {
  depends_on = [
    module.vpc
  ]
  source                           = "./_modules/rds"
  vpc_id                           = module.vpc.vpc_id
  allocated_storage                = var.rds_config.allocated_storage
  max_allocated_storage            = var.rds_config.max_allocated_storage
  apply_immediately                = var.rds_config.apply_immediately
  skip_final_snapshot              = var.rds_config.skip_final_snapshot
  db_subnet_group_name             = module.vpc.vpc_db_subnet_group_name
  availability_zone                = var.rds_config.availability_zone
  backup_retention_period          = var.rds_config.backup_retention_period
  cidr_allow                       = var.rds_config.cidr_allow
  username                         = var.rds_config.username
  rd_pwd_postgre                   = random_string.random
  identifier_db                    = var.rds_config.identifier_db
  db_name                          = var.rds_config.db_name
  enginedb                         = var.rds_config.enginedb
  engine_version                   = var.rds_config.engine_version
  instance_class                   = var.rds_config.instance_class
  db_port                          = var.rds_config.db_port
  storage_type                     = var.rds_config.storage_type
  publicly_accessible              = var.rds_config.publicly_accessible
  parameter_group_family           = var.rds_config.parameter_group_family
  parameter_group_name_description = var.rds_config.parameter_group_name_description
  multi_az                         = var.rds_config.multi_az
  storage_credential_to_ssm        = var.rds_config.storage_credential_to_ssm
  tags = merge(
    var.default_tags
  )
}
