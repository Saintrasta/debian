#!/bin/bash

ln -fs /usr/share/zoneinfo/Asia/Jakarta /etc/localtime 

echo 1 > /proc/sys/net/ipv6/conf/all/disable_ipv6 sed -i '$ i\echo 1 > /proc/sys/net/ipv6/conf/all/disable_ipv6' /etc/rc.local sed -i '$ i\echo 1 > /proc/sys/net/ipv6/conf/all/disable_ipv6' /etc/rc.d/rc.local

yum -y install wget curl
wget http://dl.fedoraproject.org/pub/epel/6/i386/epel-release-6-8.noarch.rpm
wget http://rpms.famillecollet.com/enterprise/remi-release-6.rpm
rpm -Uvh epel-release-6-8.noarch.rpm
rpm -Uvh remi-release-6.rpm
rm -f .rpm

yum -y remove sendmail;
yum -y remove httpd;
yum -y remove cyrus-sasl
yum -y update
yum -y install nginx php-fpm php-cli
service nginx start
service php-fpm start
chkconfig nginx on
chkconfig php-fpm on

yum -y install iftop htop nmap bc nethogs openvpn vnstat ngrep mtr git zsh mrtg unrar rsyslog rkhunter mrtg net-snmp net-snmp-utils expect nano
yum -y groupinstall 'Development Tools'
yum -y install cmake

service exim stop
chkconfig exim off

vnstat -u -i venet0
echo "MAILTO=root" > /etc/cron.d/vnstat
echo "/5 * * * * root /usr/sbin/vnstat.cron" >> /etc/cron.d/vnstat
sed -i 's/eth0/venet0/g' /etc/sysconfig/vnstat
service vnstat restart
chkconfig vnstat on

