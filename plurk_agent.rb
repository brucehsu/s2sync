require 'rubygems'
require 'oauth_const'
require 'plurk'

class PlurkAgent
  attr_reader :prev_id

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

  def post_content(content,qualifier='says')
    begin
      @prev_id = @plurk.add_plurk(content,qualifier)
      @prev_id = @prev_id['plurk_id']
    rescue RuntimeError  => err
      puts err
    end
  end
end
