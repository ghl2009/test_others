#!/bin/bash
###################################
## auther:Tester
## date:20181213
## work:tla322 performance testing
###################################

#*此区间内参数需进行配置********************************************************************

##定义要DBA的ip
DBA_ip='192.168.5.157'
##定义要运行meter_broadcast的ip,meter_ip与DBA_ip可相同
meter_ip='192.168.5.194'

##定义meter_broadcast打包参数,
##注:1、pcap包需要定义绝对路径 2、需要把包按路径放于打包设备上 3、顺序执行列表中的meter
meter_param=(
		#'--worker 1 --loop 1 --pps 20000 eth1 /home/meter/sto2.pcap'
		#'--worker 1 --loop 1 --pps 20000 eth1 /home/meter/sto2.pcap'
		#'--worker 1 --loop 1 --pps 20000 eth5 /home/meter/192.168.0.147-1521-orcl-2hournewsql.pcapng'
		'--worker 1 --loop 1 --pps 20000 eth5 /home/meter/192.168.0.147-1521-orcl-2hournewsql-2.pcapng'
		'--worker 1 --loop 1 --pps 20000 eth1 /home/meter/object_summary1.pcapng'
		#'--worker 1 --loop 1 --pps 20000 eth5 /home/meter/object_summary2.pcapng'
)

##定义以上meter列表是否伴随其它并行的meter_broadcast,1 要存在并行; 0 不要存在并行
And_meter=1
##定义并行meter_broadcast打包参数
And_meter_param=(
		#'--worker 5 --loop 2 --pps 5000 eth5 /home/meter/loadrunner.pcap'
		#'--worker 2 --loop 5 --pps 1000 eth5 /home/meter/loadrunner.pcap'
		'--worker 1 --loop 1 --pps 20000 eth5 /home/meter/sto2.pcap'
		'--worker 1 --loop 2 --pps 20000 eth5 /home/meter/sto2.pcap'
)

##是否留存tlog文件, 0 否; 1 是
tlog_Retain=0

##此脚本执行完后是否关闭ssh_keygen_login, 0 否; 1 是
ssh_keygen_toclose=1

#********************************************************************************************


##程序log输出函数
function printf_log()
{
	if [ $1 -eq 1 ];then
		printf "%s\t%-6s\t%-5s\t%s\n" "[$(date +%Y-%m-%d' '%H:%M:%S)]" "$$" "INFO" "$2"
		printf "%s\t%-6s\t%-5s\t%s\n" "[$(date +%Y-%m-%d' '%H:%M:%S)]" "$$" "INFO" "$2" >> $tla322_PT_dir/$PT_log_name
	elif [ $1 -eq 0 ];then
		printf "%s\t%-6s\t%-5s\t%s\n" "[$(date +%Y-%m-%d' '%H:%M:%S)]" "$$" "ERROR" "$2"
		printf "%s\t%-6s\t%-5s\t%s\n" "[$(date +%Y-%m-%d' '%H:%M:%S)]" "$$" "ERROR" "$2" >> $tla322_PT_dir/$PT_log_name

	else
		print "function prinf_log pass param error!"
	fi 
}

