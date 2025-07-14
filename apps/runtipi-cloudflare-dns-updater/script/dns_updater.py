import docker
import os
import requests

# === ENV ===
cf_url = "https://api.cloudflare.com/client/v4"
cf_zone_id = os.getenv("CF_DNS__ACCOUNTS__SCOPED_ZONE")
cf_domain = os.getenv("CF_DNS__DOMAINS_0__NAME")
cf_tunnel_id = os.getenv("CF_DNS__ACCOUNTS__SCOPED_TUNNEL")
cf_api_token = os.getenv("CF_DNS__AUTH__SCOPED_TOKEN")
cf_proxy = os.getenv("CF_DNS__DOMAINS_0__PROXIED", "false").lower() == "true"

headers = {
    "Authorization": f"Bearer {cf_api_token}",
    "Content-Type": "application/json"
}

# === Docker Events ===
client = docker.from_env()
events = client.events(decode=True)

print("[DNS-Updater] Listening for container events...")

for event in events:
    if event.get("Type") != "container":
        continue

    action = event.get("Action")
    container_id = event.get("id")[:12]
    print(f"[DNS-Updater] Event: {action} for {container_id}")

    # domain matching logic 
    name = f"{container_id}.{cf_domain}"
    if action == "create":
        print(f"[CREATE] Creating DNS record for {name}")
        payload = {
            "type": "CNAME",
            "name": name,
            "content": cf_tunnel_id,
            "proxied": cf_proxy
        }
        res = requests.post(f"{cf_url}/zones/{cf_zone_id}/dns_records", json=payload, headers=headers)
        print(res.json())

    elif action == "destroy":
        print(f"[DESTROY] Searching DNS record for {name}")
        res = requests.get(
            f"{cf_url}/zones/{cf_zone_id}/dns_records",
            params={"type": "CNAME", "name": name},
            headers=headers
        )
        data = res.json()
        for record in data.get("result", []):
            record_id = record["id"]
            print(f"[DELETE] Deleting DNS record ID: {record_id}")
            del_res = requests.delete(f"{cf_url}/zones/{cf_zone_id}/dns_records/{record_id}", headers=headers)
            print(del_res.json())
