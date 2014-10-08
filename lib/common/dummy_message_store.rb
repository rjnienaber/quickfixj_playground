class DummyMessageStore
  include Java::Quickfix::MessageStore

  def initialize
    @creation_time = Time.now
    @sender_sequence_number = AtomicInteger.new(0)
    @target_sequence_number = AtomicInteger.new(0)
  end

  def get(start_sequence, end_sequence, messages); end
  def getCreationTime
    @creation_time
  end

  def getNextSenderMsgSeqNum
    @sender_sequence_number.get
  end

  def incrNextSenderMsgSeqNum
    @sender_sequence_number.increment_and_get
  end

  def setNextSenderMsgSeqNum(sequence_number) 
    @sender_sequence_number.set(sequence_number)
  end
           
  def getNextTargetMsgSeqNum
    @target_sequence_number.get
  end
           
  def incrNextTargetMsgSeqNum
    @target_sequence_number.increment_and_get
  end

  def setNextTargetMsgSeqNum(sequence_number) 
    @target_sequence_number.set(sequence_number)
  end

  def reset
    setNextTargetMsgSeqNum(1)
    setNextSenderMsgSeqNum(1)
  end


  def refresh; end
  def set (sequence, message)

  end
end

class DummyMessageStoreFactory
  include Java::Quickfix::MessageStoreFactory

  def initialize
    @message_store = DummyMessageStore.new
  end

  def create(session_id)
    @message_store
  end
end