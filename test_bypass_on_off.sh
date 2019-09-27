#!/bin/bash
#!/bin/bash
########################################################
## author:liuguanghui
## date  :20190808
## work  :Bypass repeated on and off
########################################################

bypass_cmd="$1"
if [[ $bypass_cmd == "bp_ctl5130" ]];then
        bypass_on_cmd="/home/dbfw/dbfw/bin/$bypass_cmd 99 set_bypass_pwon on"
        echo "[`date '+%Y-%m-%d %H:%M:%S'`] bypass_on_cmd=$bypass_on_cmd"
        bypass_off_cmd="/home/dbfw/dbfw/bin/$bypass_cmd 99 set_bypass_pwon off"
        echo "[`date '+%Y-%m-%d %H:%M:%S'`] bypass_off_cmd=$bypass_off_cmd"
elif [[ $bypass_cmd == "bp_ctl5132" ]];then
        bypass_on_cmd="/home/dbfw/dbfw/bin/$bypass_cmd bpon 99 0 1"
        echo "[`date '+%Y-%m-%d %H:%M:%S'`] bypass_on_cmd=$bypass_on_cmd"
        bypass_off_cmd="/home/dbfw/dbfw/bin/$bypass_cmd bpon 99 0 0"
        echo "[`date '+%Y-%m-%d %H:%M:%S'`] bypass_off_cmd=$bypass_off_cmd"
elif [[ $bypass_cmd == "bpctl_util" ]];then
        :
elif [[ $bypass_cmd == "bp_ctl5174" ]];then
        bypass_on_cmd="/home/dbfw/dbfw/bin/$bypass_cmd bpon 99 0 1"
        echo "[`date '+%Y-%m-%d %H:%M:%S'`] bypass_on_cmd=$bypass_on_cmd"
        bypass_off_cmd="/home/dbfw/dbfw/bin/$bypass_cmd  bpon 99 0 0"
        echo "[`date '+%Y-%m-%d %H:%M:%S'`] bypass_off_cmd=$bypass_off_cmd"
elif [[ $bypass_cmd == "bp_ctl5170" ]];then
        bypass_on_cmd="/home/dbfw/dbfw/bin/$bypass_cmd bpon 99 0 1"
        echo "[`date '+%Y-%m-%d %H:%M:%S'`] bypass_on_cmd=$bypass_on_cmd"
        bypass_off_cmd="/home/dbfw/dbfw/bin/$bypass_cmd bpon 99 0 0"
        echo "[`date '+%Y-%m-%d %H:%M:%S'`] bypass_off_cmd=$bypass_off_cmd"
fi

x_packets_avg=0
for i in `seq 1 10`
        do
                x_packets_list=(`cat /dev/shm/dpdk/dpdk_nic_stats |grep x_packets|awk 'NR<=4&&NR>=0{print $3}'`)
                echo "[`date '+%Y-%m-%d %H:%M:%S'`] x_packets_list=${x_packets_list[*]}"
                x_packets_sum=0
                for x_packets_tmp in "${x_packets_list[@]}"
                        do
                                x_packets_sum=$((x_packets_sum+x_packets_tmp))
                        done
                x_packets_avg_tmp=$((x_packets_sum/4))
                x_packets_avg=$((x_packets_avg+x_packets_avg_tmp))
                if [[ $i -eq 10 ]];then
                        x_packets_avg=$((x_packets_avg/i))
                        echo "[`date '+%Y-%m-%d %H:%M:%S'`] x_packets_avg=$x_packets_avg"
                        x_packets_per_80=$((x_packets_avg*80/100))
                        echo "[`date '+%Y-%m-%d %H:%M:%S'`] x_packets_per_80=$x_packets_per_80"
                        x_packets_per_120=$((x_packets_avg*120/100))
                        echo "[`date '+%Y-%m-%d %H:%M:%S'`] x_packets_per_120=$x_packets_per_120"
                else
                        sleep 1
                fi
        done

echo "datetime,run_count,usleep_time,success_wait_count1,fail_wait_count,success_wait_count2" >test_bypass.report
run_count=0
while true
        do
                run_count=$((run_count+1))
		#echo "[0000-00-00 00:00:00],0,0,0,0,0" >> test_bypass.report
                echo "[`date '+%Y-%m-%d %H:%M:%S'`] run_count=$run_count"
		usleep_time=$((RANDOM*50))
		if [[ $bypass_cmd == "bp_ctl5170" ]] || [[ $bypass_cmd == "bp_ctl5174" ]];then
			usleep_time=$((usleep_time+1000000))
		fi
		echo "[`date '+%Y-%m-%d %H:%M:%S'`] usleep_time=$usleep_time"
                $bypass_on_cmd
		usleep $usleep_time
                $bypass_off_cmd
		echo "[`date '+%Y-%m-%d %H:%M:%S'`] bypass on off success!!"
		fail_wait_count=0
		success_wait_count=0
		success_wait_count1=0
		success_wait_count2=0
                while [[ $success_wait_count -lt 5 ]]
                        do
                                x_packets_list=(`cat /dev/shm/dpdk/dpdk_nic_stats |grep x_packets|awk 'NR<=4&&NR>=0{print $3}'`)
                                echo "[`date '+%Y-%m-%d %H:%M:%S'`] x_packets_list=${x_packets_list[*]}"
                                k=0
                                for x_packets_tmp in "${x_packets_list[@]}"
                                        do
                                                if [[ $x_packets_tmp -lt $x_packets_per_80 ]] || [[ $x_packets_tmp -gt $x_packets_per_120 ]];then
							k=$((k+1))
                                                        #fail_wait_count=$((fail_wait_count+1))
                                                        #echo "[`date '+%Y-%m-%d %H:%M:%S'`] fail_wait_count=$fail_wait_count"
                                                        success_wait_count=0
                                                        if [[ $k -eq 1 ]];then
                                                                echo "[`date '+%Y-%m-%d %H:%M:%S'`] card1 rx not expected!!"
                                                        elif [[ $k -eq 2 ]];then
                                                                echo "[`date '+%Y-%m-%d %H:%M:%S'`] card1 tx not expected!!"
                                                        elif [[ $k -eq 3 ]];then
                                                                echo "[`date '+%Y-%m-%d %H:%M:%S'`] card2 rx not expected!!"
                                                        elif [[ $k -eq 4 ]];then
                                                                echo "[`date '+%Y-%m-%d %H:%M:%S'`] card2 tx not expected!!"
                                                        fi
						fi
					done
				if [[ $k -eq 0 ]];then
					success_wait_count=$((success_wait_count+1))
					echo "[`date '+%Y-%m-%d %H:%M:%S'`] success_wait_count=$success_wait_count"
					if [[ $fail_wait_count -eq 0 ]];then
						success_wait_count1=$success_wait_count	
					else
						success_wait_count2=$success_wait_count
					fi
				else	
					fail_wait_count=$((fail_wait_count+1))
					echo "[`date '+%Y-%m-%d %H:%M:%S'`] fail_wait_count=$fail_wait_count"
				fi
				sleep 1
			done	
		if [[ $fail_wait_count -eq 0 ]];then
			success_wait_count2=$success_wait_count1
			success_wait_count1=0
		fi
		echo "[`date '+%Y-%m-%d %H:%M:%S'`],$run_count,$usleep_time,$success_wait_count1,$fail_wait_count,$success_wait_count2" >> test_bypass.report
		echo "[`date '+%Y-%m-%d %H:%M:%S'`] is expected!!" 
	done
