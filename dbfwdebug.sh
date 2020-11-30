shmid=`ipcs -m|grep dbfw|head -n1|awk '{print $2}'`;dbfwdebug $shmid sessions t sessions.txt>/dev/null;flag_old=`cat sessions.txt |grep use_flag|awk '{print $2}'`;echo "flag_old=$flag_old";num=1;echo "num=$num";sleep 10;while true;do shmid=`ipcs -m|grep dbfw|head -n1|awk '{print $2}'`;dbfwdebug $shmid sessions t sessions.txt>/dev/null;flag=`cat sessions.txt |grep use_flag|awk '{print $2}'`;echo $flag;if [[ $flag -eq $flag_old ]];then num=$((num+1));echo "num=$num";else flag_old=$flag;num=1;echo "num=$num";fi;sleep 10;done

while true;do shmid=`ipcs -m|grep dbfw|head -n1|awk '{print $2}'`;dbfwdebug $shmid proxy t proxy.txt>/dev/null;cat proxy.txt |grep "Tis Content";usleep 1000000;done


nfw_info_npp=`ll /dbfw_capbuf/pdump/nfw/info_npp/ -t|tac|grep -v total|awk '{print $9}'|tail -n1`;shmid=`ipcs -m|grep dbfw|head -n1|awk '{print $2}'`;while true;do npp_count=`cat /dbfw_capbuf/pdump/nfw/info_npp/${nfw_info_npp} |wc -l`;echo "---------------------";date "+%Y%m%d %H:%M:%S";echo nfw_npp_info = $npp_count;dbfwdebug $shmid sessions t /home/dbfw/dbfw/bin/sessions.txt>/dev/null;sga_npp=`cat /home/dbfw/dbfw/bin/sessions.txt|grep usedsession`;echo $sga_npp;sleep 1;done

nfw_info_npp=`ll /dbfw_capbuf/pdump/nfw/info_npp/ -t|tac|grep -v total|awk '{print $9}'|tail -n1`;npp_count_tmp=0;while true;do npp_count=`cat /dbfw_capbuf/pdump/nfw/info_npp/${nfw_info_npp} |wc -l`;echo "---------------------";date "+%Y%m%d %H:%M:%S";echo $npp_count;((npp_count_diff=npp_count-npp_count_tmp));echo $npp_count_diff;npp_count_tmp=$npp_count;sleep 1;done

nfw_info_npp=`ll /dbfw_capbuf/pdump/nfw/info_npp/ -t|tac|grep -v total|awk '{print $9}'|tail -n1`;shmid=`ipcs -m|grep dbfw|head -n1|awk '{print $2}'`;npp_count_tmp=0;sga_npp_tmp=0;while true;do date "+%Y%m%d %H:%M:%S.%N";npp_count=`cat /dbfw_capbuf/pdump/nfw/info_npp/${nfw_info_npp} |wc -l`;dbfwdebug $shmid sessions t /home/dbfw/dbfw/bin/sessions.txt>/dev/null;sga_npp=`cat /home/dbfw/dbfw/bin/sessions.txt|grep usedsession|awk '{print $3}'`;echo "${npp_count} npp_count";echo "${sga_npp} sga_npp";((npp_count_diff=npp_count-npp_count_tmp));((sga_npp_diff=sga_npp-sga_npp_tmp));echo "${npp_count_diff} npp_count_diff";echo "${sga_npp_diff} sga_npp_diff";npp_count_tmp=$npp_count;sga_npp_tmp=$sga_npp;echo "---------------------";usleep 800000;done

pci_num=`lspci |grep Eth|wc -l`;for num in `seq 0 $((pci_num-1))`;do Link_detected=`ethtool eth${num}|tail -n1|awk '{print $3}'`;echo -e "eth${num}\nLink_detected=${Link_detected}";done


