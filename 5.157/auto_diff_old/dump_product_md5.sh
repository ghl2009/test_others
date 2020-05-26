#!/bin/bash

## craete md5 file ##
product_file_list=(
	/home/dbfw/dbfw  
	/dbfw_capbuf
	/usr/local/tomcat
	/usr/local/rmagent
	/home/conadmin/menu.sh
	/usr/local/apache
	/usr/local/apr
	/usr/local/apr-util
	/usr/local/pcre
	/usr/share/fonts/chinese
	/etc/init.d/dcserverd
	/etc/init.d/dcserverd2
	/usr/local/focus
	/usr/local/freetds
	/etc/init.d/initcloudpart
	/etc/init.d/StartDbfw
	/usr/lib/jdk17
        /usr/lib/jdk18
        /usr/local/netdata
        /usr/lib/perl5_lib
        /usr/lib64/perl5
        /usr/share/snmp
        /var/tmp/
        /tmp/dpdk
        /etc/init.d/stopdbfw
        /usr/local/bin/StartDbfw
        /usr/local/bin/stopdbfw
        /usr/local/bin/dcserverd
        /usr/local/bin/dcserverd2
        /etc/sysconfig/ip6tables
        /etc/sysconfig/iptables
        /etc/sysconfig/arptables
        /etc/sysconfig/ebtables
	/dev/shm/
	/etc/producttype
	/dbfw_data/dbfw
	/dbfw_data/dbfw_capbuf
	/dbfw_data/tomcat
	/dbfw_data/apache
)

## no create md5 file ##
no_create_md5_list=(
	"/home/dbfw/dbfw/bin/*.pid"
	"/home/dbfw/dbfw/bin/*.out"
	"/home/dbfw/dbfw/lib/*.a"
	/home/dbfw/dbfw/scripts/dc/funcsvn.log
	/usr/local/tomcat/webapps/ROOT/WEB-INF/report-engine/logs	

	/dbfw_capbuf
	/home/dbfw/dbfw/scripts/dc/funcsvn.log
	/usr/local/tomcat/work
	/usr/local/apache/upgrade/index.html
	/usr/local/tomcat/webapps/MMS/log
	/usr/local/tomcat/webapps/MMS/WEB-INF/logs
	/usr/local/tomcat/webapps/ROOT/WEB-INF/report-engine/logs
	/home/dbfw/dbfw/scripts/repairtable/conf/auto_fix_tmp_list
	/home/dbfw/dbfw/scripts/repairtable/conf/day_check_flag
	/home/dbfw/dbfw/scripts/repairtable/conf/part_file_backup_history
	/home/dbfw/dbfw/scripts/repairtable/conf/process_handle_num_note
)

## dbfw Don't compare data list ##
dbfw_no_dump_data_list=(
	#system_net_detail
	#system_cpu_detail
	#system_param
	#systemmonitor
	#sysaudit
	#focus_runhis
	#interface_group
	#interface_info
	#disk_alarms
	#audit_log
	#sqllog_detail_update_synchronized
)

if [[ ! -e "/home/dbfw/dbfw/DBCDataCenter/bin/DBCDataView" ]] || [[ ! -e "/home/dbfw/dbfw/DBCDataCenter/bin/DBCDataDump" ]];then
	echo "not found DBCDataView or DBCDataDump"
	exit 1;
fi


dump_file="./dump_file_`date '+%Y%m%d%H%M%S'`"
table_list_file="$dump_file/table_list"
procedure_sql="$dump_file/procedure_sql"
md5_file="$dump_file/product_md5"
permission_file="$dump_file/product_permission"
sysctl_file1="$dump_file/sysctl_config_file"
sysctl_file2="$dump_file/sysctl_display_system_param"

rm -rf $dump_file
mkdir $dump_file

## create md5 file ##
sylloge_A="sylloge_A"
sylloge_B="sylloge_B"
sylloge_tmp="sylloge"
tmp="sylloge.tmp"

