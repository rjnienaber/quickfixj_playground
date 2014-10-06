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
    thread.join
  end

  private
  def send_market_update(session_id)
    loop do
      @bid = 17.79211 if (@bid || 0) < 16
      @offer = 17.80661 if (@offer || 0) < 16

      message = MessageBuilder.market_data_incremental(create_options(session_id))
      Session.send_to_target(message, session_id)
      break if ending
    end
  rescue Exception => e
    puts "#{e}: #{e.backtrace.join("\n")}"
  end

  def create_options(session_id)
    now = Time.now
    @bid = @bid * ((Random.new.rand * 10).to_i % 2 == 0 ? 0.99991 : 1.00001)
    @offer = @offer * ((Random.new.rand * 10).to_i % 2 == 0 ? 0.99991 : 1.00001)

    options = {
      session_id: session_id,
      request_id: "20140504-BVPZXH",
      group: [
        {
          action: :change,
          entry: :bid,
          price: @bid,
          volume: 10000000,
          symbol: 'GBP/ZAR',
          entry_datetime: now
        },
        {
          action: :change,
          entry: :offer,
          price: @offer,
          volume: 10000000,
          symbol: 'GBP/ZAR',
          entry_datetime: now
        }
      ]
    }
  end
end