##ssh免密登录函数,ssh-keygen login
function ssh_keygen_login()
{
	
	T_key_ip=`ifconfig eth0|awk '/inet addr/{print $2}'|awk -F : '{print $2}'`
	R_key_ip=$1
	key_yes_or_no=$2

	#ssh_key_dir="$Agent_Auto_PT_home_dir/ssh_key"

	cmd1="sed -i '/\bRSAAuthentication\b/s/.*/RSAAuthentication yes/' /etc/ssh/sshd_config"
	cmd2="sed -i '/\bPubkeyAuthentication\b/s/.*/PubkeyAuthentication yes/' /etc/ssh/sshd_config"
	cmd3="sed -i '/\bStrictHostKeyChecking\b/s/.*/StrictHostKeyChecking no/' /etc/ssh/ssh_config"
	cmd4="sed -i '/\bAuthorizedKeysFile\b/s/.*/AuthorizedKeysFile .ssh\/authorized_keys/' /etc/ssh/sshd_config"
	cmd5="sed -i '/\bRSAAuthentication\b/s/.*/RSAAuthentication no/' /etc/ssh/sshd_config"
	cmd6="sed -i '/\bPubkeyAuthentication\b/s/.*/PubkeyAuthentication no/' /etc/ssh/sshd_config"
	cmd7="sed -i '/\bStrictHostKeyChecking\b/s/.*/#   StrictHostKeyChecking ask/' /etc/ssh/ssh_config"
	#cmd8="rm -rf /root/.ssh/{authorized_keys,id_rsa}"
	cmd8="rm -rf /root/.ssh/authorized_keys"
	cmd9="service sshd restart >>/dev/null"

	if [[ $2 == y ]];then
		scp /root/.ssh/{authorized_keys,id_rsa}  root@$R_key_ip:/root/.ssh/
		ssh root@$R_key_ip "$cmd1;$cmd2;$cmd3;$cmd4;$cmd9" 
	elif [[ $2 == n ]];then
		ssh root@$R_key_ip "$cmd5;$cmd6;$cmd7;$cmd8;$cmd9"
	else
		echo "Please pass in parameters correctly."


		exit
	fi
}

##定义DbA程序目录
dbfw_home="/home/dbfw/dbfw"

##创建tla322_PT.sh程序生成日志的存放目录
tla322_PT_dir='/home/tla322_PT'
mkdir -p $tla322_PT_dir

##定义log名称
PT_log_name="tla322_PT_`date +'%Y%m%d%H%M%S'`_$$.log"

##把DBA、打包机设置不免密登录
mkdir -p /root/.ssh
rm -rf /root/.ssh/{id_rsa,id_rsa.pub,authorized_keys}
ssh-keygen  -t rsa -P '' -f /root/.ssh/id_rsa
mv /root/.ssh/{id_rsa.pub,authorized_keys}
ssh_keygen_login "${DBA_ip}" "y"
printf_log 1 "$DBA_ip ssh_keygen_login success!"
ssh_keygen_login "${meter_ip}" "y"
printf_log 1 "$meter_ip ssh_keygen_login success!"

##判断是否为双数据中心
###trace_logs_detail_part表所处数据中心端口
port=`ssh root@$DBA_ip cat ${dbfw_home}/etc/dbfw50.ini|grep "__DATASERVER_PORT_FOR_TLS"|awk -F= '{print $2}'`
if [[ $port -eq 9207 ]];then
	DBC_count=1
	printf_log 1 "DBC_count=1"
elif [[ $port -eq 9208 ]];then
	DBC_count=2
	printf_log 1 "DBC_count=2" 
fi

##定义连接trace_logs_detail_part表所在本地数据中心命令 
DBCDataView_dc="/home/dbfw/dbfw/DBCDataCenter/bin/DBCDataView -h127.0.0.1 -P9207 -uroot -p1 --default-character-set=utf8"
DBCDataView_tc="/home/dbfw/dbfw/DBCDataCenter/bin/DBCDataView -h127.0.0.1 -P9208 -uroot -p1 --default-character-set=utf8"

##得到产品版本号
soft_version=`ssh root@$DBA_ip "$DBCDataView_dc dbfwsystem -N -e 'SELECT soft_major_version,soft_minor_version,soft_svn_version,soft_build_version FROM version_main ORDER BY id desc;'"`
soft_version=`echo $soft_version |sed 's/ /./g'`
soft_version="`cat /etc/producttype`$soft_version"

##移走tla322
ssh root@$DBA_ip "mv ${dbfw_home}/bin/tla322{,_PT.bak}"
printf_log 1 "tla322 rename tla322_Pt.bak" 

##meter打包前kill掉所有npp
if [[ `ssh root@$DBA_ip "ps -ef|grep npp|grep -v grep|wc -l"` -gt 0 ]];then
	ssh root@$DBA_ip /home/dbfw/dbfw/bin/killallnpp.sh > /dev/null 2>&1
	printf_log 1 "meter before kill npp success!"
