{def $node_item = fetch('content', 'node', hash('node_id', $menu_item.item.node_id))
     $file_url=false()}

{if $node_item.object.class_name|eq('File')}
    {def $file = $node_item|attribute('file')}
    
    {set $file_url = concat("content/download/", $file.contentobject_id, "/", $file.id, "/file/", $file.content.original_filename)|ezurl(no)}
    
    {undef $file}
{/if}

<a href="
        {if $file_url}
            {$file_url}
        {else}
            {if $menu_item.item.internal}{$menu_item.item.url|ezurl(no)}{else}{$menu_item.item.url}{/if}
        {/if}
        " 
   
    {if $menu_item.item.target}target="{$menu_item.item.target}"{/if} 
    title="Vai a {$menu_item.item.name|wash()}">
    {if is_set($bold)}<b>{/if}{$menu_item.item.name|wash()}{if is_set($bold)}</b>{/if}
    
    {if ezini_hasvariable('MenuItemIcons', concat('Node_', $menu_item.item.node_id), 'fa_icons.ini')} 
        <i class="fa {ezini('MenuItemIcons', concat('Node_', $menu_item.item.node_id), 'fa_icons.ini')}"></i>
    {/if}
</a>

{undef $node_item
       $file_url}