locals {
  common_tags = {
    Project     = var.name
    Environment = "lab"
  }
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "6.5.1"

  name = "${var.name}-vpc"
  cidr = "10.60.0.0/16"

  azs = [
    "us-east-1a",
    "us-east-1b",
    "us-east-1c"
  ]

  public_subnets = [
    "10.60.101.0/24",
    "10.60.102.0/24",
    "10.60.103.0/24"
  ]

  private_subnets = [
    "10.60.11.0/24",
    "10.60.12.0/24",
    "10.60.13.0/24"
  ]

  public_subnet_tags = {
    "kubernetes.io/role/elb" = "1"
  }

  private_subnet_tags = {
    "kubernetes.io/role/internal-elb" = "1"
  }

  enable_nat_gateway = true
  single_nat_gateway = true

  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = local.common_tags
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "21.26.0"

  name               = var.name
  kubernetes_version = var.eks_version

  endpoint_public_access = true

  enable_irsa = true

  vpc_id = module.vpc.vpc_id

  subnet_ids = [
    module.vpc.private_subnets[0],
    module.vpc.private_subnets[1]
  ]

  enable_cluster_creator_admin_permissions = true


  addons = {
    vpc-cni = {
      most_recent    = true
      before_compute = true
    }

    kube-proxy = {
      most_recent    = true
      before_compute = true
    }

    coredns = {
      most_recent    = true
      before_compute = true
    }
  }

  eks_managed_node_groups = {
    lab = {
      instance_types = ["t3.medium"]

      min_size     = 1
      max_size     = 1
      desired_size = 1

      disk_size = 30

      labels = {
        workload = "security-lab"
      }
    }
  }
}

resource "aws_ecr_repository" "api" {
  name                 = "${var.name}/vulnerable-api"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  force_delete = true

  tags = local.common_tags
}

resource "aws_s3_bucket" "context" {
  bucket_prefix = "${var.name}-context-"

  force_destroy = true

  tags = local.common_tags
}

resource "aws_s3_bucket_public_access_block" "context" {
  bucket = aws_s3_bucket.context.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_versioning" "context" {
  bucket = aws_s3_bucket.context.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_cloudwatch_log_group" "lab" {
  name              = "/aws/security-agent-lab"
  retention_in_days = 7

  tags = local.common_tags
}

resource "aws_secretsmanager_secret" "db" {
  name                    = "${var.name}/database"
  recovery_window_in_days = 0

  tags = local.common_tags
}

resource "aws_secretsmanager_secret_version" "db" {
  secret_id = aws_secretsmanager_secret.db.id

  secret_string = jsonencode({
    username = var.db_username
    password = var.db_password
    database = var.db_name
  })
}

resource "aws_db_subnet_group" "postgres" {
  name       = "${var.name}-postgres"
  subnet_ids = module.vpc.private_subnets

  tags = local.common_tags
}

resource "aws_security_group" "postgres" {
  name        = "${var.name}-postgres"
  description = "PostgreSQL access from the EKS node security group"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description     = "PostgreSQL from EKS nodes"
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [module.eks.node_security_group_id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = local.common_tags
}

resource "aws_db_instance" "postgres" {
  identifier = "${var.name}-postgres"

  engine         = "postgres"
  engine_version = "17"

  instance_class        = "db.t4g.micro"
  allocated_storage     = 20
  max_allocated_storage = 30
  storage_type          = "gp3"
  storage_encrypted     = true

  db_name  = var.db_name
  username = var.db_username
  password = var.db_password
  port     = 5432

  db_subnet_group_name   = aws_db_subnet_group.postgres.name
  vpc_security_group_ids = [aws_security_group.postgres.id]

  publicly_accessible     = false
  multi_az                = false
  deletion_protection     = false
  skip_final_snapshot     = true
  backup_retention_period = 0

  tags = local.common_tags
}
