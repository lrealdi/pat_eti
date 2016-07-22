<div class="header-logo">
  <a href={"/"|ezurl} title="{ezini('SiteSettings','SiteName')}">
    {if $pagedata.header.logo.url}
      <img class="img-responsive center-block img-mobile" src={$pagedata.header.logo.url|ezroot()} alt="{ezini('SiteSettings','SiteName')}" />
    {/if}
  </a>
</div>