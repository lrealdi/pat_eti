<div class="header-menu" id="navigation">
  {if $pagedata.is_login_page|not()}
  <div class="clearfix t_sm_align_l f_right f_sm_none f_md_none relative s_form_wrap m_sm_bottom_15 p_xs_hr_0 m_xs_bottom_5">
    <!--button for responsive menu-->
    <button id="menu_button" class="btn btn-primary btn-lg btn-block d_none d_xs_block m_xs_bottom_5">
      MENU
    </button>

    <!--main menu-->
    {include uri=concat('design:menu/top_menu.tpl')}
  </div>
  {/if}
</div>