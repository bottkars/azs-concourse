#!/bin/bash
set -eu

echo "installing jq...."
DEBIAN_FRONTEND=noninteractive apt-get install -qq jq < /dev/null > /dev/null
exit 1
break some stuff