<?php


// Configurações do MikroTik

$routerIp = '172.28.29.1';

$routerUsername = 'alflow';

$routerPassword = 'alflow';

$apiPort = 5556; // Porta da API


// Função para adicionar regra no MikroTik via SSH

function addFirewallRule($ip, $username, $password, $rule) {

    $command = "/ip firewall raw add action=drop chain=prerouting comment={$rule['comment']} dst-address-list={$rule['dst-address-list']} dst-port={$rule['dst-port']} protocol={$rule['protocol']}";


    $connection = ssh2_connect($ip, 5555);

    if (!$connection) {

        return false;

    }


    if (!ssh2_auth_password($connection, $username, $password)) {

        return false;

    }


    $stream = ssh2_exec($connection, $command);

    stream_set_blocking($stream, true);

    $response = stream_get_contents($stream);

    fclose($stream);


    return $response;

}


// Função para deletar regra no MikroTik via SSH

function deleteFirewallRule($ip, $username, $password, $comment) {

    $command = "/ip firewall raw remove [find comment={$comment}]";


    $connection = ssh2_connect($ip, 5555);

    if (!$connection) {

        return false;

    }


    if (!ssh2_auth_password($connection, $username, $password)) {

        return false;

    }


    $stream = ssh2_exec($connection, $command);

    stream_set_blocking($stream, true);

    $response = stream_get_contents($stream);

    fclose($stream);


    return $response;

}


// Recebendo dados JSON

$data = json_decode(file_get_contents('php://input'), true);


if ($data) {

    if ($data['action'] == 'add') {

        $rule = array(

            'comment' => 'ALFLOW-RAW-DROP-ATACK',

            'dst-address-list' => 'ALFLOW_Blocked_IPs',

            'dst-port' => '53',

            'protocol' => 'udp'

        );


        $result = addFirewallRule($routerIp, $routerUsername, $routerPassword, $rule);


        if ($result !== false) {

            echo "Regra adicionada com sucesso. Saída do comando SSH: " . $result;

        } else {

            echo "Erro ao adicionar a regra via SSH.";

        }

    } elseif ($data['action'] == 'delete') {

        $result = deleteFirewallRule($routerIp, $routerUsername, $routerPassword, 'ALFLOW-RAW-DROP-ATACK');


        if ($result !== false) {

            echo "Regra removida com sucesso. Saída do comando SSH: " . $result;

        } else {

            echo "Erro ao remover a regra via SSH.";

        }

    }

} else {

    echo "Nenhum dado recebido.";

}


?>

