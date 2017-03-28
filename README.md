# File Moving Code Challenge

### SUMMARY
As part of a deployment for a new client, you need to build a script to handle moving critical files around and feeding them into the application processes. This data is critical for the production systems and, as such, this script will be running in the production environment(s). Due to the nature of the system, it needs to be capable of being run from a crontab. 

### INPUT:
Another process is uploading new, compressed files continuously to an “/incoming” location. The files have the format “DATA_YYYMMDD_hhmm.csv.gz”.

### OUTPUT: 
The script needs to decompress the files, move them to “/data” and delete the original file.

### CONSIDERATIONS:
The scripting of the task as detailed is relatively straight forward, so in addition to generation of a functionally correct script, please detail out a list of considerations that you’d add to the design of this and script them as appropriate. For example: how to handle failure scenarios and push them to an alerting system, etc.
