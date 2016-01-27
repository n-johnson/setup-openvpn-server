#!/bin/bash
USER='root'
IP="$1"
echo "Starting server on $IP..."

echo "Configuring server..."
ssh -oStrictHostKeyChecking=no "$USER"@"$IP" 'bash -s' < input.sh 

echo "Downloading config..." 
ssh -oStrictHostKeyChecking=no "$USER"@"$IP" curl -k 'https://localhost:8080' > "$IP"'_open.ovpn' 

echo "Cleaning up..." 
ssh -oStrictHostKeyChecking=no "$USER"@"$IP" docker rm -f "tmp-ssl" 

echo "Securing server..." 
ssh -oStrictHostKeyChecking=no "$USER"@"$IP" 'bash -s' < secure.sh 

echo "Checking connection to server..."
./verify.sh "$IP" \
  && echo "SUCCESS" \
  || echo "Failed to complete setup :/"
