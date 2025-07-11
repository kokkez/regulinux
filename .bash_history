apt --installed list
dpkg --get-selections > installed.txt
lsb_release -sc
systemd-detect-virt
curl -sL bench.monster | bash -s -- -eu
# add swap 512M
swapoff /swap.img
fallocate -l 512M /swapfile
chmod 600 /swapfile
mkswap /swapfile
swapon /swapfile
swapon --show
free -h
echo '/swapfile none swap sw 0 0' >> /etc/fstab
#
dpkg --list 'linux-*-*'
uname -r
ls -l /lib/modules
apt purge linux-*-5.10.0-20-*
update-grub
#
acme.sh --issue -d namium.rete.us -w /usr/local/ispconfig/interface/acme
acme.sh --renew -d namium.rete.us --force
swaks -s 127.0.0.1:25 -q TO -f acq@olmark.com -t RCastoldi@parker.com
swaks -s 127.0.0.1:25 -f kokez@libero.it -t k@rete.us --header "Subject: File to open now!" --attach ~/file.jar
swaks -s 127.0.0.1:25 -f root -t k@rete.us
openssl s_client -showcerts -connect localhost:465
fail2ban-client status
#
systemctl restart nginx php7.{3,4}-fpm
update-alternatives --config php
os deps
os mailserver ispconfig
os dbserver ispconfig
os ispconfig nginx
os bench
os upgrade
## namium @ provider [ namium ] ##
