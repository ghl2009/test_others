#!/bin/bash

dbfw_Pro_dir=(
		'/home/dbfw/dbfw/bin'
		'/home/dbfw/dbfw/sbin'
		'/home/dbfw/dbfw/lib'
)

no_Program_list=(
                bpctl_start
                bpctl_stop
                ifup-aliases
                ifup-eth
                initweblogin
                ipconfig
                ntpsync
                pcap-config
                sendEmail
		gnokii
		kernel
		net-snmp
		sendMail
		charset.alias
		pkgconfig
)

for list in ${dbfw_Pro_dir[@]}
do

	Program_list=`ls $list |grep -v -E ".pid|.sh|.out|.pm|.pl|.py"`

	for pro in ${Program_list[@]}
	do

		#echo "########################################"
		#echo ${no_Program_list[@]}	
		if [ "`echo ${no_Program_list[@]} | grep -w "$pro" | wc -l`" = "1" ];then
			#echo "-------------------------"
			#echo "$pro is not an ordinary file"
			#echo "-------------------------"
			continue;
		fi

		ret=`readelf -S $list/$pro |grep "debug"`

		if [[ -n $ret ]];then
			echo "$list/$pro"
			echo "带有debug的结果,stip失败"
		#else
		#	echo "不带有debug的结果,stip成功"
		fi

		#echo "########################################"
	done
done
