require 'rubygems'
require 'json/pure'
require 'rest-core/client/facebook'

class FBAgent
  def initialize
    @facebook = RestCore::Facebook.new(:app_id => FB_APP_KEY, :secret => FB_APP_SECRET)
  end

  def get_authorize_url
    return @facebook.authorize_url(:scope =>  'publish_stream,read_stream,user_about_me,offline_access',
                                   :redirect_uri => 'https://www.facebook.com/connect/login_success.html')
  end

  def get_access_token(url_or_token, html=nil)
    if url_or_token =~ /https:\/\/www.facebook.com\/connect\/login_success.html\?code=(\w|\W)+/ then
      fb_code = url_or_token.split(/https:\/\/www.facebook.com\/connect\/login_success.html\?code=/)[1]
      @facebook.authorize!(:redirect_uri => 'https://www.facebook.com/connect/login_success.html',
                           :code => fb_code)
    else
      @facebook.access_token = url_or_token
      get_user_id
    end
    return @facebook.access_token
  end

  def post_content(content)
	content = content.strip
    content = parse_url(content)
    @facebook.post("#{@user_id}/feed",{'message' => content[:content],
                   'link' => content[:url]},
                   nil)
  end

  def get_user_id(token = nil)
    @user_id = @facebook.get('me')['id']
  end

  def parse_url(content)
    link_and_content = {:url => ''}
    if content.split(/ /)[0] =~ /(http|https):\/\/(\w|\W)+/ then
      link_and_content[:url] = content.split(/ /)[0]
	  content = content.split(/ /, 2)[1]
      if content != nil and content.match(/(\([\w|\W|\p{L}]+\))/u) != nil then
        if content.split(/(\([\w|\W|\p{L}]+\) +)/u).count > 1  then
			content = content.split(/(\([\w|\W|\p{L}]+\) +)/u)[2]
		else
			content.sub!(/(\([\w|\W|\p{L}]+\))/u,'')
		end
      end
    end
    link_and_content[:content] = content
    return link_and_content
  end
end
