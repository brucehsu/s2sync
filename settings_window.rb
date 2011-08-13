class S2sync
  def init_setting_window
    @settings_window = Shell.new @display
    @settings_window.setSize(300, 300)

    layout = GridLayout.new 1, false
    layout.makeColumnsEqualWidth = true
    @settings_window.setLayout layout

    @service_tab_folder = TabFolder.new @settings_window, SWT::BORDER
    @service_tab_folder.setLayoutData(GridData.new(GridData::FILL, GridData::FILL, true, true, 1, 1))

    @fb_tab = TabItem.new @service_tab_folder, SWT::NONE
    @fb_tab.setText "Facebook"

    @fb_tab_browser = Browser.new(@service_tab_folder,SWT::V_SCROLL | SWT::H_SCROLL)
    #@fb_tab_browser.setUrl ''
    @fb_tab.setControl(@fb_tab_browser)

    @plurk_tab = TabItem.new @service_tab_folder, SWT::NONE
    @plurk_tab.setText "Plurk"
    
    @plurk_tab_browser = Browser.new(@service_tab_folder,SWT::V_SCROLL | SWT::H_SCROLL)
    @plurk_tab_browser.setUrl(@auth.get_authorize_url(:plurk))
    @plurk_tab.setControl(@plurk_tab_browser)

    @settings_window.open

  end
end