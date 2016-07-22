<?php

$Module = array( 'name' => 'etiexport' );

$ViewList = array();

$ViewList['eti_list_export'] = array(
    'script'					=>	'eti_list_export.php',
    'params'					=> 	array(),
    'unordered_params'			=> 	array(),
    'single_post_actions'		=> 	array(),
    'post_action_parameters'	=> 	array()
);

$ViewList['marker_popup'] = array(
    'script'					=>	'marker_popup.php',
    'params'					=> 	array('ID'),
    'unordered_params'			=> 	array(),
    'single_post_actions'		=> 	array(),
    'post_action_parameters'	=> 	array()
);
$ViewList['api'] = array(
    'functions' => array( 'api' ),
    'script' => 'api.php',
    'params' => array( 'Environment', 'Action', 'Param' ),
    'unordered_params' => array()
);

$FunctionList = array();
$FunctionList['api'] = array();

?>