fi

##按是否为双数据中心取trace_logs_detail_part表中的数据条数
if [[ $DBC_count -eq 1 ]];then
	trace_count_b=`ssh root@$DBA_ip "$DBCDataView_dc dbfw -N -e 'select count(tlogid) from trace_logs_detail_part;'"`
	if [[ -z $trace_count_b ]];then
		trace_count_b=0
	fi
	printf_log 1 "meter before trace_count=$trace_count_b"

elif [[ $DBC_count -eq 2 ]];then
	trace_count_b=`ssh root@$DBA_ip "$DBCDataView_tc dbfw -N -e 'select count(tlogid) from trace_logs_detail_part;'"`
	if [[ -z $trace_count_b ]];then
		trace_count_b=0
	fi
	for t_num in `seq 1 3`
		do
			trace_count_b_tmp=`ssh root@$DBA_ip "$DBCDataView_tc dbfw -N -e 'select count(tlogid) from trace_logs_detail_part_${t_num};'"`
			if [[ -z $trace_count_b ]];then
				trace_count_b_tmp=0
			fi
			((trace_count_b=trace_count_b+trace_count_b_tmp))
		done
	printf_log 1 "meter before trace_count=$trace_count_b"
fi

##按DBA版本取object或obj_table表中的数据条数
##得到数据中心所有表列表
DBC_table_list=`ssh root@$DBA_ip "$DBCDataView_dc dbfw -N -e 'show tables;'"`

##是否为对象统计的版本
obj_summary_flag=`echo $DBC_table_list |grep "obj_table" |wc -l`
printf_log 1 "Get obj_summary_flag=$obj_summary_flag"

if [[ $obj_summary_flag -gt 0 ]];then
        obj_table_count_b=`ssh root@$DBA_ip "$DBCDataView_dc dbfw -N -e 'select count(id) from obj_table;'"`
        if [[ -z $obj_table_count_b ]];then
                obj_table_count_b=0
        fi
        printf_log 1 "meter before obj_table_count=$obj_table_count_b"

else
        objects_count_b=`ssh root@$DBA_ip "$DBCDataView_dc dbfw -N -e 'select count(object_id) from objects'"`
        if [[ -z $objects_count_b ]];then
                objects_count_b=0
        fi
        printf_log 1 "meter before objects_count=$objects_count_b"
fi

##记录And_meter开始时间
And_meter_time_b=`date "+%Y-%m-%d %H:%M:%S"`
printf_log 1 "And_meter Begin time=$And_meter_time_b"

##并行meter启动函数
function And_meter_RunAndMon()
{
	And_meter_p="$1"
	((Num=$2+1))
	log_flag="$3"
	kill_flag="$4"
	And_meter_param_tmp=`echo $And_meter_p |sed 's/-/\\\-/g'`
	And_meter_flag=`ssh root@$meter_ip ps -ef |grep "$And_meter_param_tmp" |grep -v "grep"|wc -l`

	if [[ kill_flag -eq 0 ]];then
		if [[ $And_meter -eq 1 ]] && [[ $And_meter_flag -eq 0 ]];then
			ssh root@$meter_ip "nohup ${dbfw_home}/sbin/meter_broadcast $And_meter_p >/dev/null 2>&1 &"

			##定义And_meter打包次数
			And_meter_count_tmp=`eval echo '$'And_meter_count_${Num}`
			if [[ -z $And_meter_count_tmp ]];then
				eval And_meter_count_${Num}=0
			fi
			
			((And_meter_count_${Num}=And_meter_count_${Num}+1))

			printf_log 1 "And_meter${Num} Begin run!,And_meter${Num}_param: $And_meter_p"
		else
			if [[ $log_flag -eq 1 ]];then
				printf_log 1 "And_meter${Num} running!"
			fi
		fi
	else

                And_meter_pid=`ssh root@$meter_ip ps -ef|grep "$And_meter_param_tmp" |grep -v "grep" |awk '{print $2}'`
                ssh root@$meter_ip kill -9 $And_meter_pid 
                printf_log 1 "kill And_meter${Num}"
                And_meter_count=`eval echo '$'"And_meter_count_${Num}"`
                printf_log 1 "And_meter${Num} run count=$And_meter_count"
	fi
}

