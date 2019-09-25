#!/bin/bash
nfw_info_name=$1
echo $nfw_info_name
flag1=`grep -rn "nfw current was recovering from soft will delay running or no recover" $nfw_info_name |wc -l`
echo "[`date '+%Y-%m-%d %H:%M:%S'`] flag1=$flag1"
flag2=`grep -rn "nfw current was recovering from soft will delay running or no recover" $nfw_info_name |tail -n1|awk -F: '{print $1}'`
if [[ $flag2 == "" ]];then
	flag2=0
fi
echo "[`date '+%Y-%m-%d %H:%M:%S'`]flag2=$flag2"
run_count=0
Restart_port_count=0
while true
	do
		Restart_port_flag=`grep -rn "Restart port" $nfw_info_name |wc -l`
		if [[ $Restart_port_flag -gt $Restart_port_count ]];then
			echo "[`date '+%Y-%m-%d %H:%M:%S'`] ==========================================="
			Restart_port_count=$((Restart_port_count+1))
			echo "[`date '+%Y-%m-%d %H:%M:%S'`] Restart_port_count=$Restart_port_count"
			Restart_port_rownum=`grep -rn "Restart port" $nfw_info_name |tail -n1|awk -F: '{print $1}'`
			echo "[`date '+%Y-%m-%d %H:%M:%S'`] Restart_port_rownum=$Restart_port_rownum"
			echo "[`date '+%Y-%m-%d %H:%M:%S'`] ==========================================="
		fi

		Restart_port_count=`grep -rn "Restart port" $nfw_info_name |wc -l`
		run_count=$((run_count+1))
		res=$((run_count%30))

		flag3=`grep -rn "nfw current was recovering from soft will delay running or no recover" $nfw_info_name |wc -l`
		flag4=`grep -rn "nfw current was recovering from soft will delay running or no recover" $nfw_info_name |tail -n1|awk -F: '{print $1}'`
		if [[ $flag4 == "" ]];then
			flag4=0
		fi
		#echo "[`date '+%Y-%m-%d %H:%M:%S'`] flag4-flag2=$((flag4-flag2))"

		if [[ $res -eq 1 ]];then
			echo "[`date '+%Y-%m-%d %H:%M:%S'`] ------------------------------------------"
			echo "[`date '+%Y-%m-%d %H:%M:%S'`] flag3=$flag3"
			echo "[`date '+%Y-%m-%d %H:%M:%S'`] flag4=$flag4"
			echo "[`date '+%Y-%m-%d %H:%M:%S'`] res=$res"
			echo "[`date '+%Y-%m-%d %H:%M:%S'`] run_count=$run_count"
			echo "[`date '+%Y-%m-%d %H:%M:%S'`] ------------------------------------------"
		fi

		if [[ $flag1 -eq $flag3 ]];then
			sleep 30
		elif [[ $((flag4-flag2)) -eq 8 ]];then
			sleep 30
			#echo "[`date '+%Y-%m-%d %H:%M:%S'`] ------------------------------------------"
			flag1=$flag3
			flag2=$flag4
			#echo "[`date '+%Y-%m-%d %H:%M:%S'`] flag1=$flag3"
			#echo "[`date '+%Y-%m-%d %H:%M:%S'`] flag2=$flag4"
			#echo "[`date '+%Y-%m-%d %H:%M:%S'`] ------------------------------------------"
		else 
			echo "[`date '+%Y-%m-%d %H:%M:%S'`] ##########################################"
			echo "[`date '+%Y-%m-%d %H:%M:%S'`] flag4-flag2=$((flag4-flag2))"
			flag1=$flag3
			flag2=$flag4
			echo "[`date '+%Y-%m-%d %H:%M:%S'`] ------------------------------------------"
			echo "[`date '+%Y-%m-%d %H:%M:%S'`] flag1=$flag3"
			echo "[`date '+%Y-%m-%d %H:%M:%S'`] flag2=$flag4"
			echo "[`date '+%Y-%m-%d %H:%M:%S'`] failed"
			echo "[`date '+%Y-%m-%d %H:%M:%S'`] ##########################################"
			sleep 30
		fi
	done
