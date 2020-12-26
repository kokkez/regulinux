apt --installed list
dpkg --get-selections > installed.txt
lsb_release -sc
curl -LsO bench.monster/speedtest.sh; bash speedtest.sh -Europe
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
# upgrade debian 8 jessie to debian 9 stretch
command cat <<EOF > /etc/apt/sources.list
# Debian 8 Jessie :: https://wiki.debian.org/SourcesList
deb http://deb.debian.org/debian jessie main contrib non-free
#deb http://deb.debian.org/debian jessie-updates main contrib non-free
deb http://security.debian.org/ jessie/updates main contrib non-free
EOF
apt-get update
apt-get upgrade
apt-get dist-upgrade
dpkg -C             # perform database sanity and consistency checks
##apt-get install --reinstall module-init-tools
apt-mark showhold   # check what packages are held back
sed -i "s/jessie/stretch/g" /etc/apt/sources.list   # change repository
apt-get update
apt list --upgradable
apt-get upgrade
apt-get dist-upgrade
reboot
apt update && apt full-upgrade
#
# upgrade ubuntu 14.04 trusty to ubuntu 16.04 xenial
command cat <<EOF > /etc/apt/sources.list
# Ubuntu 14.04 LTS Trusty Tahr
deb http://archive.ubuntu.com/ubuntu/ trusty main universe restricted multiverse
deb http://archive.ubuntu.com/ubuntu/ trusty-updates main universe restricted multiverse
deb http://security.ubuntu.com/ubuntu trusty-security main universe restricted multiverse
deb http://archive.canonical.com/ubuntu trusty partner
EOF
apt-get update && apt-get dist-upgrade
apt-get install dialog apt-utils update-manager-core
sed -i -e "s/^Pro.*/Prompt=lts/" /etc/update-manager/release-upgrades
init 6
do-release-upgrade --help
do-release-upgrade -d
do-release-upgrade -m server -f DistUpgradeViewNonInteractive
#
acme.sh --issue -d radium.rete.us -w /usr/local/ispconfig/interface/acme
acme.sh --renew -d radium.rete.us --force
swaks -s 127.0.0.1:25 -q TO -f acq@olmark.com -t RCastoldi@parker.com
swaks -s 127.0.0.1:25 -f kokez@libero.it -t k@rete.us --header "Subject: File to open now!" --attach ~/file.jar
openssl s_client -showcerts -connect localhost:465
fail2ban-client status
#
systemctl restart nginx php7.2-fpm php7.3-fpm
bash ~/lin*/arrange.sh deps
bash ~/lin*/arrange.sh mailserver ispconfig
bash ~/lin*/arrange.sh dbserver ispconfig
bash ~/lin*/arrange.sh ispconfig nginx
bash ~/lin*/arrange.sh resolv
bash ~/lin*/arrange.sh ssh
bash ~/lin*/arrange.sh
bash ~/lin*/arrange.sh upgrade
## namium @ provider [ namium ] ##
