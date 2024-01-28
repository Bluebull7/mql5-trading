//--START--//

//--SIMPLE CLASS FOR IMPLEMENTING OPEN TRADE OPERATIONS IN METATRADER EA (MQL) --//

enum TradeType //DEFINE TRADE TYPES

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

void OpenTrade	(string Symbol,ENUM_ORDER_TYPE orderType, Lots, double volume,
 int deviation, double stopLossPoints, double takeProfitPoints, string comment,
  ulong magicNumber)
  
{
	{
		//GETTER AND SETTER METHODS		
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

//--- SetType FillingBySymbol
ENUM_ORDER_TYPE_FILLING SetTypeFillingBySymbol(const string symbol)
{

	// Get possible filling policy types by symbol
	uint filling = (uint)SymbolInfoInteger(symbol, SYMBOL_FILLING_MODE);

	if ((Filling & SYMBOL_FILLING_FOK) == SYMBOL_FILLING_FOK)
	{
		return ORDER_FILLING_FOK;
	}
	else if ((filling & SYMBOL_FILLING_IOCO) == SYMBOL_FILLING_IOC)
	{
		return ORDER_FILLING_IOC;
	}

}

//--- GetMinTradeLevel
double GetMinTradeLevel(string symbol)
{
	double minLevel = -1.0;
	double freezeLevel= -1.0;
	double stopsLevel = -1.0;

	freezeLevel = (double)SymbolInfoInteger(symbol, SYMBOL_TRADE_FREEZE_LEVEL);
	stopsLevel = (double)SymbolInfoInteger(symbol, SYMBOL_TRADE_STOPS_LEVEL);
	minLevel = MathMax(freezeLevel, stopsLevel);

	if (freezeLevel == -1 || stopsLevel == -1 || minLevel == -1)
	{
		Print("Freeze level or Stops Level not available for the symbol (-1) ");
		return 0;
	}

	if (minLevel <= 100.0 && minLevel >= 0.0)
		minLevel += 1.0;
	else if (minLevel >= 100.0)
		minLevel = 100.0;
	
	return minLevel;
}

//--- END

