LoadModule deflate_module modules/mod_deflate.so

<IfModule mod_deflate.c>
    # Kompression für typische Textformate aktivieren
    AddOutputFilterByType DEFLATE text/plain
    AddOutputFilterByType DEFLATE text/html
    AddOutputFilterByType DEFLATE text/xml
    AddOutputFilterByType DEFLATE text/css
    AddOutputFilterByType DEFLATE text/javascript
    AddOutputFilterByType DEFLATE application/xml
    AddOutputFilterByType DEFLATE application/xhtml+xml
    AddOutputFilterByType DEFLATE application/rss+xml
    AddOutputFilterByType DEFLATE application/javascript
    AddOutputFilterByType DEFLATE application/json
    AddOutputFilterByType DEFLATE application/ld+json
    AddOutputFilterByType DEFLATE application/x-javascript
    AddOutputFilterByType DEFLATE application/ecmascript

    # Problematische oder bereits komprimierte Formate ausschließen
    SetEnvIfNoCase Request_URI \
        \.(?:gif|jpe?g|png|ico|zip|gz|bz2|rar|7z|pdf|mp[34]|avi|mov|mpg|mpeg|ogg|ogv|webm)$ \
        no-gzip dont-vary

    # Browserkompatibilität sicherstellen
    BrowserMatch ^Mozilla/4 gzip-only-text/html
    BrowserMatch ^Mozilla/4\.0[678] no-gzip
    BrowserMatch \bMSIE !no-gzip !gzip-only-text/html

    # Vary-Header setzen (wichtig für Proxies/CDNs)
    Header append Vary Accept-Encoding

    # Optional: Kompressionsstufe
    DeflateCompressionLevel 6
</IfModule>
