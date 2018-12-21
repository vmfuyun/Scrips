#!/bin/bash   
yum install epel-release -y 
yum clean all 

yum install cobbler cobbler-web httpd rsync tftp-server  xinetd dhcp python-ctypes  debmirror  pykickstart  -y 

systemctl enable cobblerd  
systemctl  start cobblerd  

systemctl enable httpd 
systemctl start httpd  

systemctl stop firewalld 
systemctl disable firwalld  

sed -i 's/SELINUX=enforcing/SELINUX=disabled/g'  /etc/selinux/config 

setenforce 0 

getenforce 

echo "-----------------------"
echo " configuer  static IP"
echo "-----------------------" 

#读取键盘输入内容为变量 赋值给IP   -t 30 等待30s  -p输入提示信息 

read -t 30 -p "please input static IP:" IP
read -t 30 -p "please input netmask:" NETMASK
read -t 30 -p "please input gateway:" GATEWAY 
# \n 换行  

echo  -e "\n"

#备份配置文件

cd /etc/sysconfig/network-scripts/
cp ifcfg-ens33 ifcfg-ens33.bak

#根据变量修改IP地址

sed -i 's/BOOTPROTO=dhcp/BOOTPROTO=static/g'  ifcfg-ens33 
sed -i 's/ONBOOT=no/ONBOOT=yes'  

echo -e "\n"   >> ifcfg-ens33
echo "IPADDR=$IP" >> ifcfg-ens33
echo "NETMASK=$NETMASK" >> ifcfg-ens33
echo "GATEWAY=$GATEWAY" >> ifcfg-ens33  

service network restart 


#配置DHCP  

read -t 30 -p "请输入IP地址段：" subnet
read -t 30 -p "请输入IP起始地址：" HeadIP
read -t 30 -p "请输入IP结束地址：" EndIP

read -t 30 -p "请输入routers:" ROUTER


echo -e "subnet $subnet  netmask $NETMASK{\n range $HeadIP $EndIP;\n option domain-name-servers ns1.internal.example.org;\n option domain-name "internal.example.org";\n option routers $ROUTER;\n option broadcast-address 192.168.0.255;\n default-lease-time 600;\n max-lease-time 7200;\n next-server $IP;\n filename "pxelinux.0";\n}\n"   >> /etc/dhcp/dhcpd.conf


systemctl start dhcpd 
systemctl enable dhcpd 
 
 
#配置cobbler 

#修改setting  server and next_server 
sed -i 's/^server:127.0.0.1/server:$IP'
sed -i 's/^next_server:127.0.1/next_server:$IP/g' /etc/cobbler/setting 










