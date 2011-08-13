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
    @fb_tab_browser.setUrl "https://www.facebook.com/dialog/oauth?client_id=#{FB_APP_KEY}&redirect_uri=" +
                               "https://www.facebook.com/connect/login_success.html&scope=publish_stream,read_stream"
    @fb_tab_browser.addProgressListener { |event|
      if event.total == event.current then
        if @fb_tab_browser.getUrl =~ /https:\/\/www.facebook.com\/connect\/login_success.html\?code=(\w|\W)+/ then
          fb_code = @fb_tab_browser.getUrl.split(/https:\/\/www.facebook.com\/connect\/login_success.html\?code=/)[1]
          @fb_tab_browser.setUrl "https://graph.facebook.com/oauth/access_token?"+
                                     "client_id=#{FB_APP_KEY}&redirect_uri=" +
                                     "https://www.facebook.com/connect/login_success.html" +
                                     "&client_secret=#{FB_APP_SECRET}&code=#{fb_code}"
        end
        if @fb_tab_browser.getText =~ /access_token=(\w|\W)*&expires=(\d)+/ then
          @fb_token = @fb_tab_browser.getText.split(/access_token=/)[1].split(/&expires=/)[0]
          puts @fb_token
        end
      end
    }
    @fb_tab.setControl(@fb_tab_browser)

    @plurk_tab = TabItem.new @service_tab_folder, SWT::NONE
    @plurk_tab.setText "Plurk"

    @plurk_tab_browser = Browser.new(@service_tab_folder, SWT::V_SCROLL | SWT::H_SCROLL)
    @plurk_tab_browser.setUrl(@auth.get_authorize_url(:plurk))
    @plurk_tab_browser.addProgressListener { |event|
      if @plurk_tab_browser.getUrl == 'http://www.plurk.com/OAuth/authorizeDone' then
        if event.total == event.current then
          html = Nokogiri::HTML(@plurk_tab_browser.getText)
          @auth.get_access_token(:plurk, html.xpath("//*/span[@id='oauth_verifier']").first.text)
          @plurk_tab_browser.setText "<html><body><div width=\"100%\" align=\"center\">#{html.xpath("//*/span[@id='oauth_verifier']").first.text}</div></body></html>"
        end
      end
    }
    @plurk_tab.setControl(@plurk_tab_browser)

    @settings_window.open

  end
end