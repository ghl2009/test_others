#!/bin/bash

A_list=(
	/home/dbfw/dbfw/bin
	/home/dbfw/dbfw/DBCDataCenter/my.cnf
	/home/dbfw/dbfw/etc/fti_archive.conf.bak
	/home/dbfw/dbfw/etc/fti_archive_parameter.conf
	/home/dbfw/dbfw/etc/fti_null.conf.bak
	/home/dbfw/dbfw/etc/fti_present.conf.bak
	/home/dbfw/dbfw/etc/fti_present_MT.conf.bak
	/home/dbfw/dbfw/etc/fti_present_parameter.conf
	/home/dbfw/dbfw/etc/dbfw50.ini
	/home/dbfw/dbfw/etc/del_sms.conf
	/home/dbfw/dbfw/etc/logo.png
	/home/dbfw/dbfw/etc/totalconfig.lst
	/home/dbfw/dbfw/lib
	/home/dbfw/dbfw/scripts
	/home/conadmin/menu.sh
	/usr/local/tomcat/bin
	/usr/local/tomcat/conf
	/usr/local/tomcat/webapps/ROOT
	/usr/local/tomcat/webapps/MMS
	/usr/local/apache/bin
	/usr/local/apache/conf
)

B_list=(
	"/home/dbfw/dbfw/bin/*.pid"
	/usr/local/tomcat/webapps/ROOT/WEB-INF/report-engine/logs	
	/home/dbfw/dbfw/lib
)

## create md5 file ##
sylloge_A="sylloge_A"
sylloge_B="sylloge_B"
sylloge_tmp="sylloge"
tmp="sylloge.tmp"
md5_file="./md5_file"

rm -f $tmp $sylloge_tmp $sylloge_A $sylloge_B

for A_file_name in "${A_list[@]}"
do
	if [ "0" != "${#A_list[@]}" ];then	
		for B_file_name in "${B_list[@]}"
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

rm -f $tmp $sylloge_tmp $sylloge_A $sylloge_B