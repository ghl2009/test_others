list=`ps -ef|grep npls_server|grep -v grep |awk '{print $2}'`;echo $list;list=($list);lena=${#list[@]};i=0;echo $lena;for pid in ${list[*]};do echo $pid;((i=i+1));echo $i;kill -9 $pid;if [[ $i -ne $lena ]];then sleep 30;else break;fi;done



ps -ef|grep npls_server|grep -v grep;echo -e '\n-------------------------------------';iptables -nvL -t nat;echo -e '\n-------------------------------------';iptables -nvL;echo -e '\n-------------------------------------';ip rule show;echo -e "\n\n\n";route -n;echo -e "\n\n\n"