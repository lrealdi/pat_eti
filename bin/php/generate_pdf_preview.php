<?php

// php -d memory_limit=-1 extension/pat_eti/bin/php/generate_pdf_preview.php -s008admin

require 'autoload.php';

$script = eZScript::instance(array(
    'description' => ( "Generate pdf preview\n\n" ),
    'use-session' => false,
    'use-modules' => true,
    'use-extensions' => true
));

$script->startup();

$options = $script->getOptions();
$script->initialize();
$script->setUseDebugAccumulators(true);

$cli = eZCLI::instance();

/** @var eZUser $user */
$user = eZUser::fetchByName('admin');
eZUser::setCurrentlyLoggedInUser($user, $user->attribute('contentobject_id'));

try {

    eZDir::mkdir(eZSys::cacheDirectory() . "/temp/");

    $imageINI = eZINI::instance('image.ini');
    $executableConvert = $imageINI->variable('ImageMagick', 'ExecutablePath') . '/' . $imageINI->variable('ImageMagick',
            'Executable');

    /** @var eZContentObjectTreeNode[] $dichiarazioni */
    $dichiarazioni = eZContentObjectTreeNode::subTreeByNodeID(
        array(
            'ClassFilterType' => 'include',
            'ClassFilterArray' => array('dichiarazione_impresa'),
        ),
        1
    );

    foreach ($dichiarazioni as $dichiarazione) {
        $cli->warning($dichiarazione->attribute('name'));
        /** @var eZContentObjectAttribute[] $dataMap */
        $dataMap = $dichiarazione->attribute('data_map');
        if (isset( $dataMap['pdf'] ) && isset( $dataMap['pdf_preview'] )) {
            /** @var eZBinaryFile $pdf */
            $pdf = $dataMap['pdf']->content();
            if ($pdf instanceof eZBinaryFile) {
                $filePath = $pdf->attribute('filepath');
                $fileHandler = eZClusterFileHandler::instance($filePath);
                if ($fileHandler->exists()) {
                    $fetchedFilePath = $fileHandler->fetchUnique();
                    $imageName = str_replace('.pdf', '.jpg', basename($fetchedFilePath));
                    $target = eZSys::cacheDirectory() . "/temp/" . $imageName;
                    $cmd = "$executableConvert -density 300 {$filePath}[0] $target";
                    $out = shell_exec($cmd);
                    $cli->notice($cmd);
                    //$cli->notice($out);
                    if (file_exists($target)){
                        $dataMap['pdf_preview']->fromString($target);
                        $dataMap['pdf_preview']->store();
                    }
                    unlink($target);
                    $fileHandler->fileDeleteLocal($fetchedFilePath);
                }
            }
        }
    }

    $script->shutdown();
} catch (Exception $e) {
    $errCode = $e->getCode();
    $errCode = $errCode != 0 ? $errCode : 1; // If an error has occured, script must terminate with a status other than 0
    $script->shutdown($errCode, $e->getMessage());
}
