#!/bin/bash

#################################
# RECOMENDADMOS USO DO DEBIAN 11#
#################################

#######################
# ATUALIZANDO O LINUX #
#######################
apt-get update

###################################
# INSTALANDO PACOTES IMPORTESNTES #
###################################
apt-get install htop nano wget curl sudo git tcpdump net-tools -y

############################
# ATUALIZANDO AS VARIAVEIS #
############################
export OPENSEARCH_JAVA_HOME=/path/to/opensearch-2.11.1/jdk
cat /proc/sys/vm/max_map_count
#vm.max_map_count=262144

sleep 5
##################################
# BAIXANDO OPENSEARH E DASHBOARD #
##################################
wget https://artifacts.opensearch.org/releases/bundle/opensearch/2.11.1/opensearch-2.11.1-linux-x64.deb
wget https://artifacts.opensearch.org/releases/bundle/opensearch-dashboards/2.11.1/opensearch-dashboards-2.11.1-linux-x64.deb

####################################
# INSTALANDO OPENSEARH E DASHBOARD #
####################################
sudo dpkg -i opensearch-2.11.1-linux-x64.deb
sudo systemctl enable opensearch
sudo systemctl start opensearch
#sudo systemctl status opensearch
#TESTANDO INSLATACAO OPENSEACH
#curl -X GET https://localhost:9200 -u 'admin:admin' --insecure

sudo dpkg -i opensearch-dashboards-2.11.1-linux-x64.deb
sudo systemctl daemon-reload
sudo systemctl enable opensearch-dashboards
sudo systemctl start opensearch-dashboards
#sudo systemctl status opensearch-dashboards
#TESTANDO INSLATACAO DASHBOARD
#curl -v 0.0.0.0:5601

sleep 5
###################################
# INSTALANDO REPOSITORIO DO LINUX #
###################################
apt update
apt install firmware-linux firmware-linux-free firmware-linux-nonfree -y

########################
# TUNNING KERNEL LINUX #
########################
cp /sbin/sysctl /bin/
echo "vm.swappiness=10" >> /etc/sysctl.conf
echo "vm.max_map_count=262144" > /etc/sysctl.d/70-elasticsearch.conf
cat <<EOF >/etc/sysctl.d/60-net.conf
net.core.netdev_max_backlog=8192
net.core.rmem_default=262144
net.core.rmem_max=134217728
net.ipv4.udp_rmem_min=131072
net.ipv4.udp_mem=4194304 8388608 16777216
fs.file-max=3263776
fs.aio-max-nr=3263776
net.core.default_qdisc=fq
net.core.somaxconn=16384
EOF
sysctl -w vm.max_map_count=262144 && \
sysctl -w net.core.netdev_max_backlog=8192 && \
sysctl -w net.core.rmem_default=262144 && \
sysctl -w net.core.rmem_max=134217728 && \
sysctl -w net.ipv4.udp_rmem_min=131072 && \
sysctl -w sysctl -w fs.file-max=3263776 && \
sysctl -w sysctl -w fs.aio-max-nr=3263776 && \
sysctl -w net.core.default_qdisc=fq && \
sysctl -w net.core.somaxconn=16384 && \
sysctl -w net.ipv4.udp_mem='4194304 8388608 16777216'

sleep 5
#########################
# ATUALIZANDO OPENSEACH #
#########################
# echo -e "-Xms12g\n-Xmx12g" > /etc/opensearch/jvm.options
wget https://repository.alcloud.com.br/fs/arquivos/alflow/siem/jvm.options
wget https://repository.alcloud.com.br/fs/arquivos/alflow/siem/opensearch.service
mv jvm.options /etc/opensearch/
mv opensearch.service /lib/systemd/system/

#########################
# INSTALANDO ELASTIFLOW #
#########################
apt install libpcap-dev -y
wget https://repository.alcloud.com.br/fs/arquivos/alflow/flow-collector_5.6.0_linux_amd64.deb
sudo dpkg -i flow-collector_5.6.0_linux_amd64.deb
apt install -f
systemctl daemon-reload
systemctl enable flowcoll
systemctl start flowcolsystemctl start flowcolll
#systemctl status flowcoll

sleep 5
##########################
# ATUALIZANDO ELASTIFLOW #
##########################
# nano /etc/systemd/system/flowcoll.service.d/flowcoll.conf
wget https://repository.alcloud.com.br/fs/arquivos/alflow/siem/flowcoll.conf
wget https://repository.alcloud.com.br/fs/arquivos/alflow/siem/opensearch_dashboards.yml
mv flowcoll.conf /etc/systemd/system/flowcoll.service.d/
mv opensearch_dashboards.yml /etc/opensearch-dashboards/

