locals {
  base_name = "${var.environment}-${var.project}-${var.engine}-${var.db_name}-encrypted"
}

resource "aws_security_group" "this" {
  description = "Controls access to RDS instance ${var.db_name} in ${var.environment}"
  vpc_id      = "${var.vpc_id}"

  tags {
    Name        = "${local.base_name}-sg"
    Environment = "${var.environment}"
    Project     = "${var.project}"
    Application = "${var.db_name}-${var.engine}"
  }
}

# Allow egress traffic
resource "aws_security_group_rule" "this" {
  security_group_id = "${aws_security_group.this.id}"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["${var.db_sg_egress_cidr}"]
  type              = "egress"
}

resource "aws_kms_key" "this" {
  description             = "Used to encrypt secrets related to ${local.base_name}"
  is_enabled              = true
  key_usage               = "ENCRYPT_DECRYPT"
  deletion_window_in_days = "${var.secrets_kms_keys_deletion_window_in_days}"

  tags {
    Environment = "${var.environment}"
    Project     = "${var.project}"
    Name        = "${local.base_name}-key"
  }
}

resource "aws_kms_alias" "this" {
  name          = "alias/${local.base_name}-secrets-key"
  target_key_id = "${aws_kms_key.this.arn}"
}

resource "aws_ssm_parameter" "this" {
  name        = "${local.base_name}-master"
  description = "${var.environment} ${var.project} DB ${var.db_name} master user password"
  type        = "SecureString"
  value       = "${var.password}"
  key_id      = "${aws_kms_key.this.id}"

  tags {
    Environment = "${var.environment}"
    Project     = "${var.project}"
    Name        = "${local.base_name}-db-user-password"
  }
}

resource "aws_db_instance" "this" {
  identifier                = "${local.base_name}"
  allocated_storage         = "${var.size}"
  engine                    = "${var.engine}"
  engine_version            = "${var.engine_version}"
  instance_class            = "${var.instance_class}"
  name                      = "${var.db_name}"
  username                  = "${var.username}"
  password                  = "${var.password}"
  db_subnet_group_name      = "${aws_db_subnet_group.this.name}"
  vpc_security_group_ids    = ["${aws_security_group.this.id}"]
  apply_immediately         = "${var.apply_immediately}"
  maintenance_window        = "${var.maintenance_window}"
  backup_window             = "${var.backup_window}"
  backup_retention_period   = "${var.backup_retention_period}"
  copy_tags_to_snapshot     = true
  skip_final_snapshot       = "${var.skip_final_snapshot}"
  final_snapshot_identifier = "final-${var.environment}-${var.db_name}-ss-before-deletion"
  parameter_group_name      = "${aws_db_parameter_group.this.id}"
  storage_encrypted         = true
  kms_key_id                = "${aws_kms_key.this.arn}"

  tags {
    Name        = "${var.environment}-${var.project}-${var.db_name}"
    Environment = "${var.environment}"
    Project     = "${var.project}"
    Application = "${var.db_name}-${var.engine}"
  }
}

resource "aws_db_subnet_group" "this" {
  name        = "${local.base_name}"
  description = "${var.engine} Subnet Group for ${var.db_name} System"
  subnet_ids  = ["${split(",", var.subnet_ids)}"]

  tags {
    Name        = "${local.base_name}-subnet-group-${var.engine}"
    Environment = "${var.environment}"
    Application = "${var.db_name}-db-subnet-group"
  }
}

#
# Parameter group for daily/normal operations
#
resource "aws_db_parameter_group" "this" {
  name = "${local.base_name}-cluster"

  # example fmaily: family = postgres9.6
  #family      = "${var.engine}${element(split(".",var.engine_version), 0)}.${element(split(".",var.engine_version), 1)}"
  family = "${var.parameter_group_family}"

  description = "${local.base_name} - parameter group"
}
