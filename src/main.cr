require "http/server"
require "kemal"
require "json"
require "uri"
require "redis"

require "./config"
require "./routes/**"
require "./datahandlers/**"
require "./twitchapi/*"
require "./utils/*"

module TwAPI
end

alias TA = TwAPI

CONFIG      = Config.load
Kemal.config.port = CONFIG.port
REDIS_UTILS = TwAPI::Utils::Redis
REDIS_DB = Redis::Client.new(URI.parse("redis://#{CONFIG.redis_addr}/#{CONFIG.redis_database}#?keepalive=true"))
puts "Connected to Redis"

before_all "/v2/*" do |env|
  env.response.content_type = "application/json"
end

TwAPI::Routing.register_all

{% if flag?(:release) || flag?(:production) %}
  Kemal.config.env = "production" if !ENV.has_key?("KEMAL_ENV")
{% end %}


# THIS IS USELESS
# spawn do
# 	while true
# 	sleep 5.seconds
#     GC.collect
#   end
# end

Kemal.run
