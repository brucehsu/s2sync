require 'rubygems'
require 'oauth_const'
require 'plurk'

class PlurkAgent
  def initialize
    @plurk = Plurk.new(:consumer_key => PLURK_APP_KEY, :consumer_secret => PLURK_APP_SECRET)
  end

  def get_authorize_url
    return @plurk.authorize_url!
  end

  def get_access_token(verifier_or_token=nil,secret=nil)
    if not verifier_or_token == nil then
      if secret == nil then
        @plurk.authorize!(verifier_or_token)
      else
        @plurk.oauth_token = verifier_or_token
        @plurk.oauth_token_secret = secret
      end
    end
    return {:token => @plurk.oauth_token, :secret => @plurk.oauth_token_secret}
  end

  def post(content)
    return @plurk.post('http://www.plurk.com/APP/Timeline/plurkAdd', {"content"=>content, "qualifier" => "says"}, nil)
  end
end
