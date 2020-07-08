#!/bin/bash
if [[ $1 = ctlI ]];then
	tail -f /dbfw_capbuf/pdump/gmon/ctlInterface.log
fi

if [[ $1 = ctlS ]];then
	tail -f /dbfw_capbuf/pdump/gmon/ctlServer.log
fi

Log_Path_Home="/dbfw_capbuf/pdump/$1/info"
echo $Log_Path_Home
Log_Name=`ls -l $Log_Path_Home|tail -n1|awk '{print $9}'`
echo $Log_Name
echo $Log_Path_Home/$Log_Name
tail -f $Log_Path_Home/$Log_Name
