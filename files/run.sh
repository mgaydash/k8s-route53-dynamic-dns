#!/bin/bash
IP_FILENAME=$(mktemp)
HOSTED_ZONE_ID="{{ .Values.hosted_zone_id }}"
CHANGE_FILENAME="/files/hosted_zone.json"

HTTP_REQUEST="$({
  echo -e -n 'GET /ip HTTP/1.1\r\n'
  echo -e -n 'Host: ipinfo.io\r\n'
  echo -e -n 'Connection: close\r\n\r\n'
})"

while true; do
  # CURRENT_PUBLIC_IP=$(echo "${HTTP_REQUEST}" | openssl s_client -quiet -connect ipinfo.io:443 2>/dev/null | grep -E "^(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$")
  CURRENT_PUBLIC_IP=$(echo "${HTTP_REQUEST}" | openssl s_client -quiet -connect ipinfo.io:443 2>/dev/null | grep -E "[0-9][0-9]?[0-9]?\.[0-9][0-9]?[0-9]?\.[0-9][0-9]?[0-9]?\.[0-9][0-9]?[0-9]?")
  PREVIOUS_PUBLIC_IP=$(cat "${IP_FILENAME}" || echo "-")
  echo "Testing public IP. Current: ${CURRENT_PUBLIC_IP}. Previous: ${PREVIOUS_PUBLIC_IP}."
  if [ "${CURRENT_PUBLIC_IP}" != "${PREVIOUS_PUBLIC_IP}" ]; then
    echo "Public IP has changed since last check."
    TEMP_FILE=$(mktemp)
    sed -e "s/@@@/${CURRENT_PUBLIC_IP}/" "${CHANGE_FILENAME}" > "${TEMP_FILE}"
    aws route53 --no-cli-pager change-resource-record-sets --hosted-zone-id "${HOSTED_ZONE_ID}" --change-batch "file://${TEMP_FILE}"
    echo "${CURRENT_PUBLIC_IP}" > "${IP_FILENAME}"
  fi
  sleep 120
done
