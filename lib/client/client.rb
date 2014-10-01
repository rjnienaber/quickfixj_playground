require 'bundler/setup'
Bundler.require(:default)
# require 'sinatra/reloader'

require_relative 'queue_processor'

java_import 'java.util.concurrent.ConcurrentHashMap'

prices = ConcurrentHashMap.new

t = Thread.new do
      counter = 0
      loop do
        prices['GBP/ZAR'] = [counter, counter + 1]
        counter += 1
        sleep(1)
      end
    end


get "/" do
  slim :index, :locals => {:prices => prices}
end

use Rack::Deflater