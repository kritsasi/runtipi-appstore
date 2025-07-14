FROM alpine:3.22

# ติดตั้ง curl และ jq
RUN apk add --no-cache curl jq docker-cli

# คัดลอก shell script ไปใน container
COPY runtipi_cloudflare_dns_updater.sh /tmp/runtipi_cloudflare_dns_updater.sh

# ให้สิทธิ์รัน shell script
RUN chmod +x /tmp/runtipi_cloudflare_dns_updater.sh

# รัน shell script โดยใช้ environment ที่ส่งมาจาก docker-compose
CMD ["/tmp/runtipi_cloudflare_dns_updater.sh"]
