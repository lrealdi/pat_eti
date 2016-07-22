{def $openpa = object_handler($node)}
{if $openpa.content_tools.editor_tools}
    {include uri=$openpa.content_tools.template}
{/if}

{def $ente_filter_string = ''}
{def $user=fetch( 'user', 'current_user' )}

{if $user.contentobject.data_map.ente_appartenenza.has_content}
    {def $ente_filter = array()}
    {foreach $user.contentobject.data_map.ente_appartenenza.content.relation_list as $ente_related}
        {set $ente_filter = $ente_filter|append($ente_related.contentobject_id)}
    {/foreach}
    {if count($ente_filter)}
        {set $ente_filter_string = concat(' and elenco_ente_iscrizione.id in [',$ente_filter|implode(','), ']')}
    {/if}
{/if}


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
    'leaflet.makimarkers.js'
))}

<script type="text/javascript" language="javascript" class="init">
    var mainQuery = "{concat( 'classes [dichiarazione_impresa]', $ente_filter_string)}";
    var geoMainQuery = 'classes [sede_azienda]';
    console.log(mainQuery);
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

        mainQuery += ' facets ['+tools.buildFacetsString(facets)+']';

        /**
         * Inizializzazione della mappa
         * il callback viene interpellato da loadMarkersInMap e si aspetta un oggetto GeoJson
         */
        var datatable;
        tools.initMap(
                'map',
                function (response) {
                    return L.geoJson(response, {
                        pointToLayer: function (feature, latlng) {

                            /**
                             * Customizzazione delle icone di marker in base a stringhe sul properties.name
                             */

                            var customIcon, iconaSede, coloreSede;
                            if (feature.properties.name.search('Sede legale')) {
                                iconaSede = "building";
                                coloreSede = '#00f';
                                customIcon = L.MakiMarkers.icon({icon: iconaSede, color: coloreSede, size: "l"});
                            } else if (feature.properties.name.search('Sede amministrativ')) {
                                iconaSede = "commercial";
                                coloreSede = '#0f0';
                                customIcon = L.MakiMarkers.icon({icon: iconaSede, color: coloreSede, size: "l"});
                            } else if (feature.properties.name.search('Stabilimento')) {
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
                            url: "/etiexport/api/datatable/search/"
                        },
                        "columns": [
                            {"data": "data."+tools.settings('language')+".ragione_sociale_azienda", "name": 'ragione_sociale_azienda', "title": 'Ragione sociale'},
                            {"data": "data."+tools.settings('language')+".elenco_sedi_azienda", "name": 'elenco_sedi_azienda', "title": 'Sedi', "serchable": false, "orderable": false}
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
                                        ul.append($('<li>').html(this.name[tools.settings('language')]));
                                    });
                                    return list.html();
                                },
                                "targets": [1]
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

        // carica la pagina eseguendo una query a limit 1 per popolare le faccette
        tools.find(mainQuery + ' limit 1', function(response){
            $('.spinner').hide();
            $('.content-main').show();

            // carica jquery datatable
            datatable.loadDataTable();

            // popola il form delle faccette
            var form = $('<form class="form">');
            $.each(response.facets, function(){
                tools.buildFilterInput(facets, this, datatable, function(selectContainer){
                    form.append(selectContainer);
                });
            });

            $('.nav-section').append(form).show();
        });

        // workaround per mostrare la mappa su un tab panel
        $("body").on("shown.bs.tab", function() {
            tools.refreshMap();
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
            <div id="geo" class="tab-pane"><div id="map" style="width: 100%; height: 700px"></div></div>
        </div>
    </div>

</div>
