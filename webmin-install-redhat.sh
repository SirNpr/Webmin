#!/bin/bash

echo "Enter a Username for the Webmin Webconsole"
read username
echo "Enter Password for $username"
while true; do
	read -s -p "Password: " password1
	echo
	read -s -p "Password (again): " password2
	echo
	[ "$password1" = "$password2" ] && break || echo "Please try again"
done
ipaddress=$(dig @resolver1.opendns.com ANY myip.opendns.com +short)

/bin/cat <<EOM >"/etc/yum.repos.d/webmin.repo"
[Webmin]
name=Webmin Distribution Neutral
#baseurl=https://download.webmin.com/download/yum
mirrorlist=https://download.webmin.com/download/yum/mirrorlist
enabled=1
EOM

wget https://download.webmin.com/jcameron-key.asc
rpm --import jcameron-key.asc
rm jcameron-key.asc

yum update -y && yum upgrade -y

yum install -y webmin

/bin/cat <<EOM >"/etc/webmin/miniserv.users"
$username:abcd1234:0
EOM

/bin/cat <<EOM >>"/etc/webmin/webmin.acl"
$username: acl adsl-client ajaxterm apache at backup-config bacula-backup bandwidth bind8 change-user cluster-copy cluster-cron cluster-passwd cluster-shell cluster-software cluster-useradmin cluster-usermin cluster-webmin cpan cron custom dfsadmin dhcpd dovecot exim exports fail2ban fdisk fetchmail filemin filter firewall firewall6 firewalld fsdump grub heartbeat htaccess-htpasswd idmapd inetd init inittab ipfilter ipfw ipsec iscsi-client iscsi-server iscsi-target iscsi-tgtd jabber krb5 ldap-client ldap-server ldap-useradmin logrotate lpadmin lvm mailboxes mailcap man mon mount mysql net nis openslp package-updates pam pap passwd phpini postfix postgresql ppp-client pptp-client pptp-server proc procmail proftpd qmailadmin quota raid samba sarg sendmail servers shell shorewall shorewall6 smart-status smf software spam squid sshd status stunnel syslog-ng syslog system-status tcpwrappers telnet time tunnel updown useradmin usermin vgetty webalizer webmin webmincron webminlog wuftpd xinetd
EOM

/usr/libexec/webmin/changepass.pl /etc/webmin $username $password2

service webmin restart

clear

service webmin status

echo "Please run: ssh -L 10000:127.0.0.1:10000 -i <ssh_key> ec2-user@"$ipaddress
echo "Then browse to https://127.0.0.1:10000"
