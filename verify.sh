#!/bin/bash
## verify.sh
##  - Attempts to verify an openvpn server is running on a provided IP address

IP="$1"
PORT='1194'
TIMEOUT='5' # 5 sec - slow connections may need to increase

# Sends a openvpn connection attempt to provided IP
resp=$(echo -e "\x38\x01\x00\x00\x00\x00\x00\x00\x00" | timeout "$TIMEOUT" nc -w 2 -u "$IP" "$PORT")
resp_byte_count=$(echo "$resp" | wc -c)

if [ "$resp_byte_count" -gt 1 ]; then
  echo "Received response from server!"
else
  echo "ERROR: No data received"
  exit 1
fi

