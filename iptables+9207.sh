#!/bin/bash
iptables_conf='/etc/sysconfig/iptables'
grep_9207=`grep 'dport 9207' $iptables_conf`
if [[ $grep_9207 ]];then
	echo "Iptables has 9207 ports"
	exit
else
	echo $iptables_conf
	rownum=`grep -n 'dport 9311' $iptables_conf|awk -F ':' '{print $1}'`
	echo $rownum
	ACCEPT_9207=`grep 'dport 9311' $iptables_conf|sed 's/9311/9207/'`
	echo $ACCEPT_9207
	sed -i "${rownum}a ${ACCEPT_9207}" $iptables_conf 
	service iptables restart
	echo 'Iptables added 9207 ports successfully'
fi
