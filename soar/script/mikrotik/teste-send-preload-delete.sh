#!/bin/bash
curl -X POST -H "Content-Type: application/json" -d '{
    "action": "delete"
}' http://127.0.0.1:7771/mikrotik/preload-script-mikrotik.php
