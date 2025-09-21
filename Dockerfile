FROM caddy:2.10.2-builder AS builder

RUN git clone https://github.com/zyclonite/caddy-route53 /src/route53 && \
    git clone https://github.com/zyclonite/caddy-forwardproxy /src/forwardproxy

RUN xcaddy build \
    --replace github.com/libdns/route53=github.com/zyclonite/route53@v1.5.4 \
    --with github.com/caddy-dns/route53=/src/route53 \
    --with github.com/caddyserver/forwardproxy=/src/forwardproxy

FROM alpine:3.22

LABEL org.opencontainers.image.title="caddy" \
      org.opencontainers.image.version="2.10.2" \
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
