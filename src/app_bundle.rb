#Following code is quoted from CompassApp written by handlino
#Repository url: https://github.com/handlino/CompassApp

ruby_lib_path = File.join(File.dirname(File.dirname(File.dirname(File.dirname(__FILE__)))), "ruby").to_s()[5..-1] 
if File.exists?( ruby_lib_path ) 
  LIB_PATH = File.join(File.dirname(File.dirname(File.dirname(File.dirname(__FILE__))))).to_s()[5..-1] 
else 
  LIB_PATH = 'lib' 
end

SWT_LIB_PATH ="#{LIB_PATH}/java"

if org.jruby.platform.Platform::IS_MAC  
  os="mac"
elsif org.jruby.platform.Platform::IS_LINUX 
  os="linux"
elsif org.jruby.platform.Platform::IS_WINDOWS 
  os="win"
end

if org.jruby.platform.Platform::ARCH =~ /64/
  arch="64"
else
  arch="32"
end

require "#{SWT_LIB_PATH}/swt_#{os}_#{arch}"
