<div class="facet-nav" role="navigation"> 
	{if $data.navigation|count}
	    <form class="form-facets" role="search" action={concat('facet/proxy/', $node.node_id)|ezurl()}>
			<div class="btn-group" style="width: 100%">
				<input id="searchfacet" data-content="Premi invio per cercare (in mancanza di * individua solo parole intere)" type="text" class="form-control" placeholder="Ricerca libera" name="query" value="{$data.query}">
				<span id="searchfacetclear" class="glyphicon glyphicon-remove-circle" style="position: absolute;right: 5px;top: 0;bottom: 0;height: 14px;margin: auto;font-size: 14px;cursor: pointer;color: #ccc;"></span>
			</div>
        	
		    {foreach $data.navigation as $name => $items}
		        {if or(eq( $name, 'Categorie generali (OG)' ), eq( $name, 'Attivita' ), eq( $name, 'Ente' ), eq( $name, 'Tipologia dipendente' ))}
		            <hr/>
		        {/if}
		        <div class="form-group">
		        {if or(eq( $name, 'Categorie generali (OG)' ), eq( $name, 'Classifica OG' ), eq( $name, 'Categorie specializzate (OS)' ), eq( $name, 'Classifica OS' ), eq( $name, 'Attivita' ))}
					<select class="facet-select" data-placeholder="{$name|wash()}" name="{$name|wash()}" multiple="multiple">
				{else}
					<select class="facet-select" data-placeholder="{$name|wash()}" name="{$name|wash()}">
		        {/if}
		          <option></option>
		          {foreach $items as $item}
	            	<option {if $item.active}selected="selected"{/if} value="{$item.query}">{$item.name|wash()} {if $item.count|gt(0)}({$item.count}){/if}</option>
		          {/foreach}
		        </select>
			  </div>
			{/foreach}
    		<button type="submit" class="btn btn-info"><span class="glyphicon glyphicon-search"></span></button>
  		</form>
	{/if}	
</div>
{literal}
	<style>
	  .chosen-search input{height: auto !important}
	</style>
{/literal}