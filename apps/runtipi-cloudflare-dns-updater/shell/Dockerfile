FROM alpine:3.22

# Install curl and jq
RUN apk add --no-cache curl jq docker-cli gettext

# Copy template shell script into container
COPY runtipi_cloudflare_dns_updater.template /tmp/runtipi_cloudflare_dns_updater.template

# Replace variables from ENV as envsubst
# Use shell wrapper for generate
RUN chmod +x /tmp/runtipi_cloudflare_dns_updater.template

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

CMD ["/entrypoint.sh"]

