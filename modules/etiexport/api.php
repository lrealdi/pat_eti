<?php
/**
 * Modulo clone di https://github.com/OpencontentCoop/ocopendata/blob/version2/modules/opendata/api.php
 * creato per lavorare con la versione 2.4.6 dell'estensione ocopendata
 */

use Opencontent\Opendata\Api\EnvironmentLoader;
use Opencontent\Opendata\Api\ContentBrowser;
use Opencontent\Opendata\Api\ContentRepository;
use Opencontent\Opendata\Api\ContentSearch;
use Opencontent\Opendata\Api\ClassRepository;

$Module = $Params['Module'];
$Environment = $Params['Environment'];
$Action = $Params['Action'];
$Param = isset( $_GET['q'] ) ? urldecode($_GET['q']) : $Params['Param'];

$Debug = isset( $_GET['debug'] );

try
{
    $contentRepository = new ContentRepository();
    $contentBrowser = new ContentBrowser();
    $contentSearch = new ContentSearch();
    $classRepository = new ClassRepository();

    if ( $Environment == 'classes' ){
        $data = (array) $classRepository->load($Action);
    }
    else
    {
        $currentEnvironment = EnvironmentLoader::loadPreset( $Environment );
        $contentRepository->setEnvironment( $currentEnvironment );
        $contentBrowser->setEnvironment( $currentEnvironment );
        $contentSearch->setEnvironment( $currentEnvironment );

        $parser = new ezpRestHttpRequestParser();
        $request = $parser->createRequest();
        $currentEnvironment->__set('request', $request);

        $data = array();

        if ( $Action == 'read' )
        {
            $data = (array)$contentRepository->read( $Param );
        }
        elseif ( $Action == 'search' )
        {
            $data = (array)$contentSearch->search( $Param );
        }
    }
}
catch( Exception $e )
{
    $data = array(
        'error_code' => $e->getCode(),
        'error_message' => $e->getMessage()
    );
    if ( $Debug )
    {
        $data['trace'] = $e->getTraceAsString();
    }
}
if ( $Debug )
{
    echo '<pre>';
    print_r( $data );
    echo '</pre>';
    eZDisplayDebug();
}
else
{
    header('Content-Type: application/json');
    echo json_encode( $data );
}

eZExecution::cleanExit();