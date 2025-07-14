#!/bin/sh

# Use envsubst replace into shell script before run
envsubst < /tmp/runtipi_cloudflare_dns_updater.sh.template > /tmp/runtipi_cloudflare_dns_updater.sh

chmod +x /tmp/runtipi_cloudflare_dns_updater.sh

# Run shell script from generated script.
exec /tmp/runtipi_cloudflare_dns_updater.sh
