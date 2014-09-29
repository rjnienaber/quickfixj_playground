require_relative '../common/quickfix_application'

class SimulatorApplication < BaseApplication
  def toApp(message, sessionId)
    puts "CALLED (toApp - #{sessionId}): #{message.inspect}"
  end

  def fromApp(message, sessionId)
    puts "CALLED (fromApp - #{sessionId}): #{message.inspect}"
  end
end

class Simulator < QuickfixApplication
  def application
    SimulatorApplication.new
  end

  def process
    puts "Simulator started" 
    sleep  
  end
end

Simulator.new.start