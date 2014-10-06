require 'bundler/setup'
Bundler.require(:default)
# require 'sinatra/reloader'

require_relative '../common/imports'
require_relative 'price_store'

java_import 'java.util.concurrent.ConcurrentHashMap'
prices = ConcurrentHashMap.new

PriceStore.new(prices).start
PriceStore.new(prices).start

get "/" do
  slim :index, :locals => {:prices => prices}
end

use Rack::Deflater