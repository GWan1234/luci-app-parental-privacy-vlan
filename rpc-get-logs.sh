#!/bin/sh
# Fetch last 50 kids DNS queries for the LuCI Dashboard

LOG_FILE="/tmp/dnsmasq-kids.log"
LIMIT=50

if [ ! -f "$LOG_FILE" ]; then
    echo '{ "logs": [] }'
    exit 0
fi

# Parse dnsmasq log format:
# "date time dnsmasq[pid]: query[A] domain.com from 172.28.x.x"
# We want: Timestamp, Domain, Client
echo -n '{ "logs": ['
tail -n "$LIMIT" "$LOG_FILE" | grep "query\[" | awk '
BEGIN { first=1 }
{
    if (!first) printf ",";
    # $1=Date, $2=Time, $6=Type, $7=Domain, $9=Client
    printf "{\"time\":\"%s %s\",\"domain\":\"%s\",\"client\":\"%s\"}", $1, $2, $7, $9;
    first=0
}
END { print "" }
'
echo ']}'