rm -f $tmp $sylloge_tmp $sylloge_A $sylloge_B

for A_file_name in "${product_file_list[@]}"
do
	if [ "0" != "${#no_create_md5_list[@]}" ];then	
		for B_file_name in "${no_create_md5_list[@]}"
		do	
			if [ -e "$sylloge_B" ];then
				assemble="$sylloge_tmp"		
			else
				assemble="$sylloge_B"
			fi
			
			## B in A? ##
			if [ "`echo "$B_file_name" | grep "$A_file_name"`" = "$B_file_name" ];then	
				find "$A_file_name" '(' -path "$B_file_name" ')' -prune -o -type f -print | sort -k 2 > "$assemble"
			else
				continue; 
			fi	 
			
			## intersection ##
			if [[ -e "$sylloge_B" &&  -e "$sylloge_tmp" ]];then
				sort "$sylloge_B" "$sylloge_tmp" | uniq -d > $tmp
				cat "$tmp" > $sylloge_B
			fi
		done
		
		if [ -e "$sylloge_B" ];then
			cat "$sylloge_B" >> $sylloge_A
		else
			find "$A_file_name" -type f -print | sort -k 2 >> "$sylloge_A"
		fi
		
		rm -f $tmp $sylloge_tmp $sylloge_B
	else
		find "$A_file_name" -type f -print | sort -k 2 >> "$sylloge_A"
	fi
done
cat $sylloge_A | uniq | sort -k 2 | xargs md5sum > $md5_file
cat $sylloge_A | uniq | sort -k 2 | xargs ls -l | awk '{print $1" "$3" "$4" "$9}' > $permission_file

rm -f $tmp $sylloge_tmp $sylloge_A $sylloge_B

for port in 9207 9208
do
	if [ "$port" = "9208" ];then
		if [ "$(ps -ef |grep -v grep |grep DBCDataCenter2|wc -l)" == "0" ];then
		# 如果没有第二个策略中心 则跳过
		continue
		fi
	fi

	execute_sql="/home/dbfw/dbfw/DBCDataCenter/bin/DBCDataView -h127.0.0.1 -P$port -uroot -pDBSec@1234 --default-character-set=utf8"
	dump_table="/home/dbfw/dbfw/DBCDataCenter/bin/DBCDataDump --compact --skip-extended-insert -h127.0.0.1 -P$port -uroot -pDBSec@1234 --default-character-set=utf8"
	dump_table_no_data="/home/dbfw/dbfw/DBCDataCenter/bin/DBCDataDump --compact --no-data -h127.0.0.1 -P$port -uroot -pDBSec@1234 --default-character-set=utf8"
	dump_table_no_create="/home/dbfw/dbfw/DBCDataCenter/bin/DBCDataDump --compact --no-create-info --skip-extended-insert -h127.0.0.1 -P$port -uroot -pDBSec@1234 --default-character-set=utf8"
	dump_procedure="/home/dbfw/dbfw/DBCDataCenter/bin/DBCDataDump --compact --no-create-db --no-create-info --no-data --routines -h127.0.0.1 -P$port -uroot -pDBSec@1234 dbfw --default-character-set=utf8"

	table_list_file="$dump_file/${port}/table_list"
	create_sql="$dump_file/${port}/create_sql"
	data_sql="$dump_file/${port}/date_sql"
	procedure_sql="$dump_file/${port}/procedure_sql"

	mkdir -p $create_sql
	mkdir -p $data_sql

	## select dbfw all tables ##
	table_list=(`$execute_sql dbfw -e "show tables" | grep -vw "Tables_in_dbfw"`)
	$execute_sql dbfw -e "show tables" | grep -vw "Tables_in_dbfw" > "$table_list_file"

	## dump dbfw table ##
	for table_name in "${table_list[@]}"
	do
		$dump_table_no_data dbfw "$table_name" > "$create_sql/$table_name".sql
		sed -i '/^\/\*\!/d' "$create_sql/$table_name".sql
		sed -i '/^--/d' "$create_sql/$table_name".sql
		sed -i '/^$/d' "$create_sql/$table_name".sql
		sed -i '/^$/d' "$create_sql/$table_name".sql
		sed -i '/^(PARTITION/d' "$create_sql/$table_name".sql
		sed -i '/^ PARTITION/d' "$create_sql/$table_name".sql
		sed -i 's/AUTO_INCREMENT=[0-9]\+/AUTO_INCREMENT=xxx/' "$create_sql/$table_name".sql
		
		if [ "`echo ${dbfw_no_dump_data_list[@]} | grep -w "$table_name" | wc -l`" = "1" ];then
			continue;
		fi
		
		$dump_table_no_create dbfw "$table_name" > "$data_sql/$table_name".sql
		sed -i '/^\/\*\!/d' "$data_sql/$table_name".sql
		sed -i '/^--/d' "$data_sql/$table_name".sql
		sed -i '/^$/d' "$data_sql/$table_name".sql
		sed -i 's/[0-9]\{4\}-[0-9]\{2\}-[0-9]\{2\} [0-9]\{2\}:[0-9]\{2\}:[0-9]\{2\}/xxxx-xx-xx xx:xx:xx/g' "$data_sql/$table_name".sql
	done

	## dump procedure ##
	$dump_procedure > $procedure_sql
	sed -i '/^\/\*\!/d' $procedure_sql
	sed -i '/^--/d' $procedure_sql
	sed -i '/^$/d' $procedure_sql
