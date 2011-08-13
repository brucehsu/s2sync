class S2sync
  def init_setting_window
    @settings_window = Shell.new @display
    @settings_window.setSize(300, 300)

    @user_secret = {}

    layout = GridLayout.new 1, false
    layout.makeColumnsEqualWidth = true
    @settings_window.setLayout layout

    @service_tab_folder = TabFolder.new @settings_window, SWT::BORDER
    @service_tab_folder.setLayoutData(GridData.new(GridData::FILL, GridData::FILL, true, true, 1, 1))

    @fb_tab = TabItem.new @service_tab_folder, SWT::NONE
    @fb_tab.setText "Facebook"

    @fb_tab_browser = Browser.new(@service_tab_folder, SWT::V_SCROLL | SWT::H_SCROLL)
    @fb_tab_browser.setUrl @fb_agent.get_authorize_url
    @fb_tab_browser.addProgressListener { |event|
      if event.total == event.current then
        if (url = @fb_agent.get_access_token(@fb_tab_browser.getUrl, @fb_tab_browser.getText)) != nil then
          @fb_tab_browser.setUrl url
        end
      end
    }
    @fb_tab.setControl(@fb_tab_browser)

    @plurk_tab = TabItem.new @service_tab_folder, SWT::NONE
    @plurk_tab.setText "Plurk"

    @plurk_tab_browser = Browser.new(@service_tab_folder, SWT::V_SCROLL | SWT::H_SCROLL)
    @plurk_tab_browser.setUrl(@plurk_agent.get_authorize_url)
    @plurk_tab_browser.addProgressListener { |event|
      if @plurk_tab_browser.getUrl == 'http://www.plurk.com/OAuth/authorizeDone' then
        if event.total == event.current then
          html = Nokogiri::HTML(@plurk_tab_browser.getText)
          @plurk_agent.get_access_token(html.xpath("//*/span[@id='oauth_verifier']").first.text)
          @plurk_tab_browser.setText "<html><body><div width=\"100%\" align=\"center\">#{html.xpath("//*/span[@id='oauth_verifier']").first.text}</div></body></html>"
        end
      end
    }
    @plurk_tab.setControl(@plurk_tab_browser)

    @settings_window.open

  end
end