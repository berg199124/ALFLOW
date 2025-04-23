#!/bin/bash

#################################
# RECOMENDADMOS USO DO DEBIAN 11#
#################################

############################################################
# PRECISA ESTABELECER UM PEER BGP COM O CONTAINER DO EXABGP#
############################################################

#LADO DO ROTEADOR BGP
# neighbor [IP-DO-SERVIDOR-ALFLOW]
# REMOTE-ASN-ALFLOW: 65001
# POLITICA DE FILTROS IN: ACEITA TUDO
# POLITICA DE FILTROS OUT: NAO ANUNCIA NADA

#LADO DO EXABGP
# neighbor [IP-DO-ROTEADOR-BGP] {
# 	router-id [IP-DO-SERVIDOR-ALFLOW];
# 	local-as 65001;
# 	peer-as [ASN-DO-ROTEADOR-BGP];
# 
# 	api services {
# 		processes [ watch-loghost, watch-mailhost ];
# 	}
# }
# 
# process watch-loghost {
# 	encoder text;
# 	run python -m exabgp healthcheck --cmd "nc -z -w2 -u localhost 514" --no-syslog --label loghost --withdraw-on-down --ip [PREFIXO-QUE-DESEJA-ANUNCIAR-VIA-BGP];
# }
# 
# process watch-mailhost {
# 	encoder text;
# 	run python -m exabgp healthcheck --cmd "nc -z -w2 localhost 25" --no-syslog --label mailhost --withdraw-on-down --ip [PREFIXO-QUE-DESEJA-ANUNCIAR-VIA-BGP];
# }

#######################
# ATUALIZANDO O LINUX #
#######################
apt-get update
apt-get install curl git -y

######################################
# INSTALANDO DOCKER E DOCKER-COMPOSE #
######################################
curl -fsSL https://get.docker.com -o get-docker.sh
sh get-docker.sh
apt-get install docker-compose -y

#####################################
# EXECULTANDO CONTAINER ALFLOW-SOAR #
#####################################
docker run -d --name exabgp -p 179:179 --cap-add=NET_ADMIN --net=host -v exabgp-conf:/usr/etc/exabgp mikenowak/exabgp
docker stop exabgp

#######################
# CONFIGURANDO EXABGP #
#######################
# ARQUIVO .CONF EXABGP
#nano /var/lib/docker/volumes/exabgp-conf/_data/exabgp.conf
wget https://repository.alcloud.com.br/fs/arquivos/alflow/soar/exabgp.conf
wget https://repository.alcloud.com.br/fs/arquivos/alflow/soar/stop-exabgp.sh
mv exabgp.conf /var/lib/docker/volumes/exabgp-conf/_data/
cp stop-exabgp.sh /opt/
chmod +x /opt/stop-exabgp.sh
echo '*/1 * * * * /bin/bash /opt/stop-exabgp.sh' >> /etc/crontab
# ADD '*/1 * * * * /bin/bash /opt/stop-exabgp.sh' dentro da 'crontab' 

#################################
# MODIFICACOES MANUAL NO DOCKER #
#################################
#ADICIONAR LINHAS ABAIXO DENTRO DO ARQUIVO /lib/systemd/system/docker.service
#ExecStart=/usr/sbin/dockerd -H fd:// --containerd=/run/containerd/containerd.sock (ESSA LINHA FICA COMENTADA)
#ExecStart=/usr/sbin/dockerd -H fd:// -H=tcp://0.0.0.0:5555
## OBS: PODE SER BIN OU SBIN ##

####################################
# RESTART APOS MODIFICACOES MANUAL #
####################################
sudo service docker restart 
sudo service docker stop
sudo service docker start
systemctl daemon-reload

#############################
# TESTANDO STATUS CONTAINER #
#############################
#curl --data "t=1" http://127.0.0.1:5555/containers/exabgp/stop
#curl --data "t=1" http://127.0.0.1:5555/containers/exabgp/start
docker ps -a

###################################
#EXECULTANDO CONTAINER SOAR-SCRIPT#
###################################
wget --mirror https://repository.alcloud.com.br/fs/arquivos/alflow/soar/script/
cd repository.alcloud.com.br/fs/arquivos/alflow/soar/
mv script /opt/
docker run -d -p 7771:80 --restart always --name soar-script -v "/opt/script/":/var/www/html php:7.2-apache 
sleep 10

#TESTA API JSON DO CONTAINER SOAR-MIKROTIK
curl 127.0.0.1:7771/mikrotik/script-mikrotik.php

#EXECULTE DENTRO DO CONTAINER

#docker exec -it soar-script /bin/bash
#apt-get update;
#apt-get install -y --no-install-recommends libssh2-1-dev;
#pecl install ssh2-1.1.2;
#docker-php-ext-enable ssh2
#docker restart soar-script

#EXECULTE DENTRO DO MIKORITK ( DESCONTINUADO )
#/ip firewall raw add action=drop chain=prerouting comment=ALFLOW-RAW-DROP-ATACK dst-address-list=ALFLOW_Blocked_IPs dst-port=53 protocol=udp
#/ip firewall raw add action=drop chain=prerouting comment=ALFLOW-RAW-DROP-ATACK dst-address-list=ALFLOW_Blocked_IPs dst-port=17,19,53,69,111,123,137,161,389,520,751,1434,1645,1646,1812 protocol=udp
#/ip firewall raw add action=drop chain=prerouting comment=ALFLOW-RAW-DROP-ATACK dst-address-list=ALFLOW_Blocked_IPs dst-port=1813,1900,3702,5093,5353,11211,27015,27960 protocol=udp

#EXECULTE DENTRO DO MIKORITK
/ip firewall raw
add action=drop chain=prerouting comment=ALFLOW-RAW-DROP-ATACK src-address-list=ALFLOW_Blocked_IPs dst-port=17,19,53,69,111,123,137,161,389,520,751,1434,1645,1646,1812 protocol=udp
add action=drop chain=prerouting comment=ALFLOW-RAW-DROP-ATACK src-address-list=ALFLOW_Blocked_IPs dst-port=17,19,53,69,111,123,137,161,389,520,751,1434,1645,1646,1812 protocol=tcp
add action=drop chain=prerouting comment=ALFLOW-RAW-DROP-ATACK src-address-list=ALFLOW_Blocked_IPs dst-port=1813,1900,3702,5093,5353,11211,27015,27960 protocol=udp
add action=drop chain=prerouting comment=ALFLOW-RAW-DROP-ATACK src-address-list=ALFLOW_Blocked_IPs dst-port=1813,1900,3702,5093,5353,11211,27015,27960 protocol=tcp
add action=drop chain=prerouting comment=ALFLOW-RAW-DROP-ATACK src-address-list=ALFLOW_Blocked_IPs dst-port=21,22,23,8192,1494,3389,5900,5901,5902,5903,5904 protocol=udp
add action=drop chain=prerouting comment=ALFLOW-RAW-DROP-ATACK src-address-list=ALFLOW_Blocked_IPs dst-port=21,22,23,8192,1494,3389,5900,5901,5902,5903,5904 protocol=tcp
