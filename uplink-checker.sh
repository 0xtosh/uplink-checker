#!/bin/bash

# Define the targets for checking uptime
WEBSITES=("www.google.com" "www.dmi.dk" "www.microsoft.com")

# Delay = 5 minutes = 300 seconds
DELAY=300

DB_FILE="ping_results.db"

# Create SQLite database if it doesn't exist
if [ ! -f "$DB_FILE" ]; then
  sqlite3 "$DB_FILE" "CREATE TABLE pings (id INTEGER PRIMARY KEY, website TEXT, timestamp TEXT, response INTEGER);"
  echo "Creating database..."
fi

echo Checking status...

while true; do
  for website in "${WEBSITES[@]}"; do
    response=$(ping -c 1 "$website" | grep 'time=' | awk '{print $7}' | cut -d '=' -f 2)
    if [ -z "$response" ]; then
      is_available=0
      echo No Internet! Signaling over backup 5G...
      ./5g_send_we_down_son.sh &
    else
      is_available=1
      echo OK we are online, cat memes for all
    fi
    timestamp=$(date +"%Y-%m-%d %H:%M:%S")
    sqlite3 "$DB_FILE" "INSERT INTO pings (website, timestamp, response) VALUES ('$website', '$timestamp', $is_available);"
  done
  echo Sleeping...
  sleep $DELAY
done
