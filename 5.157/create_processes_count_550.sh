#!/bin/bash
aaa=`ps -ef|wc -l`
if [[ $aaa -lt 550 ]];then
	./create_processes_count_550.sh  >> /dev/null 2>&1
fi
sleep 3600
