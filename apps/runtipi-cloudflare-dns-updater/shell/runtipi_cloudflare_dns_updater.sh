#!/bin/sh

# Configure the parameter
cf_url=https://api.cloudflare.com/client/v4
cf_zone_id=${CF_DNS__ACCOUNTS__SCOPED_ZONE}
cf_domain=${CF_DNS__DOMAINS_0__NAME}
cf_tunnel_id=${CF_DNS__ACCOUNTS__SCOPED_TUNNEL}
cf_api_token=${CF_DNS__AUTH__SCOPED_TOKEN}
cf_proxy=${CF_DNS__DOMAINS_0__PROXIED}

# Call the script to handle container creation and destroy
docker events --filter "event=create" --filter "event=destroy" --filter "type=container" | while read line;
do
  echo $line
  echo "-"
  container_id=$(echo "$line" | awk '{print $4}')
  echo "Container id=$container_id"
  echo "domain=$cf_domain"

  # Extract domain name from log line (example assumes `Host(`...`)`)
  dn=$(echo "$line" | sed -n 's/.*Host(`\([^`]*\)`).*/\1/p' | grep "$cf_domain" | head -n 1)
  echo "dn=$dn"

  # If dn is empty, skip
  if [ -z "$dn" ]; then
    echo "No domain found, skipping..."
    echo "--"
    continue
  fi

  if echo $line | grep -q 'create' ; then
    # Create DNS Record
    record=$(curl -s -X POST "$cf_url/zones/$cf_zone_id/dns_records" \
      -H "Authorization: Bearer $cf_api_token" \
      -H "Content-Type: application/json" \
      --data '{"type":"CNAME","name":"'"$dn"'","content":"'"$cf_tunnel_id"'","proxied":'"$cf_proxy"'}')
    echo "Container created, $container_id"
    echo "Return created=$record"

  elif echo $line | grep -q 'destroy' ; then
    # Query existing DNS record
    query=$(curl -s -G "$cf_url/zones/$cf_zone_id/dns_records" \
      -H "Authorization: Bearer $cf_api_token" \
      --data-urlencode "type=CNAME" \
      --data-urlencode "name=$dn")

    id=$(echo "$query" | jq -r --arg dn "$dn" '.result[] | select(.name==$dn) | .id')

    if [ -n "$id" ]; then
      echo "Query DNS record id from $dn=$id"
      record=$(curl -X DELETE "$cf_url/zones/$cf_zone_id/dns_records/$id" \
        -H "Authorization: Bearer $cf_api_token")
      echo "Container destroyed, $container_id"
      echo "Return destroyed=$record"
    else
      echo "No matching DNS record to delete for $dn"
    fi
  fi

  echo "--"
done
