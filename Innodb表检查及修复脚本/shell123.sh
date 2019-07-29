#!/bin/bash

export DBFW_HOME=/home/dbfw/dbfw/
export CONFIG_FILE=${DBFW_HOME}/etc/dbfw50.ini
export DC_HOME=/home/dbfw/dbfw/DBCDataCenter/	
export BACKUP_DC_DIR=/dbfw_bkup/dc/
export SCRIPT_HOME=/home/dbfw/dbfw/scripts/
export LD_LIBRARY_PATH=$DBFW_HOME/lib:$LD_LIBRARY_PATH

export TABLE_DATA_DIR=$DC_HOME/data/dbfw/
export SCRIPT_REPAIR_TABLE_HOME=/home/dbfw/dbfw/scripts/repairtable/
export SCRIPT_REPAIR_TABLE_CONF=$SCRIPT_REPAIR_TABLE_HOME/conf/
export TMP_BACKUP_BAD_TABLE=/dbfw_dc/tmp_backup_bad_table/
export TMP_BACKUP_BAD_TABLE_NO_CLEAR=/dbfw_dc/tmp_backup_bad_table_no_clear/
export Back_Config_All_Table=${BACKUP_DC_DIR}/config_table/
export Check_Log_File="$DBFW_HOME/log/repairtable.log"
export Bad_Table_List=${SCRIPT_REPAIR_TABLE_CONF}/bad_table_list
export Online_Bad_Table_Id=${SCRIPT_REPAIR_TABLE_CONF}/online_bad_table_id
export Cur_Status_Progress=${SCRIPT_REPAIR_TABLE_CONF}/cur_status_progress
export Cur_Skip_List=${SCRIPT_REPAIR_TABLE_CONF}/cur_skip_list
export Process_Handle_Num_Note=${SCRIPT_REPAIR_TABLE_CONF}/process_handle_num_note
export Day_Check_Flag=${SCRIPT_REPAIR_TABLE_CONF}/day_check_flag
export Part_File_Backup_History=${SCRIPT_REPAIR_TABLE_CONF}/part_file_backup_history
export Restore_Tmp_List=${SCRIPT_REPAIR_TABLE_CONF}/restore_tmp_list
export Auto_Fix_Tmp_List=${SCRIPT_REPAIR_TABLE_CONF}/auto_fix_tmp_list
export Run_Level_File=${SCRIPT_REPAIR_TABLE_CONF}/run_level_file
export Sql_Exec_Result=${SCRIPT_REPAIR_TABLE_CONF}/sql_exec_result

## 初始化工具 ##
View='/home/dbfw/dbfw/DBCDataCenter/bin/DBCDataView -uroot -p1 -P9207 -h127.0.0.1 '

## 首先初始化列表 每一个不同的关联中的表 有一个 ##
config_list=(processmonitor
   summary_session_type
   sql_program_filter
   buz_ip_alias
   addresses_filter
   vpatch_dbversion
   vpatch_rules
   vpatchrule_category
   vpatchrule_for_dbversion
   sysaudit_status
   report_template
   report_title
   report_title_template
   menu_new_left_second
   menu_new_left_third
   menu_new_top
   dbapp_provider
   inst_db_count
   connserver
   pwdsecurity
   mask_config
   dbsysobjects
   audit_log
   ntpserver
   dbversion
   xsec_dictionary
   mask_method
   sqltype
   sqltype_detail
   sqltype_detail_templet
   performance_assess_data
   dbfw_instances
   accessips
   traffic_result
   dbfw_error_msg
   database_addresses_mir
   diag_result)

for table in ${config_list[@]}
do
	if [ -e "${TABLE_DATA_DIR}/${table}.frm" ];then
		echo "##################### test table $table ##########################"
		## 损坏此表非frm文件 ##
		echo "broken $table frm file"
		echo "123123" > ${TABLE_DATA_DIR}/${table}.frm
		sync;
		echo "flush $table "
		$View dbfw -e "flush table ${table};"
		echo "clear repair table log file "
		> $Check_Log_File 
		echo "use repair table scripts to check all table "
		touch ${Day_Check_Flag}
		${SCRIPT_REPAIR_TABLE_HOME}/repairtables.sh cron
		echo "----------rebuild table list:---------"
		cat ${Check_Log_File}|grep 'INFO  	start to rebuild table'|awk '{print $8}' |sort 
		echo "---------repair table error info:---------"
		cat ${Check_Log_File}|grep 'ERROR'
		echo "---------get rebuild table num:---------"
		cat ${Check_Log_File}|grep 'INFO  	start to rebuild table'|wc -l
		echo "---------get rebuild success num:---------"
		cat ${Check_Log_File}|grep "rebuild table result success"|wc -l
		echo -n "Do you want to test next group? [y/n]"
		#read ans
		#if [ "$ans" = "n" ];then
		#	echo "test over "
		#	break;
		#fi
	else
		echo "not find table $table frm file"
	fi
done

