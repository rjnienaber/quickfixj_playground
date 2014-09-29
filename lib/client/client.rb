require 'bundler/setup'
Bundler.require(:default)

require_relative 'queue_processor'

java_import 'java.util.concurrent.ConcurrentHashMap'

prices = ConcurrentHashMap.new

t = Thread.new do
      counter = 0
      loop do
        prices['GBP/ZAR'] = ["BID: #{counter}", "OFFER: #{counter}"]
        counter += 1
        sleep(1)
      end
    end


# require 'sinatra/reloader'

get "/" do
  erb :index, :locals => {:prices => prices}
end