ARG BASEIMAGE="library/alpine:3.22.1"
FROM ${BASEIMAGE}


ARG IMAGE_VERSION="dev"
ARG APACHE_UID="100"
ARG APACHE_GID="101"
ARG APK_UPGRADE="false"

LABEL org.opencontainers.image.authors="nmeyer"
LABEL org.opencontainers.image.title="Apache Webserver"
LABEL org.opencontainers.image.version=$IMAGE_VERSION
LABEL org.opencontainers.image.description="Flexibel Apache Minimal Container"
LABEL org.opencontainers.image.source="https://gitlab.com/container6552434/apache"

# Pre-create apache user/group with desired UID/GID before package install
RUN addgroup -g ${APACHE_GID} -S apache && \
    adduser -u ${APACHE_UID} -G apache -S -D -H apache

RUN set -eux; \
    if [ "$APK_UPGRADE" = "true" ]; then \
        apk update && apk --no-cache upgrade; \
    fi; \
    apk add --no-cache apache2 envsubst bash findutils apache2-webdav apache2-proxy apache2-ssl; \
    rm -f /etc/ssl/apache2/server.key

COPY rootfs/ /

# Write image version for runtime inspection
RUN printf "%s\n" "$IMAGE_VERSION" > /etc/image-version

RUN mkdir -p /opt/httpd/etc/conf.d /run/apache2 /var/lock/apache2 /var/www /app && \
    chown -R apache:apache /opt/httpd /run/apache2 /var/lock/apache2 /var/www /app && \
    chmod +x /entrypoint.sh /opt/httpd/bin/*.sh

USER apache

CMD ["bash","/entrypoint.sh"]
