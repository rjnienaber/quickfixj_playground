class SimulatorThread 
  attr_accessor :ending
  attr_reader :session_id, :producers, :counter, :sleep_duration

  def initialize(session_id)
    @session_id = session_id
    @counter = MessageCounter.new
    @ending = false
  end

  def start
    # threads, @sleep_duration = 4, 0.002 #about 1500/s
    # threads, @sleep_duration = 2, 0.001 #about 1300/s
    # threads, @sleep_duration = 3, 0.002 #about 1150/s
    # threads, @sleep_duration = 4, 0.003 #abput 1050/s
    # threads, @sleep_duration = 5, 0.004 #about 1020/s
    # threads, @sleep_duration = 3, 0.003 #about 800/s
    # threads, @sleep_duration = 2, 0.002 #about 780/s
    threads, @sleep_duration = 1, 0.002 #about 1500/s
    @producers =  (0..(threads-1)).map { Thread.new { send_market_update(session_id) } }
    self
  end

  def stop
    @ending = true
    counter.stop
    producers.each{ |t| t.join }
  end

  private
  def send_market_update(session_id)
    options = nil
    loop do
      @bid = 17.79211 if (@bid || 0) < 16
      @offer = 17.80661 if (@offer || 0) < 16
      options = options ? create_options(session_id) : create_options(nil, options)

      message = MessageBuilder.market_data_incremental(options)
      Session.send_to_target(message, session_id)
      # sleep(sleep_duration)
      break if ending
      counter.increment
    end
  rescue Exception => e
    puts "#{e}: #{e.backtrace.join("\n")}"
  end

  def create_options(session_id=nil, hash=nil)
    now = Time.now
    @bid = @bid * ((Random.new.rand * 10).to_i % 2 == 0 ? 0.99991 : 1.00001)
    @offer = @offer * ((Random.new.rand * 10).to_i % 2 == 0 ? 0.99991 : 1.00001)

    if hash
      hash[:group][0][:price] = @bid
      hash[:group][0][:entry_datetime] = now
      hash[:group][1][:price] = @bid
      hash[:group][1][:entry_datetime] = now
    else
      {
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
end