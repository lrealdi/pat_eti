{set_defaults(hash(
  'page_limit', 10
))}

{def $root_nodes = array( $node.node_id )
    $self = object_handler( $node )}
{if is_set( $self.content_virtual.folder.subtree )}
 {set $root_nodes = $self.content_virtual.folder.subtree}
{/if}

{def $data = class_search_result(  hash( 'subtree_array', $root_nodes,
                    'sort_by', hash( 'published', 'desc' ),
                    'limit', $page_limit ),
                  $view_parameters )}
<div class="row">
 <div class="col-md-8">
 {if and( $data.is_search_request, is_set( $view_parameters.class_id ) )}

   <h2>Risultati della ricerca</h2>
   <p class="navigation">
     {foreach $data.fields as $field}
     <a class="btn btn-xs btn-info" href={concat( $node.url_alias, $field.remove_view_parameters )|ezurl()}>
     <i class="fa fa-close"></i> <strong>{$field.name}:</strong> {$field.value}
     </a>
     {/foreach}
     <a class="btn btn-xs btn-danger" href={$node.url_alias|ezurl()}>Annulla ricerca</a>
   </p>
   
   {if $data.count}	  
     
     <div class="content-view-children">  
       <div class="row panels-container"> 
       {foreach $data.contents as $child }
         <div class="col-md-6">
           {node_view_gui content_node=$child view=panel image_class=widemedium}
         </div>
         {delimiter modulo=2}</div><div class="row panels-container">{/delimiter}
       {/foreach}
       </div>
     </div>
     
     {include name=navigator
             uri='design:navigator/google.tpl'
             page_uri=$node.url_alias
             item_count=$data.count
             view_parameters=$view_parameters
             item_limit=$page_limit}
   {else}
     <div class="warning">Nessun risultato</div>
   {/if}	
 {else}
 
  {include uri='design:parts/children/panels.tpl'}
 
 {/if}
 </div>

 {def $currentClass = false()}


 {def $classes = fetch( 'class', 'list', hash( 'class_filter', array('dichiarazione_impresa') ) )}
    
 {*
 {if is_set( $self.content_virtual.folder.classes )}
   {def $classes = fetch( 'class', 'list', hash( 'class_filter', $self.content_virtual.folder.classes ) )}
 {else}
   {def $classes = fetch( 'ocbtools', 'children_classes', hash( 'parent_node_id', $node.node_id ) )}
 {/if}
 *}

 {if $data.is_search_request}	
   {set $currentClass = cond( is_set( $data.fetch_parameters.class_id ), $data.fetch_parameters.class_id, $classes[0].id )}  
 {elseif count( $classes )|eq(1)}
   {set $currentClass = $classes[0].id}  	
 {/if}

 {if $currentClass|not()}
   {set $currentClass = $classes[0].id}
 {/if}
 
 {if count( $classes )|gt(0)}
 <div class="col-md-4">
   <div class="widget">
     <div class="widget_title">
       <h3>Cerca</h3>
     </div>
     <div class="widget_content">

       {if count( $classes )|gt(1)}
       <ul class="nav nav-tabs" role="tablist">	  
         {foreach $classes as $class}
             <li{if $currentClass|eq( $class.id )} class="active"{/if}><a href="#{$class.identifier}" role="tab" data-toggle="tab">{$class.name|wash()}</a></li>
         {/foreach}
       </ul>      
       {/if}
       
       <div class="tab-content">
         {foreach $classes as $class}
         <div class="tab-pane{if $currentClass|eq( $class.id )} active{/if}" id="{$class.identifier}">
         {class_search_form( $class.identifier, hash( 'RedirectNodeID', $node.node_id ) )}
         </div>
         {/foreach}
       </div>
     
     </div>
   </div>	
 {/if}
</div>