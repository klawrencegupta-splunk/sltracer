=== **sltracer  - [search-launcher] Tracer app** ===

_This application/script is provided at your own risk & is not a Splunk supported product. It is only meant for testing & is considered experimental_


**Problem Statement**

A scenario can arise within a Splunk deployment where the bulk of Splunk CPU  activity will get grouped under the [search-launcher]. In this situation it can become very difficult to discern which searches are causing CPU load and long-run times. 

**Splunk Overview**

- In Splunk the [search-launcher] process handles jobs with shorter run times and search threads that may not fall under the data.process_type=search category in _introspection.
- These will include searches that will have been picked up by the _audit index and be assigned a search_ids but the searches may not be reported in _introspection due to sampling window.
- Additionally the  [search-launcher] process will also re-use PIDS over time and run multiple searches using a single PID; this creates a 1:many relationship between PID:search_ids. 

**Current Solution**

**Warning:  use this code with caution strace is an implementation of ptrace which in the wrong hands can be used for code-injection attacks **

A PID to search_id mapping is needed to determine which [search-launcher] PIDS are touching which searches. Currently the only way to map this process is to send an interrupt to the [search-launcher] PIDS running and apply an **openat** filter to determine which dispatch files each PID has opened.

The script below finds these PIDS runs the strace with an openat filter while forcing a timeout after 60 seconds. The script stores the file in the local output directory of the Splunk app and will clean the text files out of the directory on each run.

**bin > wrapper.sh**

<code> #!/bin/bash
for x in $(ps -aux | grep "search-launcher" | awk '{print $2}'); do timeout 60s strace -e trace=openat -p $x -o /opt/splunk/etc/apps/sltracer/output/$x.txt; done
rm  /opt/splunk/etc/apps/sltracer/output/*.txt </code>

**default > inputs.conf**

<code>
#Run the wrapper.sh script

[script://$SPLUNK_HOME/etc/apps/sltracer/bin/./wrapper.sh]
disabled = false
interval = 120
index = main
source = sltracer.sh
sourcetype = sltracer

[monitor://$SPLUNK_HOME/etc/apps/sltracer/output/*.txt]
sourcetype = sltracer
index = main
blacklist = (\.gz$|\.tgz$)
</code>

**default > data/ui > views > sltracer.xml**

A sample dashboard showing the how the PID activity using the strace output to map the PID to the search_id in either the **search.log | _audit index | _introspection index**
