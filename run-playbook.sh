#!/usr/bin/env bash
# Wrapper that runs a playbook inside the project EE via ansible-navigator.
# All settings (EE image, env injection, mode) come from ansible-navigator.yml.
#
# Usage: ./run-playbook.sh ansible/pb_circuit_failover.yml [extra args]
#        ./run-playbook.sh ansible/pb_circuit_failover.yml --extra-vars "failed_circuit=IPLC-GB-JP-PRI"

set -e

if [ -z "$1" ]; then
  echo "Usage: ./run-playbook.sh <playbook> [ansible-playbook args...]"
  exit 1
fi

if [ ! -f .env ]; then
  echo "ERROR: .env not found. Run ./setup.sh first."
  exit 1
fi

# Export AWS session credentials if the CLI is configured (SSO, profiles, etc.).
# Silently skipped when AWS CLI is not available or not authenticated.
eval "$(aws configure export-credentials --format env 2>/dev/null)" 2>/dev/null || true

# Mount RHEL 9 crypto policy overrides for IOS-XE < 17 (SHA-1 only SSH).
# When IOSXE_VERSION is unset or >= 17, the default crypto policy is used.
CRYPTO_ARGS=()
if [[ "${IOSXE_VERSION}" == 16.* || "${IOSXE_VERSION}" == 15.* ]]; then
  CRYPTO_DIR="ansible/files/crypto-policies"
  CRYPTO_ARGS=(
    --eev "${CRYPTO_DIR}/libssh-legacy.config:/etc/crypto-policies/back-ends/libssh.config:ro"
    --eev "${CRYPTO_DIR}/opensslcnf-legacy.config:/etc/crypto-policies/back-ends/opensslcnf.config:ro"
  )
fi

ansible-navigator run "$@" -i ansible/inventory/localhost.yml "${CRYPTO_ARGS[@]}"
