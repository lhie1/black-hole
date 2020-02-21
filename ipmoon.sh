#!/bin/bash
# IPChanger Script v0.2
# Written by iLemonrain Version 20190603

# ===== 全局定义 =====
# 使用前请先修改以下参数
# DHCP操作网卡
interface_name="$(ip -4 route | awk -F' ' '/default/{print $5}')"
# 国内目标
blockcheck_chinatarget="oss-cn-beijing.aliyuncs.com"
#检测端口
ports="170"
# 全局超时设置，如果3秒太短或者误判率太高可以适当调高此值
timeout="10"

# 字体颜色定义
Font_Black="\033[30m"  
Font_Red="\033[31m" 
Font_Green="\033[32m"  
Font_Yellow="\033[33m"  
Font_Blue="\033[34m"  
Font_Purple="\033[35m"  
Font_SkyBlue="\033[36m"  
Font_White="\033[37m" 
Font_Suffix="\033[0m"

# 消息提示定义
Msg_Info="${Font_Blue}[Info] ${Font_Suffix}"
Msg_Blocked="${Font_Red}[Block] ${Font_Suffix}"
Msg_Error="${Font_Red}[Error] ${Font_Suffix}"
Msg_Success="${Font_Green}[Success] ${Font_Suffix}"
Msg_Fail="${Font_Red}[Failed] ${Font_Suffix}"

# DHCP释放
Func_DHCP() {
    dhclient -r -v $interface_name
    rm -rf /var/lib/dhcp/dhclient.leases
    sleep 5s
    dhclient -v $interface_name
    sleep 2s
    MainFund
}

# 修改MAC地址
Func_ChangeMAC() {
    ifconfig ${interface_name} down
	MAC="$(cat /sys/class/net/${interface_name}/address)"
	Temp="$(expr substr "$MAC" 1 8)"
	NewMAC="$(echo $Temp:`openssl rand -hex 3 | sed 's/\(..\)/\1:/g; s/.$//'`)"
	echo MACADDR=$NewMAC >> /etc/sysconfig/network-scripts/ifcfg-${interface_name}
    ifconfig ${interface_name} up
	sleep 15m
}


# 获取本机IP
Func_GetMyIP() {
    MyIP="$(curl --connect-timeout ${timeout} -s ip.sb)"
}

# 检查到国内是否ICMP墙
Func_CheckBlock_ChinaIP_ICMP() {
    ping -c 1 -w ${timeout} ${blockcheck_chinatarget} >/dev/null 2>&1
    if [ "$?" -ne "0" ]; then
        CheckBlock_ChinaIP_ICMP_Blocked="1"
    else
        CheckBlock_ChinaIP_ICMP_Blocked="0"
    fi
}

# 检查到国内是否TCP墙
Func_CheckBlock_ChinaIP_TCP() {
 #   response=$(curl -s "ipcheck.nic32.com/check.php?$MyIP,$ports")
 #   if [ $response = "OPEN" ]; then
 #       CheckBlock_ChinaIP_TCP_Blocked="0"
 #   else
 #       CheckBlock_ChinaIP_TCP_Blocked="1"
 #   fi
 	CheckBlock_ChinaIP_TCP_Blocked=$(curl -s "175.102.11.134:1024/$MyIP/$ports" |grep false |wc -l)
}
echo $CheckBlock_ChinaIP_TCP_Blocked

