#!/bin/bash
cat /var/version && echo ""
set -eux
om --env env/"${ENV_FILE}" apply-changes \
    --skip-unchanged-products