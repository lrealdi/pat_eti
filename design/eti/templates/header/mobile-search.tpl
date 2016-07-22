
{if not(is_set(ezhttp('SearchText', 'get')))}
<div class="col-md-12 mobile-search">
    <form action="{"/content/advancedsearch"|ezurl(no)}" id="topsearch">
    <div class="input-group">
            <input placeholder="Ricerca libera" class="form-control input-lg" type="text" name="SearchText" id="Search" value="{$search_text|wash}" />
                        <span class="input-group-btn">
                            <button type="submit" name="SearchButton" class="btn-primary btn btn-lg" title="{'Search'|i18n('design/ezwebin/content/search')}">
                                <span class="glyphicon glyphicon-search"></span>
                            </button>
                        </span>
    </div>
    </form>
</div>
{/if}