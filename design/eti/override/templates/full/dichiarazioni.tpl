{def $openpa = object_handler($node)}
{if $openpa.content_tools.editor_tools}
    {include uri=$openpa.content_tools.template}
{/if}

{def $ente_filter_string = ''
     $ente_filter_string2 = ''}
{def $user=fetch( 'user', 'current_user' )}

{def $user_ente_appartenenza_relation_list = array()}
{if $user.contentobject.data_map.ente_appartenenza.has_content}
    {set $user_ente_appartenenza_relation_list = $user.contentobject.data_map.ente_appartenenza.content.relation_list}
{/if}
{if count($user_ente_appartenenza_relation_list)}
    {def $ente_filter = array()}
    {foreach $user.contentobject.data_map.ente_appartenenza.content.relation_list as $ente_related}
        {set $ente_filter = $ente_filter|append($ente_related.contentobject_id)}
    {/foreach}
    {if count($ente_filter)}
        {set $ente_filter_string = concat(' and raw[extra_ente____s] in [',$ente_filter|implode(','), ']')}
        {set $ente_filter_string2 = concat(' and id in [',$ente_filter|implode(','), ']')}
    {/if}
{/if}
{def $enti = api_search(concat( 'classes [ente]', $ente_filter_string2, ' sort [name=>asc]') )}


{ezcss_require( array(
    'plugins/chosen.css',
    'dataTables.bootstrap.css',
    'leaflet.css',
    'MarkerCluster.css',
    'MarkerCluster.Default.css'
))}
{ezscript_require(array(
    'ezjsc::jquery',
    'plugins/chosen.jquery.js',
    'moment.min.js',
    'jquery.dataTables.js',
    'jquery.opendataDataTable.js',
    'jquery.patEtiTools.js',
    'leaflet.js',
    'leaflet.markercluster.js',
    'leaflet.makimarkers.js',
    'Control.Geocoder.js'
))}