sleep 5
################################
# TESTANDO RECEBIMENTO DE FLOW #
################################
#tcpdump -n udp port 9995 -T cnfp

sleep 5
########################
# IMPORTANDO DASHBOARD #
########################
wget https://repository.alcloud.com.br/fs/arquivos/alflow/dashboards/flow/dashboards-1.0.x-flow-codex.ndjson
wget https://repository.alcloud.com.br/fs/arquivos/alflow/dashboards/flow/dashboards-1.0.x-flow-ecs.ndjson
wget https://repository.alcloud.com.br/fs/arquivos/alflow/dashboards/flow/dashboards-2.0.x-flow-codex.ndjson
wget https://repository.alcloud.com.br/fs/arquivos/alflow/dashboards/flow/dashboards-2.0.x-flow-ecs.ndjson
wget https://repository.alcloud.com.br/fs/arquivos/alflow/dashboards/flow/dashboard-alcloud-cdn.ndjson
wget https://repository.alcloud.com.br/fs/arquivos/alflow/dashboards/flow/filtro-de-cdns.ndjson
wget https://repository.alcloud.com.br/fs/arquivos/alflow/dashboards/flow/Advanced-Settings.ndjson
wget https://repository.alcloud.com.br/fs/arquivos/alflow/dashboards/flow/interfaceuplink-donut.ndjson
wget https://repository.alcloud.com.br/fs/arquivos/alflow/dashboards/flow/DASHBOARD-ALFLOW-CDN-2.0.ndjson
sleep 1
curl -XPOST "http://admin:admin@127.0.0.1:5601/api/saved_objects/_import?overwrite=true" -k -H "osd-xsrf: true" -H "securitytenant: global" --form file=@dashboards-2.0.x-flow-ecs.ndjson
sleep 1
curl -XPOST "http://admin:admin@127.0.0.1:5601/api/saved_objects/_import?overwrite=true" -k -H "osd-xsrf: true" -H "securitytenant: global" --form file=@dashboards-2.0.x-flow-codex.ndjson
sleep 1
curl -XPOST "http://admin:admin@127.0.0.1:5601/api/saved_objects/_import?overwrite=true" -k -H "osd-xsrf: true" -H "securitytenant: global" --form file=@dashboards-1.0.x-flow-ecs.ndjson
sleep 1
curl -XPOST "http://admin:admin@127.0.0.1:5601/api/saved_objects/_import?overwrite=true" -k -H "osd-xsrf: true" -H "securitytenant: global" --form file=@dashboards-1.0.x-flow-codex.ndjson
sleep 1
curl -XPOST "http://admin:admin@127.0.0.1:5601/api/saved_objects/_import?overwrite=true" -k -H "osd-xsrf: true" -H "securitytenant: global" --form file=@dashboard-alcloud-cdn.ndjson
sleep 1
curl -XPOST "http://admin:admin@127.0.0.1:5601/api/saved_objects/_import?overwrite=true" -k -H "osd-xsrf: true" -H "securitytenant: global" --form file=@filtro-de-cdns.ndjson
sleep 1
curl -XPOST "http://admin:admin@127.0.0.1:5601/api/saved_objects/_import?overwrite=true" -k -H "osd-xsrf: true" -H "securitytenant: global" --form file=@Advanced-Settings.ndjson
sleep 1
curl -XPOST "http://admin:admin@127.0.0.1:5601/api/saved_objects/_import?overwrite=true" -k -H "osd-xsrf: true" -H "securitytenant: global" --form file=@interfaceuplink-donut.ndjson
sleep 1
curl -XPOST "http://admin:admin@127.0.0.1:5601/api/saved_objects/_import?overwrite=true" -k -H "osd-xsrf: true" -H "securitytenant: global" --form file=@DASHBOARD-ALFLOW-CDN-2.0.ndjson


