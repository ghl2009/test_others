#!/bin/bash

product_type=$1
disk_mode=$2
kernel_ver=$(uname -r|awk -F. '{print $4}')

function Usage()
{
	echo "Usage:"
	echo "		$0 fire 1"
	echo "		$0 fire_server"
	echo "		$0 clear"
	
	exit 1
}

function fire_part()
{
	if [ "$disk_mode" = "1" ];then
		part_ratio=5
		#ratio_dc=7
	else
		Usage
		echo "fail" >/root/partition_result
		exit 1
	fi
		
	capbuf_size_g=32
	tlog_size_g=96

	## get avail PE num ##
	avail_pe_num=$(vgdisplay |grep "Free  PE"|awk '{print $5}')
	get_pe_num=$(echo "$avail_pe_num / 10 * $part_ratio"|bc)
	lvcreate -y -l +${get_pe_num}    -n lv_dc     vg_dbfw >/dev/null 

	##  use lvm cmd
	lvcreate -y -L ${capbuf_size_g}G -n lv_capbuf vg_dbfw >/dev/null 
	lvcreate -y -L ${tlog_size_g}G   -n lv_tlog   vg_dbfw >/dev/null 
	lvcreate -y -l 100%FREE          -n lv_bkup   vg_dbfw >/dev/null 

	if [ "$kernel_ver" = "el6" ];then
		mkfs.ext4 -F /dev/vg_dbfw/lv_capbuf >/dev/null 2>&1 
		mkfs.ext4 -F /dev/vg_dbfw/lv_tlog   >/dev/null 2>&1 
		mkfs.ext4 -F /dev/vg_dbfw/lv_bkup   >/dev/null 2>&1 
		mkfs.ext4 -F /dev/vg_dbfw/lv_dc     >/dev/null 2>&1 
	else
		mkfs.xfs -f /dev/vg_dbfw/lv_capbuf >/dev/null 2>&1 
		mkfs.xfs -f /dev/vg_dbfw/lv_tlog   >/dev/null 2>&1 
		mkfs.xfs -f /dev/vg_dbfw/lv_bkup   >/dev/null 2>&1 
		mkfs.xfs -f /dev/vg_dbfw/lv_dc     >/dev/null 2>&1 
	fi
	
	
	sed -i '/dbfw_capbuf/d' /etc/fstab
	sed -i '/dbfw_tlog/d'   /etc/fstab
	sed -i '/dbfw_bkup/d'   /etc/fstab
	sed -i '/dbfw_dc/d'     /etc/fstab

	mkdir -p /dbfw_capbuf
	mkdir -p /dbfw_tlog
	mkdir -p /dbfw_bkup
	mkdir -p /dbfw_dc

	if [ "$kernel_ver" = "el6" ];then
		echo "/dev/vg_dbfw/lv_capbuf  /dbfw_capbuf            ext4    defaults        1 2" >>/etc/fstab
		echo "/dev/vg_dbfw/lv_tlog    /dbfw_tlog              ext4    defaults        1 2" >>/etc/fstab
		echo "/dev/vg_dbfw/lv_bkup    /dbfw_bkup              ext4    defaults        1 2" >>/etc/fstab
		echo "/dev/vg_dbfw/lv_dc      /dbfw_dc                ext4    defaults        1 2" >>/etc/fstab
	else
		echo "/dev/vg_dbfw/lv_capbuf  /dbfw_capbuf            xfs     defaults        1 2" >>/etc/fstab
		echo "/dev/vg_dbfw/lv_tlog    /dbfw_tlog              xfs     defaults        1 2" >>/etc/fstab
		echo "/dev/vg_dbfw/lv_bkup    /dbfw_bkup              xfs     defaults        1 2" >>/etc/fstab
		echo "/dev/vg_dbfw/lv_dc      /dbfw_dc                xfs     defaults        1 2" >>/etc/fstab
	fi

	echo "success" >/root/partition_result
}

