# sltracer
[search-launcher] Tracer app


bin > wrapper.sh 

#!/bin/bash
for x in $(ps -aux | grep "search-launcher" | awk '{print $2}'); do timeout 60s strace -e trace=openat -p $x -o /opt/splunk/etc/apps/sltracer/output/$x.txt; done
rm  /opt/splunk/etc/apps/sltracer/output/*.txt

default > inputs.conf

#Run the wrapper.sh script
[script://$SPLUNK_HOME/etc/apps/sltracer/bin/./wrapper.sh]
disabled = false
interval = 120
index = main
source = sltracer.sh
sourcetype = sltracer


#The output per PID is stored in a output directory and cleaned up with the wrapper script
[monitor://$SPLUNK_HOME/etc/apps/sltracer/output/*.txt]
sourcetype = sltracer
index = main
blacklist = (\.gz$|\.tgz$)

