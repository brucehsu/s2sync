require 'rubygems'
require 'json/pure'
require 'rest-core'

Plurk = RestCore::Builder.client(:data) do
  s = self.class
  use s::DefaultSite, 'http://www.plurk.com/APP'

  use s::Oauth1Header  ,
    'http://www.plurk.com/OAuth/request_token', 
    'http://www.plurk.com/OAuth/access_token',
    'http://www.plurk.com/OAuth/authorize'

  use s::CommonLogger  , method(:puts)

  use s::ErrorHandler , lambda { |env|
    raise Plurk::Error.call(env)
  }
  use s::ErrorDetectorHttp
  use s::JsonDecode    , true

  use s::Defaults      , :data     => lambda{{}}
  run s::RestClient
end

class Plurk::Error < RuntimeError
  attr_reader :error

  def initialize (error)
    @error = error
  end

  def self.call(env)
    @error = env["RESPONSE_BODY"]["error_text"]
  end
end

module Plurk::Client
  include RestCore
  
  def oauth_token
    data['oauth_token'] if data.kind_of?(Hash)
  end

  def oauth_token= token
    data['oauth_token'] = token if data.kind_of?(Hash)
  end

  def oauth_token_secret
    data['oauth_token_secret'] if data.kind_of?(Hash)
  end

  def oauth_token_secret= secret
    data['oauth_token_secret'] = secret if data.kind_of?(Hash)
  end

  def add_plurk content, qualifier='says'
    post('/Timeline/plurkAdd', {"content"=>content, "qualifier" => qualifier}, nil)
  end

  def add_response plurk_id, content, qualifier='says'
    post('/Responses/responseAdd', {'plurk_id' => plurk_id,
           'content' => content, 'qualifier' => qualifier}, nil)
  end

 private
  def set_token query
    self.data = query
  end
end

Plurk.send(:include, RestCore::ClientOauth1)
Plurk.send(:include, Plurk::Client)