function fire_part_server()
{
	ratio_dc=5
	ratio_ftidx=5
	capbuf_size_g=32
	tlog_size_g=500

    ## erase disk info ##
    dd if=/dev/urandom of=/dev/sdb bs=512 count=64 >/dev/null 2>&1 
    dd if=/dev/urandom of=/dev/sdc bs=512 count=64 >/dev/null 2>&1 

	## create pv ##
	pvcreate /dev/sdb                                    >/dev/null
	pvcreate /dev/sdc                                    >/dev/null
	
	## create vg ##
	vgcreate -s 64M vg_dc        /dev/sdb                >/dev/null
	vgcreate -s 64M vg_ftidx     /dev/sdc                >/dev/null

    ## resize / ##
    lvresize -l 100%FREE /dev/vg_dbfw/lv_root
    if [ "$kernel_ver" = "el6" ];then
        resize2fs /dev/vg_dbfw/lv_root
    else
        xfs_growfs /dev/vg_dbfw/lv_root
    fi

	## part vg_dc ##
	avail_pe_num=$(vgdisplay vg_dc|grep "Free  PE"|awk '{print $5}')
	pe_num=$(echo "$avail_pe_num * $ratio_dc / 10"|bc)
	lvcreate -y -l +${pe_num}        -n lv_dc       vg_dc   >/dev/null
	lvcreate -y -l 100%FREE          -n lv_bkup_dc  vg_dc   >/dev/null
	
	## part vg_ftidx ##
	avail_pe_num=$(vgdisplay vg_ftidx|grep "Free  PE"|awk '{print $5}')
	pe_num=$(echo "$avail_pe_num * $ratio_ftidx / 10 "|bc)
	lvcreate -y -l +${pe_num}          -n lv_ftidx       vg_ftidx   >/dev/null
	lvcreate -y -L +${capbuf_size_g}G  -n lv_capbuf vg_ftidx        >/dev/null
	lvcreate -y -L +${tlog_size_g}G    -n lv_tlog   vg_ftidx        >/dev/null
	lvcreate -y -l 100%FREE            -n lv_bkup_ftidx  vg_ftidx   >/dev/null

    if [ "$kernel_ver" = "el6" ];then
        mkfs.ext4 /dev/vg_dc/lv_dc              >/dev/null 2>&1 
        mkfs.ext4 /dev/vg_dc/lv_bkup_dc         >/dev/null 2>&1 
        mkfs.ext4 /dev/vg_ftidx/lv_capbuf       >/dev/null 2>&1 
        mkfs.ext4 /dev/vg_ftidx/lv_tlog         >/dev/null 2>&1 
        mkfs.ext4 /dev/vg_ftidx/lv_ftidx        >/dev/null 2>&1 
        mkfs.ext4 /dev/vg_ftidx/lv_bkup_ftidx   >/dev/null 2>&1 
    else
        mkfs.xfs -f /dev/vg_dc/lv_dc              >/dev/null 2>&1 
        mkfs.xfs -f /dev/vg_dc/lv_bkup_dc         >/dev/null 2>&1 
        mkfs.xfs -f /dev/vg_ftidx/lv_capbuf       >/dev/null 2>&1 
        mkfs.xfs -f /dev/vg_ftidx/lv_tlog         >/dev/null 2>&1 
        mkfs.xfs -f /dev/vg_ftidx/lv_ftidx        >/dev/null 2>&1 
        mkfs.xfs -f /dev/vg_ftidx/lv_bkup_ftidx   >/dev/null 2>&1 
    fi
    
	sed -i '/dbfw_capbuf/d'       /etc/fstab
	sed -i '/dbfw_tlog/d'         /etc/fstab
	sed -i '/dbfw_dc/d'           /etc/fstab
	sed -i '/dbfw_ftidx/d'        /etc/fstab
	sed -i '/dbfw_bkup_dc/d'      /etc/fstab
	sed -i '/dbfw_bkup_ftidx/d'   /etc/fstab

	mkdir -p /dbfw_capbuf
	mkdir -p /dbfw_tlog
	mkdir -p /dbfw_dc
	mkdir -p /dbfw_ftidx
	mkdir -p /dbfw_bkup_dc
	mkdir -p /dbfw_bkup_ftidx

    if [ "$kernel_ver" = "el6" ];then
        echo "/dev/vg_dc/lv_dc                 /dbfw_dc                ext4    defaults        1 2" >>/etc/fstab
        echo "/dev/vg_dc/lv_bkup_dc            /dbfw_bkup_dc           ext4    defaults        1 2" >>/etc/fstab
        echo "/dev/vg_ftidx/lv_capbuf          /dbfw_capbuf            ext4    defaults        1 2" >>/etc/fstab
        echo "/dev/vg_ftidx/lv_tlog            /dbfw_tlog              ext4    defaults        1 2" >>/etc/fstab
        echo "/dev/vg_ftidx/lv_ftidx           /dbfw_ftidx             ext4    defaults        1 2" >>/etc/fstab
        echo "/dev/vg_ftidx/lv_bkup_ftidx      /dbfw_bkup_ftidx        ext4    defaults        1 2" >>/etc/fstab
    else
        echo "/dev/vg_dc/lv_dc                 /dbfw_dc                xfs    defaults        1 2" >>/etc/fstab
        echo "/dev/vg_dc/lv_bkup_dc            /dbfw_bkup_dc           xfs    defaults        1 2" >>/etc/fstab
        echo "/dev/vg_ftidx/lv_capbuf          /dbfw_capbuf            xfs    defaults        1 2" >>/etc/fstab
        echo "/dev/vg_ftidx/lv_tlog            /dbfw_tlog              xfs    defaults        1 2" >>/etc/fstab
        echo "/dev/vg_ftidx/lv_ftidx           /dbfw_ftidx             xfs    defaults        1 2" >>/etc/fstab
        echo "/dev/vg_ftidx/lv_bkup_ftidx      /dbfw_bkup_ftidx        xfs    defaults        1 2" >>/etc/fstab    
    fi
    
	echo "success" >/root/partition_result
}

