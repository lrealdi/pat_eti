
{ezscript_require( array( 'ezjsc::jquery', 'jquery.tablesorter.min.js' ) )}

{def $elementForPage = 10}

{def $pages = ceil(div($data.count,$elementForPage)))}

<script type="text/javascript">
    {literal}
    $(document).ready(function() {
        $("table.list").tablesorter();
        $("table.list th").css( 'cursor', 'pointer' );
    });
    {/literal}
</script>

<script type="text/javascript" class="init">

	{literal}		
	$(document).ready(function() {
		$('#table-{/literal}{$table_id}{literal}').DataTable({
			"language": {
					"sEmptyTable":     "Nessun dato presente nella tabella",
					"sInfo":           "Vista da _START_ a _END_ di _TOTAL_ elementi",
					"sInfoEmpty":      "Vista da 0 a 0 di 0 elementi",
					"sInfoFiltered":   "(filtrati da _MAX_ elementi totali)",
					"sInfoPostFix":    "",
					"sInfoThousands":  ".",
					"sLengthMenu":     "Visualizza _MENU_ elementi",
					"sLoadingRecords": "Caricamento...",
					"sProcessing":     "Elaborazione...",
					"sSearch":         "Cerca:",
					"sZeroRecords":    "La ricerca non ha portato alcun risultato.",
					"oPaginate": {
						"sFirst":      "Inizio",
						"sPrevious":   "Precedente",
						"sNext":       "Successivo",
						"sLast":       "Fine"
					},
					"oAria": {
						"sSortAscending":  ": attiva per ordinare la colonna in ordine crescente",
						"sSortDescending": ": attiva per ordinare la colonna in ordine decrescente"
					}
			},
			"ordering": false,
			"searching": false,
			"lengthChange": true,
			"pageLength": {/literal}{$elementForPage}{literal},
			"lengthMenu": [ [{/literal}{$elementForPage}{literal}, {/literal}{mul($elementForPage,2)}{literal}, {/literal}{mul($elementForPage,3)}{literal}, {/literal}{mul($elementForPage,4)}{literal}, {/literal}{mul($elementForPage,5)}{literal}, -1], [{/literal}{$elementForPage}{literal}, {/literal}{mul($elementForPage,2)}{literal}, {/literal}{mul($elementForPage,3)}{literal}, {/literal}{mul($elementForPage,4)}{literal}, {/literal}{mul($elementForPage,5)}{literal}, "Tutti"] ]
		});
	} );
	{/literal}

</script>

<div class="facet-content">
	{if $data.count}
  
    <div class='col-sm-12'>
        <div class='box bordered-box orange-border' style='margin-bottom:0;'>
            <div class='box-content box-no-padding'>
            	<div><a name='myEtiBtn' id='myEtiBtn' href='javascript:esportaEti();' class='btn btn-mini btn-success pull-right' >Esporta Lista</a></div>
                <div class='table-responsive'>
                    <table id="table-{$table_id}" class='dt-column-filter table table-striped list' style='margin-bottom:0;'>
                        <thead>
	                        <tr>
	                            <th>Ragione sociale <i class="fa fa-sort"></i></th>
	                            <th>Sede legale <i class="fa fa-sort"></i></th>
	                            <th>Presso <i class="fa fa-sort"></i></th>
	                            <th></th>
	                        </tr>
                        </thead>
                        <tbody>
                        
                        {def $myArray=''}
                        {foreach $data.contents as $child }
				                                      
                            {set $myArray=concat( $myArray, $child.object.id ,','  ) )}

	  						{def $sediAzienda=$child.data_map.elenco_sedi_azienda.content.relation_list}

							{def $sedeAziendaIndirizzo = ''}
							{def $sedeAziendaComune = ''}
							{def $sedeAziendaProvincia = ''}
						  	{foreach $sediAzienda as $item}
  								{def $sedeAzienda = fetch( content, object, hash( object_id, $item.contentobject_id ) )}
  								
  								{if eq($sedeAzienda.data_map.tipo.content|upcase()|trim(),'SEDE LEGALE')}
									{set $sedeAziendaIndirizzo = $sedeAzienda.data_map.indirizzo.content}
									{set $sedeAziendaComune = $sedeAzienda.data_map.comune.content}
									{set $sedeAziendaProvincia = $sedeAzienda.data_map.provincia.content}
								{/if}	  									
							{/foreach}

                            {def $pdf_obj = $child.object}

                            <tr>
                                <td><a href="{$child.url_alias|ezurl('no')}" title="{$child.name|wash()}">{$child.data_map.ragione_sociale_azienda.content}</a></td>
                                <td>{$sedeAziendaIndirizzo}</td>
                                <td style="min-width: 100px;">{$sedeAziendaComune} {$sedeAziendaProvincia}</td>
                                <td><a href={concat("content/download/",$pdf_obj.id,"/",$pdf_obj.data_map.pdf.id,"/file/",$pdf_obj.data_map.pdf.content.original_filename)|ezurl} target="_blank"><i class="fa fa-file-pdf-o"></i></a></td>
                            </tr>
                        {/foreach}
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
    </div>
    <input type="hidden" name="listaETI" value='{$myArray}'>


  {include name=navigator
		   uri='design:navigator/google.tpl'
		   page_uri=$data.base_uri
		   item_count=$data.count
		   view_parameters=$view_parameters
		   item_limit=$page_limit}

{else}
  <em>Nessun risultato</em>
{/if}
</div>
{literal}
    <script language="JavaScript" type="text/javascript"> 
        function esportaEti() 
        {     
            {/literal}
            {set $myArray=concat( "/etiexport/eti_list_export/?listaETI=" , $myArray )} 
            {literal}
            window.open( {/literal}{$myArray|ezurl}{literal},'_blank');
        } 
    </script> 
{/literal}
