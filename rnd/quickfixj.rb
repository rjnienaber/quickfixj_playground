require 'pp'
require_relative '../lib/common/imports'
require 'pry'

java_import 'quickfix.field.OrigClOrdID'
java_import 'quickfix.field.ClOrdID'
java_import 'quickfix.field.Side'
java_import 'quickfix.field.TransactTime'
java_import 'quickfix.field.OrdType'
java_import 'quickfix.field.HandlInst'
java_import 'quickfix.field.ApplVerID'
java_import 'quickfix.field.MDReqID'
java_import 'quickfix.field.MDUpdateAction'
java_import 'quickfix.field.MDEntryType'
java_import 'quickfix.field.MDEntryPx'
java_import 'quickfix.field.MDEntrySize'
java_import 'quickfix.field.MDEntryRefID'
java_import 'quickfix.field.OrderID'


java_import 'quickfix.MessageUtils'
java_import 'quickfix.fix43.MarketDataIncrementalRefresh'
java_import 'quickfix.Message'
java_import 'quickfix.DataDictionary'
java_import 'quickfix.DefaultMessageFactory'
java_import 'quickfix.DefaultDataDictionaryProvider'
java_import 'quickfix.fix43.NewOrderSingle'

#8=FIX.4.39=20935=X34=1849=FIXPUSHER52=20140929-22:55:44.92256=COUNTERPARTY262=20140504-BVPZXH268=2279=0269=055=GBP/ZAR270=17.79211271=10000272=20140507279=0269=155=GBP/ZAR270=17.80661271=10000272=2014050710=047

mdir_message = MarketDataIncrementalRefresh.new 

mdir_message.set(MDReqID.new("MDQeq")) 

group = MarketDataIncrementalRefresh::NoMDEntries.new 

group.set(MDUpdateAction.new(MDUpdateAction::NEW)) 

group.set(MDEntryType.new(MDEntryType::BID)) 
group.set(MDEntryPx.new(12.32)) 
group.set(MDEntrySize.new(100)) 
group.set(Java::QuickfixField::Symbol.new("JAVA")) 
group.set(MDEntryRefID.new("dsd")) 
group.set(OrderID.new("ORDERID")) 
mdir_message.addGroup(group) 

group.set(MDEntryType.new(MDEntryType::OFFER)) 
group.set(MDEntryPx.new(12.32)) 
group.set(MDEntrySize.new(100)) 
group.set(OrderID.new("ORDERID2")) 
mdir_message.addGroup(group) 

#parse fix message
market_data_example = "8=FIX.4.3\0019=221\00135=X\00149=oanda\00156=BARX PRICES TEST\00134=8873658\00152=20140507-14:05:44\001262=20140504-BVPZXH\001268=2\001279=1\001269=0\00155=GBP/ZAR\001270=17.79211\001271=10000000\001272=20140507\001273=14:05:44\001279=1\001269=1\00155=GBP/ZAR\001270=17.80661\001271=10000000\001272=20140507\001273=14:05:44\00110=73\037j\037fixmux_oanda\037l\0371399471544\001"
market_data_example = "8=FIX.4.3\0019=221\00135=X\00149=oanda\00156=BARX PRICES TEST\00134=8873658\00152=20140507-14:05:44\001262=20140504-BVPZXH\001279=1\001269=0\00155=GBP/ZAR\001270=17.79211\001271=10000000\001272=20140507\001273=14:05:44\001279=1\001269=1\00155=GBP/ZAR\001270=17.80661\001271=10000000\001272=20140507\001273=14:05:44\00110=73\037j\037fixmux_oanda\037l\0371399471544\001"

# this is a long-winded way of parsing a message
# but will actually give you a concrete type
data_dictionary = DefaultDataDictionaryProvider.new.getApplicationDataDictionary(ApplVerID.new(ApplVerID::FIX43))
message_factory = DefaultMessageFactory.new
market_data = MessageUtils.parse(message_factory, data_dictionary, market_data_example)

#quick dirty message parser
# m = Message.new(market_data_example, false)
# m = Message.new(market_data_example)

# puts market_data_example.gsub("\001", ' | ')
pp market_data_example.gsub("\001", "\n")
puts "Currency Pair: #{market_data.string(Java::QuickfixField::Symbol::FIELD)}"
puts "Well-Formed?: #{market_data.has_valid_structure?}" 

#generate example new order single
order_example ="8=FIX.4.3\0019=223\00135=D\00149=CLIENT PRICES TEST\00156=BARX PRICES TEST\00134=4\00152=20070903 14:42:01\00140=D\001167=FOR\00121=2\00111=D1188830521017\00155=GBP/USD\00115=GBP\00154=1\00138=5000000.0\00164=20070905\00160=20070903 15:42:01\00178=0\001117=ZEZUZUBA12131681999999995\00144=2.01845\00110=9"

#how jruby deals with java 'char' fields 
#has changed going from 1.8 to 1.9
IS_18 = !!/^1\.8/.match(RUBY_VERSION)
order = NewOrderSingle.new(
             ClOrdID.new("1234"),
             HandlInst.new(HandlInst::AUTOMATED_EXECUTION_ORDER_PRIVATE),
             Side.new('1'.ord),
             # Java::QuickfixField::Symbol.new("AAPL"),
             TransactTime.new(Time.now),
             OrdType.new(OrdType::LIMIT)
          )



puts order_example.gsub("\001", ' | ')

# order.Price = new Price(new decimal(22.4));
# order.Account = new Account("18861112");

# Session.SendToTarget(order, sessionID);