function fire_check()
{
	:
}

function part_clear()
{
	umount /dbfw_capbuf      >/dev/null 2>&1 
	umount /dbfw_tlog        >/dev/null 2>&1 
	umount /dbfw_bkup        >/dev/null 2>&1 
	umount /dbfw_dc          >/dev/null 2>&1 
	umount /dbfw_bkup_ftidx  >/dev/null 2>&1 
	umount /dbfw_bkup_dc     >/dev/null 2>&1 
	umount /dbfw_ftidx       >/dev/null 2>&1 
	
	lvremove -y -f /dev/vg_dbfw/{lv_capbuf,lv_tlog,lv_bkup,lv_dc}             >/dev/null 2>&1 
	lvremove -y -f /dev/vg_dc/{lv_dc,lv_bkup_dc}                              >/dev/null 2>&1 
	lvremove -y -f /dev/vg_ftidx/{lv_capbuf,lv_bkup_ftidx,lv_ftidx,lv_tlog}   >/dev/null 2>&1 

	vgremove -y -f vg_dbfw         >/dev/null 2>&1
	vgremove -y -f vg_dc           >/dev/null 2>&1
	vgremove -y -f vg_ftidx        >/dev/null 2>&1
	
}

if [ "$product_type" = "" ];then
	Usage
	echo "fail" >/root/partition_result
	exit 1
fi

if [ "$product_type" = "fire" ];then
	fire_part $disk_mode
elif [ "$product_type" = "fire_server" ];then
	fire_part_server $disk_mode
elif [ "$product_type" = "clear" ];then
	part_clear
else
	Usage
	exit 2
fi

