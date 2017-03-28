#!/bin/bash
###############################################################
#Program takes input from the 'incoming' directory as gzipped #
#files, decompresses them, moves them to the 'data' directory #
#and deletes the original archive. Files that have been moved #
#to the data directory have been placed in a subdirectory with#
#the same name as the original archive which maintains the    #
#following naming schema: DATA_YYYMMDD_hhmm.csv.gz            #
###############################################################
