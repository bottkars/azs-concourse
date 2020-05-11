#!/bin/bash
set -eu
echo "deleteing ${PPDM_VMNAME}"

govc about

govc vm.destroy  ${PPDM_VMNAME}
