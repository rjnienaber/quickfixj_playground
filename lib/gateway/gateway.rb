require_relative '../common/quickfix_application'

class GatewayApplication < BaseApplication
  def toApp(message, sessionId)
    puts "CALLED (toApp - #{sessionId}): #{message.inspect}"
  end

  def fromApp(message, sessionId)
    puts "CALLED (fromApp - #{sessionId}): #{message.inspect}"
  end
end

class Gateway < QuickfixApplication
  def application
    GatewayApplication.new
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
    end
  end
end

Gateway.new.start