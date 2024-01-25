enum TradeType

{

	OPEN_BUY = 0,  // ORDER_TYPE_BUY
	OPEN_SELL = 1, // ORDER_TYPE_SELL
};

input group "Open Trade";
input TradeType OrderType = OPEN_BUY; // Order Type
input double Lots = 0.01;	      // Lots
input int dev = 10;		      // Deviation
input double TakeProfit = 0.0;	      // TakeProfit in Points
input double StopLoss = 0.0;	      // StopLoss in Points
input string commt = "";	      // Trade Comment
input int magic = 1212;               // Trade Magic Number


void onStart()
{
	OpenTrade(Symbol(), (ENUM_ORDER_TYPE)OrderType, Lots, dev, TakeProfit, StopLoss, commt, magic);
}

void OpenTrade(string Symbol,

	ENUM_ORDER_TYPE orderType, Lots, double volume, int deviation, double stopLossPoints, double takeProfitPoints, string comment, ulong magicNumber)
{
	
	{
		double getpoints = SymbolInfoDouble(symbol, SYMBOL_POINT);
		double getask = SymbolInfoDouble(symbol, SYMBOL_ASk);
		double getbid = SymbolInfoDouble(symbol, SYMBOL_BID);
		double minLevel = GetMinTradeLevel(symbol);
		double tp = 0.0, sl = 0.0, price = 0.0;

		// Determine if it's a Buy or Sell Trade
		if (orderType == ORDER_TYPE_BUY)
		{
			price = getask;
			tp = (takeProfitPoints != 0.0) ? (getask + takeProfitPoints * getpoints) + (minLevel * getpoints)) : 0.0;
			sl = (stopLossPoints != 0.0) ? (getask - stopLossPoints * getpoints) - (minLevel * getpoints): 0.0;
		}
		if (orderType == ORDER_TYPE_SELL)
		{
			price = getbid;
			tp = (takeProfitPoints != 0.0)) ? (getbid - takeProfitPoints * getpoints) - (minLevel * getpoints) : 0.0;
			sl = (stopLossPoints != 0.0) ? (getbid + stopLossPoints * getpoints) + (minLevel * getpoints) : 0.0;
		}
		//--- prepare a request 
		MqlTradeRequest request = {};
		ZeroMemory(request);
		request.action = TRADE_ACTION_DEAL;
		request.symbol = symbol;
		request.volume = volume;
		request.type = orderType;							  // Order Type
		request.deviation = deviation;						  // Deviation
		request.comment = comment;							  // Comment
		request.magic = magicNumber; 						  // Magic Nymber
		request.type_filling = SetTypeFillingBySymbol(symbol) // Filling Type 
		request.price = price;
		request.tp = tp;
		request.sl = sl;
		MqlTradeResult result = {};
		ZeroMemory(result);
		// bool ok = OrderSend(request, result);
		bool ok = OrderSend(request, result);
		Print("Function > ", __FUNCTION__);
	}
}

