#!/bin/bash
/home/dbfw/dbfw/bin/bp_ctl$1 show_bypass_slot|grep "bp group">/tmp/bypass_info_tmp
slot_info=(`cat /tmp/bypass_info_tmp |awk -F, '{print $1}'`)
echo ${slot_info[@]}
for slot in "${slot_info[@]}"
        do
                echo $slot
                slot_num=${slot:4}
                echo "slot_num=$slot_num"
                group_count=(`cat /tmp/bypass_info_tmp|grep ${slot}|awk -F: '{print $2}'`)
                echo "group_count=$group_count"
                for group_num in `seq 1 ${group_count}`
                        do
                                echo "group_num=$group_num"
                                /home/dbfw/dbfw/bin/bp_ctl$1 bpon ${slot_num} ${group_num} $2
                                echo "/home/dbfw/dbfw/bin/bp_ctl$1 bpon ${slot_num} ${group_num} $2 success!!"
                                usleep $3
                        done
        done
rm -rf /tmp/bypass_info_tmp
