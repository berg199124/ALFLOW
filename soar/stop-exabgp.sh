#!/bin/bash

if pgrep -x exabgp >/dev/null
then
echo "CONTAINER DO EXABGP ESTA SENDO EXECULTADO."
sleep 30
docker stop exabgp
echo "CONTAINER DO EXABGP FOI PARADO."
else
echo "CONTAINER DO EXABGP ESTA PARADO."
fi
