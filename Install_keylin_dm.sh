#!/usr/bin/env bash
Green_font_prefix="\033[32m" && Red_font_prefix="\033[31m" && Green_background_prefix="\033[42;37m" && Red_background_prefix="\033[41;37m" && Font_color_suffix="\033[0m"
check_user() {
    if id dmdba &>/dev/null; then
        echo "用户 dmdba 已经存在"
    else
        groupadd -g 10001 dinstall
        useradd -u 10001 -g dinstall -m -d /home/dmdba -s /bin/bash dmdba
    fi
}
add_disk(){
    pvcreate /dev/vdb
    
    if vgdisplay | grep dmdata &>/dev/null; then
        echo "虚拟VG卷已存在"
        vgdisplay
    else
        echo "创建VG卷"
        vgcreate dmdata /dev/vdb
        
        if lvs | grep dmdata &>/dev/null; then
            echo "逻辑卷已存在，请检查(lvs)"
        else
            echo "创建逻辑卷"
            lvcreate -l 100%VG -n dmdata dmdata
            
            echo "格式化逻辑卷"
            mkfs.ext4 /dev/dmdata/dmdata
        fi
    fi
}
mount_disk(){
    if [ ! -d "/dmdata" ]; then
        mkdir /dmdata
    else ls /dmdata
    fi
    
    if ! grep -q '/dev/dmdata/dmdata /dmdata ext4 defaults 0 0' /etc/fstab; then
        echo '/dev/dmdata/dmdata /dmdata ext4 defaults 0 0' >> /etc/fstab
        mount -a
        df -Th
    else cat /etc/fstab
    fi
}
make_dir(){
    # Check and create /home/dmdba/dmdbms
    if [ ! -d "/home/dmdba/dmdbms" ]; then
        mkdir -p /home/dmdba/dmdbms
    else echo "/home/dmdba/dmdbms已存在"
    fi

    # Check and create /dmdata/dmdata
    if [ ! -d "/dmdata/dmdata" ]; then
        mkdir -p /dmdata/dmdata
    else echo "/dmdata/dmdata已存在"
    fi

    # Check and create /dmdata/backup
    if [ ! -d "/dmdata/backup" ]; then
        mkdir -p /dmdata/backup
    else echo "/dmdata/backup已存在"
    fi

    # Check and create /dmdata/dmarch
    if [ ! -d "/dmdata/dmarch" ]; then
        mkdir -p /dmdata/dmarch
    else echo "/dmdata/dmarch已存在"
    fi

    # Set ownership and permissions
    chown dmdba.dinstall -R /home/dmdba
    chown dmdba.dinstall -R /dmdata/
    chmod -R 777 /dmdata/
}
make_var(){
    echo "修改环境变量"
    
    # Check and set environment variables
    if ! grep -q "export DM_HOME=/home/dmdba/dmdbms" ~/.bash_profile; then
        echo "export DM_HOME=/home/dmdba/dmdbms" >> ~/.bash_profile
    fi
    
    if ! grep -q "export LD_LIBRARY_PATH=\"$LD_LIBRARY_PATH:/home/dmdba/dmdbms/bin\"" ~/.bash_profile; then
        echo "export LD_LIBRARY_PATH=\"$LD_LIBRARY_PATH:/home/dmdba/dmdbms/bin\"" >> ~/.bash_profile
    fi
    
    if ! grep -q "export DM_INSTALL_TMPDIR=/tmp" ~/.bash_profile; then
        echo "export DM_INSTALL_TMPDIR=/tmp" >> ~/.bash_profile
    fi
    
    if ! grep -q "export PATH=\$DM_HOME/bin:\$PATH" ~/.bash_profile; then
        echo "export PATH=\$DM_HOME/bin:\$PATH" >> ~/.bash_profile
    fi
    
    source ~/.bash_profile
    
    echo "当前环境变量"
    echo $DM_HOME

    echo "修改系统变量"
    
    # Check and add sysctl configuration
    if ! grep -q "vm.overcommit_memory=0" /etc/sysctl.conf; then
        echo "vm.overcommit_memory=0" >> /etc/sysctl.conf
    fi
    
    sysctl -p

    # Check and add limits.conf configuration
    cat > /etc/security/limits.conf << EOF
dmdba soft nproc 10240
dmdba hard nproc 10240
dmdba soft nofile 65536
dmdba hard nofile 65536
dmdba hard data unlimited
dmdba soft data unlimited
dmdba hard fsize unlimited
dmdba soft fsize unlimited
dmdba soft core unlimited
dmdba hard core unlimited
EOF
}
make_login(){
    file="/etc/pam.d/login"

    if ! grep -q "session  required  /lib64/security/pam_limits.so" "$file"; then
        echo "session  required  /lib64/security/pam_limits.so" >> "$file"
    fi

    if ! grep -q "session  required  pam_limits.so" "$file"; then
        echo "session  required  pam_limits.so" >> "$file"
    fi

    cat "$file"
}
disable_selinux(){
    sed -i 's/^SELINUX=.*/SELINUX=disabled/' /etc/selinux/config
}
download_installler(){
    wget -P /home/ --no-check-certificate https://oss.xxxx.com/dmxxxx.key
    wget --no-check-certificate https://oss.xxxx.com/DMInstall.bin
    chmod 777 /root/DMInstall.bin
}
install_dbm(){
    echo "请手动选择安装,参考选项 C,y,/home/dmxxxx.key,y,21,1,/home/dmdba/dmdbms,y,y"
    /root/DMInstall.bin -i console
    wait $!
    chown -R dmdba.dinstall /home/dmdba/*
    su - dmdba -c "/home/dmdba/dmdbms/bin/dminit PATH=/dmdata/dmdata"
}
regist_service(){
    /home/dmdba/dmdbms/script/root/dm_service_installer.sh -t dmserver -dm_ini /dmdata/dmdata/DAMENG/dm.ini -p DMSERVER
    /home/dmdba/dmdbms/bin/DmServiceDMSERVER start
}
login_sql(){
    echo "进入数据库后请开启归档,命令："
    echo "alter database mount;"
    echo "alter database add archivelog 'dest= /dmdata/dmarch,type=local,file_size=64,space_limit=10240';"
    echo "alter database archivelog;"
    echo "alter database open;"
    /home/dmdba/dmdbms/bin/disql SYSDBA/SYSDBA
    wait $!
}
echo && echo -e " ${Green_font_prefix}达梦中间件安装脚本Powered By Meina${Font_color_suffix}
${Green_font_prefix}0.${Font_color_suffix} 检查用户
${Green_font_prefix}1.${Font_color_suffix} 添加硬盘
${Green_font_prefix}2.${Font_color_suffix} 挂载硬盘
${Green_font_prefix}3.${Font_color_suffix} 创建目录
${Green_font_prefix}4.${Font_color_suffix} 建立变量
${Green_font_prefix}5.${Font_color_suffix} 配置用户
${Green_font_prefix}6.${Font_color_suffix} 关闭SELinux
${Green_font_prefix}7.${Font_color_suffix} 下载达梦中间件安装包
${Green_font_prefix}8.${Font_color_suffix} 安装达梦
${Green_font_prefix}9.${Font_color_suffix} 注册并启动服务
${Green_font_prefix}10.${Font_color_suffix} 登录SQL
${Green_font_prefix}11.${Font_color_suffix} 全自动安装(仅纯净环境)
注意：仅初始化安装脚本,已经运行后出错的 ${Red_font_prefix}严禁使用全自动安装${Font_color_suffix}出现问题请联系i@xzc-meina.top(浙政钉15355507503)" && echo
read -e -p " 请输入数字 [0-11]:" num
case "$num" in
	0)
	check_user
	;;
	1)
	add_disk
	;;
	2)
	mount_disk
	;;
	3)
	make_dir
	;;
	4)
	make_var
	;;
	5)
	make_login
	;;
    6)
	disable_selinux
	;;
    7)
	download_installler
	;;
    8)
	install_dbm
	;;
    9)
	regist_service
	;;
    10)
	login_sql
	;;
    11)
    check_user
    add_disk
    mount_disk
    make_dir
    make_var
    make_login
    disable_selinux
    download_installler
    install_dbm
    regist_service
    login_sql
    ;;
	*)
	echo "请输入正确数字 [0-11]"
	;;
esac