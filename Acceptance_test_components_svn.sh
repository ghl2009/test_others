#!/bin/bash
################################################
## auther:liuguanghui
## date:20181218
## work:Acceptance test components svn
################################################


################################################
## param1:svn path(tag)
## param2:svn username
## param3:svn password
################################################

svn_path_tag=$1
username=$2
password=$3

DBC_View="/home/dbfw/dbfw/DBCDataCenter/bin/DBCDataView -h127.0.0.1 -P9207 -uroot -pDBSec@1234 --default-character-set=utf8"

components_list=(
		1,AOL,/DBFWWorkstation
		2,ASS,/DBFWWorkstation
		3,BKUP,/DBFWWorkstation
		4,CHKANDREPAIR,/DBFWWorkstation
		5,DEL,/DBFWWorkstation
		6,DMON,/DBFWWorkstation
		7,DBFWDIAG,/DBFWWorkstation
		8,DLP,/DBFWWorkstation
		9,FTM,/DBFWWorkstation
		10,GMON,/DBFWWorkstation
		11,HAD,/DBFWWorkstation
		12,IM,/DBFWWorkstation
		13,NFW,/DBFWWorkstation
		14,NPC,/DBFWWorkstation
		15,NPLS,/DBFWWorkstation
		16,NPP,/DBFWWorkstation
		17,NPP_PROXY,/DBFWWorkstation
		18,RMS,/DBFWWorkstation
		19,SBUF2DB,/DBFWWorkstation
		20,SMON,/DBFWWorkstation
		21,TFW,/DBFWWorkstation
		22,TLA,/DBFWWorkstation
		23,TLC,/DBFWWorkstation
		24,TLS,/DBFWWorkstation
		25,TLW,/DBFWWorkstation
		26,TMAN,/DBFWWorkstation
		27,UDMP,/DBFWWorkstation
		28,WEB,/DBFWWorkstation
		29,SCRIPTS,/DBFWWorkstation
		)
mkdir -p /tmp/components_svn
echo > /tmp/components_svn/components_svn_expect.txt
for var in  ${components_list[*]}
	do
		component_id=`echo $var|awk -F, '{print $1}'`	
		component_name=`echo $var|awk -F, '{print $2}'`	
		component_svn_path=`echo $var|awk -F, '{print $3}'`	
                component_last_rev=`svn info $svn_path_tag/$component_svn_path --username $username --password $password|awk 'NR==8{print $4}'`

		if [ "$?" -ne 0 ];then
			echo "svn info $svn_path_tag/$component_svn_path --username $username --password $password|awk 'NR==8{print $4}' fail"
		fi

                echo $component_id,$component_name,$component_last_rev >>/tmp/components_svn/components_svn_expect.txt 
	done

$DBC_View dbfwsystem -N -e "select concat(id,',',component_name,',',component_svn_version) from version_component" >/tmp/components_svn/components_svn_fact.txt

if [ "$?" -ne 0 ];then
	echo "$DBC_View -N -e 'select concat(id,',',component_name,',',component_svn_version) from version_component' fail"
fi

diff /tmp/components_svn/components_svn_* > /tmp/components_svn/components_svn_diff.txt

if [[ -s /tmp/components_svn/components_svn_diff.txt ]];then 
	echo -e "#######################\nNot meet expectations\n#######################"
	echo "##Compare results:##"
	cat /tmp/components_svn/components_svn_diff.txt
else
	echo -e "#######################\nYes meet expectations\n#######################"
fi

rm -rf /tmp/components_svn/components_svn_*