done
	
## sysctl param ##
#sysctl -p | sort | uniq > $sysctl_file
cat /etc/sysctl.conf > $sysctl_file1
sysctl -a | sort | uniq > $sysctl_file2


##cp config file
configfile="$dump_file/configfile"
mkdir $configfile
cp -af /home/dbfw/dbfw/etc/dbfw50.ini* $configfile
cp -af /home/dbfw/dbfw/etc/sql_kafka_dataflow_fields.ini $configfile
cp -af /home/dbfw/dbfw/etc/csv_dataflow_fields.ini $configfile
cp -af /home/dbfw/dbfw/etc/totalconfig.lst $configfile
cp -af /usr/local/tomcat/webapps/ROOT/WEB-INF/configures.properties $configfile
cp -af /usr/local/tomcat/webapps/MMS/WEB-INF/configures.properties $configfile/MMS_configures.properties
cp -af /home/dbfw/dbfw/scripts/dc/dbfw_param_config_default.sql $configfile
cp -af /etc/sysconfig/iptables $configfile
iptables -L -n -v >> $configfile/iptables_cmd.txt
cp -af /etc/sysconfig/ip6tables $configfile
ip6tables -L -n -v >> $configfile/ip6tables_cmd.txt
cp -af /etc/sysconfig/arptables $configfile
arptables -L -n -v >> $configfile/arptables_cmd.txt
cp -af /etc/sysconfig/etables $configfile
crontab -l >> $configfile/crontab.txt

dbfwsystem_table="$dump_file/dbfwsystem_table"
mkdir $dbfwsystem_table
/home/dbfw/dbfw/DBCDataCenter/bin/DBCDataDump --compact --no-create-info --skip-extended-insert -h127.0.0.1 -P9207 -uroot -pDBSec@1234 --default-character-set=utf8 dbfwsystem "version_component" > $dbfwsystem_table/version_component.sql

