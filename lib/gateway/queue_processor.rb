class QueueProcessor
  attr_reader :connection, :channel, :queue, :executor

  def initialize
    @connection = MarchHare.connect(:user => "admin", :password => "Rabbit123")
    @channel = connection.create_channel
    @queue  = channel.queue("gateway.incoming_fix")
  end

  def publish(fix_message)
    queue.publish(fix_message.to_s, :routing_key => queue.name)
  end

  def close
    connection.close
    executor.shutdown
  end
end