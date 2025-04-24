from flask import Flask, request
import subprocess

app = Flask(__name__)

# Rota que recebe os argumentos IP e tempo e executa o script .sh
@app.route('/execute-exabgp', methods=['POST'])
def execute_exabgp():
    data = request.get_json()
    ip = data.get('ip')
    tempo = data.get('tempo')

    if not ip or not tempo:
        return "Erro: IP ou tempo não fornecido.", 400

    try:
        # Comando para executar o script shell com os parâmetros recebidos
        result = subprocess.run(['./send-exabgp.sh', ip, str(tempo)], capture_output=True, text=True)

        # Retorna a saída do comando
        return f"Comando executado com sucesso:\n{result.stdout}", 200

    except subprocess.CalledProcessError as e:
        return f"Erro ao executar o comando:\n{e}", 500

if __name__ == '__main__':
    app.run(host='127.0.0.1', port=5000)