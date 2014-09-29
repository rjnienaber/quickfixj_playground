require 'pp'
require 'quickfixj-all-1.5.3'
require 'pry'

java_import 'quickfix.field.OrigClOrdID'
java_import 'quickfix.field.ClOrdID'
java_import 'quickfix.field.Side'
java_import 'quickfix.field.TransactTime'
java_import 'quickfix.field.OrdType'
java_import 'quickfix.field.HandlInst'
java_import 'quickfix.field.ApplVerID'

java_import 'quickfix.MessageUtils'
java_import 'quickfix.Message'
java_import 'quickfix.DataDictionary'
java_import 'quickfix.DefaultMessageFactory'
java_import 'quickfix.DefaultDataDictionaryProvider'
java_import 'quickfix.fix43.NewOrderSingle'

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
side = IS_18 ? '1'[0] : '1'.ord

order = NewOrderSingle.new(
             ClOrdID.new("1234"),
             HandlInst.new(HandlInst::AUTOMATED_EXECUTION_ORDER_PRIVATE),
             Side.new(side),
             # Java::QuickfixField::Symbol.new("AAPL"),
             TransactTime.new(Time.now),
             OrdType.new(OrdType::LIMIT)
          )



puts order_example.gsub("\001", ' | ')

# order.Price = new Price(new decimal(22.4));
# order.Account = new Account("18861112");

# Session.SendToTarget(order, sessionID);