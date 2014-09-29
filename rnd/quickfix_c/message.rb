$: << '/tmp/quickfix/src/ruby'
require 'quickfix_ruby'

message = Quickfix42Sp0::MarketDataSnapshotFullRefresh.new()
group = Quickfix42Sp0::MarketDataSnapshotFullRefresh::NoMDEntries.new();

group.setField(Quickfix::MDEntryType.new('0'))
group.setField(Quickfix::MDEntryPx.new(12.32))
group.setField(Quickfix::MDEntrySize.new(100))
group.setField(Quickfix::OrderID.new("ORDERID"))
message.addGroup( group )

group.setField(Quickfix::MDEntryType.new('1'))
group.setField(Quickfix::MDEntryPx.new(12.32))
group.setField(Quickfix::MDEntrySize.new(100))
group.setField(Quickfix::OrderID.new("ORDERID"))
message.addGroup( group )

puts message.to_s.gsub("\001", ' | ')
