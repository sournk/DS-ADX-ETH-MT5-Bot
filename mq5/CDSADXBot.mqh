//+------------------------------------------------------------------+
//|                                                    CDSADXBot.mqh |
//|                                                  Denis Kislitsyn |
//|                                             https://kislitsyn.me |
//+------------------------------------------------------------------+

#include <Trade\PositionInfo.mqh>
#include <Trade\OrderInfo.mqh>
#include <Trade\SymbolInfo.mqh>
#include <Trade\Trade.mqh>

#include "Include\DKStdLib\Common\DKStdLib.mqh"
#include "Include\DKStdLib\Logger\DKLogger.mqh"
#include "Include\DKStdLib\TradingManager\CDKTrade.mqh"

class CDSADXBot {
public:
  // Must be set direclty
  int                      ADXHandle;
  CDKTrade                 Trade;
  int                      Magic;
  DKLogger*                logger;

  // Must be init. Have default values
  string                   Sym;
    
  bool                     BuyEnabled;
  bool                     SellEnabled;
  ENUM_MM_TYPE             MMType;
  double                   MMValue;
  
  uint                     ADXBarShift;
  double                   ADXTradingValue;
  uint                     EntryPriceExtremePeriod;
  ENUM_TIMEFRAMES          EntryPriceExtremeTF;

  double                   SLDist;
  double                   TPDist;
  double                   BEDist;
  bool                     EXOnBarSize;
  
  
  // Signal detection
  bool                     CDSADXBot::HasPos(void);
  bool                     CDSADXBot::HasOrder(void);
  bool                     CDSADXBot::HasSignal(void);  
  
  // Trade
  ulong                    CDSADXBot::OpenOrder(const ENUM_POSITION_TYPE _dir, const double _lot, const double _price,
                                                const double _sl, const double _tp, const string _comment);
  double                   CDSADXBot::GetEntryPrice(const ENUM_POSITION_TYPE _dir);  
  bool                     CDSADXBot::OpenOrders(void);  
  bool                     CDSADXBot::DeleteOrders(void);
  bool                     CDSADXBot::CheckBarHighLowAndClosePos(void);
  bool                     CDSADXBot::CheckAndSetBE(void);
  
  // Event Handlers
  void                     CDSADXBot::OnTick(void);
  void                     CDSADXBot::CDSADXBot(void);
};

//+------------------------------------------------------------------+
//| Get entry price as HIGH/LOW of previos period
//+------------------------------------------------------------------+
double CDSADXBot::GetEntryPrice(const ENUM_POSITION_TYPE _dir){
  int extreme_idx = -1;
  double price = 0.0;
    
  if (_dir == POSITION_TYPE_BUY) {
    extreme_idx = iHighest(Sym, EntryPriceExtremeTF, MODE_HIGH, EntryPriceExtremePeriod, 0);
    price = iHigh(Sym, EntryPriceExtremeTF, extreme_idx);
  }
    
  if (_dir == POSITION_TYPE_SELL) {
    extreme_idx = iLowest(Sym, EntryPriceExtremeTF, MODE_LOW, EntryPriceExtremePeriod, 0);    
    price = iLow(Sym, EntryPriceExtremeTF, extreme_idx);
  }
    
  logger.Debug(StringFormat("%s/%d: Found last %d bars %s on %s for %s: PRICE=%f; IDX=%d",
                            __FUNCTION__, __LINE__,
                            EntryPriceExtremePeriod,
                            (_dir == POSITION_TYPE_BUY) ? "HIGH" : "LOW",
                            TimeframeToString(EntryPriceExtremeTF), 
                            PositionTypeToString(_dir),
                            price,
                            extreme_idx
                            ));    
    
  return price;
}

ulong CDSADXBot::OpenOrder(const ENUM_POSITION_TYPE _dir, 
                           const double _lot,
                           const double _price,
                           const double _sl,
                           const double _tp,
                           const string _comment
                           ) {
  ENUM_ORDER_TYPE order_type = (_dir == POSITION_TYPE_BUY) ? ORDER_TYPE_BUY_STOP : ORDER_TYPE_SELL_STOP;
  return Trade.OrderOpen(Sym, order_type, _lot, 0, _price, _sl, _tp, 0, 0, _comment);  
}

