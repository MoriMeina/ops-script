#!/usr/bin/env bash
Green_font_prefix="\033[32m" && Red_font_prefix="\033[31m" && Green_background_prefix="\033[42;37m" && Red_background_prefix="\033[41;37m" && Font_color_suffix="\033[0m"
check_java(){
    if type -p java; then
        echo "Java已安装"
    else
        echo "未检测到Java,开始安装"
        wget --no-check-certificate -O /root/zulu8.74.0.17-ca-jdk8.0.392-linux.x86_64.rpm https://oss.xxxx.com/zulu8.74.0.17-ca-jdk8.0.392-linux.x86_64.rpm
        rpm -ivh /root/zulu8.74.0.17-ca-jdk8.0.392-linux.x86_64.rpm
        rm -rf /root/zulu8.74.0.17-ca-jdk8.0.392-linux.x86_64.rpm
        if type -p java; then
            echo "Java安装成功"
        else
            echo "Java安装失败,请手动检查"
        fi
    fi
}
download_inst(){
    wget --no-check-certificate -O /root/AAS-V10.zip https://oss.xxxx.com/AAS-V10.zip
    chmod -R /root/AAS-V10.zip
    unzip /root/AAS-V10.zip
}
download_license(){
    wget --no-check-certificate -O /root/ApusicAS/aas/license.xml https://oss.xxxx.com/xxxx.xml
}
exec(){
    echo "请进入后设置密码audit Sqwe@2023   admin Sasd@2023    secure Szxc@2023"
    /root/ApusicAS/bin/asadmin start-domain
    wait $!
}
check(){
    lsof -i :6848
}
echo && echo -e " ${Green_font_prefix}金蝶中间件安装脚本Powered by Meina${Font_color_suffix}
${Green_font_prefix}0.${Font_color_suffix} 安装java
${Green_font_prefix}1.${Font_color_suffix} 下载并解压安装包
${Green_font_prefix}2.${Font_color_suffix} 下载License
${Green_font_prefix}3.${Font_color_suffix} 执行
${Green_font_prefix}4.${Font_color_suffix} 检查监听端口为6848的进程
${Green_font_prefix}5.${Font_color_suffix} 全自动安装
注意：仅初始化安装脚本,已经运行后出错的 ${Red_font_prefix}严禁使用全自动安装${Font_color_suffix}出现问题请联系i@xzc-meina.top(浙政钉15355507503)" && echo
read -e -p " 请输入数字 [0-5]:" num
case "$num" in
	0)
	check_java
	;;
	1)
	download_inst
	;;
	2)
	download_license
	;;
	3)
	exec
	;;
	4)
	check
	;;
	5)
	check_java
    download_inst
    download_license
    exec
    check
	;;
	*)
	echo "请输入正确数字 [0-5]"
	;;
esac