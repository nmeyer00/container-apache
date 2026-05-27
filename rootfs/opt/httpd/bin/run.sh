#!/bin/bash
# shellcheck disable=SC1091

set -o errexit
set -o nounset
set -o pipefail
# set -o xtrace # Uncomment this line for debugging purposes

. /opt/httpd/lib/colors.sh
. /opt/httpd/lib/httpd.env

#cat $APACHE_CONF_FILE


# Create new Self Signed Certificate SSL
openssl req -x509 -newkey rsa:4096 -keyout /opt/httpd/etc/ssl/selfsigned.key -out /opt/httpd/etc/ssl/selfsigned.crt -sha256 -days 3650 -nodes -subj "/C=DE/ST=StateName/L=CityName/O=CompanyName/OU=IT/CN=localhost"


printf "${BLUE} -> DEBUG Apache Module:\n $(httpd -M -f /opt/httpd/etc/httpd.conf) ${RESET}\n"
printf "${GREEN} -> Running httpd in forground on Port: ${APACHE_LISTEN_PORT} ${RESET}\n"

"${APACHE_BIN_DIR}/httpd" -DFOREGROUND -f "$APACHE_CONF_FILE"