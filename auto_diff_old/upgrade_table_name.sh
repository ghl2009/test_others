#!/bin/bash
###########################################################
## author:liuguanghui
## date  :20191205
## work  :Table found in upgrade
###########################################################

###########################################################
## 说明:
## 1.在老的环境上执行执行此脚本（传参数 1）,生成table_name_list.txt
## 2.在老的环境上执行cp /home/dbfw/dbfw/scripts/repairtable/conf/table_type_info ./
## 3.把升级时涉及的sql文件放入此目录,
##   如：addition.sh addition_new.sql vpatch_deal.sql等
## 4.把addition.sh里所有涉及的.sql文件及上边的那几个文件
##   放入列表file_dir_list
## 5.把关于存储过程的注释掉,因为存储过程涉及的表太多
## 6.在安装包环境或升级完的环境执行此脚本
###########################################################

if [[ $1 -eq 1 ]];then
	table_name_list=""
	for table_filename in `ls /dbfw_dc/dbfw/ |grep -v -E ".MYI|.MYD"`
		do
			#echo ${table_filename}
			table_filename=${table_filename%%.*}	
			table_name=${table_filename%%#*}	
			#echo ${table_name}
			table_name_list="${table_name_list}\n${table_name}"
		done

	table_name_list=(`echo -e $table_name_list|sort -u`)
	> table_name_list.txt
	for table_name in "${table_name_list[@]}"
		do
			if [[ $table_name = "db" ]];then
				continue	
			fi
			echo $table_name >> table_name_list.txt
		done
	exit
fi

table_name_list=(`cat table_name_list.txt`)
echo $table_name_list


SCRIPTS_HOME="/home/dbfw/dbfw/scripts/dc"
file_dir_list=(
#"$SCRIPTS_HOME/dbaa_new_summary_procedure.sql"
"$SCRIPTS_HOME/dbfw_error_msg.sql"
"$SCRIPTS_HOME/dbfw_syslog_filetype.sql"
#"$SCRIPTS_HOME/procedure.sql"
"$SCRIPTS_HOME/user_permission_url.sql"
./addition/addition_dbaa.sql
./addition/addition_dbctrl.sql
./addition/addition_dbfw.sql
./addition/addition_dbfwusers.sql
./addition/addition_dbmd.sql
./addition/addition_new.sql
./addition/addition.sh
./addition/addition_u_role.sql
./addition/backup.sql
)

echo "############################################################################"
upgrade_table_list=""
for table_name in "${table_name_list[@]}"
	do
		#echo $table_name
		for file_dir in "${file_dir_list[@]}"
			do
				#echo $file_dir
				num=`grep -wc "$table_name" $file_dir`
				
				if [[ $num -gt 0 ]];then
					echo "----------------------------------------------------------------------------"
					echo $file_dir
					echo $table_name
					upgrade_table_list="${upgrade_table_list}\n${table_name}"
					break
				fi
			done

	done
echo -e $upgrade_table_list

upgrade_table_list=(`echo -e $upgrade_table_list|sort -u`)
echo "upgrade_table_list=${#upgrade_table_list[@]}"

table_info_file="./table_type_info"
table_config_list=($(cat $table_info_file|awk '{if($3 == "config"){print $1}}'))
echo "table_config_list=${#table_config_list[@]}"

echo "****************************************************************************"
upgrade_tables=""
i=0
for upgrade_table in "${upgrade_table_list[@]}"
	do
		i=$((i+1))
		#echo $i
		#echo $upgrade_table
		j=0
		k=0
		for table_config in "${table_config_list[@]}" 
			do
				j=$((j+1))
				#echo $i $j
				#echo $upgrade_table
				#echo $table_config
				if [[ $upgrade_table == $table_config ]];then
					k=1
					break
				fi
			done	
		if [[ $k -ne 1 ]];then
			upgrade_tables="$upgrade_tables $upgrade_table"
		fi
	done

echo $upgrade_tables