//+------------------------------------------------------------------+
//| Open orders
//+------------------------------------------------------------------+
bool CDSADXBot::OpenOrders(void) {
  CSymbolInfo sym;
  if (!sym.Name(Sym)) return false;
  if (sym.TickValue() <= 0) return false;
  if (sym.TickSize() <= 0) return false;
  
  double price_buy = GetEntryPrice(POSITION_TYPE_BUY);
  double price_sell = GetEntryPrice(POSITION_TYPE_SELL);  
  //double lot_buy = CalculateLotSuperForSum(Sym, MMValue, price_buy, 0);
  //double lot_sell = CalculateLotSuperForSum(Sym, MMValue, price_sell, 0);
  double lot_buy = (price_buy > 0) ? NormalizeLot(Sym, MMValue/price_buy) : 0;
  double lot_sell = (price_sell > 0) ? NormalizeLot(Sym, MMValue/price_sell) : 0;

  double sl_dist = SLDist;
  double tp_dist = TPDist;
  double sl_buy = price_buy-sl_dist;
  double sl_sell = price_sell+sl_dist;
  double tp_buy = price_buy+tp_dist;
  double tp_sell = price_sell-tp_dist;
  string time = TimeToString(TimeCurrent());
  string comment = StringFormat("%s|%s", logger.Name, time);
  
  bool res = OpenOrder(POSITION_TYPE_BUY,  lot_buy,  price_buy,  sl_buy,  tp_buy,  comment) &&
             OpenOrder(POSITION_TYPE_SELL, lot_sell, price_sell, sl_sell, tp_sell, comment);
             
  logger.Assert(res,
                StringFormat("%s/%d: Both orders opened",
                             __FUNCTION__, __LINE__), INFO,
                StringFormat("%s/%d: One or both orders open error",
                             __FUNCTION__, __LINE__), ERROR);

  return res;
} 

//+------------------------------------------------------------------+
//| Check And Cancel Orders
//+------------------------------------------------------------------+
bool CDSADXBot::DeleteOrders(void) {  
  bool res = false;
  COrderInfo order;
  int i=0;
  while (i<OrdersTotal()) {
    if (!order.SelectByIndex(i)) {i++; continue;};
    if (!(order.Magic() == Magic && order.Symbol() == Sym)) {i++; continue;};
    
    if (Trade.OrderDelete(order.Ticket())) res = true;
    else i++;
  }
 
  return res;  
} 

//+------------------------------------------------------------------+
//| Check High and Lows condition to close pos
//+------------------------------------------------------------------+
bool CDSADXBot::CheckBarHighLowAndClosePos(void) { 
  double h[];
  double l[];
  double c[];
  double o[];
  
  if (!(CopyHigh(Sym, EntryPriceExtremeTF, 0, 2, h) >= 2 &&
        CopyLow(Sym, EntryPriceExtremeTF, 0, 2, l) >= 2 &&
        CopyClose(Sym, EntryPriceExtremeTF, 0, 2, c) >= 2 &&
        CopyOpen(Sym, EntryPriceExtremeTF, 0, 2, o) >= 2)) 
    return false;
    

  int res = 0;  
  if ((h[1]-o[1]) > (h[0]-l[0])*2) {
    CPositionInfo pos;
    int i=0;
    while (i<PositionsTotal()) {
      if (!pos.SelectByIndex(i)) {i++; continue;};
      if (!(pos.Magic() == Magic && pos.Symbol() == Sym)) {i++; continue;};
      
      if (Trade.PositionClose(pos.Ticket())) res++;
      else i++;
    }  
  }
  
  logger.Debug(StringFormat("%s/%d: CLOSE_COND=%s; h=%f; o=%f; h[-1]=%f; l[-1]=%f; DEL_POS_CNT=%d",
                            __FUNCTION__, __LINE__,
                            ((h[1]-o[1]) > (h[0]-l[0])*2) ? "True" : "False",
                            h[1], o[1], h[0], l[0],
                            res));
  return res>0;
}

