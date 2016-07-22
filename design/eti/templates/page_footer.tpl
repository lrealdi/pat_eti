<div id="footer">

{if and( $ui_context|ne( 'edit' ), $ui_context|ne( 'browse' ), $pagedata.is_login_page|not() )}
    <div class="footer_top_part">
        <div class="container">
            <div class="row clearfix">

              {include uri='design:footer/notes.tpl'}

              {include uri='design:footer/contacts.tpl'}

              {def $footer_links = fetch( 'openpa', 'footer_links' )
                   $footer_objects = array()
                   $footer_banner = array()}
                {if count( $footer_links )}
                  {foreach $footer_links as $item}
                    {if $item.class_identifier|eq('banner')}
                      {set $footer_banner = $footer_banner|append($item)}
                    {else}
                      {set $footer_objects = $footer_objects|append($item)}
                    {/if}
                  {/foreach}
                {/if}
              {undef $footer_links}
              <div class="col-lg-3 col-md-3 col-sm-3 m_xs_bottom_30 m_top_20">
                  {if count( $footer_objects )}
                      <ul class="list-unstyled vertical_list">
                          {foreach $footer_objects as $item}
                              {def $href = $item.url_alias|ezurl(no)}
                              {if eq( $ui_context, 'browse' )}
                                  {set $href = concat("content/browse/", $item.node_id)|ezurl(no)}
                              {elseif $pagedata.is_edit}
                                  {set $href = '#'}
                              {elseif and( is_set( $item.data_map.location ), $item.data_map.location.has_content )}
                                  {set $href = $item.data_map.location.content}
                              {/if}
                              <li><a href="{$href}" title="Leggi {$item.name|wash()}">{$item.name|wash()}<i class="fa fa-angle-right"></i></a></li>
                              {undef $href}
                          {/foreach}
                      </ul>
                  {/if}
              </div>

              <div class="col-lg-3 col-md-3 col-sm-3 m_xs_bottom_30 m_top_20">
                {if count( $footer_banner )}
                        <ul class="list-unstyled vertical_list footer_banner">
                          {foreach $footer_banner as $item}
                              {def $banner = object_handler( $item )
                                   $href = $banner.content_link.full_link}
                              {if eq( $ui_context, 'browse' )}
                                  {set $href = concat("content/browse/", $item.node_id)|ezurl(no)}
                              {elseif $pagedata.is_edit}
                                  {set $href = '#'}                              
                              {/if}
                              {if $item|has_attribute('image')}
                              <li>
                                {attribute_view_gui attribute=$item|attribute('image') image_class='widemedium' href=$href title=$item.name|wash()}
                              </li>
                              {/if}
                              {undef $href $banner}
                          {/foreach}
                      </ul>
                {/if}
              </div>

            </div>
        </div>
  </div>
{/if}

  <div class="footer_bottom_part">
    <div class="container clearfix t_mxs_align_c">
        {*include uri='design:footer/copyright.tpl'*}
    </div>
  </div>

</div>