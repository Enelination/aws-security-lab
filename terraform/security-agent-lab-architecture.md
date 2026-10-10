# AWS Security Agent Evaluation Lab — Architecture

## 1. Purpose

This environment is a deliberately vulnerable AWS laboratory used to evaluate AWS Security Agent capabilities including code review, threat modeling, design review, penetration testing, remediation, and revalidation.

The environment is isolated as a dedicated security testing lab and is not intended for production workloads.

## 2. Architecture

Internet
  |
  v
Internet-facing Application Load Balancer
  |
  v
Amazon EKS
  |
  v
Vulnerable REST API
  |
  v
Private Amazon RDS PostgreSQL

Supporting services:

GitHub
  |
  v
Amazon ECR
  |
  v
Amazon EKS

Amazon EKS
  |
  +--> AWS Secrets Manager
  |
  +--> Amazon CloudWatch
  |
  +--> Amazon S3

## 3. Network Architecture

VPC CIDR:

10.60.0.0/16

Availability Zones:

- us-east-1a
- us-east-1b
- us-east-1c

Public subnets:

- 10.60.101.0/24
- 10.60.102.0/24
- 10.60.103.0/24

Private subnets:

- 10.60.11.0/24
- 10.60.12.0/24
- 10.60.13.0/24

The EKS cluster uses the first two private subnets.

The RDS PostgreSQL database uses private subnets and is not publicly accessible.

A single NAT Gateway provides outbound internet connectivity from private subnets.

## 4. Application Architecture

The application is a Node.js REST API running in Amazon EKS.

The application exposes:

- GET /health
- GET /api/users/:id
- GET /api/profile
- GET /api/admin/config

The application connects to Amazon RDS PostgreSQL.

## 5. Data Flow

External client
    |
    v
Internet-facing ALB
    |
    v
Kubernetes Service
    |
    v
Vulnerable API Pod
    |
    v
Private RDS PostgreSQL

The database is not directly reachable from the Internet.

## 6. Security Controls

The environment uses:

- Amazon EKS
- Kubernetes network boundaries
- AWS security groups
- Private RDS PostgreSQL
- AWS Secrets Manager
- Amazon S3 with public access blocked
- S3 versioning
- AWS KMS encryption
- Amazon ECR
- CloudWatch logging
- IAM roles
- EKS IRSA

## 7. External Exposure

The application is intentionally exposed through an internet-facing Application Load Balancer.

The ALB currently exposes HTTP port 80.

The application is deliberately vulnerable because the purpose of the environment is security testing.

## 8. Database

Database:

Amazon RDS PostgreSQL 17

Configuration:

- Private
- Not publicly accessible
- Port 5432
- Encrypted storage
- Access restricted through a security group
- Database access originates from the EKS workload/node security boundary

## 9. Identity and Secrets

Application database credentials are stored in AWS Secrets Manager and supplied to the Kubernetes workload.

The application also uses JWT-based authentication.

## 10. Security Testing Objective

The environment is designed to evaluate whether AWS Security Agent can:

1. Identify application vulnerabilities.
2. Identify architectural security weaknesses.
3. Identify realistic threats and attack paths.
4. Assess an internet-facing application.
5. Assess resources within a private VPC.
6. Recommend or generate remediation.
7. Revalidate the environment after remediation.

## 11. Trust Boundaries

The primary trust boundaries are:

1. Internet → ALB
2. ALB → EKS application
3. EKS application → private RDS
4. GitHub → ECR → EKS deployment
5. EKS workload → AWS services
6. Security testing operator → AWS Security Agent