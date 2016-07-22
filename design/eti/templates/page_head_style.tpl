{if is_unset( $load_css_file_list )}
    {def $load_css_file_list = true()}
{/if}

{if $load_css_file_list}
  {ezcss_load( array( 'app.css',
                      'app_2.css',
                      'debug.css',
                      'websitetoolbar.css',
                      ezini( 'StylesheetSettings', 'CSSFileList', 'design.ini' ),
                      ezini( 'StylesheetSettings', 'FrontendCSSFileList', 'design.ini' ) ), 'all', 'text/css', 'stylesheet', '', cond( $ie9|eq(1), 0, 3 ) )}
{else}
  {ezcss_load( array( 'app.css',
                      'app_2.css',
                      'debug.css',
                      'websitetoolbar.css' ), 'all', 'text/css', 'stylesheet', '', cond( $ie9|eq(1), 0, 3 ) )}
{/if}