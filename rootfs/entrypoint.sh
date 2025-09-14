#!/bin/bash
set -e
# shellcheck disable=SC1091

set -o errexit
set -o nounset
set -o pipefail
# set -o xtrace # Uncomment this line for debugging purposes

. /opt/httpd/lib/colors.sh

# Loading Enviroment from file
printf "${GREEN} ->  Loading Build Enviroment... ${RESET}\n"
source /opt/httpd/bin/loadenv.sh /opt/httpd/lib/httpd.env
printf "${YELLOW} ->  done ${RESET}\n"
printf "${GREEN} -> Docker Imageversion: $(cat /etc/image-version) ${RESET}\n"


for defaultVars in $(env | grep "^APACHE_"); do
    # Remove präfix APACHE_
    baseName="${defaultVars#APACHE_}"
    # Split <name>=<value>
    defaultVarEnvKey="${baseName%%=*}"
    defaultVarEnvValue="${baseName#*=}"

    # Get docker env Name -> see Readme.txt: Enviroment
    defaultEnvKey="${defaultVars%%=*}"
    defaultEnvValue="$(printenv "$defaultVarEnvKey" || true)"

    # Replacing default enviroment with docker enviroment
    if [[ -v defaultEnvValue && -n "$defaultEnvValue" ]]; then
        printf "${GREEN} -> Found enviroment var: $defaultVarEnvKey with $defaultEnvValue ${RESET}\n"
        if [ "APACHE_${defaultVarEnvKey}" == "${defaultEnvKey}" ]; then
            printf "${GREEN} -> Found Docker enviroment Variabel: ${defaultVarEnvKey} ${RESET}\n"
            if [ ${defaultVarEnvKey} != ${defaultEnvValue} ]; then
                printf "${YELLOW} -> Replacing "APACHE_${defaultVarEnvKey}" with ${defaultEnvValue} ${RESET}\n"
                export "APACHE_${defaultVarEnvKey}"="$defaultEnvValue"
            fi
        fi
    fi
done

envsubst < /opt/httpd/templates/httpd.tpl > /opt/httpd/etc/httpd.conf

printf "${BLUE} -> DEBUG: vars:\n$(env) ${RESET}\n"

modules="
APACHE_ENABLE_ACCESS_LOG=enable-access-log.conf
APACHE_MOD_REWRITE=enable-mod-rewrite.conf
APACHE_MOD_MPM_PREFORK=enable-mod-prefork.conf
APACHE_MOD_CGI=enable-mod-cgi.conf
APACHE_MOD_STATUS=enable-mod-status.conf
APACHE_MOD_MPM_EVENT=enable-mod-mpm-event.conf
APACHE_MOD_NEGOTIATION=enable-mod-negotiation.conf
APACHE_MOD_DEFLATE=enable-mod-deflate.conf
APACHE_MOD_AUTOINDEX=enable-mod-autoindex.conf
APACHE_MOD_MIME=enable-mod-mime.conf
APACHE_MOD_DAV=enable-mod-dav.conf
APACHE_MOD_PROXY=enable-mod-proxy.conf
APACHE_MOD_SSL=enable-mod-ssl.conf
"

for entry in $modules; do
    moduleName=$(printf "%s" "$entry" | cut -d= -f1)
    moduleConfig=$(printf "%s" "$entry" | cut -d= -f2)

    moduleValue=$(printenv "$moduleName")
    if [ "$moduleValue" = "true" ]; then
        printf "${GREEN} ->Enabling $moduleName ${moduleConfig} ${RESET}\n"
        cp "/opt/httpd/templates/${moduleConfig}.tpl" "/opt/httpd/etc/conf.d/${moduleConfig}"
    fi
done

# Prepare SSL extras (e.g., HSTS) before rendering SSL config
if [ -f /opt/httpd/etc/conf.d/enable-mod-ssl.conf ]; then
    : "${APACHE_SSL_ENABLE_HSTS:=false}"
    if [ "${APACHE_SSL_ENABLE_HSTS}" = "true" ]; then
        export APACHE_SSL_HSTS_HEADER='Header always set Strict-Transport-Security "max-age=15552000; includeSubDomains; preload"'
    else
        export APACHE_SSL_HSTS_HEADER='# HSTS disabled'
    fi
    envsubst < /opt/httpd/templates/ssl-basic-config.conf.tpl > /opt/httpd/etc/conf.d/ssl-basic-config.conf
fi

/opt/httpd/bin/run.sh
