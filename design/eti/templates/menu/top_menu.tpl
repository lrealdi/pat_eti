<div class="main-nav" role="navigation">

        <ul class="horizontal_list main_menu clearfix">
          {def $top_menu_node_ids = openpaini( 'TopMenu', 'NodiCustomMenu', array() )}
          {def $top_menu_node_ids_count = $top_menu_node_ids|count()}
          {if $top_menu_node_ids_count}
            {foreach $top_menu_node_ids as $id}
              {def $tree_menu = tree_menu( hash( 'root_node_id', $id, 'scope', 'top_menu'))}
              <li class="menu-item{if or($tree_menu.item.node_id|eq($current_node_id), $pagedata.path_id_array|contains($tree_menu.item.node_id))} current{/if}">
                {include name=top_menu uri='design:menu/top_menu_item.tpl' menu_item=$tree_menu bold=true()}
              </li>
              {undef $tree_menu}
            {/foreach}
          {/if}
        </ul>
</div>