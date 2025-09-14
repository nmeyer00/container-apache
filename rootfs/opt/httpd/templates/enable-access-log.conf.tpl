LoadModule remoteip_module modules/mod_remoteip.so

# Optionally specify header and trusted proxies to prevent spoofing
#RemoteIPHeader X-Forwarded-For
#RemoteIPTrustedProxy 127.0.0.1 ::1 10.0.0.0/8 172.16.0.0/12 192.168.0.0/16

<IfModule log_config_module>
    # Use %a (client IP after mod_remoteip) instead of %h
    LogFormat "%a %l %u %t \"%r\" %>s %b \"%{Referer}i\" \"%{User-Agent}i\"" combined
    LogFormat "%a %l %u %t \"%r\" %>s %b" common

    CustomLog /proc/self/fd/1 combined
</IfModule>