shmid=`ipcs -m|grep dbfw|head -n1|awk '{print $2}'`;while true;do echo "---------------------";date "+%Y%m%d %H:%M:%S";dbfwdebug $shmid fixed t /home/dbfw/dbfw/bin/fixed.txt>/dev/null;license_stat=`cat /home/dbfw/dbfw/bin/fixed.txt|grep LICENSE`;echo $license_stat;sleep 1;done

echo 18 > /dev/shm/bypass_test_nfw_hangup_time_config;sleep 8;rm -rf /dev/shm/bypass_test_nfw_hangup_time_config


list=`ps -ef|grep npls_server|grep -v grep |awk '{print $2}'`;echo $list;list=($list);lena=${#list[@]};i=0;echo $lena;for pid in ${list[*]};do echo $pid;((i=i+1));echo $i;kill -9 $pid;if [[ $i -ne $lena ]];then sleep 30;else break;fi;done



ps -ef|grep npls_server|grep -v grep;echo -e '\n-------------------------------------';iptables -nvL -t nat;echo -e '\n-------------------------------------';iptables -nvL;echo -e '\n-------------------------------------';ip rule show;echo -e "\n\n\n";route -n;echo -e "\n\n\n"


fork_before=0;npls_info_name=`ls /dbfw_capbuf/pdump/npls/info/ -t|tac|tail -n2`;cd /dbfw_capbuf/pdump/npls/info/;while true;do echo "`date '+%Y%m%d %H:%M:%S.%N'`" >> /home/fork.txt;fork_after=`wc $npls_info_name|grep total|awk '{print $1}'`;echo $fork_after >> /home/fork.txt;((fork_diff=fork_after-fork_before));if [[ $fork_diff -gt 0 ]];then echo $fork_diff >> /home/fork.txt;else echo "#########$fork_diff" >> /home/fork.txt;fi;fork_before=$fork_after;echo "-------------------" >> /home/fork.txt;usleep 800000;done

i=0;logname="nfw`date '+%Y%m%d%H%M%S%N'`.txt";while true;do /home/dbfw/dbfw/DBCDataCenter/bin/DBCDataView -P9207 -h192.168.5.157 -uroot -pDBSec@1234 dbfw -e "select 1";if [[ $? -ne 0 ]];then ((i=i+1));echo "`date '+%Y%m%d %H:%M:%S'` $i" >> /home/$logname;fi;echo "i=$i";done 

i=0;logname="nfw`date '+%Y%m%d%H%M%S'`.txt";while true;do /home/dbfw/dbfw/DBCDataCenter/bin/DBCDataView -P9207 -h192.168.5.80 -uroot -pDBSec@1234 dbfw -e "select 1";if [[ $? -ne 0 ]];then ((i=i+1));echo "`date '+%Y%m%d %H:%M:%S'` $i" >> /home/$logname;fi;echo "i=$i";done 



for num in `seq 10 110`;
        do;
                ./meter_broadcast --mode modify --server 192.168.1.24:1521=192.168.1.${num}:1521 --client 192.168.1.72:12540=192.168.1.${num}:12540 loadrunner.pcap;
                mv loadrunner-modify.pcap loadrunner-tmp.pcap;
                for num1 in `seq 10 110`;
                        do;
                                ./meter_broadcast --mode modify --server 192.168.1.${num}:1521=192.168.${num1}.${num}:1521 --client 192.168.1.72:12540=192.168.${num1}.${num}:12540 loadrunner-tmp.pcap;
                                mv loadrunner-tmp-modify.pcap loadrunner-modify-${num1}-${num}.pcap;
                        done;
        done;
	

for pcapfile in $(ls *|grep -E "modify"|grep -v "aaa");do date '+%y-%m-%d %H:%M:%S';echo $pcapfile;./meter_broadcast --worker 1 --loop 1 --pps 50000 eth21 $pcapfile > /dev/null;date "+%y-%m-%d %H:%M:%S";echo "------------------------------------------";done 


