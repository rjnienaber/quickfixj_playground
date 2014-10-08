require 'bundler/setup'
Bundler.require(:default)

require_relative '../common/quickfix_application'
require_relative 'queue_processor'

class Gateway < QuickfixApplication
  attr_accessor :queue_processor, :counter

  def initialize
    super
    @counter = MessageCounter.new
  end

  def fromApp(message, session_id)
    queue_processor.publish(message)
    counter.increment
  rescue Exception => e
    puts "#{e}: #{e.backtrace.join("\n")}"
  end

  def process
    i = 0
    loop do
      i += 1
      sleep(1)
      break unless ((!connector.isLoggedOn) && (i < 10)) #wait 10 seconds for log on
    end
    if i < 10
      puts "We logged on! Sleeping..." 
      sleep
    else
      puts "We couldn't logon"
    end
  end
end

puts "PROCESS: #{Process.pid}"
gateway = Gateway.new
gateway.queue_processor = QueueProcessor.new

Thread.new do
  loop do
    puts "QUEUE SIZE: #{gateway.connector.queue_size}" if gateway.connector
    sleep(1)
  end
end

gateway.start


    
