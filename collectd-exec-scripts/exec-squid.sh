#!/bin/sh
# Exec script for collectd to read Squid stats
# Optional: Specify and uncomment to monitor inside a jail from host on FreeBSD
#HOST_TO_MONITOR="10.100.102.19"
#PATH=$PATH:/usr/jails/squid.test.com/usr/local/sbin/

SQUID_HOST="${HOST_TO_MONITOR:-localhost}"
HOSTNAME="${COLLECTD_HOSTNAME:-`hostname -s`}"
INTERVAL="${COLLECTD_INTERVAL:-60}"

while sleep "$INTERVAL"
do
	squidclient -h "$SQUID_HOST" cache_object://localhost/counters \
	    | awk -F ' = ' -v HOSTNAME=$HOSTNAME -v INTERVAL=$INTERVAL \
	    '/requests|^(server|client)/ \
	    { print "PUTVAL", HOSTNAME"/exec-squid/counter-squid/"$1, "interval="INTERVAL, "N:"$2 }'

	squidclient -h "$SQUID_HOST" cache_object://localhost/ipcache \
	    | awk -F ':' -v HOSTNAME=$HOSTNAME -v INTERVAL=$INTERVAL \
	    '/IPcache (Requests|Hits|Misses)/ \
	    { gsub(/ /, "", $1); gsub(/ /, "", $2);
	      print "PUTVAL", HOSTNAME"/exec-squid/counter-squid/"$1, "interval="INTERVAL, "N:"$2 }'

	squidclient -h "$SQUID_HOST" cache_object://localhost/storedir \
	    | awk -F ':' -v HOSTNAME=$HOSTNAME -v INTERVAL=$INTERVAL \
	    '/(Maximum Swap Size|Current Store Swap Size)/ \
	    { gsub(/KB/, ""); gsub(/ /, "", $1); gsub(/ /, "", $2);
	      print "PUTVAL", HOSTNAME"/exec-squid/gauge-squid/"$1,   "interval="INTERVAL, "N:"$2 }'
done
