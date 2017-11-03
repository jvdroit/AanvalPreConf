#!/bin/bash

# disable SElinux

sed -i '/SELINUX=enforcing/s/enforcing/disabled/g' /etc/sysconfig/selinux
sed -i '/SELINUX=enforcing/s/enforcing/disabled/g' /etc/selinux/config

# disable Firewall

service firewalld stop
systemctl disable firewalld

# Install requed software

yum -y install gcc libdnet-1.12-13.1.el7.x86_64 libdnet-devel.x86_64 flex bison libpcap libpcap-devel libnetfilter_quene libnetfilter_queue-devel.x86_64 pcre.x86_64 pcre.i686 pcre-devel zlib-devel iptables-services httpd mod_ssl php php-common php-gd php-mysql php-xml php-mbstring mariadb mariadb-libs mariadb-server mysql-devel vim wget man make gcc flex bison zlib zlib-devel libpcap libpcap-devel pcre pcre-devel tcpdump gcc-c++ mysql-server mysql mysql-devel libtool perl-libwww-perl perl-Archive-Tar perl-Crypt-SSLeay git gcc libxml2 libxml2-devel libxslt libxslt-devel httpd curl-devel httpd-devel apr-devel apr-util-devel libXrender fontconfig libXext ruby-devel unzip xz

# Update and upgrade software

yum -y update
yum -y upgrade

# Make root/snort_scr directory and download snort and DAQ source

mkdir /snort_scr
cd snort_scr
wget https://www.snort.org/downloads/snort/snort-2.9.8.3.tar.gz
tar -zxvf snort-2.9.8.3.tar.gz 
wget https://www.snort.org/downloads/snort/daq-2.0.6.tar.gz
tar -zxvf daq-2.0.6.tar.gz

# Compile DAQ with nfqueue

cd daq-2.0.6/
./configure --libdir=/usr/lib64 --prefix=/usr --enable-nfq-module=yes
make
make install

# Compile Snort

cd ..
cd snort-2.9.8.3/
./configure
make
make install

# Make directory for Snort, copy files, download and unzip rules

mkdir /etc/snort/
cp /snort_scr/snort-2.9.8.3/etc/*.* /etc/snort/
cd /etc/snort/
cp /etc/snort/etc/sid-msg.map /etc/snort/
wget https://www.snort.org/rules/snortrules-snapshot-2982.tar.gz?oinkcode=ec6efc2e580ddc8aee6817ed9ddf3a234b7537f6
tar -zxvf snortrules-snapshot-2982.tar.gz\?oinkcode\=ec6efc2e580ddc8aee6817ed9ddf3a234b7537f6

# Make requed files for Snort

mkdir /usr/local/lib/snort_dynamicrules
mkdir /var/log/snort
touch /var/log/snort/alert
touch /etc/snort/rules/white_list.rules
touch /etc/snort/rules/black_list.rules

# Edit snort.conf

sed -i '/var RULE_PATH ..\/rules/s/..\/rules/rules/g' /etc/snort/snort.conf
sed -i '/var SO_RULE_PATH ..\/so_rules/s/..\/so_rules/so_rules/g' /etc/snort/snort.conf
sed -i '/var PREPROC_RULE_PATH ..\/preproc_rules/s/..\/preproc_rules/preproc_rules/g' /etc/snort/snort.conf
sed -i '/var WHITE_LIST_PATH ..\/rules/s/..\/rules/\/etc\/snort\/rules/g' /etc/snort/snort.conf
sed -i '/var BLACK_LIST_PATH ..\/rules/s/..\/rules/\/etc\/snort\/rules/g' /etc/snort/snort.conf
sed -i '/# config daq: <type>/s/# config daq: <type>/config daq: nfq/g' /etc/snort/snort.conf
sed -i '/# config daq_mode: <mode>/s/# config daq_mode: <mode>/config daq_mode: inline/g' /etc/snort/snort.conf
sed -i '/# config daq_var: <var>/s/# config daq_var: <var>/config daq_var: queue=0/g' /etc/snort/snort.conf

# Add iptables rules

iptables -I FORWARD -j NFQUEUE --queue-num 0
iptables -I INPUT -p tcp --dport 80 -j ACCEPT
brctl addbr br0
brctl addif br0 ens192 ens224
sysctl -w net.bridge.bridge-nf-call-iptables=1
ifconfig ens192 up
ifconfig ens224 up
ifconfig br0 up
service iptables save

# Start MariaDB

systemctl start mariadb.service
systemctl enable mariadb.service

# MariaDB secure install and create aanval db

mysql_secure_installation <<< $'\nn\nn\nn\nn\ny\n'
mysqladmin create aanvaldb

# Allow root remotely connect to DB
mysql <<< $'GRANT ALL PRIVILEGES ON *.* TO 'root'  WITH GRANT OPTION;'

# Prepare for Aanval

cd /var/www/html
mkdir aanval
cd aanval
wget download.aanval.com/aanval-8-latest-stable.tar.gz
tar -zxvf aanval-8-latest-stable.tar.gz

# Edit php.ini - timezone and max_upload_size

sed -i '/;date.timezone =/s/;date.timezone =/date.timezone = Europe\/Paris/g' /etc/php.ini
echo 'Need increase MAX_UPLOAD_SIZE in PHP.INI'

# Start apache

systemctl enable httpd.service
service httpd start

# Prepare for Aanval SMT to Snort

mkdir /smt
cp /var/www/html/aanval/contrib/smt2/*.* /smt

# Download Barnyard2 and install

cd /snort_scr
git clone https://github.com/firnsy/barnyard2.git
cd barnyard2/
./autogen.sh
./configure --with-mysql-libraries=/usr/lib64/mysql/
make
make install
cp ./etc/barnyard2.conf /etc/

# Create db for Barnyard2

mysqladmin create snort
mysql snort < ./schemas/create_mysql

# Add scripts to crontab and copy

crontab -l | { cat; echo "*/10 * * * * /root/sql.sh > /dev/null 2>&1"; } | crontab -
crontab -l | { cat; echo "@reboot /root/startup.sh > /dev/null 2>&1"; } | crontab -
crontab -l | { cat; echo "@reboot /root/snort.sh > /dev/null 2>&1"; } | crontab -
cp *.sh /root

# Make it executable

chmod +x /root/*.sh








