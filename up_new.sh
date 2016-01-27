#!/bin/bash

echo "Starting server..."
IP=$(node do.js)
if [ "$?" -ne 0 ]; then
  echo "WARNING: Failed to run node script to start new digital ocean droplet"
  exit 1
fi

./up.sh "$IP"
