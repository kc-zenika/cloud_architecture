#!/bin/bash
set -euo pipefail

# Run Terraform commands inside Docker to avoid requiring a local Terraform install.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
TF_DIR="${PROJECT_ROOT}/aws/development"
TF_WORKDIR="/project/aws/development"
TF_IMAGE="hashicorp/terraform:1.11.0"
PROVIDER_FILE="${TF_DIR}/provider.tf"

if ! command -v docker >/dev/null 2>&1; then
  echo "Error: docker is not installed. Install Docker Desktop first."
  exit 1
fi

if ! docker info >/dev/null 2>&1; then
  echo "Error: docker daemon is not running. Start Docker Desktop and try again."
  exit 1
fi

if [[ ! -d "${HOME}/.aws" ]]; then
  echo "Error: ~/.aws directory not found. Configure AWS SSO first."
  exit 1
fi

if [[ ! -f "${HOME}/.aws/config" ]]; then
  echo "Error: ~/.aws/config not found. Configure AWS SSO profile first."
  exit 1
fi

if [[ ! -d "${TF_DIR}" ]]; then
  echo "Error: Terraform directory not found at ${TF_DIR}"
  exit 1
fi

usage() {
  cat <<'EOF'
Usage: ./assets/tf_in_docker.sh <command> [extra terraform args]

Commands:
  init      terraform init
  plan      terraform plan
  apply     terraform plan -> apply
  destroy   terraform destroy
  destroy-plan terraform plan -destroy (preview only)
  base-apply   terraform init -> plan -> apply (for initial base resources)
  base-destroy terraform destroy (for cleanup)
  bootstrap-base setup backend + push assets + base-apply

Examples:
  ./assets/tf_in_docker.sh init
  ./assets/tf_in_docker.sh plan
  ./assets/tf_in_docker.sh apply
  ./assets/tf_in_docker.sh destroy
  ./assets/tf_in_docker.sh destroy-plan
  ./assets/tf_in_docker.sh base-apply
  ./assets/tf_in_docker.sh base-destroy
  ./assets/tf_in_docker.sh bootstrap-base
  ./assets/tf_in_docker.sh plan -var-file=dev.tfvars
EOF
}

if [[ $# -lt 1 ]]; then
  usage
  exit 1
fi

TF_CMD="$1"
shift

case "${TF_CMD}" in
  init|plan|apply|destroy|destroy-plan|base-apply|base-destroy|bootstrap-base)
    ;;
  *)
    echo "Error: unsupported command '${TF_CMD}'"
    usage
    exit 1
    ;;
esac

run_tf() {
  local cmd="$1"
  shift
  docker run --rm -it \
    -v "${PROJECT_ROOT}:/project" \
    -v "${HOME}/.aws:/root/.aws:ro" \
    -w "${TF_WORKDIR}" \
    -e AWS_PROFILE="${AWS_PROFILE:-}" \
    -e AWS_REGION="${AWS_REGION:-ap-southeast-1}" \
    -e AWS_DEFAULT_REGION="${AWS_DEFAULT_REGION:-ap-southeast-1}" \
    "${TF_IMAGE}" "${cmd}" "$@"
}

require_aws_cli() {
  if ! command -v aws >/dev/null 2>&1; then
    echo "Error: aws CLI is not installed. Install AWS CLI first."
    exit 1
  fi
}

sync_account_id_placeholders() {
  if [[ ! -f "${PROVIDER_FILE}" ]]; then
    echo "Error: provider file not found at ${PROVIDER_FILE}"
    exit 1
  fi

  local account_id
  account_id="$(aws sts get-caller-identity --query Account --output text)"

  if grep -q "<ACCOUNT_ID>" "${PROVIDER_FILE}"; then
    sed -i.bak "s/<ACCOUNT_ID>/${account_id}/g" "${PROVIDER_FILE}"
    rm -f "${PROVIDER_FILE}.bak"
    echo "Updated provider placeholders with account ID ${account_id}."
  fi
}

if [[ "${TF_CMD}" == "base-apply" ]]; then
  run_tf init
  run_tf plan
  run_tf apply
elif [[ "${TF_CMD}" == "destroy-plan" ]]; then
  run_tf plan -destroy
elif [[ "${TF_CMD}" == "base-destroy" ]]; then
  run_tf plan -destroy
  run_tf destroy
elif [[ "${TF_CMD}" == "bootstrap-base" ]]; then
  require_aws_cli
  "${PROJECT_ROOT}/assets/create_tfstate_backend.sh"
  "${PROJECT_ROOT}/assets/push_assets_to_s3.sh"
  sync_account_id_placeholders
  run_tf init -reconfigure
  run_tf plan
  run_tf apply
else
  if [[ "${TF_CMD}" == "destroy" ]]; then
    run_tf plan -destroy
    run_tf destroy "$@"
  fi
  if [[ "${TF_CMD}" == "apply" ]]; then
    run_tf plan
    run_tf apply "$@"
  else
    run_tf "${TF_CMD}" "$@"
  fi
fi
