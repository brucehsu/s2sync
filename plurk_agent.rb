require 'rubygems'
require 'oauth_const'
require 'oauth'
require 'json/pure'

class PlurkAgent
  def initialize

    @consumer= OAuth::Consumer.new(PLURK_APP_KEY, PLURK_APP_SECRET, {
        :site => 'http://www.plurk.com',
        :scheme => :header,
        :http_method => :post,
        :request_token_path => '/OAuth/request_token',
        :access_token_path => '/OAuth/access_token',
        :authorize_path => '/OAuth/authorize'
    })
  end

  def get_authorize_url
    @request_token = @consumer.get_request_token
    return @request_token.authorize_url
  end

  def get_access_token(key_or_token=nil,secret=nil)
    if not key_or_token == nil then
      if secret == nil then
        @access_token = @request_token.get_access_token :oauth_verifier=>key_or_token
      else
        @access_token = OAuth::AccessToken.new(@consumer, key_or_token, secret)
      end
    else
      @access_token = OAuth::AccessToken.new(@consumer, @access_token.token, @access_token.secret)
    end
    return @access_token
  end

  def post(content)
    return get_access_token.post('http://www.plurk.com/APP/Timeline/plurkAdd', {"content"=>content, "qualifier" => "says"}, nil)
  end
end