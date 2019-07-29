#!/bin/bash
aaa=`ps -ef|wc -l`
if [[ $aaa -lt $1 ]];then
	./create_processes.sh $1 >> /dev/null 2>&1
fi
sleep 3600
