# Security Agent Lab - Architecture Context

## Purpose

This is an isolated application security evaluation lab. The application intentionally contains
vulnerabilities so AWS Security Agent can discover, validate and later revalidate them.

## Components

- Internet-facing Application Load Balancer
- Amazon EKS
- Vulnerable Node.js API
- Amazon RDS for PostgreSQL
- Amazon ECR
- AWS Secrets Manager
- Amazon S3
- Amazon CloudWatch
- GitHub repository

## Trust boundaries

1. Internet -> ALB
2. ALB -> EKS service
3. EKS workload -> RDS
4. EKS workload -> AWS APIs
5. Developer -> GitHub/CI pipeline

## Sensitive assets

- User identities
- Authentication tokens
- Database credentials
- Application configuration
- Database records

## Intended security requirements

- Authentication must be enforced on protected resources.
- Authorization must be server-side and deny by default.
- SQL queries must use parameterized statements.
- Secrets must not be hard-coded.
- APIs should have rate limiting.
- File uploads must reject executable content.
- Audit events should be retained.
- Administrative endpoints must require an administrative role.
- Public infrastructure should expose only required ports.
