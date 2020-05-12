#!/bin/bash
set -eu
govc about
govc vm.info ${PPDM_VMNAME}
echo "deleteing ${PPDM_VMNAME}"
govc vm.destroy ${PPDM_VMNAME}
echo "done"
