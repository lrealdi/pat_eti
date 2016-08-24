{def $openpa = object_handler($node)}
{set-block scope=root variable=cache_ttl}0{/set-block}

{if $openpa.content_tools.editor_tools}
  {include uri=$openpa.content_tools.template}
{/if}

{ezscript_require( array( 'leaflet.js') )}
{ezcss_require( array( 'leaflet.css' ) )}

		   {ezscript_require( array( 'ezjsc::jquery', 'leaflet.markercluster.js', 'Leaflet.MakiMarkers.js') )}
		   {ezcss_require( array( 'plugins/leaflet/map.css', 'MarkerCluster.css', 'MarkerCluster.Default.css' ) )}

<ul class="nav nav-tabs">
  <li id="tit_tab-impresa"><a href="#tab-impresa" data-toggle="tab">Impresa</a></li>
  <li id="tit_tab-legale"><a href="#tab-legale" data-toggle="tab">Legale Rappresentante</a></li>
  <li id="tit_tab-sedi"><a href="#tab-sedi" data-toggle="tab">Sedi</a></li>
  <li id="tit_tab-consorzio"><a href="#tab-consorzio" data-toggle="tab">Consorzio</a></li>
  <li id="tit_tab-dipendenti"><a href="#tab-dipendenti" data-toggle="tab">Dipendenti - Soci Lavoratori</a></li>
  <li id="tit_tab-categorie"><a href="#tab-categorie" data-toggle="tab">Categorie</a></li>
  <li id="tit_tab-attivita"><a href="#tab-attivita" data-toggle="tab">Attivit&agrave;</a></li>
  <li id="tit_tab-enti"><a href="#tab-enti" data-toggle="tab">Enti Iscrizione</a></li>
  <li id="tit_tab-altro"><a href="#tab-altro" data-toggle="tab">Altro</a></li>
  <li id="tit_tab-mappa"><a href="#tab-mappa" data-toggle="tab" id="linkmap">Mappa Sedi</a></li>
</ul>

