#!/bin/bash
iptables_conf='/etc/sysconfig/iptables'
grep_9207=`grep 'dport 9207' $iptables_conf`
grep_9208=`grep 'dport 9208' $iptables_conf`
if [[ $grep_9207 ]] && [[ $grep_9208 ]];then
	echo "Iptables has 9207and9208 ports"
	exit
fi

if [[ ! $grep_9207 ]];then
	echo $iptables_conf
	rownum=`grep -n 'dport 9311' $iptables_conf|awk -F ':' '{print $1}'`
	echo $rownum
	ACCEPT_9207=`grep 'dport 9311' $iptables_conf|sed 's/9311/9207/'`
	echo $ACCEPT_9207
	sed -i "${rownum}a ${ACCEPT_9207}" $iptables_conf 
	service iptables restart
	echo 'Iptables added 9207 ports successfully'
else
	echo "Iptables has 9207 ports"
fi
	
if [[ ! $grep_9208 ]];then
	echo $iptables_conf
	rownum=`grep -n 'dport 9311' $iptables_conf|awk -F ':' '{print $1}'`
	echo $rownum
	ACCEPT_9208=`grep 'dport 9311' $iptables_conf|sed 's/9311/9208/'`
	echo $ACCEPT_9208
	sed -i "${rownum}a ${ACCEPT_9208}" $iptables_conf 
	service iptables restart
	echo 'Iptables added 9208 ports successfully'
else
	echo "Iptables has 9208 ports"
	
fi
