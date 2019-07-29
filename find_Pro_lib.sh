#!/bin/bash

dbfw_dir=(
	'/home/dbfw/dbfw/bin'
	'/home/dbfw/dbfw/lib'
	'/home/dbfw/dbfw/sbin'
	'/dbfw_capbuf/pdump'
	)

dbfw_Pro_lib=(
dpdk
dpdkapi
mongodb
		hbase
		hive
		dbfw_splt_wds
		libPretreatmentSql
		npls
		rms
		rmagent
		had
		nfw
		npp_proxy
		bmt
		mkl
		upgradeLicense
		bypass
		npp
			)

no_Pro_lib=(
		)

echo ${dbfw_Pro_lib[@]}
for list_Pro_lib in ${dbfw_Pro_lib[@]}
do

	for list_dir in ${dbfw_dir[@]}
	do
		ret=`find $list_dir -name "*${list_Pro_lib}*"`
		if [[ -n $ret ]];then
			echo "-----------------------------------------------"
			echo $list_dir
			echo "$list_Pro_lib"
			echo "$ret"
			echo "-----------------------------------------------"
		fi
	done
done

echo "#################################################"
echo 'cat /usr/local/tomcat/webapps/ROOT/OEM/DAS/WEB-INF/sphinx.ini |grep "data-update-deal"'
cat /usr/local/tomcat/webapps/ROOT/OEM/DAS/WEB-INF/sphinx.ini |grep "data-update-deal"
echo 'cat /usr/local/tomcat/webapps/ROOT/WEB-INF/sphinx.ini |grep "data-update-deal"'
cat /usr/local/tomcat/webapps/ROOT/WEB-INF/sphinx.ini |grep "data-update-deal"