##meter打包，及监控meter是否退出的函数
function meter_RunAndMon()
{
	##meter打包
	ssh root@$meter_ip "nohup ${dbfw_home}/sbin/meter_broadcast $1 >/dev/null 2>&1 &"
	printf_log 1 "meter$2 Begin run! meter_param: $1"

	##记录打包前时间
	meter_time_b=`date "+%Y-%m-%d %H:%M:%S"`
	printf_log 1 "meter$2 Begin time=$meter_time_b"

	##处理参数，特殊字符的转义
	meter_param_tmp=`echo $1 |sed 's/-/\\\-/g'`
	
	#printf_log 1 "meter param:"

	##监控meter是否退出
	num=0
	while true
		do
			meter_flag=`ssh root@$meter_ip ps -ef |grep "$meter_param_tmp" |grep -v "grep"|wc -l`
			((num=num+1))
			if [[ meter_flag -gt 0 ]];then
				if [[ $num -eq 30 ]];then
					printf_log 1 "meter$2 running,Need to wait!"
					num=0

					##并行meter运行
					for i in `seq 1 ${#And_meter_param[@]}`
						do
							((i=i-1))
							And_meter_RunAndMon "${And_meter_param[$i]}" "$i" "1" "0"
						done

					sleep 1
					continue
				else

                                        ##并行meter运行
					#echo ${#And_meter_param[@]}
					for i in `seq 1 ${#And_meter_param[@]}`
						do
							((i=i-1))

							And_meter_RunAndMon "${And_meter_param[$i]}" "$i" "0" "0"
						done

					sleep 1
					continue
				fi
			else
				meter_time_e=`date "+%Y-%m-%d %H:%M:%S"`
				printf_log 1 "meter$2 End time=$meter_time_e"
				meter_time_b_stamp=`date -d "$meter_time_b" +%s`
				meter_time_e_stamp=`date -d "$meter_time_e" +%s`
				((meter_Use_time=meter_time_e_stamp-meter_time_b_stamp))
				printf_log 1 "meter$2 Use time=$meter_Use_time"
				export meter_Use_time
				break
			fi
		done
}

meter_Num=0
meter_Use_time_totel=0
for meter_param_Num in "${meter_param[@]}"  
	do
		((meter_Num=meter_Num+1))
		meter_RunAndMon "$meter_param_Num" "$meter_Num"
		##已运行完的meter打包耗时
		((meter_Use_time_totel=meter_Use_time_totel+meter_Use_time))
	done

##监测And_meter是否结束,记录结束时间
#if [[ And_meter -eq 1 ]];then
#	while true
#		do
#			And_meter_flag=`ps -ef|grep "$And_meter_param_tmp" |grep -v "grep"|wc -l`
#			if [[ $And_meter_flag -eq 1 ]];then
#				printf_log 1 "And_meter running,Need to wait!"
#				sleep 1
#			else
#				And_meter_time_e=`date "+%Y-%m-%d %H:%M:%S"`
#				printf_log 1 "And_meter End time=$And_meter_time_e!"	
#				((And_meter_count=And_meter_count+1))
#				printf_log 1 "And_meter run num=$And_meter_count"	
#				((And_meter_Use_time=And_meter_time_e-And_meter_time_b))
#				printf_log 1 "And_meter Use time=$And_meter_Use_time"
#				break
#			fi
#		done
#fi

sleep 5 
##得到tlog名称列表
tlog_name_list=(`ssh root@$DBA_ip ls -l /dbfw_tlog |grep -v "total" |awk '{print $9}'`)
if [[ -z $tlog_name_list ]];then
	printf_log 0 "tlogfile not exist,Please check meter param!"
	##移回tla322
	ssh root@$DBA_ip mv ${dbfw_home}/bin/tla322{_PT.bak,}
	ssh root@$DBA_ip chown dbfw:dbfw ${dbfw_home}/bin/tla322
	ssh root@$DBA_ip chmod 775 ${dbfw_home}/bin/tla322
	exit
