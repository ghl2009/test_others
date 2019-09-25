#!/bin/bash
nfw_info_name=$1
echo $nfw_info_name
flag1=`grep -rn "nfw current was recovering from soft will delay running or no recover" $nfw_info_name |wc -l`
echo "flag1=$flag1"
flag2=`grep -rn "nfw current was recovering from soft will delay running or no recover" $nfw_info_name |tail -n1|awk -F: '{print $1}'`
echo "flag2=$flag2"
while true
	do
		flag3=`grep -rn "nfw current was recovering from soft will delay running or no recover" $nfw_info_name |wc -l`
		echo "flag3=$flag3"
		flag4=`grep -rn "nfw current was recovering from soft will delay running or no recover" $nfw_info_name |tail -n1|awk -F: '{print $1}'`
		echo "flag4=$flag4"
		echo "flag4-flag2=$((flag4-flag2))"
		if [[ $flag1 -eq $flag3 ]];then
			sleep 30
		elif [[ $((flag4-flag2)) -eq 8 ]];then
			sleep 30
			echo "------------------------------------------"
			flag1=$flag3
			flag2=$flag4
			echo "flag1=$flag3"
			echo "flag2=$flag4"
			echo "------------------------------------------"
		else 
			echo "##########################################"
			echo "failed"
			echo "##########################################"
			break
		fi
	done
