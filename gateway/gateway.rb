require_relative '../java_lib/quickfixj-all-1.5.3'
require_relative '../java_lib/slf4j-api-1.7.7.jar'
require_relative '../java_lib/slf4j-jdk14-1.7.7.jar'
require_relative '../java_lib/mina-core-1.1.0.jar'

java_import 'quickfix.SessionSettings'
java_import 'quickfix.MemoryStoreFactory'
java_import 'quickfix.fix43.MessageCracker'
java_import 'quickfix.ScreenLogFactory'
java_import 'quickfix.DefaultMessageFactory'
java_import 'quickfix.SocketInitiator'
java_import 'quickfix.fix43.Logon'
java_import 'quickfix.field.BeginString'
java_import 'quickfix.field.HeartBtInt'
java_import 'quickfix.field.ResetSeqNumFlag'
java_import 'quickfix.Session'

class Gateway < MessageCracker
  include Java::Quickfix::Application

  def onCreate(sessionId)
    #Called when socket initiator is started
  end

  def onLogon(sessionId)
  end

  def onLogout(sessionId)
  end

  def toAdmin(message, sessionId)
    #used to intercept admin messages to the gateway e.g. Logon, Heartbeat
    # puts "CALLED (toAdmin - #{sessionId}): #{message.inspect}"
  end

  def fromAdmin(message, sessionId)
    #used to intercept admin messages from the gateway e.g. Logon replies, Heartbeat
    # puts "CALLED (fromAdmin - #{sessionId}): #{message.inspect}"
  end

  def toApp(message, sessionId)
    puts "CALLED (toApp - #{sessionId}): #{message.inspect}"
  end

  def fromApp(message, sessionId)
    puts "CALLED (fromApp - #{sessionId}): #{message.inspect}"
  end
end

class InterruptException < Exception; end
class UserInterruptException < InterruptException; end
class KillInterruptException < InterruptException; end

def main
  application = Gateway.new
  settings = SessionSettings.new('./settings.ini')
  store_factory = MemoryStoreFactory.new
  log_factory = ScreenLogFactory.new(settings)
  message_factory = DefaultMessageFactory.new
  socket_initiator = SocketInitiator.new(application, store_factory, settings, log_factory, message_factory)

  trap("SIGINT") { throw raise UserInterruptException.new('CTRL-C pressed.') }
  trap("SIGTERM") { throw raise KillInterruptException.new('KILL signal received.')}

  socket_initiator.start
  i = 0
  loop do
    i += 1
    sleep(1)
    break unless ((!socket_initiator.isLoggedOn) && (i < 10)) #wait 10 seconds for log on
  end
  if i < 10
    puts "We logged on! Sleeping..." 
    sleep
  end
rescue InterruptException => e
  puts "\n" if e.is_a?(UserInterruptException)
  puts "#{e} Ending..."
ensure
  socket_initiator.stop(true) if socket_initiator
end

main