{def $openpa = object_handler($node)}
{if $openpa.content_tools.editor_tools}
    {include uri=$openpa.content_tools.template}
{/if}

{def $page_limit = 50}
{def $ente_filters = array()}
{def $user=fetch( 'user', 'current_user' )}

{if $user.contentobject.data_map.ente_appartenenza.has_content}
    {def $ente_filter = array('or')}
    {foreach $user.contentobject.data_map.ente_appartenenza.content.relation_list as $itemUser}
        {def $infoUser = fetch( 'content', 'object', hash( 'object_id', $itemUser.contentobject_id) )}

        {set $ente_filter = $ente_filter|append(array(concat('extra_ente____s:"',$infoUser.data_map.ente.content,'"')))}
    {/foreach}
    {set $ente_filters = hash('filter',array($ente_filter))}
{/if}

{def $data = facet_navigation(
    hash(
        'subtree_array', array( $node.object.main_node_id ),
        'class_id', array( 'dichiarazione_impresa' ),
        'limit', $page_limit,
        'offset', $view_parameters.offset,
        'sort_by', hash('name', 'asc' ),
        'facet', array(
            hash( 'field', 'extra_tipo_sede____s', 'name', 'Tipologia sede aziendale', 'limit', 300, 'sort', 'alpha'),
            hash( 'field', 'extra_provincia_sede____s', 'name', 'Provincia sede aziendale', 'limit', 300, 'sort', 'alpha'),
            hash( 'field', 'extra_comune_sede____s', 'name', 'Comune sede aziendale', 'limit', 300, 'sort', 'alpha'),
            hash( 'field', 'extra_categoria_generale____s', 'name', 'Categorie generali (OG)', 'limit', 300, 'sort', 'alpha'),
            hash( 'field', 'extra_categoria_generale_classifica____s', 'name', 'Classifica OG', 'limit', 300, 'sort', 'alpha'),
            hash( 'field', 'extra_categoria_specializzata____s', 'name', 'Categorie specializzate (OS)', 'limit', 300, 'sort', 'alpha'),
            hash( 'field', 'extra_categoria_specializzata_classifica____s', 'name', 'Classifica OS', 'limit', 300, 'sort', 'alpha'),
            hash( 'field', 'extra_attivita____s', 'name', 'Attivita', 'limit', 300, 'sort', 'alpha'),
            hash( 'field', 'extra_dipendenti_tipologia____s', 'name', 'Tipologia dipendente', 'limit', 300, 'sort', 'alpha'),
            hash( 'field', 'extra_dipendenti_determinati____s', 'name', 'Numero dip. determinati', 'limit', 300, 'sort', 'alpha'),
            hash( 'field', 'extra_dipendenti_indeterminati____s', 'name', 'Numero dip. indeterminati', 'limit', 300, 'sort', 'alpha'),
            hash( 'field', 'extra_ente____s', 'name', 'Ente', 'limit', 300, 'sort', 'alpha')
        )
    )|merge($ente_filters),
    $view_parameters,
    $node.url_alias
)}

{ezscript_require( array( 'ezjsc::jquery', 'ezjsc::jqueryio', 'plugins/chosen.jquery.js', 'jquery.facetnavigation.js', 'jquery.tablesorter.min.js' ) )}

<script>
    {literal}
    $(document).ready(function () {
        $('#facetcontainer').facetnavigation({
            useForm: true,
            navigationContainer: ".facet-nav",
            json: '{/literal}{$data.json_params|wash(javascript)}{/literal}',
            token: '{/literal}{$data.token}{/literal}',
            template: {
                content: {
                    name: "parts/dichiarazione/facet-children.tpl",
                    view: "line",
                    page_limit: {/literal}{$page_limit}{/literal}
                },
                navigation: "parts/dichiarazione/facet-nav.tpl"
            },
            chosen: {
                allow_single_deselect: true,
                width: '100%'
            }
        });
        $("table.list").tablesorter();
        $("table.list th").css( 'cursor', 'pointer' );
    });
    {/literal}
</script>

<div id="facetcontainer" class="content-view-full class-folder row">

    <div class="nav-section">
        {include uri='design:parts/dichiarazione/facet-nav.tpl' data=$data}
    </div>

    <div class="content-main">
        {include uri='design:parts/dichiarazione/facet-children.tpl' view='line' data=$data}
    </div>

</div>
