require 'bundler/setup'
Bundler.require(:default)
require 'sinatra/reloader'

require_relative '../common/imports'
require_relative 'price_store'

java_import 'java.util.concurrent.ConcurrentHashMap'

price_store = PriceStore.new
price_store.start

get "/" do
  slim :index, :locals => {:prices => price_store.prices}
end

use Rack::Deflater