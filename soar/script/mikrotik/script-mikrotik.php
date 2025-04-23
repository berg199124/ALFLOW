<?php


// Recupera o JSON enviado via POST

$json = file_get_contents('php://input');


// Decodifica o JSON para um array associativo

$data = json_decode($json, true);


// Verifica se o JSON foi decodificado com sucesso

if ($data === null) {

    // Se o JSON estiver inv�lido, retorna um erro

    http_response_code(400);

    echo json_encode(array("error" => "Invalid JSON"));

    exit();

}


// Verifica se o endere�o IP foi fornecido

if (!isset($data['ip'])) {

    // Se o endere�o IP n�o estiver presente, retorna um erro

    http_response_code(400);

    echo json_encode(array("error" => "IP address not provided"));

    exit();

}


// IP para bloqueio

$ip = $data['ip'];


// Comando para criar a regra de bloqueio no MikroTik

$command = "/ip firewall address-list add list=ALFLOW_Blocked_IPs address=$ip timeout=1d";


// Conex�o SSH com o MikroTik

$ssh = ssh2_connect('172.28.29.1', 5555);


// Autentica��o SSH

ssh2_auth_password($ssh, 'alflow', 'alflow');


// Executa o comando no MikroTik

ssh2_exec($ssh, $command);


// Verifica se houve algum erro durante a execu��o do comando

$error = ssh2_fetch_stream($ssh, SSH2_STREAM_STDERR);


// Se houver erro, retorna um erro

if ($error) {

    http_response_code(500);

    echo json_encode(array("error" => "Failed to execute command on MikroTik"));

    exit();

}


// Se tudo ocorrer bem, retorna sucesso

echo json_encode(array("success" => true));


?>

