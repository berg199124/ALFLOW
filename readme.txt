#################################
# RECOMENDADMOS USO DO DEBIAN 11#
#################################

############################################
# USE O NPM PARA DEIXA O AMBIENTE-WEB HTTPS#
############################################

#####################
# TIMER DATA E HORAS#
#####################
timedatectl
timedatectl list-timezones
sudo timedatectl set-timezone America/Fortaleza
timedatectl

##########################
# SCRIPT PRELOAD MIKROTIK#
##########################
/ip firewall raw
add action=drop chain=prerouting comment=ALFLOW-RAW-DROP-ATACK src-address-list=ALFLOW_Blocked_IPs dst-port=17,19,53,69,111,123,137,161,389,520,751,1434,1645,1646,1812 protocol=udp
add action=drop chain=prerouting comment=ALFLOW-RAW-DROP-ATACK src-address-list=ALFLOW_Blocked_IPs dst-port=17,19,53,69,111,123,137,161,389,520,751,1434,1645,1646,1812 protocol=tcp
add action=drop chain=prerouting comment=ALFLOW-RAW-DROP-ATACK src-address-list=ALFLOW_Blocked_IPs dst-port=1813,1900,3702,5093,5353,11211,27015,27960 protocol=udp
add action=drop chain=prerouting comment=ALFLOW-RAW-DROP-ATACK src-address-list=ALFLOW_Blocked_IPs dst-port=1813,1900,3702,5093,5353,11211,27015,27960 protocol=tcp
add action=drop chain=prerouting comment=ALFLOW-RAW-DROP-ATACK src-address-list=ALFLOW_Blocked_IPs dst-port=21,22,23,8192,1494,3389,5900,5901,5902,5903,5904 protocol=udp
add action=drop chain=prerouting comment=ALFLOW-RAW-DROP-ATACK src-address-list=ALFLOW_Blocked_IPs dst-port=21,22,23,8192,1494,3389,5900,5901,5902,5903,5904 protocol=tcp

###########################
# PARA TESTA ATACK DE ICMP#
###########################
#apt-get install hping3 -y
#sudo hping3 -1 --flood <endereço_IP_do_alvo>

################################
# PARA TESTA ATACK FLOOD TELNET#
################################
#ADD ARQUIVO telnet_flood.sh
#!/bin/bash

# Define a quantidade de conexões a serem feitas
num_connections=1000

# Loop para abrir múltiplas conexões Telnet
for ((i=1; i<=$num_connections; i++)); do
    # Conecta-se ao servidor Telnet
    telnet <endereço_IP_servidor> &
done

#chmod +x telnet_flood.sh
#./telnet_flood.sh


#####################################
# CRIANDO REPOSITORIO PARA SNAPSHOTS#
#####################################
#echo 'path.repo: ["/mnt/snapshots"]' >> /etc/opensearch/opensearch.yml
#mkdir /mnt/snapshots
chmod 7777 /mnt/snapshots/
#/sbin/reboot

#Snapshot Management
#Repositories
#Repository name:repository-bkp-opensearch
#Repository type: Shared file system
#Location: /mnt/snapshots

#Snapshots
#Create snapshot
#Snapshot name: bkp-op-dia-mes-ano
#Select or input source indexes or index patterns: op*
#Select a repository for snapshots: repository-bkp-opensearch 

#EXECULTE DENTRO DO OPENSEARCH DET-TOOLS
PUT /_snapshot/repositorio_local
{
  "type": "fs",
  "settings": {
    "location": "/mnt/snapshots"
  }
}

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

######################
# LOG-ROTATION 7 DIAS#
######################
#Policy ID: LOG-ROTATION-7DIAS
#Description: ROTATIONA OS LOG DO INDEX ELASTIFLOW POR 7 DIAS

#Index patterns:elastiflow-flow-codex-*
#Priority: 100

#States (2)
#Initial state: HOT

#State name: HOT
#Add before: DELETE
#Transitions: Minimum index age is 7d
#Destination state: DELETE
#Condition: Minimum Index Age
#Minimum index age: 7d

#State name: DELETE
#Add after: HOT
#Actions: Delete
#Action type: Delete
#Retry count: 3
#Retry backoff: Exponential
#Retry delay: 1m

##################################################
# O ANUNCIO DO EXABGP PARA AUTOMATICAMENTE EM 30M#
##################################################
#PARA PARAR MANUALMENTE EXECULTER A TRIGGERS EXEC-STOP-ANUNCIOS-EXABGP DENTRO DO ALERTA ALFLOW-EXEC-SOAR
#PARA DEIXAR OS ANUNCIOS BGP PERMANEMTEMENTE COMENTE A LINHA 'docker stop exabgp' DENTRO DE /opt/stop-exabgp.sh

####################################################################
# CRIANDO ALERTAS MANUALMENTE PARA EXECULTAR TAREFAS DO ALFLOW-SOAR#
####################################################################
NOME: ALFLOW-EXEC-SOAR
FREQUENCY: 900days
INDEX: elastiflow-flow-codex-1.5-*
Time Field: flow.collect.timestamp