//+------------------------------------------------------------------+
//| Check and set BE
//+------------------------------------------------------------------+
bool CDSADXBot::CheckAndSetBE(void) { 
  int res = 0;  
  CPositionInfo pos;
  for (int i=0; i<PositionsTotal(); i++) {
    if (!pos.SelectByIndex(i)) continue;
    if (!(pos.Magic() == Magic && pos.Symbol() == Sym)) continue;
    
    if (pos.Profit() <= 0) continue; // Move to BE only if we have profit
    if ((pos.PositionType() == POSITION_TYPE_BUY  && pos.StopLoss() >= pos.PriceOpen()) ||
        (pos.PositionType() == POSITION_TYPE_SELL && pos.StopLoss() <= pos.PriceOpen())) continue; // SL already better than BE
    if (MathAbs(pos.PriceCurrent()-pos.PriceOpen()) < (double)BEDist) continue; // Move to BE only if we pass BEDistPnt
    
    logger.Debug(StringFormat("%s/%d: Updating pos to BE: TICKET=%I64u; DIST=%d>=%d",
                              __FUNCTION__, __LINE__,
                              pos.Ticket(),
                              PriceToPoints(Sym, MathAbs(pos.PriceCurrent()-pos.PriceOpen())),
                              BEDist
                              ));
                              
    Trade.PositionModify(pos.Ticket(), pos.PriceOpen(), 0);
  }  
  
  return true;
}

//+------------------------------------------------------------------+
//| Check No Open Pos
//+------------------------------------------------------------------+
bool CDSADXBot::HasPos(void) {
  CPositionInfo pos;
  for (int i=0; i<PositionsTotal(); i++) {
    if (!pos.SelectByIndex(i)) continue;
    if (!(pos.Magic() == Magic && pos.Symbol() == Sym)) continue;
    
    logger.Debug(StringFormat("%s/%d: Found open pos: TICKET=%I64u",
                              __FUNCTION__, __LINE__,
                              pos.Ticket()));
    return true;
  }
  
  logger.Debug(StringFormat("%s/%d: No pos found",
                            __FUNCTION__, __LINE__));  
  return false;
}

//+------------------------------------------------------------------+
//| Check Pending Orders
//+------------------------------------------------------------------+
bool CDSADXBot::HasOrder(void) {
  COrderInfo order;
  for (int i=0; i<OrdersTotal(); i++) {
    if (!order.SelectByIndex(i)) continue;
    if (!(order.Magic() == Magic && order.Symbol() == Sym)) continue;
    
    logger.Debug(StringFormat("%s/%d: Found order: TICKET=%I64u",
                              __FUNCTION__, __LINE__,
                              order.Ticket()));
    return true;
  }
  
  logger.Debug(StringFormat("%s/%d: No order found",
                            __FUNCTION__, __LINE__));  
  return false;
}

//+------------------------------------------------------------------+
//| Check Signal
//+------------------------------------------------------------------+
bool CDSADXBot::HasSignal(void) {
  double adx[];
  if (!CopyBuffer(ADXHandle, 0, ADXBarShift, 1, adx)) {
    logger.Debug(StringFormat("%s/%d: ADX buffer is empty",
                              __FUNCTION__, __LINE__
                              ));
    return false;
  }

  logger.Debug(StringFormat("%s/%d: ADX_SIG=%s (%f %s %f)",
                            __FUNCTION__, __LINE__,
                            (adx[0] < ADXTradingValue) ? "SIG" : "NO_SIG",
                            adx[0],
                            (adx[0] < ADXTradingValue) ? "<" : ">=",
                            ADXTradingValue
                            ));  
  if (!(adx[0] < ADXTradingValue)) return false;
  
  if (HasPos()) return false;
  if (HasOrder()) return false;
  
  logger.Info(StringFormat("%s/%d: Signal detected: ADX=%f %s %f",
                            __FUNCTION__, __LINE__,
                            adx[0],
                            (adx[0] < ADXTradingValue) ? "<" : ">=",
                            ADXTradingValue
                            ));  

  return true;
}

//+------------------------------------------------------------------+
//| OnTick Handler
//+------------------------------------------------------------------+
void CDSADXBot::OnTick(void) {
  if (HasSignal()) 
    OpenOrders();
    
  if (HasPos()) {
    DeleteOrders();
    if (EXOnBarSize) 
      CheckBarHighLowAndClosePos();
    CheckAndSetBE();
  }
}

//+------------------------------------------------------------------+
//| Constructor
//+------------------------------------------------------------------+
void CDSADXBot::CDSADXBot(void) {
  Sym = Symbol();
  BuyEnabled = false;
  SellEnabled = false;
  MMType = ENUM_MM_TYPE_FIXED_LOT;
  MMValue = 0.01;
  ADXBarShift = 0;
  ADXTradingValue = 50;
  EntryPriceExtremePeriod = 46;
  EntryPriceExtremeTF = PERIOD_CURRENT;
  SLDist = 3000;
  TPDist = 4500;
  BEDist = 2000;
}