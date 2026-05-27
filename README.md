# Apache Container
Apache HTTP Server is a widely used web server that delivers websites. Running it in a container (e.g., with Docker) is practical because it isolates the application and its dependencies, making it portable.

| Plattform | Link |
|------|---------|
| <img src="https://cdn.simpleicons.org/github/2496ED" width="40" alt="Docker"> | [container-apache](https://github.com/nmeyer00/container-apache) |
| <img src="https://cdn.simpleicons.org/docker" width="40" alt="Docker"> | [Apache](https://hub.docker.com/r/nmeyer99/apache-httpd) |



## Why Run Apache as a Non-Root User?
For security reasons, Apache should not run as root inside a container. By default, many container processes run as root, which poses a high risk. If a vulnerability is exploited, an attacker could gain full control over the host server.

By starting the Apache process as a non-root user, you significantly limit the potential damage in case of an attack. The attacker would only have the restricted privileges of that user and couldn't access or manipulate the underlying host system.

## Container Security
While containers offer good isolation, they are not immune to attacks. Key security practices include:
- Regularly updating the container image.
- Using a minimalist image with only essential components.
- Running containers as a non-root user.
- Setting restrictive access permissions within the container image.


## Envirment:
- BIN_DIR=/usr/sbin
- CONF_FILE=/opt/httpd/etc/httpd.conf
- LISTEN_PORT=8001
- SERVER_ROOT=/var/www
- DOCUMENT_ROOT=/app
- SERVERNAME=localhost
- SERVERADMIN=root@localhost
- ENABLE_ACCESS_LOG=true
- MOD_REWRITE=false
- MOD_MPM_PREFORK=false
- MOD_MPM_EVENT=true
- MOD_CGI=false (Repuirement: MOD_MPM_PREFORK=true) 
- MOD_STATUS=false (Limited on 127.0.0.1)
- MOD_NEGOTIATION=true
- MOD_DEFLATE=false
- MOD_AUTOINDEX=false
- MOD_MIME=true
- MOD_DAV=false
- LOG_LEVEL=warn (emerg,alert,crit,error,warn,notice,info,debug,trace1-trace8)
- ENABLE_ACCESS_LOG
- MOD_PROXY=false
- SSL_HONOR_CIPHER_ORDER=on
- SSL_LISTEN_SSL_PORT=8443
- SSL_CIPHER_SUITE=TLSv1.2+AESGCM+ECDHE
- SSL_PROXY_CIPHER_SUITE=TLSv1.2+AESGCM+ECDHE
- SSL_PROTOCOL='TLSv1.2 TLSv1.3"
- SSL_PROXY_PROTOCOL="TLSv1.2 TLSv1.3"
- SSL_SESSION_CACHE_TIMEOUT=300
- SSL_USE_STAPLING=on
- SSL_STAPLING_STANDARD_CACHE_TIMEOUT=3600
- SSL_STAPLING_ERROR_CACHE_TIMEOUT=600
- SSL_CERTIFICATE_FILE=/etc/certs/selfsigned.crt
- SSL_CERTIFICATE_KEY_FILE=/etc/certs/selfsigned.key 
- SSL_ENABLE_HSTS=true (toggles Strict-Transport-Security header)

## UID/GID Matching (optional)
To avoid permission issues with bind mounts, you can build the image so that the `apache` user inside the container uses the same UID/GID as your host user.

- Build with host IDs:
  - `docker build --build-arg APACHE_UID=$(id -u) --build-arg APACHE_GID=$(id -g) -t httpd:latest .`
- Defaults (if not provided): `APACHE_UID=100`, `APACHE_GID=101`.

Note: The container still runs as `apache` (not root). The Apache config also uses `User apache`/`Group apache`.

## Optional `apk upgrade` during build
You can opt-in to upgrading all base packages during build via a build arg:

- Enable upgrade: `docker build --build-arg APK_UPGRADE=true -t httpd:latest .`
- Default: `APK_UPGRADE=false` (no upgrade for reproducibility)

The Dockerfile conditionally runs `apk update && apk upgrade` before installing required packages.

## Image version label
You can set the image metadata version label via a build arg:

- From git tag/commit: `docker build --build-arg IMAGE_VERSION=$(git describe --tags --always --dirty) -t httpd:latest .`
- Or short commit: `docker build --build-arg IMAGE_VERSION=$(git rev-parse --short HEAD) -t httpd:latest .`

This value is written to label `org.opencontainers.image.version`.

## Runtime version file
The image also writes the version into a file inside the container for easy runtime inspection:

- Path: `/etc/image-version`
- Check inside container: `cat /etc/image-version`

This mirrors the `IMAGE_VERSION` build arg and stays immutable at runtime.
## SSL Support

To enable SSL support, the following environment variables must be provided:


- MOD_SSL=true
- SSL_CERTIFICATE_FILE=path to certificate
- SSL_CERTIFICATE_KEY_FILE=path to private key

Certificates can be mounted into the container using a volume, for example:
```./certificates:/etc/certs:ro```

If SSL_CERTIFICATE_FILE and SSL_CERTIFICATE_KEY_FILE are not set, a default self-signed certificate will be loaded. This should be replaced with a valid certificate for production use.


## Docker-compose
```
services:
  webinternal:
    container_name: webinternal
    image: nmeyer99/apache-httpd:latest
    networks:
      - internal
    ports:
      - "8001:8080"
    environment:
      MOD_AUTOINDEX: true
    volumes:
      - rootfs:/app

```