fi
##得到tlog数量
tlog_count=${#tlog_name_list[@]}
printf_log 1 "Get tlog_count=$tlog_count"
##得到第一个tlog名称
tlog_name_First=`echo ${tlog_name_list[0]}`
printf_log 1 "First tlog_name=$tlog_name_First"
##得到最后一个tlog名称
tlog_name_Last=`echo ${tlog_name_list[$((tlog_count-1))]}`
printf_log 1 "Last tlog_name=$tlog_name_Last"

##留存tlog文件
if [[ $tlog_Retain -eq 1 ]];then
	tlog_file_dir="$tla322_PT_dir/tlog_file_`date +'%Y%m%d%H%M%S'`"
	mkdir -p $tlog_file_dir
	for tlog_name in "${tlog_name_list[@]}"
		do
			scp -r root@$DBA_ip:/dbfw_tlog/$tlog_name $tlog_file_dir/$tlog_name >> /dev/null
		done
	printf_log 1 "Get tlog_file Success! tlog_file_dir=$tlog_file_dir"
elif [[ $tlog_Retain -eq 0 ]];then
	printf_log 1 "Not Retain tlog_file"
else
	printf_log 0 "tlog_Retain param set error!"
fi


##打包过程产生的tlog数量,等5秒再取一次，如果两次相同，说明npc对包的处理已完成
#while true
#	do
#		tlog_count=`ls -l /dbfw_tlog |grep -v "total" |wc -l`
#		sleep 5
#		tlog_count_tmp=`ls -l /dbfw_tlog |grep -v "total" |wc -l`
#		if [[ $tlog_count -eq $tlog_count_tmp ]];then
#			printf_log 1 "tlog_count=$tlog_count"
#			break
#		fi
#	done

##移回tla322
ssh root@$DBA_ip mv ${dbfw_home}/bin/tla322{_PT.bak,}
ssh root@$DBA_ip chown dbfw:dbfw ${dbfw_home}/bin/tla322
ssh root@$DBA_ip chmod 775 ${dbfw_home}/bin/tla322

printf_log 1 "restore tla322"

##记录tla322入库开始时间,即tla322移回时间
tlog_time_b=`ssh root@$DBA_ip 'date "+%Y-%m-%d %H:%M:%S"'`
printf_log 1 "tlog Analysis Begin time=$tlog_time_b"

##启动nmon,nmon参数为10s一次,启动6小时
ssh root@$DBA_ip mkdir -p $tla322_PT_dir/data_nmon
ssh root@$DBA_ip /usr/bin/nmon -s10 -c2160 -f -m $tla322_PT_dir/data_nmon > /dev/null 2>&1
nmon_pid=`ssh root@$DBA_ip ps -ef|grep "/usr/bin/nmon -s10"|grep -v "grep"|awk '{print $2}'`
printf_log 1 "nmon Begin run! nmon_pid=$nmon_pid,output file dir:$tla322_PT_dir/data_nmon"

##监控tlog是否入库完成
num=0

while true
	do
		tlog_count=`ssh root@$DBA_ip ls -l /dbfw_tlog |grep "$tlog_name_Last"|wc -l`
		if [[ $tlog_count -eq 0 ]];then

			tlog_time_e=`ssh root@$DBA_ip 'date "+%Y-%m-%d %H:%M:%S"'`
			printf_log 1 "tlog Analysis completed! End time=$tlog_time_e"

			##kill 并行meter
                        for i in `seq 1 ${#And_meter_param[@]}`
                                do
                                        ((i=i-1))
                                        And_meter_RunAndMon "${And_meter_param[$i]}" "$i" "1" "1"
                                done			

			break
		elif [[ $num -eq 30 ]];then
			num=0
			printf_log 1 "tlog Analysis running,Need to wait!"

                        for i in `seq 1 ${#And_meter_param[@]}`
                                do
                                        ((i=i-1))
                                        And_meter_RunAndMon "${And_meter_param[$i]}" "$i" "1" "0"
                                done

			sleep 1
			continue
		else
			((num=num+1))

			##并行meter运行
                        for i in `seq 1 ${#And_meter_param[@]}`
                                do
                                        ((i=i-1))
                                        And_meter_RunAndMon "${And_meter_param[$i]}" "$i" "0" "0"
                                done

			sleep 1
			continue

		fi
	done


##kill nmon进程
sleep 10 
nmon_pid=`ssh root@$DBA_ip ps -ef|grep "/usr/bin/nmon -s10"|grep -v "grep"|awk '{print $2}'`
ssh root@$DBA_ip kill -9 $nmon_pid

##tlog入库完成后获取trace_logs_detail_part表内数据条数			
if [[ $DBC_count -eq 1 ]];then
        trace_count_e=`ssh root@$DBA_ip "$DBCDataView_dc dbfw -N -e 'select count(tlogid) from trace_logs_detail_part;'"`
        if [[ -z $trace_count_e ]];then
                trace_count_e=0
        fi
        printf_log 1 "tlog Analysis after trace_count=$trace_count_e"
elif [[ $DBC_count -eq 2 ]];then
        trace_count_e=`ssh root@$DBA_ip "$DBCDataView_tc dbfw -N -e 'select count(tlogid) from trace_logs_detail_part;'"`
        if [[ -z $trace_count_e ]];then
                trace_count_e=0
        fi
        for t_num in `seq 1 3`
                do
                        trace_count_e_tmp=`ssh root@$DBA_ip "$DBCDataView_tc dbfw -N -e 'select count(tlogid) from trace_logs_detail_part_${t_num};'"`
                        if [[ -z $trace_count_e ]];then
                                trace_count_e_tmp=0
                        fi
                        ((trace_count_e=trace_count_e+trace_count_e_tmp))
                done
        printf_log 1 "tlog Analysis after trace_count=$trace_count_e"
fi

##按DBA版本取object或obj_table表中的数据条数
if [[ $obj_summary_flag -gt 0 ]];then
        obj_table_count_e=`ssh root@$DBA_ip "$DBCDataView_dc dbfw -N -e 'select count(id) from obj_table;'"`
        if [[ -z $obj_table_count_e ]];then
                obj_table_count_e=0
        fi
        printf_log 1 "meter after obj_table_count=$obj_table_count_e"

else
        objects_count_e=`ssh root@$DBA_ip "$DBCDataView_dc dbfw -N -e 'select count(object_id) from objects;'"`
        if [[ -z $objects_count_e ]];then
                objects_count_e=0
        fi
        printf_log 1 "meter after objects_count=$objects_count_e"
fi


##产品版本


##所有meter打包耗时总和
printf_log 1 "meter totel Use time=$meter_Use_time_totel"

##取系统cpu mem信息
function Get_Sys_Info()
{
        local cpu mem disk

    cpu=`ssh root@$DBA_ip cat /proc/cpuinfo|grep processor|tail -n 1|awk '{print $3+1}'`
    mem=`ssh root@$DBA_ip /usr/bin/free -g|grep 'Mem'|awk '{print $2}'`
    disk=`ssh root@$DBA_ip fdisk -l 2>/dev/null|grep -E 'Disk /dev/sd|Disk /dev/xvd'|awk '{sum+=$5} END {print sum/1000/1000/1000}'`

    if [ "$mem" -le 32 ];then
        ((mem=$mem+1))
    elif [ "$mem" -gt 32 -a "$mem" -le 64 ];then
        ((mem=$mem+2))
    elif [ "$mem" -gt 64 -a "$mem" -le 128 ];then
        ((mem=$mem+3))
    else
        ((mem=$mem+4))
    fi

        export SYS_CPU=${cpu}
        export SYS_MEM=${mem}
        export SYS_DISK=${disk}

}

Get_Sys_Info
echo "--------------------------------------------------------------------------------------------------"
printf_log 1 "OS_CPU_Core=$SYS_CPU;OS_MEM=${SYS_MEM}G;OS_SYS_DISK=${SYS_DISK}G"

echo "--------------------------------------------------------------------------------------------------"
if [[ $soft_version == 'DBA3.2.4.5' ]] && [[ $obj_summary_flag == 1 ]];then
	printf_log 0 "version_main Record version error! soft_version=$soft_version"
	soft_version='DBA3.2.4.6'
	printf_log 1 "version_main Record Correct version should be $soft_version"
	echo "--------------------------------------------------------------------------------------------------"
else
	printf_log 1 "Get version Success! soft_version=$soft_version"
	echo "--------------------------------------------------------------------------------------------------"
fi

##对像统计是否支持,支持的情况下,开关是否开启
if [[ $obj_summary_flag -gt 0 ]];then
	printf_log 1 "Version support object_summary!"
	echo "--------------------------------------------------------------------------------------------------"
	S_OBJECTS_SWITCH=`ssh root@$DBA_ip "$DBCDataView_dc dbfw -N -e 'SELECT param_value FROM param_config where param_id=103;'"`
	if [[ $S_OBJECTS_SWITCH -eq 1 ]];then
		printf_log 1 "objects summary switch state: Open! S_OBJECTS_SWITCH=$S_OBJECTS_SWITCH"
		echo "--------------------------------------------------------------------------------------------------"
	else
		printf_log 1 "objects summary switch state: Close! S_OBJECTS_SWITCH=$S_OBJECTS_SWITCH"
		echo "--------------------------------------------------------------------------------------------------"
	fi
fi

##tlog入库前后obj_table或object表中数增长条数
if [[ $obj_summary_flag -gt 0 ]];then
	((obj_table_count=obj_table_count_e-obj_table_count_b))
        printf_log 1 "obj_table incr count=$obj_table_count"
	#echo "--------------------------------------------------------------------------------------------------"
	#((obj_table_count_sec=obj_table_count/tlog_time))
	#printf_log 1 "obj_table per-second count=$obj_table_count_sec"
	echo "--------------------------------------------------------------------------------------------------"
else
	((objects_count=obj_table_count_e-obj_table_count_b))
        printf_log 1 "objects incr count=$objects_count"
	echo "--------------------------------------------------------------------------------------------------"
	#((objects_count_sec=objects_count/tlog_time))
	#printf_log 1 "objects per-second count=$objects_count_sec"
	#echo "--------------------------------------------------------------------------------------------------"
fi

##tlog入库时长
tlog_time_b_stamp=`date -d "$tlog_time_b" +%s` 
tlog_time_e_stamp=`date -d "$tlog_time_e" +%s` 
((tlog_time=tlog_time_e_stamp-tlog_time_b_stamp))
printf_log 1 "tlog Analysis Use time=${tlog_time}s"
echo "--------------------------------------------------------------------------------------------------"

##tlog入库前后trace_logs_detail_part表中数增长条数
((trace_count=trace_count_e-trace_count_b))
printf_log 1 "trace_logs_detail_part incr count=$trace_count"
echo "--------------------------------------------------------------------------------------------------"
##每秒入库条数
((trace_count_sec=trace_count/tlog_time))
printf_log 1 "trace_logs_detail_part per-second count=$trace_count_sec"
echo "--------------------------------------------------------------------------------------------------"

##关闭DBA及打包机的ssh_keygen_login
if [[ $ssh_keygen_toclose -eq 1 ]];then
	if [[ ${DBA_ip} == ${meter_ip} ]];then
		ssh_keygen_login "${DBA_ip}" "n"
	else
		ssh_keygen_login "${DBA_ip}" "n"
		ssh_keygen_login "${meter_ip}" "n"
	fi
elif [[ $ssh_keygen_toclose -eq 0 ]];then
	exit
else
	printf_log 0 "ssh_keygen_toclose param error!"
fi
