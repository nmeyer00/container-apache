#!/bin/bash
# shellcheck disable=SC1091

set -o errexit
set -o nounset
set -o pipefail
# set -o xtrace # Uncomment this line for debugging purposes

. /opt/httpd/lib/httpd.env

printf "${GREEN} -> Stopping httpd${RESET}\n"
"${APACHE_BIN_DIR}/httpd" -k stop