<div class="row">

    {def $pdf_obj = $node.object}
	
	{if not( is_set( $tabid ) )}
		{def $tabid = "tab-impresa"}
	{/if}
	{def $tittabid = concat('tit_', $tabid)}
	
	{literal}
	<script>
	$(document).ready(function() {
	
		$('#{/literal}{$tabid}{literal}').addClass( 'active' );
		$('#{/literal}{$tittabid}{literal}').addClass( 'active' );
		
	});
	</script>
	{/literal}

	<div class="tab-content">
		<div class="tab-pane" id="tab-impresa">
		    <div class="col-xs-5">
				<p style="margin: 20px 0">
					{attribute_view_gui attribute=$node.data_map.pdf_preview image_class=original href=concat("content/download/",$pdf_obj.id,"/",$pdf_obj.data_map.pdf.id,"/file/",$pdf_obj.data_map.pdf.content.original_filename)|ezurl}
				</p>
		    </div>
		    <div class="col-xs-7">
				<div class="panel panel-default">
				  <div class="panel-heading">
				    <h3 class="panel-title">{$node.data_map.ragione_sociale_azienda.contentclass_attribute_name}</h3>
				  </div>
				  <div class="panel-body">
				    {if eq($node.data_map.ragione_sociale_azienda.content|count_chars(),0)}&nbsp;{else}{$node.data_map.ragione_sociale_azienda.content|wash()}{/if}
				  </div>
				  <div class="panel-heading">
				    <h3 class="panel-title">{$node.data_map.partita_iva_azienda.contentclass_attribute_name}</h3>
				  </div>
				  <div class="panel-body">
				    {if eq($node.data_map.partita_iva_azienda.content|count_chars(),0)}&nbsp;{else}{$node.data_map.partita_iva_azienda.content|wash()}{/if}
				  </div>
				  <div class="panel-heading">
				    <h3 class="panel-title">{$node.data_map.telefono.contentclass_attribute_name}</h3>
				  </div>
				  <div class="panel-body">
				    {if eq($node.data_map.telefono.content|count_chars(),0)}&nbsp;{else}{$node.data_map.telefono.content|wash()}{/if}
				  </div>
				  <div class="panel-heading">
				    <h3 class="panel-title">{$node.data_map.fax.contentclass_attribute_name}</h3>
				  </div>
				  <div class="panel-body">
				    {if eq($node.data_map.fax.content|count_chars(),0)}&nbsp;{else}{$node.data_map.fax.content|wash()}{/if}
				  </div>
				  <div class="panel-heading">
				    <h3 class="panel-title">{$node.data_map.email.contentclass_attribute_name}</h3>
				  </div>
				  <div class="panel-body">
				    {if eq($node.data_map.email.content|count_chars(),0)}&nbsp;{else}{$node.data_map.email.content|wash('email')}{/if}
				  </div>
				  <div class="panel-heading">
				    <h3 class="panel-title">{$node.data_map.emailpec.contentclass_attribute_name}</h3>
				  </div>
				  <div class="panel-body">
				    {if eq($node.data_map.emailpec.content|count_chars(),0)}&nbsp;{else}{$node.data_map.emailpec.content|wash('email')}{/if}
				  </div>
				</div>
		    </div>
		</div>
		<div class="tab-pane" id="tab-legale">
		    <div class="col-xs-12">
		    	<div class="panel panel-default">
				  <div class="panel-heading">{$node.data_map.ragione_sociale_azienda.content|wash()}</div>
				  <div class="panel-body">
				    <p>Informazioni legale rappresentante dell'impresa</p>
				  </div>
				  <table class="table">
				  	<tr>
				  		<th>{$node.data_map.nome_legale_rappresentante.contentclass_attribute_name}</th>
				  		<td>{if eq($node.data_map.nome_legale_rappresentante.content|count_chars(),0)}&nbsp;{else}{$node.data_map.nome_legale_rappresentante.content|wash()}{/if}</td>
				  	</tr>
				  	<tr>
				  		<th>{$node.data_map.cognome_legale_rappresentante.contentclass_attribute_name}</th>
				  		<td>{if eq($node.data_map.cognome_legale_rappresentante.content|count_chars(),0)}&nbsp;{else}{$node.data_map.cognome_legale_rappresentante.content|wash()}{/if}</td>
				  	</tr>
				  	<tr>
				  		<th>{$node.data_map.codicefiscale_legale_rappresentante.contentclass_attribute_name}</th>
				  		<td>{if eq($node.data_map.codicefiscale_legale_rappresentante.content|count_chars(),0)}&nbsp;{else}{$node.data_map.codicefiscale_legale_rappresentante.content|wash()}{/if}</td>
				  	</tr>
				  </table>
				</div>    
		    </div>
		</div>
		<div class="tab-pane" id="tab-sedi">
		    <div class="col-xs-12">
				<div class="panel panel-default">
				  <div class="panel-heading">{$node.data_map.ragione_sociale_azienda.content|wash()}</div>
				  <div class="panel-body">
				    <p>Informazioni sedi dell'impresa</p>
				  </div>
				  <table class="table">
				  	{def $sediAzienda=$node.data_map.elenco_sedi_azienda.content.relation_list $count=0} 
				  	{foreach $sediAzienda as $item}
			  			{def $sedeAzienda = fetch( content, object, hash( object_id, $item.contentobject_id ) )}
			  			{if eq( $count, 0) }
					  		<tr>
					  			<th>{$sedeAzienda.data_map.tipo.contentclass_attribute_name}</th>
					  			<th>{$sedeAzienda.data_map.indirizzo.contentclass_attribute_name}</th>
					  			<th>{$sedeAzienda.data_map.comune.contentclass_attribute_name}</th>
					  			<th>{$sedeAzienda.data_map.provincia.contentclass_attribute_name}</th>
					  			<th>{$sedeAzienda.data_map.cap.contentclass_attribute_name}</th>
					  		</tr>
					  	{/if}
				  		<tr>
				  			<td>{if eq($sedeAzienda.data_map.tipo.content|count_chars(),0)}&nbsp;{else}{$sedeAzienda.data_map.tipo.content|wash()}{/if}</td>
				  			<td>{if eq($sedeAzienda.data_map.indirizzo.content|count_chars(),0)}&nbsp;{else}{$sedeAzienda.data_map.indirizzo.content|wash()}{/if}</td>				  			
				  			<td>{if eq($sedeAzienda.data_map.comune.content|count_chars(),0)}&nbsp;{else}{$sedeAzienda.data_map.comune.content|wash()}{/if}</td>				  			
				  			<td>{if eq($sedeAzienda.data_map.provincia.content|count_chars(),0)}&nbsp;{else}{$sedeAzienda.data_map.provincia.content|wash()}{/if}</td>				  			
				  			<td>{if eq($sedeAzienda.data_map.cap.content|count_chars(),0)}&nbsp;{else}{$sedeAzienda.data_map.cap.content|wash()}{/if}</td>				  			
				  		</tr>
				  		{set $count=inc( $count )}
				  	{/foreach}
				  </table>
				</div>
			</div>    
		</div>
		<div class="tab-pane" id="tab-consorzio">
		    <div class="col-xs-5">
		    	<div class="panel panel-default">
				  <div class="panel-heading">{$node.data_map.ragione_sociale_azienda.content|wash()}</div>
				  <div class="panel-body">
				    <p>Informazioni consorzio</p>
				  </div>
				  {def $aderenteConsorzio = $node.data_map.consorzio_aderente_consorzio_valore.content}
				  <table class="table">
				  	<tr>
				    	<td>{$node.data_map.consorzio_aderente_consorzio_descrizione.content|wash()}</td>
				    </tr>
					{if eq( $aderenteConsorzio, 1) }
							<tr>
						    	<td>{if eq($node.data_map.ragione_sociale_consorzio.content|count_chars(),0)}&nbsp;{else}{$node.data_map.ragione_sociale_consorzio.content|wash()}{/if}</td>
						    </tr>
						    <tr>
						    	<td>{if eq($node.data_map.partita_iva_consorzio.content,'')}&nbsp;{else}{$node.data_map.partita_iva_consorzio.content|wash()}{/if}</td>
						    </tr>
					{/if}
				  </table>
			    </div>
			</div>		
		    <div class="col-xs-7">
				<div class="panel panel-default">
				  <div class="panel-heading">&nbsp;</div>
				  <div class="panel-body">
				    <p>Sedi del consorzio</p>
				  </div>
				  <table class="table">
				 	{if eq( $aderenteConsorzio, 1) }
				 		{def $sediConsorzio=$node.data_map.elenco_sedi_consorzio.content.relation_list $count=0}
				 		{foreach $sediConsorzio as $item}	  
				  			{def $sedeConsorzio = fetch( content, object, hash( object_id, $item.contentobject_id ) )}
				  			{if eq( $count, 0) }
						  		<tr>
						  			<th>{$sedeConsorzio.data_map.tipo.contentclass_attribute_name}</th>
						  			<th>{$sedeConsorzio.data_map.indirizzo.contentclass_attribute_name}</th>
						  			<th>{$sedeConsorzio.data_map.comune.contentclass_attribute_name}</th>
						  			<th>{$sedeConsorzio.data_map.provincia.contentclass_attribute_name}</th>
						  			<th>{$sedeConsorzio.data_map.cap.contentclass_attribute_name}</th>
						  		</tr>
						  	{/if}
					  		<tr>
					  			<td>{if eq($sedeConsorzio.data_map.tipo.content|count_chars(),0)}&nbsp;{else}{$sedeConsorzio.data_map.tipo.content|wash()}{/if}</td>
					  			<td>{if eq($sedeConsorzio.data_map.indirizzo.content|count_chars(),0)}&nbsp;{else}{$sedeConsorzio.data_map.indirizzo.content|wash()}{/if}</td>				  			
					  			<td>{if eq($sedeConsorzio.data_map.comune.content|count_chars(),0)}&nbsp;{else}{$sedeConsorzio.data_map.comune.content|wash()}{/if}</td>				  			
					  			<td>{if eq($sedeConsorzio.data_map.provincia.content|count_chars(),0)}&nbsp;{else}{$sedeConsorzio.data_map.provincia.content|wash()}{/if}</td>				  			
					  			<td>{if eq($sedeConsorzio.data_map.cap.content|count_chars(),0)}&nbsp;{else}{$sedeConsorzio.data_map.cap.content|wash()}{/if}</td>				  			
					  		</tr>
					  		{set $count=inc( $count )}
					  {/foreach}
					{else}
						<tr>
							<td></td>
						</tr>
					{/if}  
				  </table>
				</div>    
		    </div>
		</div>
		<div class="tab-pane" id="tab-dipendenti">
		    <div class="col-xs-12">
				<div class="panel panel-default">
				  <div class="panel-heading">{$node.data_map.ragione_sociale_azienda.content|wash()}</div>
				  <div class="panel-body">
				    <p>Informazioni sui dipendenti e soci lavoratori</p>
				  </div>
				  <table class="table">
