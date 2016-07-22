{def $identifiers = array()}
{if fetch( 'user', 'has_access_to', hash( 'module', 'ufficiostampa', 'function', 'dashboard' ) )}
  {foreach $helper.attribute_fields as $input}
    {set $identifiers = $identifiers|append($input.class_attribute.identifier)}
  {/foreach}
{else}
  {set $identifiers = array( 'published', 'tags', 'argomento' )}
{/if}

<form name="{concat('class_search_form_',$helper.class.identifier)}" method="get" action="{'/ocsearch/action'|ezurl( 'no' )}">

  {include uri='design:class_search_form/query.tpl' helper=$helper input=$helper.query_field}

  {foreach $helper.attribute_fields as $input}
    {if $identifiers|contains( $input.class_attribute.identifier )}
      {attribute_search_form( $helper, $input )}
    {/if}
  {/foreach}

  {include uri='design:class_search_form/sort.tpl' helper=$helper input=$helper.sort_field}

  {*include uri='design:class_search_form/publish_date.tpl' helper=$helper input=$helper.published_field*}

  {foreach $parameters as $key => $value}
	<input type="hidden" name="{$key}" value="{$value}" />
  {/foreach}

  <input type="hidden" name="class_id" value="{$helper.class.id}" />

  <button class="defaultbutton" type="submit">{'Search'|i18n('design/ocbootstrap/pagelayout')}</button>
</form>