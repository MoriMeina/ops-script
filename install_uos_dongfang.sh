#!/usr/bin/env bash
Green_font_prefix="\033[32m" && Red_font_prefix="\033[31m" && Green_background_prefix="\033[42;37m" && Red_background_prefix="\033[41;37m" && Font_color_suffix="\033[0m"
check_java(){
    if type -p java; then
        echo "Java已安装"
    else
        echo "未检测到Java,开始安装"
        echo "nameserver 114.114.114.114">>/etc/resolv.conf
        yum install -y java
        if type -p java; then
            echo "Java安装成功"
        else
            echo "Java安装失败,请手动检查"
        fi
    fi
}
download_inst(){
    wget --no-check-certificate -O /root/TongWeb7.0.4.9_M1_Enterprise_Linux.tar.gz https://ops-iso-and-scripts.oss111b-cn-sx-zjsxzwy01-d01-a.inner.zjsxzwy.cn/TongWeb7.0.4.9_M1_Enterprise_Linux.tar.gz
    chmod -R /root/TongWeb7.0.4.9_M1_Enterprise_Linux.tar.gz
    tar -xvzf /root/TongWeb7.0.4.9_M1_Enterprise_Linux.tar.gz
}
download_license(){
    wget --no-check-certificate -O /root/TongWeb7.0.4.9_M1_Enterprise_Linux/license.dat https://ops-iso-and-scripts.oss111b-cn-sx-zjsxzwy01-d01-a.inner.zjsxzwy.cn/%E4%B8%9C%E6%96%B9%E9%80%9Alicense%EF%BC%88web%E4%BC%81%E4%B8%9A%E7%89%88%EF%BC%89.dat
}
exec(){
    bash /root/TongWeb7.0.4.9_M1_Enterprise_Linux/bin/startservernohup.sh
    wait $!
}
check(){
    lsof -i :8088
    lsof -i :9060
}
echo && echo -e " ${Green_font_prefix}东方通中间件安装脚本Powered by Meina${Font_color_suffix}
${Green_font_prefix}0.${Font_color_suffix} 安装java
${Green_font_prefix}1.${Font_color_suffix} 下载并解压安装包
${Green_font_prefix}2.${Font_color_suffix} 下载License
${Green_font_prefix}3.${Font_color_suffix} 执行
${Green_font_prefix}4.${Font_color_suffix} 检查监听端口为8088,9060的进程
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