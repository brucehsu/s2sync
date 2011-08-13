require 'java'
require 'open-uri'
require 'net/https'
require 'rubygems'
require 'nokogiri'

require 'service_auth'
require 'settings_window'

class S2sync
  include_package 'org.eclipse.swt'
  include_package 'org.eclipse.swt.layout'
  include_package 'org.eclipse.swt.widgets'
  include_package 'org.eclipse.swt.events'
  include_package 'org.eclipse.swt.browser'

  def initialize
    @auth = ServiceAuth.new
    Display.setAppName "Social Status Sync"

    @display = Display.new
    @main_window = Shell.new @display
    @main_window.setSize(250, 300)

    layout = GridLayout.new 5, false
    layout.makeColumnsEqualWidth = true

    @main_window.setLayout layout
    @main_window.setText "Social Status Sync"

    @status_field = Text.new(@main_window, SWT::MULTI | SWT::WRAP)
    @status_field.setLayoutData(GridData.new(GridData::FILL, GridData::FILL, true, true, 5, 5))
    @status_field.addModifyListener { |event|
      #split(//u) eliminates extra bytes in Unicode string and get exact length
      @word_count_label.setText(@status_field.getText.split(//u).length.to_s)
    }

    @update_button = Button.new(@main_window, SWT::PUSH)
    @update_button.setText "Update"
    @update_button.setLayoutData(GridData.new(GridData::FILL, GridData::FILL, true, false, 5, 1))
    @update_button.addSelectionListener { |event|
      #for plurk
      @auth.get_access_token(:plurk).post('http://www.plurk.com/APP/Timeline/plurkAdd', {"content"=>@status_field.getText, "qualifier" => "says"}, nil).body

      #for facebook
      uri = URI.parse("https://graph.facebook.com/brucehsu13/feed")
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      data = "access_token=#{CGI::escape @fb_token}&message=#{CGI::escape @status_field.getText}"
      res = http.post(uri.path,data, {'Content-Type'=> 'application/x-www-form-urlencoded'})
      puts res.body

    }

    @setting_button = Button.new(@main_window, SWT::PUSH)
    @setting_button.setText "Service Settings"
    @setting_button.setLayoutData(GridData.new(GridData::FILL, GridData::FILL, true, false, 5, 1))
    @setting_button.addSelectionListener { |event|
      init_setting_window
    }

    @word_count_label = Label.new(@main_window, SWT::RIGHT)
    @word_count_label.setText "     0"
    @word_count_label.setLayoutData(GridData.new(GridData::END, GridData::CENTER, true, false, 5, 1))

    @main_window.open

    while (!@main_window.isDisposed) do
      @display.sleep unless @display.readAndDispatch
    end

    @display.dispose
  end

end

S2sync.new