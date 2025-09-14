ServerTokens Prod
ServerRoot ${APACHE_SERVER_ROOT}
Listen ${APACHE_LISTEN_PORT}

LoadModule authn_file_module modules/mod_authn_file.so
LoadModule authn_core_module modules/mod_authn_core.so
LoadModule authz_host_module modules/mod_authz_host.so
LoadModule authz_groupfile_module modules/mod_authz_groupfile.so
LoadModule authz_user_module modules/mod_authz_user.so
LoadModule authz_core_module modules/mod_authz_core.so
LoadModule auth_basic_module modules/mod_auth_basic.so
LoadModule reqtimeout_module modules/mod_reqtimeout.so
LoadModule filter_module modules/mod_filter.so
LoadModule log_config_module modules/mod_log_config.so
LoadModule env_module modules/mod_env.so
LoadModule headers_module modules/mod_headers.so
LoadModule setenvif_module modules/mod_setenvif.so
LoadModule version_module modules/mod_version.so
LoadModule unixd_module modules/mod_unixd.so
LoadModule dir_module modules/mod_dir.so
LoadModule alias_module modules/mod_alias.so

<IfModule unixd_module>
User apache
Group apache
</IfModule>

ServerAdmin ${APACHE_SERVERADMIN}
ServerSignature off
ServerName ${APACHE_SERVERNAME}

<Directory />
    AllowOverride All
    Require all denied
</Directory>

DocumentRoot "${APACHE_DOCUMENT_ROOT}"
<Directory "${APACHE_DOCUMENT_ROOT}">
    Options Indexes FollowSymLinks
    AllowOverride All
    Require all granted
</Directory>

<IfModule dir_module>
    DirectoryIndex index.html index.php
</IfModule>

<Files ".ht*">
    Require all denied
</Files>

ErrorLog  /proc/self/fd/2
LogLevel ${APACHE_LOGLEVEL}

<IfModule alias_module>
    ScriptAlias /cgi-bin/ "/app/cgi-bin/"
</IfModule>

<Directory "/app/cgi-bin">
    AllowOverride None
    Options None
    Require all granted
</Directory>

<IfModule headers_module>
    RequestHeader unset Proxy early
</IfModule>

IncludeOptional /opt/httpd/etc/conf.d/*.conf