cd wget -O /etc/nginx/nginx.conf "https://raw.github.com/arieonline/autoscript/master/conf/nginx.conf"
sed -i 's/www-data/nginx/g' /etc/nginx/nginx.conf
mkdir -p /home/vps/public_html echo "<pre>Installed by Ahmad Thoriq Najahi</pre>" > /home/vps/public_html/index.html
echo "<?php phpinfo(); ?>" > /home/vps/public_html/info.php
rm /etc/nginx/conf.d/*
wget -O /etc/nginx/conf.d/vps.conf "https://raw.github.com/arieonline/autoscript/master/conf/vps.conf"
sed -i 's/apache/nginx/g' /etc/php-fpm.d/www.conf
chmod -R +rx /home/vps
chown -R nginx:nginx /home/vps/public_html
service php-fpm restart
service nginx restart

wget -O /etc/openvpn/openvpn.tar "https://raw.github.com/arieonline/autoscript/master/conf/openvpn-debian.tar"
cd /etc/openvpn/ tar xf openvpn.tar
wget -O /etc/openvpn/1194.conf "https://raw.github.com/arieonline/autoscript/master/conf/1194-centos.conf"
wget -O /etc/iptables.up.rules "https://raw.github.com/arieonline/autoscript/master/conf/iptables.up.rules"
sed -i '$ i\iptables-restore < /etc/iptables.up.rules' /etc/rc.local
sed -i '$ i\iptables-restore < /etc/iptables.up.rules' /etc/rc.d/rc.local
MYIP=curl -s ifconfig.me;
MYIP2="s/xxxxxxxxx/$MYIP/g";
sed -i $MYIP2 /etc/iptables.up.rules;
wget -O /home/vps/public_html/1194-client.conf "https://raw.github.com/arieonline/autoscript/master/conf/1194-client.conf"
sed -i $MYIP2 /home/vps/public_html/1194-client.conf;
iptables-restore < /etc/iptables.up.rules
sysctl -w net.ipv4.ip_forward=1
sed -i 's/net.ipv4.ip_forward=0 /net.ipv4.ip_forward = 1/g' /etc/sysctl.conf
service openvpn restart
chkconfig openvpn on
cd

wget -O /usr/bin/badvpn-udpgw "https://raw.github.com/arieonline/autoscript/master/conf/badvpn-udpgw"
sed -i '$ i\screen -AmdS badvpn badvpn-udpgw --listen-addr 127.0.0.1:7200' /etc/rc.local
sed -i '$ i\screen -AmdS badvpn badvpn-udpgw --listen-addr 127.0.0.1:7200' /etc/rc.d/rc.local
chmod +x /usr/bin/badvpn-udpgw
screen -AmdS badvpn badvpn-udpgw --listen-addr 127.0.0.1:7200

cd /etc/snmp/
wget -O /etc/snmp/snmpd.conf "https://raw.github.com/arieonline/autoscript/master/conf/snmpd.conf"
wget -O /root/mrtg-mem.sh "https://raw.github.com/arieonline/autoscript/master/conf/mrtg-mem.sh"
service snmpd restart
chkconfig snmpd on
snmpwalk -v 1 -c public localhost | tail
mkdir -p /home/vps/public_html/mrtg
cfgmaker --zero-speed 100000000 --global 'WorkDir: /home/vps/public_html/mrtg' --output /etc/mrtg/mrtg.cfg
public@localhost curl "https://raw.github.com/arieonline/autoscript/master/conf/mrtg.conf" >> /etc/mrtg/mrtg.cfg
sed -i 's/WorkDir: /var/www/mrtg/# WorkDir: /var/www/mrtg/g' /etc/mrtg/mrtg.cfg
sed -i 's/# Options[]: growright, bits/Options[]: growright/g' /etc/mrtg/mrtg.cfg
indexmaker --output=/home/vps/public_html/mrtg/index.html /etc/mrtg/mrtg.cfg
echo "0-59/5 * * * * root env LANG=C /usr/bin/mrtg /etc/mrtg/mrtg.cfg" > /etc/cron.d/mrtg LANG=C /usr/bin/mrtg /etc/mrtg/mrtg.cfg LANG=C /usr/bin/mrtg /etc/mrtg/mrtg.cfg LANG=C /usr/bin/mrtg /etc/mrtg/mrtg.cfg

cd
echo "Port 143" >> /etc/ssh/sshd_config
echo "Port 22" >> /etc/ssh/sshd_config
service sshd restart
chkconfig sshd on

yum -y install dropbear
echo "OPTIONS="-p 109 -p 110 -p 443"" > /etc/sysconfig/dropbear
echo "/bin/false" >> /etc/shells
service dropbear restart
chkconfig dropbear on

cd /home/vps/public_html/
wget http://www.sqweek.com/sqweek/files/vnstat_php_frontend-1.5.1.tar.gz
tar xf vnstat_php_frontend-1.5.1.tar.gz
rm vnstat_php_frontend-1.5.1.tar.gz
mv vnstat_php_frontend-1.5.1 vnstat
cd vnstat
sed -i 's/eth0/venet0/g' config.php
sed -i "s/$iface_list = array('venet0', 'sixxs');/$iface_list = array('venet0');/g" config.php
sed -i "s/$language = 'nl';/$language = 'en';/g" config.php
sed -i 's/Internal/Internet/g' config.php
sed -i '/SixXS IPv6/d' config.php

cd
yum -y install fail2ban
service fail2ban start
chkconfig fail2ban on

yum -y install squid
wget -O /etc/squid/squid.conf "https://raw.github.com/arieonline/autoscript/master/conf/squid-centos.conf"
sed -i $MYIP2 /etc/squid/squid.conf;
service squid restart
chkconfig squid on

cd
wget http://prdownloads.sourceforge.net/webadmin/webmin-1.660-1.noarch.rpm
rpm -i webmin-1.660-1.noarch.rpm;
rm webmin-1.660-1.noarch.rpm
service webmin restart

echo "==============================================="
echo "		SELAMAT, SERVER ANDA SIAP DI GUNAKAN     "
echo "==============================================="
echo ""
echo "Auto installer server SSH/VPN vps Centos 6"
echo "By Ahmad Thoriq Najahi"
echo ""
echo "Service"
echo "-------"
echo "OpenVPN : TCP 1194 (client config : http://$MYIP/1194-client.conf)"
echo "OpenSSH : 22, 143"
echo "Dropbear : 109, 110, 443"
echo "Squid : 8080 (limit to IP SSH)"
echo "badvpn : badvpn-udpgw port 7200"
echo ""
echo "Fitur lain"
echo "----------"
echo "Webmin : http://$MYIP:10000/"
echo "vnstat : http://$MYIP/vnstat/"
echo "MRTG : http://$MYIP/mrtg/"
echo "Timezone : Asia/Jakarta"
echo "Fail2Ban : [on]"
echo "IPv6 : [off]"
echo ""
echo "SILAHKAN REBOOT VPS ANDA !"
echo ""
echo "==============================================="
echo "			SETUP BY AHMAD THORIQ NAJAHI     	 "
echo "==============================================="
