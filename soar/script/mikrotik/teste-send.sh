#!/bin/bash
curl -X POST \
-H "Content-Type: application/json" \
-d '{"ip": "192.168.1.100"}' \
http://127.0.0.1:7771/mikrotik/script-mikrotik.php

#EXECULTE DENTRO DO MIKORITK
#/ip firewall raw add action=drop chain=prerouting comment=ALFLOW-RAW-DROP-ATACK dst-address-list=ALFLOW_Blocked_IPs dst-port=53 protocol=udp


#EXECULTE DENTRO DO CONTAINER 
#docker exec -it soar-script /bin/bash 
#apt-get update; 
#apt-get install -y --no-install-recommends curl libssh2-1-dev; 
#pecl install ssh2-1.1.2; 
#docker-php-ext-enable ssh2 
#docker restart soar-script