###### QUERY ######
Metrics: COUNT OF documents
Time range for the last: 1m

###### Triggers01 ######
Trigger name: EXEC-STOP-ANUNCIOS-EXABGP
Trigger condition: IS ABOVE > 100000000

###### Actions 1 ######
Action name: ACTION-STOP-ANUNCIOS-EXABGP
Channels: [Channel] STOP-SOAR-EXABGP
Message: none

###### Triggers02 ######
Trigger name: EXEC-SCRIPT-PRELOAD-MIKROTIK
Trigger condition: IS ABOVE > 100000000

###### Actions 1 ######
Action name: SEND-SCRIPT-PRELOAD-MIKROTIK-ADD
Channels: [Channel] SEND-SCRIPT-PRELOAD-MIKROTIK
Message: 
 {
    "action": "add",
    "comment": "ALFLOW-RAW-DROP-ATACK",
    "dst-address-list": "ALFLOW_Blocked_IPs",
    "dst-port": "53",
    "protocol": "udp"
}

###### Actions 2 ######
Action name: SEND-SCRIPT-PRELOAD-MIKROTIK-DELETE
Channels: [Channel] SEND-SCRIPT-PRELOAD-MIKROTIK
Message:
{
    "action": "delete"
}

##########################################################
# CRIANDO ALERTAS PARA VOLUMETRIA DE PACOTES POR SEGUNDOS#
##########################################################
NOME: ALERT-FLOW-OVERLOAD-TRAFIC-PPS
FREQUENCY: 1m
INDEX: elastiflow-flow-codex-1.5-*
Time Field: flow.collect.timestamp

###### QUERY ######
Metrics: COUNT OF flow.packets
Time range for the last: 1m
Data filter: flow.packets is greater than 1000

###### Triggers ######
Trigger name: TRG-ALERT-OVERLOAD-TRAFIC-PPS
Trigger condition: IS ABOVE > 8500
# AQUI VOCE COLOCA A MEDIA DE PACOTES TRAFEGANDO NA SUA REDE POR SEGUNDOS.

###### Actions 1 ######
Action name: ACTION-SEND-SOAR-EXABGP
Channels: [Channel] SEND-SOAR-EXABGP
Message: none
###### Actions 2 ######
Action name: ACTION-SEND-EMAIL-POSTFIX
Channels: [Channel] SEND-EMAIL-POSTFIX
Message subject: ALFLOW - Ação de notificação de alerta (NOME-DO-ISP)
Message:
🔴 ALERT - ALFLOW 🔴
Monitor ALERT-FLOW-OVERLOAD-TRAFIC-PPS acabou de entrar no status de alerta. Por favor, investigue o problema.
  - Trigger: {{ctx.trigger.name}}
  - Gravidade: {{ctx.trigger.severity}}
  - Início do período: {{ctx.periodStart}}
  - Fim do período: {{ctx.periodEnd}}
🟢 𝗔𝗟𝗙𝗟𝗢𝗪 - 𝗔𝗟𝗦𝗢𝗟𝗨𝗖𝗢𝗘𝗦 🟢
Fone: (85) 981355252
Email: lindemberg@allnettelecom.com.br
###### Actions 3 ######
Action name: ACTION-SEND-TELEGRAM
Channels: [Channel] SEND-TELEGRAM
Message:
{
   "text": " 🔴 ALERT - ALFLOW 🔴 (NOME-DO-ISP)
Monitor ALERT FLOW OVERLOAD TRAFIC PPS acabei de entrar no status de alerta. Investigue o problema.

ALERT OVERLOAD TRAFIC PPS
  - Gravidade: {{ctx.trigger.severity}}
  - Início do período: {{ctx.periodStart}}
  - Fim do período: {{ctx.periodEnd}}
🟢 𝗔𝗟𝗙𝗟𝗢𝗪 - 𝗔𝗟𝗦𝗢𝗟𝗨𝗖𝗢𝗘𝗦 🟢
Fone: (85) 981355252
Email: lindemberg@allnettelecom.com.br",
   "chat_id": "-1001433339691"
}
#OBS: NESSE CAMPO CHAT_ID COLOQUEI O ID DO SEU GRUPO DO TELEGRAM PARA SER ENVIANDO A NOTIFICACAO PARA ELE

#####################################
# CRIANDO NOTIFICACOES SOAR MIKROTIK#
#####################################
NOME:SEND-SOAR-MIKROTIK
TIPO: WEBHOOK
METODO: POST
URL: http://127.0.0.1:7771/mikrotik/script-mikrotik.php

NOME:SEND-SCRIPT-PRELOAD-MIKROTIK
TIPO: WEBHOOK
METODO: POST
URL: http://127.0.0.1:7771/mikrotik/preload-script-mikrotik.php

###################################
# CRIANDO NOTIFICACOES SOAR-EXABGP#
###################################
NOME:SEND-SOAR-EXABGP
TIPO: WEBHOOK
METODO: POST
URL: http://127.0.0.1:5555/containers/exabgp/start

