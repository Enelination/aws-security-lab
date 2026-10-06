#!/usr/bin/env bash
set -euo pipefail

REGION="${AWS_REGION:-us-east-1}"
REPO="$(terraform -chdir=../terraform output -raw ecr_repository_url)"

aws ecr get-login-password --region "$REGION" |
  docker login --username AWS --password-stdin "${REPO%/*}"

docker build -t "${REPO}:lab-v1" ../app
docker push "${REPO}:lab-v1"

echo "Image pushed: ${REPO}:lab-v1"