sleep 5
####################################################
# INSTALACAO DO POSTFIX PARA NOTIFICACAO VIA EMAIL #
####################################################
apt-get install postfix mailutils -y
mkdir postfix
cd postfix
wget https://repository.alcloud.com.br/fs/arquivos/alflow/siem/postfix/main.cf
wget https://repository.alcloud.com.br/fs/arquivos/alflow/siem/postfix/sasl_passwd
wget https://repository.alcloud.com.br/fs/arquivos/alflow/siem/postfix/sasl_passwd.db
cp main.cf /etc/postfix/
cp sasl_passwd /etc/postfix/
cp sasl_passwd.db /etc/postfix/
sudo chmod 0600 /etc/postfix/sasl_passwd /etc/postfix/sasl_passwd.db
sudo postmap /etc/postfix/sasl_passwd
sudo systemctl restart postfix
#TESTANDO ENVIO DE EMAIL E TELEGRAM(AQUI VOCE COLOCA O SEU EMAIL E O ID DO GRUPO DO TELEGRAM)
echo "AL-FLOW Instalado com sucesso." | mail -s "Instalacao AL-FLOW" bergnogueira1991@gmail.com
curl --location 'https://api.telegram.org/bot1814036548:AAEyKl5ifomRT4LiUDY_hPs80q7VDYs5cLU/sendMessage?text=%F0%9D%97%94%F0%9D%97%9F%F0%9D%97%99%F0%9D%97%9F%F0%9D%97%A2%F0%9D%97%AA%20-%20%F0%9D%97%94%F0%9D%97%9F%F0%9D%97%A6%F0%9D%97%A2%F0%9D%97%9F%F0%9D%97%A8%F0%9D%97%96%F0%9D%97%A2%F0%9D%97%98%F0%9D%97%A6%20%E2%9C%85%0AINSTALCAO%20CONCLUIDA%F0%9F%A5%B3&chat_id=-1001433339691'

sleep 5
#############################
# ATUALIZANDO GEOIP MAXMIND #
#############################
cd /etc/elastiflow/maxmind
wget https://git.io/GeoLite2-ASN.mmdb
wget https://git.io/GeoLite2-City.mmdb
wget https://git.io/GeoLite2-Country.mmdb

sleep 5
#######################
# ATUALIZANDO CRONTAB #
#######################
echo '*/1 * * * * /bin/bash /opt/init-opensearch.sh' >> /etc/crontab
cd /opt
wget https://repository.alcloud.com.br/fs/arquivos/alflow/init-opensearch.sh
chmod +x init-opensearch.sh

##############
# HORA CERTA #
##############
apt install chrony -y
#EXECULTE ISSO MANUALMENTE 
#DIRETORIO: /etc/chrony/chrony.conf
#COMENTE: pool 2.debian.pool.ntp.org iburst
#ADD: server a.st1.ntp.br iburst nts
#ADD: server b.st1.ntp.br iburst nts
#ADD: server c.st1.ntp.br iburst nts
#ADD: server d.st1.ntp.br iburst nts

systemctl restart chronyd.service
chronyc sourcestats
chronyc sources

##################################
#INSTALACAO-NETDATA-MONITORAMENTO#
##################################
sudo useradd -r -s /usr/sbin/nologin netdata
wget -O /tmp/netdata-kickstart.sh https://get.netdata.cloud/kickstart.sh && sh /tmp/netdata-kickstart.sh
#REINSTALAR
#wget -O /tmp/netdata-kickstart.sh https://get.netdata.cloud/kickstart.sh && sh /tmp/netdata-kickstart.sh --reinstall
#REMOVER
#wget -O /tmp/netdata-kickstart.sh https://get.netdata.cloud/kickstart.sh && sh /tmp/netdata-kickstart.sh --reinstall-clean

#CONFIG MANUALMENTE
#DIRECTORY: /lib/systemd/system/netdata.service
#MUDE netdata PARA root SEGUE EXEMPLO ABAIXO
#ExecStartPre=/bin/chown -R root /opt/netdata/var/cache/netdata
#ExecStartPre=/bin/chown -R root /run/netdata

#ALERT VIA TELEGRAM
#Directory: /opt/netdata/etc/netdata ou /etc/netdata/
#COMANDO: ./edit-config health_alarm_notify.conf
#TOKEN DO TELEGRAM
#TELEGRAM_BOT_TOKEN="1814036548:AAEyKl5ifomRT4LiUDY_hPs80q7VDYs5cLU"
#GRUPO DO TELEGRAM QUE VAI RECEBER A MENSSAGEM 
#DEFAULT_RECIPIENT_TELEGRAM="-1001433339691"
systemctl stop netdata
systemctl start netdata

sleep 10
#############################################
# REINICIANDO PARA CONLCUIR TODA INSTALACAO #
#############################################
/sbin/reboot
