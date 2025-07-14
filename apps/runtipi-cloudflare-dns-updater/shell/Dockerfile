FROM alpine:3.22

# install curl and jq
RUN apk add --no-cache curl jq docker-cli

# copy shell script into container
COPY runtipi_cloudflare_dns_updater.sh /tmp/runtipi_cloudflare_dns_updater.sh

# add permission shell script
RUN chmod +x /tmp/runtipi_cloudflare_dns_updater.sh

# run shell script with environment from docker-compose
CMD ["/bin/sh", "-c", "/tmp/runtipi_cloudflare_dns_updater.sh && sleep 9999"]

