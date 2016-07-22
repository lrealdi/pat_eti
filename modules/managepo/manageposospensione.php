<?php

$tpl = eZTemplate::factory();
$module = $Params['Module'];
$action = $Params['Action'];
$piva_azienda = $Params['piva_azienda'];
$id_ente = $Params['id_ente'];
$sospensione = $Params['sospensione'];
$node_id = $Params['node_id'];
if ($sospensione != 1)
{
	$sospensione = 1;
}

if (isset($piva_azienda) && isset($id_ente))
{ 
    if ( $action == 'insert' )
    {
		$newrecfields = array( 'piva_azienda' => $piva_azienda, 'id_ente' => $id_ente, 'sospensione' => $sospensione);
		$simpleObj = SospensioniPObject::create( $newrecfields );
		$simpleObj->store();
    }
    elseif ( $action == 'delete' )
    {
		$cond = array( 'piva_azienda' => $piva_azienda, 'id_ente' => $id_ente);
		eZPersistentObject::removeObject( SospensioniPObject::definition(), $cond );
    }
    
    $tabid = 'tab-enti';
    //$tpl->setVariable( "tabid", $tabid );
	//$Result['content'] = $tpl->fetch( 'design:override/full/dichiarazione.tpl' );
	$node = eZContentObjectTreeNode::fetch($node_id);
	$url = $node->attribute('url_alias');
	$module->redirectTo( $url.'/(tabid)/'.$tabid );
}