##dir permission
dir_permission="$dump_file/dir_permission"
product_dir_list=(
        /home/dbfw/dbfw
        /dbfw_capbuf
        /usr/local/tomcat
        /usr/local/rmagent
        /home/conadmin/menu.sh
        /usr/local/apache
        /usr/local/apr
        /usr/local/apr-util
        /usr/local/pcre
        /usr/share/fonts/chinese
        /etc/init.d/dcserverd
        /etc/init.d/dcserverd2
        /usr/local/focus
        /usr/local/freetds
        /etc/init.d/initcloudpart
        /etc/init.d/StartDbfw
        /usr/lib/jdk17
        /usr/lib/jdk18
        /usr/local/netdata
        /usr/lib/perl5_lib
        /usr/lib64/perl5
        /usr/share/snmp
        /var/tmp/
        /tmp/dpdk
        /etc/init.d/stopdbfw
        /usr/local/bin/StartDbfw
        /usr/local/bin/stopdbfw
        /usr/local/bin/dcserverd
        /usr/local/bin/dcserverd2
        /etc/sysconfig/ip6tables
        /etc/sysconfig/iptables
        /etc/sysconfig/arptables
        /etc/sysconfig/ebtables
	/dev/shm/
	/etc/producttype
	/dbfw_data/dbfw
	/dbfw_data/dbfw_capbuf
	/dbfw_data/tomcat
	/dbfw_data/apache
)
dirlist_permission()
{
        ls "$1" | while read line
        do
        if [[ -d $1/$line ]];then
                DIR="$1/$line"
                ls -l -d "$DIR"|awk '{print $1,$3,$4,$9}' >> $dir_permission
	else
		continue	
        fi
                DIR1=`dirname "$DIR"`
                A=`ls -F "$DIR1" | grep / | grep "\<$line\>"`
                if [[ "$A" == "$line/" ]];then
                        dirlist_permission  "$DIR1/$line"
                fi
        done
}

for product_dir in "${product_dir_list[@]}"
	do
		dirlist_permission $product_dir
	done

##Softlink files
ln_files="$dump_file/ln_files"
product_dir_list=(
	/home/dbfw/dbfw
	/dbfw_capbuf
	/dbfw_data/dbfw
	/usr/local/tomcat
	/usr/local/rmagent/rmagent-dist
	/home/conadmin/menu.sh
	/usr/local/apache
	/usr/local/apr
	/usr/local/apr-util
	/usr/local/pcre
	/usr/share/fonts/chinese
	/etc/init.d/dcserverd
	/etc/init.d/dcserverd2
	/usr/local/focus
	/usr/local/freetds
	/etc/init.d/initcloudpart
	/etc/init.d/StartDbfw
	/usr/lib/jdk17
        /usr/lib/jdk18
        /usr/local/netdata
        /usr/lib/perl5_lib
        /usr/lib64/perl5
        /usr/share/snmp
        /var/tmp/
        /tmp/dpdk
        /etc/init.d/stopdbfw
        /usr/local/bin/StartDbfw
        /usr/local/bin/stopdbfw
        /usr/local/bin/dcserverd
        /usr/local/bin/dcserverd2
        /etc/sysconfig/ip6tables
        /etc/sysconfig/iptables
        /etc/sysconfig/arptables
        /etc/sysconfig/ebtables
	/dev/shm/
	/etc/producttype
	/dbfw_data/dbfw
	/dbfw_data/dbfw_capbuf
	/dbfw_data/tomcat
	/dbfw_data/apache
)
ln_files()
	{
        ls "$1" | while read line
		do
		if [[ -d $1/$line ]];then
			DIR="$1/$line"
			if [[ -L $DIR ]];then
				ls -l -d "$DIR"|awk '{print $1,$3,$4,$9,$10,$11}' >> $ln_files
			fi
		else
			file_name="$1/$line"
                        if [[ -L $file_name ]];then
                                ls -l -d "$file_name"|awk '{print $1,$3,$4,$9,$10,$11}' >> $ln_files
                        fi
			continue	
		fi
			DIR1=`dirname "$DIR"`
			A=`ls -F "$DIR1" | grep / | grep "\<$line\>"`
			if [[ "$A" == "$line/" ]];then
				ln_files  "$DIR1/$line"
			fi
		done
	}

for product_dir in "${product_dir_list[@]}"
	do
		ln_files $product_dir
	done

exit 0;
