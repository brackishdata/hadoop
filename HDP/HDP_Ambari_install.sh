#!/bin/bash
# setup and install HDP from scratch - still requires web interaction.
# see Ambari Blueprints to automate full installation.
# https://cwiki.apache.org/confluence/display/AMBARI/Blueprints
# adam@techtonka.com

#important PATHS
HWXREPO="HOSTNAME"
AMBSRV="headnodename"


ssh-keygen -q -t rsa -f ~/.ssh/id_rsa -N ""
ssh-copy-id root@localhost

##loop over nodes
# hostlist="hostname1 hostname2"
# for i in $hostlist;do
# ssh-copy-id root@$i
# fi 


# Run on ALL NODES
sed -i 's/SELINUX=permissive/SELINUX=disabled/g;s/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config
chkconfig --del iptables
iptables -F
service iptables stop
iptables -vnL
yum -y erase mysql-libs postgresql nagios ganglia ganglia-gmetad libganglia
wait
yum -y install net-snmp net-snmp-utils ntp wget
wait
service ntpd start
chkconfig --add ntpd
chkconfig --levels 35 ntpd on
JDKLOC="http://$HWXREPO/artifacts/jdk-7u45-linux-x64.tar.gz"
wget $JDKLOC -O /tmp/jdk-7u45-linux-x64.tar.gz
mkdir -p /usr/java
tar -C /usr/java -zxvf /tmp/jdk-7u45-linux-x64.tar.gz
wait
echo "export JAVA_HOME=/usr/java/jdk1.7.0_45" > /etc/profile.d/java.sh
echo "export PATH=/usr/java/jdk1.7.0_45/bin:$PATH" >> /etc/profile.d/java.sh
echo "export PDSH_SSH_ARGS_APPEND=\"-o StrictHostKeyChecking=no\"" > /etc/profile.d/login.sh
source /etc/profile.d/java.sh
source /etc/profile.d/login.sh
export AMBARIREPO="http://$HWXREPO/ambari/centos6/1.x/updates/1.6.0/ambari.repo"
wget $AMBARIREPO -O /etc/yum.repos.d/ambari.repo
wait
sed -i 's/gpgcheck=1/gpgcheck=0/' /etc/yum.conf /etc/yum.repos.d/*
yum clean all
wait
service iptables stop
yum -y install ambari-agent
wait
sed -i "s/^hostname=.*/hostname=$AMBSRV/" /etc/ambari-agent/conf/ambari-agent.ini
ambari-agent start

# Optional for Post install tuning.
#export yarnutil="http://$HWXREPO/artifacts/yarn-utils.py"
#wget $yarnutil -P /usr/sbin
#chmod 755 /usr/sbin/yarn-utils.py

# Ambari Server Node ONLY
yum -y install ambari-server
wait
ambari-server setup -v -s -i /usr/java/jdk1.7.0_45 -j /usr/java/jdk1.7.0_45
wait
ambari-server start
