<div class="container">
  <div class="row">
    <div class="col-md-12">
      <ul class="list-inline pull-right text-center">
        
        {if $current_user.is_logged_in}
      {*
          {if fetch( 'user', 'has_access_to', hash( 'module', 'ufficiostampa', 'function', 'dashboard' ) )}      
            <li><a href={"/ufficiostampa/dashboard/"|ezurl} title="Pannello strumenti" class="has_tooltip"  data-toggle="tooltip" data-placement="bottom"><i class="fa fa-dashboard"></i></a></li>
              {/if}
*}
          {if fetch( 'user', 'has_access_to', hash( 'module', 'user', 'function', 'selfedit' ) )}
            <li id="myprofile"><a href={"/user/edit/"|ezurl} title="Visualizza il tuo profilo utente" class="has_tooltip" data-toggle="tooltip" data-placement="bottom"><i class="fa fa-user"></i></a></li>
          {/if}
          
          <li id="logout"><a href={"/user/logout"|ezurl} class="has_tooltip" title="Esegui il logout ({$current_user.contentobject.name|wash})" data-toggle="tooltip" data-placement="bottom"><i class="fa fa-unlock"></i> <small>{$current_user.login|wash()}</small></a></li>
      
        {else}
      
          <li id="login"><a href={concat("/user/login?url=",$module_result.uri)|ezurl} class="has_tooltip" title="Accedi con il tuo account utente" data-toggle="tooltip" data-placement="bottom"><i class="fa fa-lock"></i></a></li>
          {*<li id="registeruser"><a href={"/user/register"|ezurl} class="has_tooltip"  data-toggle="tooltip" data-placement="bottom" title="Crea il tuo utente per accedere alle aree riservate"><i class="fa fa-child"></i></a></li>*}
      
        {/if}                
        
        {*<li><a href={"/notification/settings/"|ezurl} title="Per rimanere aggiornato" class="has_tooltip"  data-toggle="tooltip" data-placement="bottom"><i class="fa fa-rss"></i></a></li>*}
        
        {if is_set( $pagedata.contacts.telefono )}
          <li><a href="tel:{$pagedata.contacts.telefono}" class="has_tooltip" title="Telefono {$pagedata.contacts.telefono}" data-toggle="tooltip" data-placement="bottom"><i class="fa fa-phone-square"></i></a></li>
        {/if}
        
        {if is_set( $pagedata.contacts.email )}
          <li><a href="mailto:{$pagedata.contacts.email}" class="has_tooltip" title="Email {$pagedata.contacts.email}" data-toggle="tooltip" data-placement="bottom"><i class="fa fa-envelope-o"></i></a></li>
        {/if}
      </ul>
    </div>
{*
	<div class="col-md-3">
	  <form action="{"/content/advancedsearch"|ezurl(no)}" id="topsearch">
		  {if $pagedata.is_edit|not()}
			<input type="text" name="SearchText" class="top-search-text" placeholder="Ricerca libera">
			<input id="facet_field" name="facet_field" value="class" type="hidden" />
			<input type="hidden" value="Cerca" name="SearchButton" />
			<button type="submit" name="SearchButton" class="btn btn-link" style="color: #fff; font-size: 1em"><i class="fa fa-search "></i> </button>
			{if eq( $ui_context, 'browse' )}
			  <input name="Mode" type="hidden" value="browse" />
			{/if}
		  {/if}
	  </form>
	</div>
*}
  </div>
</div>