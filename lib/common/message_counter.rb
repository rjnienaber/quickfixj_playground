class MessageCounter
  def initialize
    @counter = AtomicInteger.new(0)
    @last_counter = 0
    @thread = Thread.new { updater }
    @ending = false
  end

  def increment
    @counter.increment_and_get
  end

  def cleanup

  end

  def stop
    @ending = true
    @thread.join
  end

  def updater
    loop do
      counter = @counter.get
      puts "Messages/sec: #{counter - @last_counter}"
      @last_counter = counter
      sleep 1
      break if @ending
    end
  end
end