#create the security group for rds instance
resource "aws_security_group" "sg_rds_postgres_instance" {
  vpc_id      = var.vpc_id
  name        = "SG RDS INSTANCE"
  description = "Allow app can access into the rds instance"
  ingress {
    description = "Allow all subnet in the vpc can accessable"
    from_port   = var.db_port
    to_port     = var.db_port
    protocol    = "tcp"
    cidr_blocks = [var.cidr_allow]
  }
  egress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = var.tags
}

#crate the db parameter group
resource "aws_db_parameter_group" "dbpg_rds_postgres" {
  name        = "postgres-pg"
  family      = var.parameter_group_family
  description = var.parameter_group_name_description
}


#create the postgresql
resource "aws_db_instance" "rds_postgre_db" {
  identifier = var.identifier_db
  db_name    = var.db_name

  username = var.username
  password = var.rd_pwd_postgre.result
  port     = var.db_port

  engine                = var.enginedb
  engine_version        = var.engine_version
  instance_class        = var.instance_class
  allocated_storage     = var.allocated_storage
  storage_type          = var.storage_type
  max_allocated_storage = var.max_allocated_storage

  # availability_zone   = var.availability_zone
  publicly_accessible = var.publicly_accessible

  vpc_security_group_ids  = [aws_security_group.sg_rds_postgres_instance.id]
  db_subnet_group_name    = var.db_subnet_group_name
  skip_final_snapshot     = var.skip_final_snapshot
  backup_retention_period = var.backup_retention_period

  apply_immediately = var.apply_immediately

  parameter_group_name = aws_db_parameter_group.dbpg_rds_postgres.name
  multi_az             = var.multi_az

  # #Temporary not running the performance insight
  # performance_insights_enabled = true
  # performance_insights_kms_key_id = aws_kms_key.kms_db_key.arn
  # performance_insights_retention_period = 0

  # monitoring_interval = var.monitoring_interval
  # monitoring_role_arn = var.iam_monitoring_interval_rds_arn

  tags = var.tags

}

#creat the ssm
resource "aws_ssm_parameter" "default_postgres_ssm_parameter_identifier" {
  count = var.storage_credential_to_ssm ? 1 : 0
  name  = format("/rds/db/%s/identifier", var.identifier_db)
  value = var.identifier_db
  type  = "String"
  tags  = var.tags
}

resource "aws_ssm_parameter" "default_postgres_ssm_parameter_endpoint" {
  count = var.storage_credential_to_ssm ? 1 : 0
  name  = format("/rds/db/%s/endpoint", var.identifier_db)
  value = aws_db_instance.rds_postgre_db.endpoint
  type  = "String"
  tags  = var.tags
}

resource "aws_ssm_parameter" "default_postgres_ssm_parameter_username" {
  count = var.storage_credential_to_ssm ? 1 : 0
  name  = format("/rds/db/%s/superuser/username", var.identifier_db)
  value = var.username
  type  = "String"
  tags  = var.tags
}

resource "aws_ssm_parameter" "default_postgres_ssm_parameter_password" {
  count = var.storage_credential_to_ssm ? 1 : 0
  name  = format("/rds/db/%s/superuser/password", var.identifier_db)
  value = aws_db_instance.rds_postgre_db.password
  type  = "String"
  tags  = var.tags
}
resource "aws_ssm_parameter" "default_postgres_db_name" {
  count = var.storage_credential_to_ssm ? 1 : 0
  name  = format("/rds/db/%s/dbname", var.db_name)
  value = var.db_name
  type  = "String"
  tags  = var.tags
}
