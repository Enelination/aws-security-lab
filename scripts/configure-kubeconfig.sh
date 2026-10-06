#!/usr/bin/env bash
set -euo pipefail

REGION="${AWS_REGION:-us-east-1}"
CLUSTER="$(terraform -chdir=../terraform output -raw cluster_name)"

aws eks update-kubeconfig \
  --region "$REGION" \
  --name "$CLUSTER"

kubectl get nodes
