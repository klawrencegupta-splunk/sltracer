#!/bin/bash

for x in $(ps -aux | grep "search-launcher" | awk '{print $2}'); do timeout 60s strace -e trace=openat -p $x -o /opt/splunk/etc/apps/sltracer/output/$x.txt; done
rm  /opt/splunk/etc/apps/sltracer/output/*.txt
