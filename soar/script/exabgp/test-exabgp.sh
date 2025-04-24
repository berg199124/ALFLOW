curl -X POST http://127.0.0.1:5000/execute-exabgp \
     -H "Content-Type: application/json" \
     -d '{"ip": "7.7.7.7/32", "tempo": "10"}'