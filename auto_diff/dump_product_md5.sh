#!/bin/bash

dump_file="./dump_file_`date '+%Y%m%d%H%M%S'`"
sysctl_file="$dump_file/sysctl_p"
md5_file="$dump_file/product_md5"
permission_file="$dump_file/product_permission_file"
permission_folder="$dump_file/product_permission_folder"

## 要创建MD5文件的文件夹列表 ##
product_file_list=(
    /home/dbfw/dbfw
    /dbfw_capbuf
    /usr/local/tomcat
    /usr/local/rmagent/rmagent-disk
    /home/conadmin/menu.sh
    /usr/local/apache
    /usr/local/apr
    /usr/local/apr-util
    /usr/local/pcre
    /usr/share/fonts/chinese
    /etc/init.d/dcserverd
    /etc/init.d/dcserverd2
    /etc/init.d/initcloudpart
    /etc/init.d/StartDbfw
    /etc/init.d/stopdbfw
    /usr/local/focus
    /usr/local/freetds
    /usr/lib/jdk17
    /usr/lib/jdk18
    /usr/local/netdata
    /usr/lib/perl5_lib
    /usr/lib64/perl5
    /usr/share/snmp
    /var/tmp
    /tmp/dpdk
    #/usr/local/bin
    /usr/local/bin/StartDbfw
    /usr/local/bin/stopdbfw
    /usr/local/bin/dcserverd
    /usr/local/bin/dcserverd2
    /etc/sysconfig/ip6tables
    /etc/sysconfig/iptables
    /etc/sysconfig/arptables
    /etc/sysconfig/ebtables
    /dbfw_data/dbfw
    /dbfw_data/dbfw_capbuf
    /dbfw_data/tomcat
    /dbfw_data/apache
    /usr/local/authtool
    /usr/lib/systemd/system/controldbfw.service
    /usr/lib/systemd/system/dcserverd2.service
    /usr/lib/systemd/system/dcserverd.service
    /usr/lib/systemd/system/initpart.service
    /etc/security/limits.conf
    /etc/pam.d/login
    /etc/profile
    /lib/modules/dbfw
    /var/spool/cron
    /var/tmp/board_vendor
    /etc/ntp/ntpservers
    /etc/rsyslog.conf
    /etc/resolv.conf
    /etc/sysconfig/network
    /etc/sysconfig/network-scripts
    /etc/udev/rules.d
    /etc/iptables/rules.v4
    /etc/init.d/network_boot.im
    /etc/init.d/halt
    /etc/init.d/killall
    /etc/init.d/mdmonitor
    /etc/init.d/netconsole
    /etc/init.d/netfs
    /etc/init.d/network
    /etc/init.d/single
    /etc/init.d/ip6tables
    /etc/init.d/iptables
    /etc/init.d/irqbalance
    /etc/selinux/config
    /etc/modprobe.d
    /etc/init/serial.conf
    /etc/sudoers
    /etc/logrotate.d/tomcat
    /usr/lib/jre164
    /usr/kafka
    /usr/local/ukeyclient
    /usr/lib64/libsecureServiceAPI.so
    /usr/lib64/libsecureServiceGmonAPI.so
    /usr/lib64/libACE.so.5.6.5
    /usr/lib64/libACE_SSL.so.5.6.5
    /usr/lib64/libssl.so.0.9.8
    /usr/lib64/libsystemdevice.so
    /usr/lib64/libcrypto.so.0.9.8
    /usr/lib64/libdbfwRewrite.so
    /usr/lib64/libmysql.so.16
    /usr/bin/apply
    /usr/bin/daemon
    /etc/ssh/sshd_config
    /etc/apt/sources.list
    /etc/acpi/events/power.conf
    /etc/snmp/snmpd.conf
    /etc/rc.d/init.d/rsyslog
    /etc/rc.d/init.d/iptables
    /etc/rc.d/init.d/ip6tables
    /etc/rc.d/init.d/snmpd
    /etc/rc.d/init.d/vsftpd
    /etc/vsftpd/vsftpd.conf
    /etc/vsftpd.conf
    /etc/rc.d/init.d/crond
    /etc/rc.d/init.d/lldpad
    /etc/sysconfig/irqbalance
    /etc/sysconfig/nfs
    /etc/logrotate.conf
    /etc/passwd
    /home/dbfw/.bash_profile
    /etc/run_environment
    /etc/producttype
    /etc/bashrc
    /root/.bash_profile
    /root/.bashrc
    /etc/rc.d/rc.sysinit
    /lib/systemd/system/rescue.service
    /etc/rc.d/init.d/functions
    /etc/had/ha_status
    /usr/local/bin/initcloudpart.sh
    /usr/local/bin/initpart
    /usr/local/bin/top
    /boot/grub/grub.cfg
    /boot/grub2/grub.cfg
)

