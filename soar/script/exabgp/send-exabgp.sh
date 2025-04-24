#!/bin/bash

# Verifica se o prefixo foi passado como argumento
#if [ -z "$1" ]; then
#  echo "Erro: Nenhum prefixo fornecido."
#  echo "Uso: $0 <prefixo>"
#  exit 1
#fi

# Define o prefixo com o primeiro argumento
PREFIXO=$1
TIME=$2

# Anunciar o prefixo
echo "Anunciando a rota $PREFIXO"
curl -X POST http://127.0.0.1:6660/announce -d "
announce route $PREFIXO next-hop 45.232.138.10
"

# Esperar por 1 hora (3600 segundos)
sleep $TIME

# Remover o prefixo após 1 hora
echo "Removendo a rota $PREFIXO"
curl -X POST http://127.0.0.1:6660/withdraw -d "
withdraw route $PREFIXO next-hop 45.232.138.10
"