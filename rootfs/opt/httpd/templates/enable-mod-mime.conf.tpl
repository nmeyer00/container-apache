LoadModule mime_module modules/mod_mime.so
<IfModule mime_module>
    TypesConfig /opt/httpd/etc/mime.types
</IfModule>

<IfModule mime_magic_module>
    MIMEMagicFile /opt/httpd/etc/magic
</IfModule>