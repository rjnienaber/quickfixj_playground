class BaseApplication < MessageCracker
  include Java::Quickfix::Application

  def onCreate(sessionId)
    #Called when socket initiator is started
  end

  def onLogon(sessionId)
  end

  def onLogout(sessionId)
  end

  def toAdmin(message, sessionId)
    #used to intercept admin messages to the gateway e.g. Logon, Heartbeat
    # puts "CALLED (toAdmin - #{sessionId}): #{message.inspect}"
  end

  def fromAdmin(message, sessionId)
    #used to intercept admin messages from the gateway e.g. Logon replies, Heartbeat
    # puts "CALLED (fromAdmin - #{sessionId}): #{message.inspect}"
  end

  def toApp(message, sessionId)
  end

  def fromApp(message, sessionId)
  end
end