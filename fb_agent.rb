require 'open-uri'
require 'net/https'
require 'rubygems'
require 'json/pure'

class FBAgent
  def initialize

  end

  def get_authorize_url
    return "https://www.facebook.com/dialog/oauth?client_id=#{FB_APP_KEY}&redirect_uri=" +
        "https://www.facebook.com/connect/login_success.html&scope=publish_stream,read_stream,user_about_me"
  end

  def get_access_token(url, html)
    if url =~ /https:\/\/www.facebook.com\/connect\/login_success.html\?code=(\w|\W)+/ then
      fb_code = url.split(/https:\/\/www.facebook.com\/connect\/login_success.html\?code=/)[1]
      return "https://graph.facebook.com/oauth/access_token?" +
          "client_id=#{FB_APP_KEY}&redirect_uri=" +
          "https://www.facebook.com/connect/login_success.html" +
          "&client_secret=#{FB_APP_SECRET}&code=#{fb_code}"
    end
    if html =~ /access_token=(\w|\W)*&expires=(\d)+/ then
      @access_token = html.split(/access_token=/)[1].split(/&expires=/)[0]
      get_user_id
    end
    return nil
  end

  def post(content)
    uri = URI.parse("https://graph.facebook.com/#{@user_id}/feed")
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    data = "access_token=#{CGI::escape @access_token}&message=#{CGI::escape content}"
    res = http.post(uri.path, data, {'Content-Type'=> 'application/x-www-form-urlencoded'})
  end

  def get_user_id
    uri = URI.parse("https://graph.facebook.com")
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    res = JSON.parse(http.get("/me?access_token=#{CGI::escape @access_token}", nil).body)
    @user_id = res['id']
  end
end