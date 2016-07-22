{def $openpa = object_handler($node)}
{if $openpa.content_tools.editor_tools}
  {include uri=$openpa.content_tools.template}
{/if}

{ezscript_require( array( 'leaflet.js') )}
{ezcss_require( array( 'leaflet.css' ) )}

		   {ezscript_require( array( 'ezjsc::jquery', 'leaflet.markercluster.js', 'Leaflet.MakiMarkers.js') )}
		   {ezcss_require( array( 'plugins/leaflet/map.css', 'MarkerCluster.css', 'MarkerCluster.Default.css' ) )}
		   
<div class="row">
	{set-block scope=root variable=cache_ttl}0{/set-block}
	<div class="nav-section">
		<h1>
			<i class="fa fa-search"></i>
			Ricerca
		</h1>
		
		{* memorizzazione array degli enti associati all'utente corrente *}
		{* creazione array associativo "$entiutente" con id, denominazione e coordinate geo degli enti *}			
		{def $user=fetch( 'user', 'current_user' )}
		{def $elencoEnteUtente=$user.contentobject.data_map.ente_appartenenza.content.relation_list}
		{def $identiutente = array()}
		{def $entiutente = hash()}
		{foreach $elencoEnteUtente as $item}	  
			{def $enteIscrizione = fetch( 'content', 'object', hash( 'object_id', $item.contentobject_id ) )}
			{set $identiutente = $identiutente|append($enteIscrizione.data_map.id.content)}
			{set $entiutente = $entiutente|merge(hash($enteIscrizione.data_map.id.content, hash('id',$enteIscrizione.data_map.id.content,'ente',$enteIscrizione.data_map.ente.content,'lat',$enteIscrizione.data_map.geo.content.latitude,'long',$enteIscrizione.data_map.geo.content.longitude,'range',$enteIscrizione.data_map.km_range_interesse.content)))}
			{undef $enteIscrizione}
		{/foreach}	

		{* definisco le variabili che mi serviranno per l'elaborazione e le valorizzo con i valori che ritornano dal post nel caso siano vuote le imposto con il valore 0 dell'array deglianeti associati all'utente *}
		{def $enteselezionato=ezhttp('enteselezionato','POST')}
		{if $enteselezionato|is_null()}
			{set $enteselezionato = 0}
		{/if}
		{def $kmdistanza=ezhttp('kmdistanza','POST')}
		{if $kmdistanza|is_null()}
			{set $kmdistanza = $entiutente[$enteselezionato].range}
		{/if}
		
		{* valore iniziale del range di ricerca e delle coordinate del centro *}
		{def $rangericercainmetri = mul($kmdistanza,1000)}
		{def $coordcentroricerca = hash()}
		{set $coordcentroricerca = hash('lat',$entiutente[$enteselezionato].lat,'long',$entiutente[$enteselezionato].long)}
		
		
		{* form di scelta enti e impostazione distanza kilometrica *}
		<form class="form-inline" role="form" method="POST">
			<div class="well row">
				<div>Enti associati all'utente</div>
				<div class="form-group">
						<select class="form-control" name="enteselezionato" id="ente-select">
							{foreach $entiutente as $optionitemkey => $optionitem}
								<option value="{$optionitemkey}" {if $optionitemkey|eq($enteselezionato)} selected="selected"{/if}>{$optionitem[ente]}</option>
							{/foreach}
						</select>
				</div>
				<div>&nbsp;</div>
				<div>Range di ricerca dall'Ente:</div>
				<div class="input-group">
					<input id="kminput" type="text" class="form-control" name="kmdistanza" placeholder="Range di ricerca in Km" value="{$kmdistanza}">
					<span class="input-group-addon">Km</span>
				</div>
			</div>
			<div class="row">
				<div class="form-group">
					<button type="submit" class="btn btn-success btn-lg base-filter" id="search">Cerca</button>
				</div>
			</div>
		</form>
		
		<script type="text/javascript">
		{literal}
		$("#kminput").on('input', function (event) { 
   	 		this.value = this.value.replace(/[^0-9]/g, '');
		});
		
		$(document).ready(function() {
		    $("#kminput").keyup(function() {
		
		        var empty = false;
		        $("#kminput").each(function() {
		            if ($(this).val().length == 0) {
		                empty = true;
		            }
		        });
		
		        if (empty) {
		            $("#search").attr('disabled', 'disabled');
		        } else {
		            $("#search").attr('disabled', false);
		        }
		    });
		});
				
		$( "#ente-select" ).change(function () {
			var enteselezionato = {/literal}{$enteselezionato}{literal};
			var kmdistanzapost = {/literal}{$kmdistanza}{literal};
			var index;
			var kmdistanzaselect;
			var kminput = $( "#kminput" ).val();
			var array = [
		{/literal}		
		{foreach $entiutente as $key => $item}
			{$item[range]}
			{if ne($entiutente|count(),$key|inc())} 
				{literal},{/literal}
			{/if}	
		{/foreach}
		{literal}
			];
		  
		  $( "select option:selected" ).each(function() {
		  	index = $( this ).val();
		  	kmdistanzaselect = array[$( this ).val()];  
		  });
		  	if ((enteselezionato == index) && (kmdistanzapost != kmdistanzaselect)) {
				$( "#kminput" ).val( kmdistanzapost );
		  	} else {
				$( "#kminput" ).val( kmdistanzaselect );
			}
		})
		.change();		
		{/literal}
		</script>
	</div>
			
	<div class="content-main">
		<div class="widget">
            <h1>
                <i class="fa fa-map-marker"></i>
                Mappa Sedi Imprese
            </h1>
            <div id="map-{$node.node_id}" class="leaflet-container leaflet-fade-anim" style="height: 600px; width: 100%"></div>
			
			{def $SediArray = fetch( 'content', 'list', 
									  hash( 'parent_node_id',     15465,
											'depth', 2,
											'class_filter_type',  'include',               
											'class_filter_array', array( 'sede_azienda')
																						) )}



			{* definizione array che conterrà le PIVA delle aziende non legate agli enti associati all'utente corrente *}
			{def $AziendeObjIdNoUtente = array()}
			
			{* controllo delle aziende (parent) associate alle sedi *}
			{foreach $SediArray as $mapNode}
				{def $AziendaSede = $mapNode.parent}

				{def $elencoEnteIscrizione=$AziendaSede.data_map.elenco_ente_iscrizione.content.relation_list}
				
				{* controllo degli enti associati alle aziende e confronto con gli enti associati all'utente corrente *}
				{def $aziendaokutente = false()}
				{def $identiazienda = array()}
				{foreach $elencoEnteIscrizione as $item}	  
					{def $enteIscrizione = fetch( 'content', 'object', hash( 'object_id', $item.contentobject_id ) )}
					{set $identiazienda = $identiazienda|append($enteIscrizione.data_map.id.content)}
					{if $identiutente|contains($enteIscrizione.data_map.id.content)}
						{set $aziendaokutente = true()}
						{break}
					{/if}
					{undef $enteIscrizione}
				{/foreach}
				
				{if $aziendaokutente|eq(false())}
				  {set $AziendeObjIdNoUtente = $AziendeObjIdNoUtente|append($AziendaSede.contentobject_id)}
				{/if}
				{undef $AziendaSede}
				{undef $elencoEnteIscrizione}
				{undef $identiazienda}
				{undef $aziendaokutente}
			{/foreach}

			{* generazione mappa *}
            <script>
            {literal}
                var tiles = L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {maxZoom: 18,attribution: '&copy; <a href="https://openstreetmap.org/copyright">OpenStreetMap</a> contributors'});
                var map = L.map('{/literal}map-{$node.node_id}{literal}').addLayer(tiles);
                
                map.scrollWheelZoom.disable();
                
                var markers = L.markerClusterGroup();
				
                {/literal}{foreach $SediArray as $mapNode}
				
					{def $AziendaSede = $mapNode.parent}
					{if $AziendeObjIdNoUtente|contains($AziendaSede.contentobject_id)|not()}
					
						{if and($mapNode.data_map.geo.content.latitude|ne(''),$mapNode.data_map.geo.content.latitude|gt(-90),$mapNode.data_map.geo.content.latitude|lt(90),$mapNode.data_map.geo.content.longitude|gt(-180),$mapNode.data_map.geo.content.longitude|lt(180) )}
						
							{literal}
							if(true){
								var distanza =  {/literal}{distanzageo($coordcentroricerca[lat],$coordcentroricerca[long],$mapNode.data_map.geo.content.latitude,$mapNode.data_map.geo.content.longitude)}{literal};
								var longitude = {/literal}{$mapNode.data_map.geo.content.latitude}{literal};
								var latitude = {/literal}{$mapNode.data_map.geo.content.longitude}{literal};
								var address = "{/literal}<h2><a href={$AziendaSede.url_alias|ezurl('no')}>{$AziendaSede.data_map.ragione_sociale_azienda.content|explode('"')|implode("'")}</a></h2><br/><h3>{$mapNode.data_map.tipo.content}</h3>{literal}";
								{/literal}
								{if $mapNode.data_map.tipo.content|eq('Sede legale')}
									var iconaSede = "building";
									var coloreSede = '#00f';
								{elseif $mapNode.data_map.tipo.content|eq('Sede amministrativa')}
									var iconaSede = "commercial";
									var coloreSede = '#0f0';
								{elseif $mapNode.data_map.tipo.content|eq('Stabilimento')}
									var iconaSede = "industrial";
									var coloreSede = '#ff0';
								{else}
									var iconaSede = "warehouse";
									var coloreSede = '#f00';
								{/if}
								{literal}
								
								var customIcon = L.MakiMarkers.icon({icon: iconaSede, color: coloreSede, size: "l"});
							   
								markers.addLayer(L.marker([longitude, latitude], {icon: customIcon}).bindPopup(address));
								
							}
							{/literal}
						
						{/if}
					{/if}
					{undef $AziendaSede}
				{/foreach}
				
				{literal}
				var lat = {/literal}{$coordcentroricerca[lat]}{literal};
				var lon = {/literal}{$coordcentroricerca[long]}{literal};
				var range = {/literal}{$rangericercainmetri}{literal};
				
				if (!isNaN(lat)) { 
				
					var circle = L.circle([lat, lon], range, {
						color: '#0b2',
						fillColor: '#3f6',
						fillOpacity: 0.2
					}).addTo(map);
				
				}
                
                map.addLayer(markers);
                
                if(markers.getLayers().length > 0){
                    map.fitBounds(markers.getBounds());
                }
                else{
                    map.setView([46.0805156,11.0853364], 12);
                }
                
            {/literal}
            </script>
			
			</div>



			
		</div>	
	</div>

</div>
