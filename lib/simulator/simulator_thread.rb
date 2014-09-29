class SimulatorThread 
  attr_accessor :ending
  attr_reader :session_id, :thread

  def initialize(session_id)
    @session_id = session_id
    @thread = Thread.new { send_market_update(session_id) }
    @ending = false
  end

  def start
    thread.run
    self
  end

  def stop
    @ending = true
  end

  private
  def send_market_update(session_id)
    now = Time.now
    options = {
      session_id: session_id,
      request_id: "20140504-BVPZXH",
      group: [
        {
          action: :change,
          entry: :bid,
          price: 17.79211,
          volume: 10000000,
          symbol: 'GBP/ZAR',
          entry_datetime: now
        },
        {
          action: :change,
          entry: :offer,
          price: 17.80661,
          volume: 10000000,
          symbol: 'GBP/ZAR',
          entry_datetime: now
        }
      ]
    }

    message = MessageBuilder.market_data_incremental(options)
    loop do
      Session.send_to_target(message, session_id)
      sleep(1)
      break if ending
    end
  rescue Exception => e
    puts "#{e}: #{e.backtrace.join("\n")}"
  end

end