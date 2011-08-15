require 'open-uri'
require 'net/https'
require 'rubygems'
require 'json/pure'

class FBAgent
  def initialize

  end

  def get_authorize_url
    return "https://www.facebook.com/dialog/oauth?client_id=#{FB_APP_KEY}&redirect_uri=" +
        "https://www.facebook.com/connect/login_success.html&scope=publish_stream,read_stream,user_about_me,offline_access"
  end

  def get_access_token(url_or_token, html=nil)
    if url_or_token =~ /https:\/\/www.facebook.com\/connect\/login_success.html\?code=(\w|\W)+/ then
      fb_code = url_or_token.split(/https:\/\/www.facebook.com\/connect\/login_success.html\?code=/)[1]
      return {:url => "https://graph.facebook.com/oauth/access_token?" +
          "client_id=#{FB_APP_KEY}&redirect_uri=" +
          "https://www.facebook.com/connect/login_success.html" +
          "&client_secret=#{FB_APP_SECRET}&code=#{fb_code}"}
    end
    if html =~ /access_token=(\w|\W)*/ then
      @access_token = html.split(/access_token=/)[1]
      get_user_id
    end
    if html == nil then
      @access_token = url_or_token
    end
    return {:token => @access_token}
  end

  def post(content)
    uri = URI.parse("https://graph.facebook.com/#{@user_id}/feed")
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    data = "access_token=#{CGI::escape @access_token}"

    content = parse_url(content)
    if content.has_key? :url then
      data += "&link=#{CGI::escape content[:url]}"
    end
    if content[:content] != nil then
      data += "&message=#{CGI::escape content[:content]}"
    end

    res = http.post(uri.path, data, {'Content-Type'=> 'application/x-www-form-urlencoded'})
  end

  def get_user_id(token = nil)
    uri = URI.parse("https://graph.facebook.com")
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    if token == nil then
      res = JSON.parse(http.get("/me?access_token=#{CGI::escape @access_token}", nil).body)
    else
      res = JSON.parse(http.get("/me?access_token=#{CGI::escape token}", nil).body)
    end

    if res.has_key? 'error' then
      return nil
    end

    @user_id = res['id']
  end

  def parse_url(content)
    link_and_content = {}
    if content.split(/ /)[0] =~ /(http|https):\/\/(\w|\W)+/ then
      link_and_content[:url] = content.split(/ /)[0]
      content = content.split(/ /, 2)[1]
    end
    link_and_content[:content] = content
    return link_and_content
  end
end