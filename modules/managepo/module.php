<?php

$Module = array( 'name' => 'managepo' );

$ViewList = array();

$ViewList['manageposospensione'] = array(
    'functions' => array( 'manageposospensione' ),
    'script' => 'manageposospensione.php',
    'params' => array( 'Action', 'piva_azienda', 'id_ente', 'sospensione', 'node_id'),
    'unordered_params' => array()
);

$FunctionList['manageposospensione'] = array();

?>