#!/bin/bash

###############################################
## author:liuguanghui
## date  :20190417
## work:Get Store_log_days_estimate
###############################################

echo "---------------------------------------------------------------"
##定义数据中心连接
DB_View='/home/dbfw/dbfw/DBCDataCenter/bin/DBCDataView -P9207 -h127.0.0.1 -uroot -p1 dbfw'

##得到bkup分区总大小
if [[ $1 -eq 1 ]];then
	##df -m得到bkup分区可用大小
	bkup_total=`df -m -P|grep dbfw_bkup|awk '{print $2}'`
	#bkup_total=`cat /home/dbfw/dbfw/etc/diskinfo|grep dbfw_bkup|awk '{print $2}'`

	##得到bkup分区可用大小
	#bkup_Avail=`cat /home/dbfw/dbfw/etc/diskinfo|grep dbfw_bkup|awk '{print $4}'`
	bkup_Avail=`df -m -P|grep dbfw_bkup|awk '{print $4}'`
	##算出bkup区已用分区大小

	bkup_used=`echo $bkup_total-$bkup_Avail|bc`
else
	##得到shmid
	Shmid=`ps -ef|grep smon|grep -v grep|awk '{print $(NF-2)}'`
	##debug fixed区
	su - dbfw -c "/home/dbfw/dbfw/bin/dbfwdebug $Shmid fixed t fixed.txt" >/dev/null
	sleep 2
	##fixed共享内存区得到bkup分区总大小
	bkup_total=`cat /home/dbfw/fixed.txt|grep disk_backup_total|awk '{print $3}'`
	echo `date '+[%Y%m%d %H:%m:%S]'` SGA_bkup_total=$bkup_total

	##fixed共享内存区得到bkup分区已用分区大小
	bkup_used=`cat /home/dbfw/fixed.txt|grep disk_backup_used|awk '{print $3}'`
	echo `date '+[%Y%m%d %H:%m:%S]'` SGA_bkup_used=$bkup_used
fi

##删除fixed.txt文件
#rm -rf /home/dbfw/fixed.txt


##得到前台配置清理门限，即不清理的情况下可用大小

S_TLC_GATE=`$DB_View -N -e 'select param_value from param_config where param_id=251'`
echo `date '+[%Y%m%d %H:%m:%S]'` S_TLC_GATE=$S_TLC_GATE

####工控机环境下需要减去磁盘管理信息的空间占用,虚拟化和服务器环境不需要
##查看是否为虚拟化的条件
RUN_ENVIRONMENT=`$DB_View -N -e 'select param_value from param_config where param_id=164'`
echo `date '+[%Y%m%d %H:%m:%S]'` RUN_ENVIRONMENT=$RUN_ENVIRONMENT

##查看是否为服务器的条件
Server_flag=`cat /home/dbfw/dbfw/etc/dbfw50.ini|grep 9208|wc -l`
echo `date '+[%Y%m%d %H:%m:%S]'` Server_flag=$Server_flag

if [[ $RUN_ENVIRONMENT == 'NORMAL' ]] && [[ $Server_flag == 0 ]];then
	##工控机设备获取磁盘管理信息的空间占用
	bkup_inode_used=`echo $bkup_total*5/100|bc`
	echo `date '+[%Y%m%d %H:%m:%S]'` bkup_inode_used=$bkup_inode_used
	bkup_avail=`echo "($bkup_total-$bkup_inode_used)*$S_TLC_GATE/100"|bc`
	#bkup_avail_tmp=`echo $bkup_total*$S_TLC_GATE/100|bc`
	bkup_avail_tmp=0
	bkup_used=`echo $bkup_used-$bkup_inode_used|bc`
else
	##虚拟化或服务器设备不需要获取磁盘管理信息的空间占用
	echo `date '+[%Y%m%d %H:%m:%S]'` VIRTUAL or SERVER not need to remove bkup_inode_used
	bkup_avail=`echo $bkup_total*$S_TLC_GATE/100|bc`
	bkup_used=`echo $bkup_used`
fi

#upgrade_bkup_flag=`ls -l -d /dbfw_bkup/dc/upgrade_bkup|wc -l`
upgrade_bkup_flag=`find /dbfw_bkup/ -name 'upgrade_bkup' -type d|wc -l`
echo `date '+[%Y%m%d %H:%m:%S]'` upgrade_bkup_flag=$upgrade_bkup_flag
#upgrade_tmp_flag=`ls -l -d /dbfw_bkup/dc/upgrade_tmp|wc -l`
upgrade_tmp_flag=`find /dbfw_bkup/ -name 'upgrade_tmp' -type d|wc -l`
echo `date '+[%Y%m%d %H:%m:%S]'` upgrade_tmp_flag=$upgrade_tmp_flag

if [[ $upgrade_bkup_flag -ne 0 ]];then
	bkup_avail=`echo $bkup_avail-300|bc`
	bkup_used=`echo $bkup_used-300|bc`
fi

if [[ $upgrade_tmp_flag -ne 0 ]];then 
	bkup_avail=`echo $bkup_avail-100|bc`
	bkup_used=`echo $bkup_used-100|bc`
fi

echo `date '+[%Y%m%d %H:%m:%S]'` bkup_avail=$bkup_avail
echo `date '+[%Y%m%d %H:%m:%S]'` bkup_used=$bkup_used

##得到已备份的天数
#day_num=`ls -l -d /dbfw_bkup/dc/20*|wc -l`
day_num=`find /dbfw_bkup/dc/ -name '20*' -type d|wc -l`
echo `date '+[%Y%m%d %H:%m:%S]'` day_num=$day_num

if [[ $day_num -eq 0 ]] || [[ $bkup_used -le 0 ]];then
	Store_log_days_estimate="---"
else
	##可用空间小于0时，加防守，直接为0
	if [[ $bkup_avail -lt 0 ]];then
		bkup_avail=$bkup_avail_tmp
	fi
	##算出平均每天占用了多少
	folder_size_per_day=`echo $bkup_used/$day_num|bc`
	echo `date '+[%Y%m%d %H:%m:%S]'` folder_size_per_day=$folder_size_per_day

	##获取前台设置的备份几天前数据
	S_BKUP_INTERVAL=`$DB_View -N -e 'select param_value from param_config where param_id=247'`
	day_interval=$S_BKUP_INTERVAL
	echo `date '+[%Y%m%d %H:%m:%S]'` day_interval=$day_interval

	##估算出还可以存备份的总天数
	Store_log_days_estimate_tmp=`echo $bkup_avail/$folder_size_per_day`
	##可以备份的天数加上在线分区未备份的天数
	Store_log_days_estimate=`echo $Store_log_days_estimate_tmp+$day_interval|bc`
fi


echo "---------------------------------------------------------------"
echo `date '+[%Y%m%d %H:%m:%S]'` Store_log_days_estimate=$Store_log_days_estimate
echo "---------------------------------------------------------------"


