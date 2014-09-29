class MessageBuilder
  def self.market_data_incremental(options = {})
    message = MarketDataIncrementalRefresh.new 

    set_participant_ids(message, options[:session_id]) if options[:session_id]
    message.set(MDReqID.new(options[:request_id]))

    if options[:group] && !options[:group].empty?
      entries = MarketDataIncrementalRefresh::NoMDEntries.new 
      options[:group].each do |group|
        set_group_constant(entries, MDUpdateAction, group[:action])
        set_group_constant(entries, MDEntryType, group[:entry])
        entries.set(MDEntryPx.new(group[:price])) if group[:price]
        entries.set(MDEntrySize.new(group[:volume])) if group[:volume]
        entries.set(Java::QuickfixField::Symbol.new(group[:symbol])) if group[:symbol]
        entries.set(MDEntryRefID.new(group[:reference])) if group[:reference]
        entries.set(MDEntryDate.new(group[:entry_datetime])) if group[:entry_datetime]
        entries.set(MDEntryTime.new(group[:entry_datetime])) if group[:entry_datetime]


        entries.set(OrderID.new(group[:order_id])) if group[:order_id]
        
        message.add_group(entries) 
      end
    end
    message
  end

  private
  def self.set_group_constant(group, constant, name)
    group.set(constant.new(constant.const_get(name.to_s.upcase))) if name
  end

  def self.set_participant_ids(message, session_id)
    set_field(message, SenderCompID, session_id.sender_comp_id)
    set_field(message, TargetCompID, session_id.target_comp_id)
  end

  def self.set_field(message, constant, value)
    return unless  value
    field_no = constant.const_get('FIELD')
    message.setField(StringField.new(field_no, value))
  end
end