<!--				  	<tr>
				  		<th colspan="2">{$node.data_map.numero_soci_lavoratori.contentclass_attribute_name}</th>
				  		<td>{if eq($node.data_map.numero_soci_lavoratori.content|count_chars(),0)}&nbsp;{else}{$node.data_map.numero_soci_lavoratori.content|wash()}{/if}</td>
				  	</tr>
				  	<tr>
				  		<td>&nbsp;</td>
				  		<td>&nbsp;</td>
				  		<td>&nbsp;</td>				  		
				  	</tr>-->
			 		{def $elencoLavoratori=$node.data_map.elenco_numero_dipendenti.content.relation_list $count=0}
				 		{foreach $elencoLavoratori as $item}	  
				  			{def $lavoratori = fetch( content, object, hash( object_id, $item.contentobject_id ) )}
				  			{if eq( $count, 0) }
						  		<tr>
						  			<th>{$lavoratori.data_map.tipologia.contentclass_attribute_name}</th>
						  			<th>{$lavoratori.data_map.tempo_determinato.contentclass_attribute_name}</th>
						  			<th>{$lavoratori.data_map.tempo_indeterminato.contentclass_attribute_name}</th>
						  		</tr>
						  	{/if}
					  		<tr>
					  			<td>{if eq($lavoratori.data_map.tipologia.content|count_chars(),0)}&nbsp;{else}{$lavoratori.data_map.tipologia.content|wash()}{/if}</td>
					  			<td>{if eq($lavoratori.data_map.tempo_determinato.content|count_chars(),0)}&nbsp;{else}{$lavoratori.data_map.tempo_determinato.content|wash()}{/if}</td>				  			
					  			<td>{if eq($lavoratori.data_map.tempo_indeterminato.content|count_chars(),0)}&nbsp;{else}{$lavoratori.data_map.tempo_indeterminato.content|wash()}{/if}</td>				  			
					  		</tr>
					  		{set $count=inc( $count )}
					  {/foreach}
				  </table>
				</div>
		    </div>
		</div>		
		<div class="tab-pane" id="tab-categorie">
		    <div class="col-xs-6">
				<div class="panel panel-default">
				  <div class="panel-heading">{$node.data_map.ragione_sociale_azienda.content|wash()}</div>
				  <div class="panel-body">
				    <p>Informazioni sulle categorie generali (OG)</p>
				  </div>
				  <table class="table">
			 		{def $categorieGenerali=$node.data_map.elenco_categorie_generali.content.relation_list $count=0}
				 		{foreach $categorieGenerali as $item}	  
				  			{def $categoriaGenerale = fetch( content, object, hash( object_id, $item.contentobject_id ) )}
				  			{if eq( $count, 0) }
						  		<tr>
						  			<th>{$categoriaGenerale.data_map.categoria.contentclass_attribute_name}</th>
						  			<th>{$categoriaGenerale.data_map.classifica.contentclass_attribute_name}</th>
						  		</tr>
						  	{/if}
					  		<tr>
					  			<td>{if eq($categoriaGenerale.data_map.categoria.content|count_chars(),0)}&nbsp;{else}{$categoriaGenerale.data_map.categoria.content|wash()}{/if}</td>
					  			<td>{if eq($categoriaGenerale.data_map.classifica.content|count_chars(),0)}&nbsp;{else}{$categoriaGenerale.data_map.classifica.content|wash()}{/if}</td>				  			
					  		</tr>
					  		{set $count=inc( $count )}
					  {/foreach}
				  </table>
				</div>
		    </div>
		    <div class="col-xs-6">
				<div class="panel panel-default">
				  <div class="panel-heading">&nbsp;</div>
				  <div class="panel-body">
				    <p>Informazioni sulle categorie specializzate (OS)</p>
				  </div>
				  <table class="table">
			 		{def $categorieSpecializzate=$node.data_map.elenco_categorie_specializzate.content.relation_list $count=0}
				 		{foreach $categorieSpecializzate as $item}	  
				  			{def $categoriaSpecializzata = fetch( content, object, hash( object_id, $item.contentobject_id ) )}
				  			{if eq( $count, 0) }
						  		<tr>
						  			<th>{$categoriaSpecializzata.data_map.categoria.contentclass_attribute_name}</th>
						  			<th>{$categoriaSpecializzata.data_map.classifica.contentclass_attribute_name}</th>
						  		</tr>
						  	{/if}
					  		<tr>
					  			<td>{if eq($categoriaSpecializzata.data_map.categoria.content|count_chars(),0)}&nbsp;{else}{$categoriaSpecializzata.data_map.categoria.content|wash()}{/if}</td>
					  			<td>{if eq($categoriaSpecializzata.data_map.classifica.content|count_chars(),0)}&nbsp;{else}{$categoriaSpecializzata.data_map.classifica.content|wash()}{/if}</td>				  			
					  		</tr>
					  		{set $count=inc( $count )}
					  {/foreach}
				  </table>
				</div>
		    </div>
		</div>		
		<div class="tab-pane" id="tab-attivita">
		    <div class="col-xs-12">
				<div class="panel panel-default">
				  <div class="panel-heading">{$node.data_map.ragione_sociale_azienda.content|wash()}</div>
				  <div class="panel-body">
				    <p>Informazioni sulle attivit&agrave;</p>
				  </div>
				  <table class="table">
			 		{def $elencoAttivita=$node.data_map.elenco_sezione_attivita.content.relation_list $count=0}
				 		{foreach $elencoAttivita as $item}	  
				  			{def $attivita = fetch( content, object, hash( object_id, $item.contentobject_id ) )}
				  			{if eq( $count, 0) }
						  		<tr>
						  			<th>{$attivita.data_map.attivita.contentclass_attribute_name}</th>
						  		</tr>
						  	{/if}
					  		<tr>
					  			<td>{if eq($attivita.data_map.attivita.content|count_chars(),0)}&nbsp;{else}{$attivita.data_map.attivita.content|wash()}{/if}</td>
					  		</tr>
					  		{set $count=inc( $count )}
					  {/foreach}
				  </table>
				</div>
		    </div>
		</div>
		<div class="tab-pane" id="tab-enti">
		    <div class="col-xs-12">
				<div class="panel panel-default">
				  <div class="panel-heading">{$node.data_map.ragione_sociale_azienda.content|wash()}</div>
				  <div class="panel-body">
				    <p>Informazioni sulle iscrizioni presso gli enti</p>
				  </div>
				  <table class="table">
			 		{def $elencoEnteIscrizione=$node.data_map.elenco_ente_iscrizione.content.relation_list}
				 		{foreach $elencoEnteIscrizione as $item}	  
				  			{def $enteIscrizione = fetch( content, object, hash( object_id, $item.contentobject_id ) )}
				  			{def $miavariabile = etisospensione('statosospensioneenteazienda',$node.data_map.partita_iva_azienda.content,$enteIscrizione.data_map.id.content)}
						  	<tr>
						    	<th>{$enteIscrizione.data_map.ente.content|wash()}</th>
				  				{if eq($miavariabile.0.sospensione, 1) }
						    		<td>Iscrizione Sospesa &nbsp; <a class="btn btn-success pull-right" href={concat('managepo/manageposospensione/delete/',$node.data_map.partita_iva_azienda.content,'/',$enteIscrizione.data_map.id.content,'/0/',$node.node_id)|ezurl()}>Disattiva sospensione</a></td>
						    	{else}
						    		<td>Iscrizione Attiva  &nbsp; <a class="btn btn-warning pull-right" href={concat('managepo/manageposospensione/insert/',$node.data_map.partita_iva_azienda.content,'/',$enteIscrizione.data_map.id.content,'/1/',$node.node_id)|ezurl()}>Attiva sospensione</a></td>
						    	{/if}
						    </tr>
					  {/foreach}
				  </table>
				</div>
		    </div>
		</div>
		<div class="tab-pane" id="tab-altro">
		    <div class="col-xs-12">
				<div class="panel panel-default">
				  <div class="panel-heading">{$node.data_map.ragione_sociale_azienda.content|wash()}</div>
				  <div class="panel-body">
				    <p>Altre informazioni sull'impresa</p>
				  </div>
				  <table class="table">
				  	<tr>
				    	<th>{$node.data_map.req_ordine_gen_art38dlgs163_2006_descrizione.contentclass_attribute_name}</th>
					    <td>{if eq($node.data_map.req_ordine_gen_art38dlgs163_2006_descrizione.content|count_chars(),0)}&nbsp;{else}{$node.data_map.req_ordine_gen_art38dlgs163_2006_descrizione.content|wash()}{/if}</td>
				    </tr>
				    <tr>
					    <th>{$node.data_map.requisiti_capacita_descrizione.contentclass_attribute_name}</th>
					    <td>{if eq($node.data_map.requisiti_capacita_descrizione.content|count_chars(),0)}&nbsp;{else}{$node.data_map.requisiti_capacita_descrizione.content|wash()}{/if}</td>
				    </tr>
				    <tr>
					    <th>{$node.data_map.iscritta_registro_imprese_descrizione.contentclass_attribute_name}</th>
					    <td>{if eq($node.data_map.iscritta_registro_imprese_descrizione.content|count_chars(),0)}&nbsp;{else}{$node.data_map.iscritta_registro_imprese_descrizione.content|wash()}{/if}</td>
				   	</tr>
				  </table>
				</div>
		    </div>
		</div>
		<div class="tab-pane" id="tab-mappa">
			<div class="col-xs-4">
				<div class="panel panel-default">
				  <div class="panel-heading">{$node.data_map.ragione_sociale_azienda.content|wash()}</div>
				  <div class="panel-body">
				    <p>Mappa delle sedi dell'impresa</p>
					<table class="table" style="table-layout:fixed;">
					  	{def $sediAzienda=$node.data_map.elenco_sedi_azienda.content.relation_list $count=0} 
					  	{foreach $sediAzienda as $item}
				  			{def $sedeAzienda = fetch( content, object, hash( object_id, $item.contentobject_id ) )}
				  			{if eq( $count, 0) }
						  		<tr>
						  			<th>{$sedeAzienda.data_map.tipo.contentclass_attribute_name}</th>
						  			<th>{$sedeAzienda.data_map.indirizzo.contentclass_attribute_name}</th>
						  			<th>{$sedeAzienda.data_map.comune.contentclass_attribute_name}</th>
						  		</tr>
						  	{/if}
					  		<tr>
					  			{def $arrayTest = $sedeAzienda.data_map.tipo.content|explode( ' ' )}
					  			{def $checkWord = false}
					  			{foreach $arrayTest as $itemWord}
					  				{if gt($itemWord|count_chars(),14)}
					  					{set checkWord = true}
					  				{/if} 
					  			{/foreach}	
					  			<td>{if eq($sedeAzienda.data_map.tipo.content|count_chars(),0)}&nbsp;{else}{if eq(checkWord,true)}{$sedeAzienda.data_map.tipo.content|shorten(14)}{else}{$sedeAzienda.data_map.tipo.content|wash()}{/if}{/if}</td>
					  			{set arrayTest = $sedeAzienda.data_map.indirizzo.content|explode( ' ' )}
					  			{set checkWord = false}
					  			{foreach $arrayTest as $itemWord}
					  				{if gt($itemWord|count_chars(),14)}
					  					{set checkWord = true}
					  				{/if} 
					  			{/foreach}	
					  			<td>{if eq($sedeAzienda.data_map.indirizzo.content|count_chars(),0)}&nbsp;{else}{if eq(checkWord,true)}{$sedeAzienda.data_map.indirizzo.content|shorten(14)}{else}{$sedeAzienda.data_map.indirizzo.content|wash()}{/if}{/if}</td>
					  			{set arrayTest = $sedeAzienda.data_map.comune.content|explode( ' ' )}
					  			{set checkWord = false}
					  			{foreach $arrayTest as $itemWord}
					  				{if gt($itemWord|count_chars(),14)}
					  					{set checkWord = true}
					  				{/if} 
					  			{/foreach}	
					  			<td>{if eq($sedeAzienda.data_map.comune.content|count_chars(),0)}&nbsp;{else}{if eq(checkWord,true)}{$sedeAzienda.data_map.comune.content|shorten(14)}{else}{$sedeAzienda.data_map.comune.content|wash()}{/if}{/if}</td>				  			
					  		</tr>
					  		{set $count=inc( $count )}
					  	{/foreach}
					</table>
				  </div>
				</div>
			</div>
		    <div class="col-xs-8">
				<div class="panel panel-default">
				  <div class="panel-heading">&nbsp;</div>
				  <div class="panel-body">
				  	<div id="map-{$node.node_id}" class="leaflet-container leaflet-fade-anim" style="height: 600px; width: 100%"></div>
			
						{def $SediArray = fetch( 'content', 'list', 
												  hash( 'parent_node_id',     $node.node_id,
														'depth', 2,
														'class_filter_type',  'include',               
														'class_filter_array', array( 'sede_azienda')
																									) )}
						{* generazione mappa *}
			            <script>
			             	{literal}
			                	var tiles = L.tileLayer('http://{s}.tile.osm.org/{z}/{x}/{y}.png', {maxZoom: 18,attribution: '&copy; <a href="http://osm.org/copyright">OpenStreetMap</a> contributors'});
			                	var map = L.map('{/literal}map-{$node.node_id}{literal}').addLayer(tiles);
			                
			                	map.scrollWheelZoom.disable();
			                
			                	var markers = L.markerClusterGroup();
			             	{/literal}
			             		{foreach $SediArray as $mapNode}
			             			{if ne($mapNode.data_map.geo.content.latitude|count_chars(),0)}
			             				{literal}
			             					if(true){
												var longitude = {/literal}{$mapNode.data_map.geo.content.latitude}{literal};
												var latitude = {/literal}{$mapNode.data_map.geo.content.longitude}{literal};
												var address = '{/literal}<h2>{$mapNode.data_map.tipo.content|shorten(25)}</h2><h3>{$mapNode.data_map.indirizzo.content|shorten(25)}<br/>{$mapNode.data_map.comune.content|shorten(25)}</h3>{literal}';
												{/literal}
													{switch match = $mapNode.data_map.tipo.content}
														{case match = 'Sede legale'}
															{literal}
																var iconaSede = "building";
																var coloreSede = "#00f";											
															{/literal}
														{/case}
														{case match = 'Sede amministrativa'}
															{literal}
																var iconaSede = "commercial";
																var coloreSede = "#0f0";
															{/literal}
														{/case}
														{case match = 'Stabilimento'}
															{literal}
																var iconaSede = "industrial";
																var coloreSede = "#ff0";
															{/literal}
														{/case}
														{case match}
															{literal}
																var iconaSede = "warehouse";
																var coloreSede = "#f00";
															{/literal}
														{/case}
													{/switch}
												{literal}

												var customIcon = L.MakiMarkers.icon({icon: iconaSede, color: coloreSede, size: "l"});
											   
												markers.addLayer(L.marker([longitude, latitude], {icon: customIcon}).bindPopup(address));

			             					}
			             				{/literal}
			             			{/if}
			             		{/foreach}
							{literal}
				                map.addLayer(markers);
				                
				                if(markers.getLayers().length > 0){
				                    map.fitBounds(markers.getBounds());
				                }
				                else{
				                    map.setView([46.0805156,11.0853364], 12);
				                }
								
								$("body").on("shown.bs.tab", '#linkmap', function() { 
	  								map.invalidateSize(false);
		 							if(markers.getLayers().length > 0){
					                    map.fitBounds(markers.getBounds());
					                }
					                else{
					                    map.setView([46.0805156,11.0853364], 12);
					                }
								});										                
			            	{/literal}
			            </script>
				  </div>
				</div>
			</div>		
		</div>		
	</div>
</div>