<script type="text/javascript" language="javascript" class="init">
	var endpoints = {ldelim}
		geo: "{'/etiexport/api/geo/search/'|ezurl(no)}/",
		search: "{'/etiexport/api/content/search/'|ezurl(no)}/",
		class: "{'/etiexport/api/classes/'|ezurl(no)}/",
		root: "{'/'|ezurl(no)}/",
		datatable: "{'/etiexport/api/datatable/search/'|ezurl(no)}/"
	{rdelim};
	var mainQuery = "{concat( 'classes [dichiarazione_impresa]', $ente_filter_string)}";
    var geoMainQuery = 'classes [sede_azienda]';
    //console.log(mainQuery);
    {literal}
    var SessionCacheKey = 'dichiarazioni_impresa';

    /**
     * Definizione delle faccette:
     *  - field: campo di ricerca in OCSQL vedi https://github.com/Opencontent/openservices/blob/master/doc/06-search-query.md
     *  - limit: numero massimo di faccette
     *  - sort: ordinamento (alpha o count)
     *  - name: titolo esposto
     *  - multiple: booleano per permettere la scelta multipla
     *  - hidden: se true il form non viene esposto
     */

    var facets = [
        {field: 'raw[extra_tipo_sede____s]', 'limit': 300, 'sort': 'alpha', name: 'Tipologia sede aziendale'},
        {field: 'raw[extra_provincia_sede____s]', 'limit': 300, 'sort': 'alpha', name: 'Provincia sede aziendale'},
        {field: 'raw[extra_comune_sede____s]', 'limit': 300, 'sort': 'alpha', name: 'Comune sede aziendale'},
        {field: 'raw[extra_categoria_generale____s]', 'limit': 300, 'sort': 'alpha', name: 'Categorie generali (OG)', multiple: true},
        {field: 'raw[extra_categoria_generale_classifica____s]', 'limit': 300, 'sort': 'alpha', name: 'Classifica OG', multiple: true},
        {field: 'raw[extra_categoria_specializzata____s]', 'limit': 300, 'sort': 'alpha', name: 'Categorie specializzate (OS)', multiple: true},
        {field: 'raw[extra_categoria_specializzata_classifica____s]', 'limit': 300, 'sort': 'alpha', name: 'Classifica OS', multiple: true},
        {field: 'raw[extra_attivita____s]', 'limit': 300, 'sort': 'alpha', name: 'Attività', multiple: true},
        {field: 'raw[extra_dipendenti_tipologia____s]', 'limit': 300, 'sort': 'alpha', name: 'Tipologia dipendente'},
        {field: 'raw[extra_dipendenti_determinati____s]', 'limit': 300, 'sort': 'alpha', name: 'Numero dip. determinati'},
        {field: 'raw[extra_dipendenti_indeterminati____s]', 'limit': 300, 'sort': 'alpha', name: 'Numero dip. indeterminati'},
        {field: 'raw[extra_ente____s]', 'limit': 300, 'sort': 'alpha', name: 'Ente'},
        {field: 'raw[meta_main_node_id_si]', 'limit': 5000, 'sort': 'alpha', name: 'Enti', hidden: true}
    ];

    $(document).ready(function () {
        var tools = $.patEtiTools;
		tools.settings('endpoint',endpoints);

        mainQuery += ' facets ['+tools.buildFacetsString(facets)+']';

        /**
         * Inizializzazione della mappa
         * il callback viene interpellato da loadMarkersInMap e si aspetta un oggetto GeoJson
         */
        var datatable;
        var map = tools.initMap(
                'map',
                function (response) {
                    return L.geoJson(response, {
                        pointToLayer: function (feature, latlng) {

                            /**
                             * Customizzazione delle icone di marker in base a stringhe sul properties.name
                             */

                            var customIcon, iconaSede, coloreSede;
                            if (feature.properties.name.search('Sede legale') > -1) {
                                iconaSede = "building";
                                coloreSede = '#00f';
                                customIcon = L.MakiMarkers.icon({icon: iconaSede, color: coloreSede, size: "l"});
                            } else if (feature.properties.name.search('Sede amministrativ') > -1) {
                                iconaSede = "commercial";
                                coloreSede = '#0f0';
                                customIcon = L.MakiMarkers.icon({icon: iconaSede, color: coloreSede, size: "l"});
                            } else if (feature.properties.name.search('Stabilimento')> -1) {
                                iconaSede = "industrial";
                                coloreSede = '#ff0';
                                customIcon = L.MakiMarkers.icon({icon: iconaSede, color: coloreSede, size: "l"});
                            } else {
                                iconaSede = "warehouse";
                                coloreSede = '#f00';
                                customIcon = L.MakiMarkers.icon({icon: iconaSede, color: coloreSede, size: "l"});
                            }
                            return L.marker(latlng, {icon: customIcon});
                        },
                        onEachFeature: function (feature, layer) {

                            /**
                             * Creazione del popup di default
                             * nell'evento di apertura (popupopen) viene sovrascritto dal risultato della richiesta sincrona
                             */

                            var popupDefault = '<p><a href="/content/view/full/' + feature.properties.mainNodeId + '" target="_blank">';
                            popupDefault += feature.properties.name;
                            popupDefault += '</a></p>';
                            var popup = new L.Popup({maxHeight: 360});
                            popup.setContent(popupDefault);
                            layer.on('popupopen', function (e) {
                                $.get("etiexport/marker_popup/" + feature.id, function (data) {
                                    popup.setContent(data);
                                    popup.update();
                                });
                            });
                            layer.bindPopup(popup);
                        }
                    });
                }
        );

        /**
         * Inizialiazzaione di OpendataDataTable (wrapper di jquery datatable)
         */
        datatable = $('.content-data').opendataDataTable({
                    "builder":{
                        "query": mainQuery
                    },
                    "datatable":{                        
						"ajax": {
                            url: endpoints.datatable
                        },
                        "columns": [
                            {"data": "data."+tools.settings('language')+".ragione_sociale_azienda", "name": 'ragione_sociale_azienda', "title": 'Ragione sociale'},
                            {"data": "data."+tools.settings('language')+".elenco_sedi_azienda", "name": 'elenco_sedi_azienda', "title": 'Sedi', "serchable": false, "orderable": false},
							{"data": "data."+tools.settings('language')+".nome_legale_rappresentante", "name": 'nome_legale_rappresentante', "title": 'PDF', "serchable": false, "orderable": false}
                        ],
                        "columnDefs": [
                            {
                                "render": function ( data, type, row ) {
                                    return '<a href="/content/view/full/'+row.metadata.mainNodeId+'">'+data+'</a>';
                                },
                                "targets": [0]
                            },
                            {
                                "render": function ( data, type, row, meta ) {
                                    var list = $('<div>');
                                    var ul = $('<ul class="list-unstyled">').appendTo(list);
                                    $.each(data,function(){
										// scommenta se vuoi far vedere solo le sedi legali
										//if (this.name[tools.settings('language')].search('Sede legale') == 0){
											ul.append($('<li>').html(this.name[tools.settings('language')]));									
										//}
                                    });
                                    return list.html();
                                },
                                "targets": [1]
                            },
							{
                                "render": function ( data, type, row ) {
                                    // workaoround per bug indicizzazione url
									var getLocation = function(href) {
										var l = document.createElement("a");
										l.href = href;
										return l;
									};
									var l = getLocation(row.data[tools.settings('language')].pdf.url);									
									var fileUrl = endpoints.root+l.pathname;									
									return '<a target="_blank" href="'+fileUrl+'"><i class="fa fa-file-pdf-o"></i></a>';
                                },
                                "targets": [2]
                            }
                        ]
                    }
                })
                .on('xhr.dt', function ( e, settings, json, xhr ) {
                    /**
                     * Ad ogni aggiornamento di datatable:
                     *  - salva in sessionStorage i parametri di ricerca
                     *  - aggiorna le select delle faccette in base al risultato (json)
                     *  - esegue una query geo per aggiornare la mappa
                     */

                    // salva in sessionStorage i parametri di ricerca
                    var builder = JSON.stringify({
                        'builder': datatable.settings.builder,
                        'query': datatable.buildQuery()
                    });
                    sessionStorage.setItem(SessionCacheKey, builder);


                    $.each(json.facets, function(index,val){
                        // aggiorna le select delle faccette in base al risultato (json)
                        var facet = this;
                        tools.refreshFilterInput(facet, function(select){
                            select.trigger("chosen:updated");
                        });

                        // esegue una query geo per aggiornare la mappa
                        // in base ai risultati ottenuti cerca le sedi
                        if (facet.name == 'raw[meta_main_node_id_si]'){
                            var parentNodes = $.map(facet.data, function(element,index) {return parseInt(index)});
                            var query = geoMainQuery;
                            if (parentNodes.length){
                                query += ' and raw[meta_main_parent_node_id_si] in [' + parentNodes.join(',')  + ']';
                                var spinnerContainer = $('a[href="#geo"]');
                                var currentText = spinnerContainer.html();
                                var spinner = $('#tab-spinner');
                                if (spinner.length == 0) {
                                    spinner = $('<span id="tab-spinner"></span>');
                                    spinnerContainer.append(spinner);
                                }
                                spinner.html('<i class="fa fa-circle-o-notch fa-spin fa-fw"></i>');								
								tools.loadMarkersInMap(query, function(data){
                                    spinner.html(' ('+data.features.length+')');
                                });
                            }
                        }
                    });
                })
                .data('opendataDataTable');

        // carica i parametrtri di ricerca salvati in sessionStorage
        if (sessionStorage.getItem(SessionCacheKey)) {
            datatable.settings.builder = JSON.parse(sessionStorage.getItem(SessionCacheKey)).builder;
        }

        // giochini sulla mappa
        var geocoder = new L.Control.Geocoder({geocoder: null});
        if (window.XDomainRequest) geocoder.options.geocoder = L.Control.Geocoder.bing('Ahmnz1XxcrJXgiVWzx6W8ewWeqLGztZRIB1hysjaoHI5nV38WXxywjh6vj0lyl4u');
        else geocoder.options.geocoder = L.Control.Geocoder.google('AIzaSyDVnxoH2lLysFsPPQcwxZ0ROYNVCBkmQZk');

        var inputRange = $('input[name="CustomDrawRange"]');
        var selectEnte = $('select[name="SelectDrawEnte"]');
        var selectCustom = $('input[name="SelectDrawCustom"]');
        var currentEnteData = {
            lat: null,
            lon: null,
            range: null,
            title: null
        }, enteCircle, enteMarker;
        var drawEnteCircle = function(lat,lon,range,title){
            currentEnteData = {
                lat: lat,
                lon: lon,
                range: range,
                title: title
            };
            drawCircle();
        };
        var updateEnteCircleRange = function(range){
            currentEnteData.range = range;
            drawCircle();
        };
        var removeCircle = function(){
            if(typeof enteCircle == 'object'){
                map.removeLayer(enteCircle);
            }
            if(typeof enteMarker == 'object'){
                map.removeLayer(enteMarker);
            }
        };
        var fitBoundsCircle = function(){
            if(typeof enteCircle == 'object'){
                map.fitBounds(enteCircle.getBounds());
            }
        };
        var drawCircle = function(){
            removeCircle();
            if (currentEnteData.lat && currentEnteData.lon && currentEnteData.range && currentEnteData.title) {
                enteCircle = L.circle([currentEnteData.lat, currentEnteData.lon], currentEnteData.range, {
                    color: '#0b2',
                    fillColor: '#3f6',
                    fillOpacity: 0.2
                }).addTo(map);
                enteMarker = L.marker(
                        [currentEnteData.lat, currentEnteData.lon],
                        {icon: L.MakiMarkers.icon({icon: "star", color: '#000', size: "m"})}
                ).addTo(map).bindPopup(currentEnteData.title);
                fitBoundsCircle();
            }
        };

        // carica la pagina eseguendo una query a limit 1 per popolare le faccette
        tools.find(mainQuery + ' limit 1', function(response){
            $('.spinner').hide();
            $('.content-main').show();

            // carica jquery datatable
            datatable.loadDataTable();
			
			$('.dataTables_filter input').unbind().attr('placeholder','Premi invio per cercare');
			$('.dataTables_filter input').bind('keyup', function(e) {		  
			  if(e.keyCode == 13) {
				datatable.datatable.search(this.value).draw();
			  }
			}); 

            // popola il form delle faccette
            var form = $('<form class="form">');
            $.each(response.facets, function(){
                tools.buildFilterInput(facets, this, datatable, function(selectContainer){
                    form.append(selectContainer);
                });
            });

            $('.nav-section').append(form).show();
            selectEnte.val('');
            inputRange.val('');
            selectCustom.val('');
        });

        // workaround per mostrare la mappa su un tab panel
        $("body").on("shown.bs.tab", function() {
            tools.refreshMap();
        });

        $('.closeSelectDrawCustom').bind('click',function(){
            removeCircle();
            selectEnte.val('');
            selectEnte.parent().show();
            selectCustom.parent().hide();
        });
        selectEnte.bind('change', function(e){
            var option = $(e.currentTarget).find(':selected');
            var value = option.val();
            if (value == 'custom') {
                removeCircle();
                selectEnte.parent().hide();
                selectCustom.val('');
                inputRange.val('');
                selectCustom.parent().show();
            }else{
                var range = parseInt(option.data('range'));
                var latitude = option.data('latitude');
                var longitude = option.data('longitude');
                drawEnteCircle(latitude, longitude, range * 1000, option.html());
                inputRange.val(range);
            }
            e.preventDefault();
        });
        inputRange.bind('keyup change click', function (e) {
            if (! $(this).data("previousValue") ||
                    $(this).data("previousValue") != $(this).val())
            {
                updateEnteCircleRange($(this).val() * 1000);
                $(this).data("previousValue", $(this).val());
            }

        });
        selectCustom.bind('keypress',function(e){
            if(e.which == 13) {
                var defaultRange = 10;
                inputRange.val(defaultRange);
                var query = $(this).val();
                geocoder.options.geocoder.geocode(query, function (result) {
                    if(result.length == 0){
                        alert("Nessun risultato trovato")
                    }else{
                        drawEnteCircle(result[0].center.lat, result[0].center.lng, defaultRange * 1000, result[0].name);
                    }
                }, this);
            }
        });
    });

    {/literal}
