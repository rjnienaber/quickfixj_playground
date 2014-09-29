class QueueProcessor
  attr_reader :connection, :channel, :queue

  def initialize
    @connection = MarchHare.connect(:user => "admin", :password => "Rabbit123")
    @channel = connection.create_channel
    @queue  = channel.queue("gateway.incoming_fix", :auto_delete => true)
  end

  def publish(fix_message)
    queue.publish(fix_message, :routing_key => queue.name)
  end

  def close
    connection.close
  end
end