# 亮灯
check_pid_client(){
	PID=`ps -ef| grep "status-client.py"| grep -v grep| grep -v ".sh"| grep -v "init.d"| grep -v "service"| awk '{print $2}'`
}
Restart_ServerStatus_client(){
    /etc/init.d/status-client restart
}
MainFunc() {
    echo -e "${Msg_Info}Getting Public IP ..."
    Func_GetMyIP
    echo -e "${Msg_Info}Checking ICMP Availablity on ${MyIP} ..."
    Func_CheckBlock_ChinaIP_ICMP
    echo -e "${Msg_Info}Checking TCP Availablity on ${MyIP} ..."
    Func_CheckBlock_ChinaIP_TCP
    if [ "${CheckBlock_ChinaIP_ICMP_Blocked}" = "0" ] && [ "${CheckBlock_ChinaIP_TCP_Blocked}" = "0" ]; then
        echo -e "${Msg_Success}IP ${MyIP} seems FINE !"
        CheckCode="101"
    elif [ "${CheckBlock_ChinaIP_ICMP_Blocked}" = "1" ] && [ "${CheckBlock_ChinaIP_TCP_Blocked}" = "0" ]; then
        echo -e "${Msg_Blocked}IP ${MyIP} is Blocked： ICMP: ${Font_Red}No${Font_Suffix} / TCP: ${Font_Green}Yes${Font_Suffix} "
        CheckCode="102"
    elif [ "${CheckBlock_ChinaIP_ICMP_Blocked}" = "0" ] && [ "${CheckBlock_ChinaIP_TCP_Blocked}" = "1" ]; then
        echo -e "${Msg_Blocked}IP ${MyIP} Blocked： ICMP: ${Font_Green}Yes${Font_Suffix} / TCP: ${Font_Red}No${Font_Suffix} "
        CheckCode="103"
    elif [ "${CheckBlock_ChinaIP_ICMP_Blocked}" = "1" ] && [ "${CheckBlock_ChinaIP_TCP_Blocked}" = "1" ]; then
        echo -e "${Msg_Blocked}IP ${MyIP} Blocked： ICMP: ${Font_Red}No${Font_Suffix} / TCP: ${Font_Red}No${Font_Suffix} "
        CheckCode="104"
    else
        echo -e "${Msg_Error}Cannot determine ip status, perhaps it's a bug?"
        exit 100
    fi
    if [ "${CheckCode}" == "102" ] || [ "${CheckCode}" == "103" ] || [ "${CheckCode}" == "104" ]; then
        echo -e "${Msg_Info}Retrying IP Assign .."
        CheckCode="0" && MyIP="0.0.0.0"
        MainFune
    else
        echo -e "${Msg_Success}Successfully Changed IP: ${MyIP}"
		sleep 30s
		MainFunc
    fi
}
MainFune() {
    echo -e "${Msg_Info}Getting Public IP ..."
    Func_GetMyIP
    echo -e "${Msg_Info}Checking ICMP Availablity on ${MyIP} ..."
    Func_CheckBlock_ChinaIP_ICMP
    echo -e "${Msg_Info}Checking TCP Availablity on ${MyIP} ..."
    Func_CheckBlock_ChinaIP_TCP
    if [ "${CheckBlock_ChinaIP_ICMP_Blocked}" = "0" ] && [ "${CheckBlock_ChinaIP_TCP_Blocked}" = "0" ]; then
        echo -e "${Msg_Success}IP ${MyIP} seems FINE !"
        CheckCode="101"
    elif [ "${CheckBlock_ChinaIP_ICMP_Blocked}" = "1" ] && [ "${CheckBlock_ChinaIP_TCP_Blocked}" = "0" ]; then
        echo -e "${Msg_Blocked}IP ${MyIP} is Blocked： ICMP: ${Font_Red}No${Font_Suffix} / TCP: ${Font_Green}Yes${Font_Suffix} "
        CheckCode="102"
    elif [ "${CheckBlock_ChinaIP_ICMP_Blocked}" = "0" ] && [ "${CheckBlock_ChinaIP_TCP_Blocked}" = "1" ]; then
        echo -e "${Msg_Blocked}IP ${MyIP} Blocked： ICMP: ${Font_Green}Yes${Font_Suffix} / TCP: ${Font_Red}No${Font_Suffix} "
        CheckCode="103"
    elif [ "${CheckBlock_ChinaIP_ICMP_Blocked}" = "1" ] && [ "${CheckBlock_ChinaIP_TCP_Blocked}" = "1" ]; then
        echo -e "${Msg_Blocked}IP ${MyIP} Blocked： ICMP: ${Font_Red}No${Font_Suffix} / TCP: ${Font_Red}No${Font_Suffix} "
        CheckCode="104"
    else
        echo -e "${Msg_Error}Cannot determine ip status, perhaps it's a bug?"
        exit 100
    fi
    if [ "${CheckCode}" == "102" ] || [ "${CheckCode}" == "103" ] || [ "${CheckCode}" == "104" ]; then
        echo -e "${Msg_Info}Retrying IP Assign .."
        CheckCode="0" && MyIP="0.0.0.0"
        Func_DHCP
    else
        echo -e "${Msg_Success}Successfully Changed IP: ${MyIP}"
		sleep 30s
		MainFunc
    fi
}
MainFund() {
    echo -e "${Msg_Info}Getting Public IP ..."
    Func_GetMyIP
    echo -e "${Msg_Info}Checking ICMP Availablity on ${MyIP} ..."
    Func_CheckBlock_ChinaIP_ICMP
    echo -e "${Msg_Info}Checking TCP Availablity on ${MyIP} ..."
    Func_CheckBlock_ChinaIP_TCP
    if [ "${CheckBlock_ChinaIP_ICMP_Blocked}" = "0" ] && [ "${CheckBlock_ChinaIP_TCP_Blocked}" = "0" ]; then
        echo -e "${Msg_Success}IP ${MyIP} seems FINE !"
        CheckCode="101"
    elif [ "${CheckBlock_ChinaIP_ICMP_Blocked}" = "1" ] && [ "${CheckBlock_ChinaIP_TCP_Blocked}" = "0" ]; then
        echo -e "${Msg_Blocked}IP ${MyIP} is Blocked： ICMP: ${Font_Red}No${Font_Suffix} / TCP: ${Font_Green}Yes${Font_Suffix} "
        CheckCode="102"
    elif [ "${CheckBlock_ChinaIP_ICMP_Blocked}" = "0" ] && [ "${CheckBlock_ChinaIP_TCP_Blocked}" = "1" ]; then
        echo -e "${Msg_Blocked}IP ${MyIP} Blocked： ICMP: ${Font_Green}Yes${Font_Suffix} / TCP: ${Font_Red}No${Font_Suffix} "
        CheckCode="103"
    elif [ "${CheckBlock_ChinaIP_ICMP_Blocked}" = "1" ] && [ "${CheckBlock_ChinaIP_TCP_Blocked}" = "1" ]; then
        echo -e "${Msg_Blocked}IP ${MyIP} Blocked： ICMP: ${Font_Red}No${Font_Suffix} / TCP: ${Font_Red}No${Font_Suffix} "
        CheckCode="104"
    else
        echo -e "${Msg_Error}Cannot determine ip status, perhaps it's a bug?"
        exit 100
    fi
    if [ "${CheckCode}" == "102" ] || [ "${CheckCode}" == "103" ] || [ "${CheckCode}" == "104" ]; then
        echo -e "${Msg_Info}Retrying IP Assign .."
        CheckCode="0" && MyIP="0.0.0.0"
        Func_DHCP
    else
        echo -e "${Msg_Success}Successfully Changed IP: ${MyIP}"
		sleep 1s
		Restart_ServerStatus_client
		sleep 1s
		Dnspod_ddns
		
    fi
}

Dnspod_ddns() {
	bash /root/dnspod_ddns.sh
	sleep 1s
	MainFunc
}

# 全局入口
MainFunc