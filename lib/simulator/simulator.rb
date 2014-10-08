require_relative '../common/quickfix_application'
require_relative 'simulator_thread'

class Simulator < QuickfixApplication
  attr_reader :threads, :ending

  def initialize
    super
    @threads = {}
    @ending = false
  end

  def onLogout(session_id)
    threads[session_id].stop
  end

  def onLogon(session_id)
    threads[session_id] = SimulatorThread.new(session_id).start
  end

  def process
    puts "Simulator started"
    sleep
  end
end

puts "PROCESS: #{Process.pid}"
simulator = Simulator.new
simulator.start