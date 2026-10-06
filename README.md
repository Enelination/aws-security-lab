# AWS Security Agent Evaluation Lab

Phase 1 provisions a cost-conscious AWS foundation for the AWS Security Agent evaluation:

- VPC with public/private subnets
- EKS cluster with one small managed node
- ECR repository
- S3 security-agent context bucket
- Secrets Manager test credentials
- CloudWatch log group
- RDS PostgreSQL
- AWS Load Balancer Controller prerequisites
- Vulnerable demo API scaffold
- Kubernetes manifests
- Security Agent CLI/API helper scripts

## Important

This repository contains intentionally vulnerable application code for an isolated security lab.
Do NOT expose it to real users or production data.

Phase 1 does not automatically start an AWS Security Agent pentest. We will first verify the
application, target ownership, scope and credentials, then create the pentest with the current
Security Agent API.

## Estimated cost

EKS control plane, NAT gateways, RDS and other AWS resources can incur charges. For the first
run, use one NAT gateway and small instances. Destroy the environment when finished:

    terraform destroy

## Prerequisites

- AWS CLI configured
- Terraform >= 1.9
- kubectl
- Helm
- Docker
- An AWS account with permission to create the resources

## Deploy

    cd terraform
    cp terraform.tfvars.example terraform.tfvars
    # edit region, DB password and other values

    terraform init
    terraform plan
    terraform apply

Then configure kubectl:

    aws eks update-kubeconfig --region <REGION> --name security-agent-lab

Build/push the API:

    cd ../app
    docker build -t security-agent-demo:latest .
    # tag/push to the ECR repository output by Terraform

The next phase will install the AWS Load Balancer Controller, deploy the app, configure Route 53
and wire AWS Security Agent.
# aws-security-lab
