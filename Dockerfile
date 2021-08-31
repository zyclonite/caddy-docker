FROM caddy:2.4.3-builder AS builder

RUN xcaddy build \
    --with github.com/caddy-dns/route53 \
    --with github.com/caddyserver/forwardproxy@caddy2

FROM alpine:3.14

LABEL org.opencontainers.image.title="caddy" \
      org.opencontainers.image.version="2.4.3" \
      org.opencontainers.image.description="Custom Caddyserver as Docker Image" \
      org.opencontainers.image.licenses="Apache-2.0" \
      org.opencontainers.image.source="https://github.com/zyclonite/caddy-docker"

ENV XDG_CONFIG_HOME /config
ENV XDG_DATA_HOME /data

RUN apk add --no-cache --purge --clean-protected -u ca-certificates mailcap \
 && mkdir -p /config/caddy /data/caddy /etc/caddy /usr/share/caddy \
 && rm -rf /var/cache/apk/*

COPY --from=builder /usr/bin/caddy /usr/bin/caddy

EXPOSE 80 443 2019

WORKDIR /srv

ENTRYPOINT ["caddy"]
CMD ["run", "--config", "/etc/caddy/Caddyfile", "--adapter", "caddyfile"]
