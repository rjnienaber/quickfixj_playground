require 'bundler/setup'
Bundler.require(:default)
# require 'sinatra/reloader'

require_relative '../common/imports'
require_relative '../common/message_counter'
require_relative 'price_store'

java_import 'java.util.concurrent.ConcurrentHashMap'
prices = ConcurrentHashMap.new

counter = MessageCounter.new
PriceStore.new(prices, counter).start
PriceStore.new(prices, counter).start

get "/" do
  slim :index, :locals => {:prices => prices}
end

use Rack::Deflater
puts "PROCESS: #{Process.pid}"