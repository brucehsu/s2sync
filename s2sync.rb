require 'java'
require 'rubygems'
require 'nokogiri'
require 'yaml'

require 'plurk_agent'
require 'fb_agent'
require 'settings_window'

class S2sync
  include_package 'org.eclipse.swt'
  include_package 'org.eclipse.swt.layout'
  include_package 'org.eclipse.swt.widgets'
  include_package 'org.eclipse.swt.events'
  include_package 'org.eclipse.swt.browser'

  def initialize
    init_agent
    read_config

    Display.setAppName "Social Status Sync"

    @display = Display.new
    @main_window = Shell.new @display
    @main_window.setSize(250, 300)

    layout = GridLayout.new 5, false
    layout.makeColumnsEqualWidth = true

    @main_window.setLayout layout
    @main_window.setText "Social Status Sync"

    init_widgets(layout)
    init_listener
    init_setting_window

    @main_window.open

    while (!@main_window.isDisposed) do
      @display.sleep unless @display.readAndDispatch
    end

    @display.dispose
  end

  def init_agent
    @agents = {}
    @agents[:fb] = FBAgent.new
    @agents[:plurk] = PlurkAgent.new
  end

  def init_listener
    #Display current content length
    @status_field.addModifyListener { |event|
      #split(//u) eliminates extra bytes in Unicode string and get exact length
      @word_count_label.setText(@status_field.getText.split(//u).length.to_s)
    }

    #Post content to every SNS
    @update_button.addSelectionListener { |event|
	  content = @status_field.getText.strip
	  
      if not content.length == 0 then
        @agents.each { |sns, agent|
          agent.post_content(content)
        }
      end

      @status_field.setText ""

      #TODO: Service status for both posting and authorizing
    }

    #Connect setting button to setting window
    @setting_button.addSelectionListener { |event|
      if @settings_window.isDisposed then
        init_setting_window
      end
      @settings_window.open
    }

  end

  def init_widgets(layout)
    @status_field = Text.new(@main_window, SWT::MULTI | SWT::WRAP)
    @status_field.setLayoutData(GridData.new(GridData::FILL, GridData::FILL, true, true, 5, 5))


    @update_button = Button.new(@main_window, SWT::PUSH)
    @update_button.setText "Update"
    @update_button.setLayoutData(GridData.new(GridData::FILL, GridData::FILL, true, false, 5, 1))

    @setting_button = Button.new(@main_window, SWT::PUSH)
    @setting_button.setText "Service Settings"
    @setting_button.setLayoutData(GridData.new(GridData::FILL, GridData::FILL, true, false, 5, 1))

    @word_count_label = Label.new(@main_window, SWT::RIGHT)
    @word_count_label.setText "     0"
    @word_count_label.setLayoutData(GridData.new(GridData::END, GridData::CENTER, true, false, 5, 1))
  end

  def write_config
    config_file = File.new('config.yaml', 'w+')
    config_file.write(@config.to_yaml)
    config_file.close
  end

  def read_config
    #Read stored tokens from a yaml file
    @config = {}
    if File.exists? 'config.yaml' then
      @config = YAML::load(File.open('config.yaml'))
    end
  end

end

S2sync.new