</script>
{literal}
    <style>
        .chosen-search input, .chosen-container-multi input{height: auto !important}
    </style>
{/literal}

<div class="content-view-full class-folder row">

    <div class="spinner text-center col-md-12">
        <i class="fa fa-circle-o-notch fa-spin fa-3x fa-fw"></i>
        <span class="sr-only">Loading...</span>
    </div>

    <div class="nav-section" style="display: none">
    </div>

    <div class="content-main" style="display: none">
        <ul class="nav nav-tabs">
            <li class="active"><a data-toggle="tab" href="#table">Dati</a></li>
            <li><a data-toggle="tab" href="#geo">Mappa delle sedi</a></li>
        </ul>
        <div class="tab-content">
            <div id="table" class="tab-pane active"><div class="content-data"></div></div>
            <div id="geo" class="tab-pane">
                <div class="row" style="margin: 20px 0">
                    <div class="col-md-6">
                        <div class="form-group">
                            <label>Ente</label>
                            <select name="SelectDrawEnte" class="form-control">
                                <option value=""> - Seleziona un ente</option>
                                <option value="custom">  - oppure digita un indirizzo</option>
                                {foreach $enti.searchHits as $ente}
                                    <option value="{$ente.metadata.id}"
                                            data-latitude="{$ente.data['ita-IT'].geo.latitude}"
                                            data-longitude="{$ente.data['ita-IT'].geo.longitude}"
                                            data-range="{$ente.data['ita-IT'].km_range_interesse}">
                                        {$ente.data['ita-IT'].ente|wash()}
                                    </option>
                                {/foreach}
                            </select>
                        </div>
                        <div class="form-group" style="display: none">
                            <label style="display:block">Digita un indirizzo e premi invio:
                                <span class="pull-right closeSelectDrawCustom" style="cursor: pointer"><i class="fa fa-close"></i></span>
                            </label>
                            <input type="text" value="" name="SelectDrawCustom" class="form-control"/>
                        </div>
                    </div>
                    <div class="col-md-2">
                        <div class="form-group">
                            <label>Distanza in Km</label>
                            <input type="number" value="" name="CustomDrawRange" class="form-control"/>
                        </div>
                    </div>
                </div>
                <div id="map" style="width: 100%; height: 700px"></div>
            </div>
        </div>
    </div>

</div>
