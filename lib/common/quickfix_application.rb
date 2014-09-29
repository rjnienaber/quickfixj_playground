require_relative 'imports'
require_relative 'exceptions'
require_relative 'message_builder'

class QuickfixApplication < MessageCracker
  include Java::Quickfix::Application

  attr_reader :settings, :logger, :store_factory, :message_factory, :connector

  def initialize
    @settings = SessionSettings.new('./settings.ini')
    @logger = ScreenLogFactory.new(settings)
    @store_factory = MemoryStoreFactory.new
    @message_factory = DefaultMessageFactory.new
  end

  def start
    trap("SIGINT") { throw raise UserInterruptException.new('CTRL-C pressed.') }
    trap("SIGTERM") { throw raise KillInterruptException.new('KILL signal received.')}

    @connector = connector_class(settings).new(self, store_factory, settings, logger, message_factory)
    connector.start
    process
  rescue InterruptException => e
    puts "\n" if e.is_a?(UserInterruptException)
    puts "#{e} Ending..."
  ensure
    connector.stop(true) if connector
    exit
  end

  #Called when socket initiator is started
  def onCreate(sessionId); end
  def onLogon(sessionId); end
  def onLogout(sessionId); end
  #used to intercept admin messages to the gateway e.g. Logon, Heartbeat
  def toAdmin(message, sessionId); end
  #used to intercept admin messages from the gateway e.g. Logon replies, Heartbeat
  def fromAdmin(message, sessionId); end
  def toApp(message, sessionId); end
  def fromApp(message, sessionId); end

  protected
  def application
    raise 'The application method should be overridden and provide a class that overrides from BaseApplication'
  end

  def process
    raise 'The process method should be overridden and provide an implementation that does work'
  end

  private
  def connector_class(settings)
    klass = settings.getString('ConnectionType').downcase == 'acceptor' ? 'SocketAcceptor' : 'SocketInitiator'
    Kernel.const_get(klass)
  end
end