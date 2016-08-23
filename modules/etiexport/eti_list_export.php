<?php

$module = $Params['Module'];
$http = eZHTTPTool::instance();

try {

    if (!$http->hasVariable('query')) {
        throw new Exception('Query not found');
    }

    $csv = new PatEtiDichiarazioneImpresaCsv($http->variable('query'));
    $csv->download();

} catch (Exception $e) {

    echo $e->getMessage();
    eZExecution::cleanExit();

}
