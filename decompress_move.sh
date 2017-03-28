#!/bin/bash
###############################################################
#Program takes input from the 'incoming' directory as gzipped #
#files, decompresses them, moves them to the 'data' directory #
#and deletes the original archive. Files that have been moved #
#to the data directory have been placed in a subdirectory with#
#the same name as the original archive which maintains the    #
#following naming schema: DATA_YYYMMDD_hhmm.csv.gz            #
###############################################################

#Check to see how many datasets are in 'incoming'. Ignore errors because ls throws a non-zero exit code when your glob doesn't return any matches.
numArchives=$((ls incoming/*.csv.gz | wc -l) 2> /dev/null)

#If there are no incoming datasets, exit with a status code.
if [[ $numArchives -lt 1 ]]
then
	echo "$(date) - There are no incoming archives to parse."
	exit 1 
else
	echo "$(date) - There are $numArchives archives to parse."
fi

for
