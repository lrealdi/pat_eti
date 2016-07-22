<!-- Path content: START -->
<div class="container">
  <ul class="breadcrumb">
    {foreach $pagedata.default_path_array as $path}
      {if $path.url}
        <li>
          <a href={cond( is_set( $path.url_alias ), $path.url_alias, $path.url )|ezurl}>{$path.text|wash}</a>
        </li>
      {else}
        <li class="active">
          {$path.text|wash}
        </li>
      {/if}
    {/foreach}
  </ul>
</div>
<!-- Path content: END -->
