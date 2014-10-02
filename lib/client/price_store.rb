class PriceStore
  attr_reader :connection, :channel, :queue, :prices, :thread, :data_dictionary, :message_factory

  def initialize
    @connection = MarchHare.connect(:user => "admin", :password => "Rabbit123")
    @channel = connection.create_channel
    @queue  = channel.queue("gateway.incoming_fix", :auto_delete => true)

    @data_dictionary = DefaultDataDictionaryProvider.new.getApplicationDataDictionary(ApplVerID.new(ApplVerID::FIX43))
    @message_factory = DefaultMessageFactory.new

    @prices = ConcurrentHashMap.new
  end

  def start
    @thread = Thread.new { message_receiver }
    thread.run
  end

  def message_receiver
    connection.start
    queue.subscribe(:block => true) do |metadata, payload|
      message = MessageUtils.parse(message_factory, data_dictionary, payload)
      update_prices(message)
    end
  rescue Interrupt => _
    connection.close
  end

  private
  def update_prices(message)
    length = message.get(NoMDEntries.new).value
    group = MarketDataIncrementalRefresh::NoMDEntries.new

    (1..length).each do |index|
      message.getGroup(index, group)
      symbol = group.get(Java::QuickfixField::Symbol.new).value
      bid_offer = group.get(MDEntryType.new).value
      price = group.get(MDEntryPx.new).value

      price_index = bid_offer == MDEntryType::BID ? 0 : 1
      prices.putIfAbsent(symbol, [])
      prices[symbol][price_index] = price
    end
  end
end