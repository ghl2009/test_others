#!/bin/bash
result_file="./result_file"
rm -rf $result_file

A_file="$1"
B_file="$2"

if [[ -z "$A_file" ]] || [[ -z "$B_file" ]];then
	echo "param is null"
	exit 1;
fi
if [[ ! -e "$A_file/create_sql" ]] || [[ ! -e "$A_file/date_sql" ]] || [[ ! -e "$B_file/create_sql" ]] || [[ ! -e "$B_file/date_sql" ]];then
	echo "file not found"
	exit 1;	
fi
if [[ ! -e "$A_file/product_md5" ]] || [[ ! -e "$A_file/sysctl_p" ]] || [[ ! -e "$B_file/product_md5" ]] || [[ ! -e "$B_file/sysctl_p" ]];then
	echo "file not found"
	exit 1;	
fi
if [[ ! -e "$A_file/procedure_sql" ]] || [[ ! -e "$B_file/procedure_sql" ]];then
	echo "file not found"
	exit 1;	
fi

## diff product list ##
echo "---------------------------product list---------------------------" >> $result_file
diff -ra $A_file/product_md5 $B_file/product_md5 >> $result_file

## diff table list ##
echo "---------------------------table list---------------------------" >> $result_file
diff -ra $A_file/table_list $B_file/table_list >> $result_file

## diff create sql ## 
echo "---------------------------create sql---------------------------" >> $result_file
diff -ra $A_file/create_sql $B_file/create_sql >> $result_file

## diff data sql ##
echo "---------------------------date_sql---------------------------" >> $result_file
diff -ra $A_file/date_sql $B_file/date_sql >> $result_file

## diff procedure sql ##
echo "---------------------------procedure_sql---------------------------" >> $result_file
diff -ra $A_file/procedure_sql $B_file/procedure_sql >> $result_file

## diff sysctl list ##
echo "---------------------------sysctl list---------------------------" >> $result_file
diff -ra $A_file/sysctl_p $B_file/sysctl_p >> $result_file