NOME:STOP-SOAR-EXABGP
TIPO: WEBHOOK
METODO: POST
URL: http://127.0.0.1:5555/containers/exabgp/stop

################################
# CRIANDO NOTIFICACOES TELEGRAM#
################################
NOME:SEND-TELEGRAM
TIPO: WEBHOOK
METODO: POST
URL: https://api.telegram.org/SEU-TOKEN/sendMessage?
#OBS: AQUI VOCE COLOCA O SEU TOKEN DO TELEGRAM 

#############################
# CRIANDO NOTIFICACOES EMAIL#
#############################
NOME:SEND-EMAIL-POSTFIX
CHANNEL: EMAIL
SMTP: server-email-postfix
Default recipients: [O-EMAIL-DO-DESTINATARIO]

#Create SMTP sender
NOME: server-email-postfix
EMAIL: SEU-EMAIL@gmail.com
HOST: 127.0.0.1
PORTA: 25
TLS: None

#######################################
# RELATORIOS AGENDADOS OU SOBREDEMANDA#
#######################################

NOME: REPORT-24HORAS-DNS
TIMESTAMP: 24HORAS
TIPO: PDF
#####CABECALHO:#########
🟢 𝗔𝗟𝗙𝗟𝗢𝗪 - 𝗔𝗟𝗦𝗢𝗟𝗨𝗖𝗢𝗘𝗦 🟢
**Fone:** (85) 98135-XXXX
**Email:** SEU-EMAIL@gmail.com
**Site:** www.SEU-SITE.com.br

###################################
# Documentacao Exporta Flow Huawei#
###################################
ip netstream as-mode 32
ip netstream timeout active 1
ip netstream timeout inactive 15
ip netstream export version 9 origin-as bgp-nexthop ttl
ip netstream export template sequence-number fixed
ip netstream export index-switch 32
ip netstream export template timeout-rate 1
ip netstream sampler fix-packets 1024 inbound
ip netstream sampler fix-packets 1024 outbound
ip netstream export source [IP-DA-LOOPBACK-DO-HUAWEI]
ip netstream export host [IP-DO-SERVIDOR-ALFLOW] 9995
ip netstream export template option sampler
ip netstream export template option timeout-rate 1
ip netstream export template option application-label

#PARA ADICIONAR DENTRO DE TODAS INTERFACE UPLINK
ip netstream inbound
ip netstream outbound
ipv6 netstream inbound
ipv6 netstream outbound

##################################
# Documentacao Exporta Flow Cisco#
##################################

####################################
# Documentacao Exporta Flow Juniper#
####################################

#####################################
# Documentacao Exporta Flow Mikrotik#
#####################################
/ip traffic-flow set \
    active-flow-timeout=5m \
    inactive-flow-timeout=15 \
    cache-entries=1k \
    enabled=yes 
    interfaces=[INTERFACES_UPSTREAM]

/ip traffic-flow target add \
    dst-address=[IP-DO-SERVIDOR-ALFLOW] \
    port=9995 \
    src-address=[IP-DA-LOOPBACK-DO-MIKROTIK] \
    version=9

#######################################
# TUNNING MANUAL OPENSEARCH-DASHBOARD #
#######################################
DIRETORIO-WEB http://127.0.0.1:5601/app/management/opensearch-dashboards/settings

Pin filters by default: On
Highlight results : Off
Store URLs in session storage: On
Dark mode: On
Day of week: Monday
Formatting locale: Portuguese (Brazil)
Number format: 0,0.[00]
Percent format: 0,0.[00]%
#timepicker:timeDefaults
{
  "from": "now-1h/m",
  "to": "now"
}
#timepicker:quickRanges
[
  {
    "from": "now-15m/m",
    "to": "now/m",
    "display": "Last 15 minutes"
  },
  {
    "from": "now-30m/m",
    "to": "now/m",
    "display": "Last 30 minutes"
  },
  {
    "from": "now-1h/m",
    "to": "now/m",
    "display": "Last 1 hour"
  },
  {
    "from": "now-2h/m",
    "to": "now/m",
    "display": "Last 2 hours"
  },
  {
    "from": "now-4h/m",
    "to": "now/m",
    "display": "Last 4 hours"
  },
  {
    "from": "now-12h/m",
    "to": "now/m",
    "display": "Last 12 hours"
  },
  {
    "from": "now-24h/m",
    "to": "now/m",
    "display": "Last 24 hours"
  },
  {
    "from": "now-48h/m",
    "to": "now/m",
    "display": "Last 48 hours"
  },
  {
    "from": "now-7d/m",
    "to": "now/m",
    "display": "Last 7 days"
  },
  {
    "from": "now-30d/m",
    "to": "now/m",
    "display": "Last 30 days"
  },
  {
    "from": "now-60d/m",
    "to": "now/m",
    "display": "Last 60 days"
  },
  {
    "from": "now-90d/m",
    "to": "now/m",
    "display": "Last 90 days"
  }
]
