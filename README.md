# isn
IPS based on Snort and Aanval on CentOS7

# preinstall.sh

+ disable SElinux
+ disable Firewall
+ Install requed software
+ Update and upgrade software
+ Make root/snort_scr directory and download snort and DAQ source
+ Compile DAQ with nfqueue
+ Compile Snort
+ Make directory for Snort, copy files, download and unzip rules
+ Make requed files for Snort
+ Edit snort.conf
+ Add iptables rules
+ Start MariaDB
+ MariaDB secure install and create aanval db
+ Allow root remotely connect to DB
+ Prepare for Aanval
+ Edit php.ini - timezone and max_upload_size
+ Start apache
+ Prepare for Aanval SMT to Snort
+ Download Barnyard2 and install
+ Create db for Barnyard2
+ Add scripts to crontab and copy
+ Make it executable

#sql.sh

+ Change rules in Aanval from alert to drop

#startup.sh

+ Disable Ipv6
+ Add bridge and start it up
+ Enable iptables for bridge
+ Start AAnval BPU and SMT
+ Start barnyard2

#snort.sh

+ Start snort
