curl -X POST -H "Content-Type: application/json" -d '{
    "routerIp": "172.28.29.1",
    "routerUsername": "alflow",
    "routerPassword": "alflow",
    "port": 5555,
    "action": "add",
    "comment": "ALFLOW-RAW-DROP-ATACK",
    "dst-address-list": "ALFLOW_Blocked_IPs",
    "dst-port": "53",
    "protocol": "udp"
}' http://127.0.0.1:7771/mikrotik/preload-script-mikrotik.php