## no create md5 file ##
no_create_md5_list=(
    "/home/dbfw/dbfw/bin/*.pid"
    "/home/dbfw/dbfw/bin/*.out"
    "/home/dbfw/dbfw/lib/*.a"
    "/home/dbfw/dbfw/*.log"
    "/home/dbfw/dbfw/*.pid"
    "/home/dbfw/dbfw/etc/*_INST"
    "/home/dbfw/dbfw/bin/*.pyc"
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
    /dbfw_data/dbfw_capbuf
)

## dbfw Don't compare data list ##
dbfw_no_dump_data_list=(
	system_detail
	system_param
	systemmonitor
	sysaudit
	focus_runhis
	interface_group
	interface_info
	disk_alarms
	audit_log
	sqllog_detail_update_synchronized
)

if [[ ! -e "/home/dbfw/dbfw/DBCDataCenter/bin/DBCDataView" ]] || [[ ! -e "/home/dbfw/dbfw/DBCDataCenter/bin/DBCDataDump" ]];then
	echo "not found DBCDataView or DBCDataDump"
	exit 1;
fi

## create md5 file ##
rm -f all_list skip_list result_list

# 生成所有文件的文件列表
> all_list 
mkdir -p ./$dump_file/local_files
for file in ${product_file_list[@]}
do 
    if [ -L "$file" ];then continue;fi
    find $file -type f >> all_list 2>/dev/null
    cp -raf $file ./$dump_file/local_files/ 2>/dev/null
done

# 生成不需要获取信息的文件列表
> skip_list
for file in ${no_create_md5_list[@]}
do 
    if [ -L "$file" ];then continue;fi
    find $file -type f >> skip_list 2>/dev/null
done

# 从A列表中过滤掉B列表
grep -v -f skip_list all_list > result_list 2>/dev/null

cat result_list | uniq | sort -k 2 | xargs -i md5sum "{}" > $md5_file
cat result_list | uniq | sort -k 2 | xargs -i ls -l "{}"| awk '{print $1" "$3" "$4" "$9}' > $permission_file

# 在所有文件列表中增加文件夹  用于获取文件夹权限
> result_list
for file in ${product_file_list[@]}
do 
    if [ -L "$file" ];then continue;fi
    if [ -d $file ];then
        find $file -type d >> result_list
    fi
done
cat result_list | uniq | sort -k 2 | xargs -i ls -ld "{}" | awk '{print $1" "$3" "$4" "$9}' >> $permission_folder

rm -f all_list skip_list result_list

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
    table_list=(`$execute_sql dbfw -N -e "show tables"`)
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
    
    if [ "$port" = "9207" ];then
        cp -af $data_sql/param_config_default.sql $dump_file
    fi
done

## sysctl param ##
sysctl -p | sort | uniq > $sysctl_file

cp -af ./$dump_file/local_files/dbfw/etc/dbfw50.ini $dump_file/
cp -af ./$dump_file/local_files/dbfw/etc/totalconfig.lst $dump_file/
cp -af ./$dump_file/local_files/tomcat/webapps/ROOT/WEB-INF/configures.properties $dump_file/

exit 0;






# param_config_default.sql 
# dbfw50.ini 
# totalconfig.lst 
# configure.pro   
# 
# 文件权限  文件夹权限 结果分开




