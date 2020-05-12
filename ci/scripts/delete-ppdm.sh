#!/bin/bash
set -eu
govc about
govc vm.info ${PPDM_VMNAME}
echo "deleting PowerProtect Appliance ${PPDM_VMNAME}"
govc vm.destroy ${PPDM_VMNAME}
echo "done"
