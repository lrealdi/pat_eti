<?php

$id = $Params['ID'];
$tpl = eZTemplate::factory();
$tpl->setVariable('object_id', $id);
echo $tpl->fetch('design:parts/dichiarazione/marker_popup.tpl');
eZExecution::cleanExit();