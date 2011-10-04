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

    @fb_tab_browser = Browser.new(@service_tab_folder, SWT::NONE)

    if (@config.has_key? 'fb') then
      @agents[:fb].get_access_token(@config['fb']['token'])
      @fb_tab_browser.setText 'Already authorized'
    else
      @fb_tab_browser.setUrl(@agents[:fb].get_authorize_url)
    end
    @fb_tab_browser.addProgressListener { |event|
      if not @config.has_key? 'fb' then
        if event.total == event.current then
          if @fb_tab_browser.getUrl =~ /https:\/\/www.facebook.com\/connect\/login_success.html/ then
            @config['fb'] = {'token' => @agents[:fb].get_access_token(@fb_tab_browser.getUrl, @fb_tab_browser.getText) }
            write_config
          end
        end
      end
    }
    @fb_tab.setControl(@fb_tab_browser)

    @plurk_tab = TabItem.new @service_tab_folder, SWT::NONE
    @plurk_tab.setText "Plurk"

    @plurk_tab_browser = Browser.new(@service_tab_folder, SWT::NONE)
    if @config.has_key? 'plurk' then
      @agents[:plurk].get_access_token(@config['plurk']['token'], @config['plurk']['secret'])
    else
      @plurk_tab_browser.setUrl(@agents[:plurk].get_authorize_url)
    end

    if @agents[:plurk].has_authorized? then
      @plurk_tab_browser.setText 'Already authorized'
    else
      @agents[:plurk] = PlurkAgent.new
      @plurk_tab_browser.setUrl(@agents[:plurk].get_authorize_url)
    end

    @plurk_tab_browser.addProgressListener { |event|
      if @plurk_tab_browser.getUrl == 'http://www.plurk.com/OAuth/authorizeDone' then
        if event.total == event.current then
          html = Nokogiri::HTML(@plurk_tab_browser.getText)
          token = @agents[:plurk].get_access_token(html.xpath("//*/span[@id='oauth_verifier']").first.text)
          @config['plurk'] = {'token' => token[:token], 'secret' => token[:secret]}
          write_config
        end
      end
    }
    @plurk_tab.setControl(@plurk_tab_browser)

    if not @fb_tab_browser.getText == 'Already authorized' then
      #@settings_window.open
    elsif not @plurk_tab_browser.getText == 'Already authorized' then
      #@service_tab_folder.setSelection @plurk_tab_browser
      @settings_window.open
    else
      return true
    end
    return false
  end
end
