require_relative 'imports'
require_relative 'exceptions'
require_relative 'base_application'

class QuickfixApplication
  attr_reader :settings, :logger, :store_factory, :message_factory, :connector

  def initialize()
    @settings = SessionSettings.new('./settings.ini')
    @logger = ScreenLogFactory.new(settings)
    @store_factory = MemoryStoreFactory.new
    @message_factory = DefaultMessageFactory.new
  end

  def start
    trap("SIGINT") { throw raise UserInterruptException.new('CTRL-C pressed.') }
    trap("SIGTERM") { throw raise KillInterruptException.new('KILL signal received.')}

    @connector = connector_class(settings).new(application, store_factory, settings, logger, message_factory)
    connector.start
    process
  rescue InterruptException => e
    puts "\n" if e.is_a?(UserInterruptException)
    puts "#{e} Ending..."
  ensure
    connector.stop(true) if connector
  end

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