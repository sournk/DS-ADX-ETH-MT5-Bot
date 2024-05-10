//+------------------------------------------------------------------+
//|                                           DS-ADX-ETH-MT5-Bot.mq5 |
//|                                                  Denis Kislitsyn |
//|                                             https://kislitsyn.me |
//+------------------------------------------------------------------+

#include <Trade\AccountInfo.mqh>
#include <Trade\PositionInfo.mqh>

#include "Include\DKStdLib\Common\DKStdLib.mqh"
#include "Include\DKStdLib\License\DKLicense.mqh"
#include "Include\DKStdLib\Logger\DKLogger.mqh"
#include "Include\DKStdLib\TradingManager\CDKTrade.mqh"

#include "CDSADXBot.mqh"

#property script_show_inputs

input  group               "1. ENTRY TRADE"
input  bool                InpTRBuy                          = true;                             // 1.TR.B: Buy enabled
input  bool                InpTRSell                         = true;                             // 1.TR.S: Sell enabled
       ENUM_MM_TYPE        InpMMT                            = ENUM_MM_TYPE_FIXED_LOT;           // 1.MM.T: Money Management
input  double              InpMMV                            = 0.01;                             // 1.MM.L: Lot Size
input  ulong               InpSLP                            = 2;                                // 1.SLP: Max Slippage, point
input  uint                InpADXPeriod                      = 24;                               // 1.ADX.MAP: ADX MA Period, bars
input  uint                InpADXBarShift                    = 0;                                // 1.ADX.BS: Bar Shift to get Signal, bars (0-current bar)
input  double              InpADXTV                          = 50;                               // 1.ADX.TV: Place Pending Orders when ADX < Value 
input  uint                InpEPExtPeriod                    = 46;                               // 1.EP.EP: Entry Price as HIGH/LOW of Period, bars
input  ENUM_TIMEFRAMES     InpEPExtTF                        = PERIOD_CURRENT;                   // 1.EP.ETF: Entry Price as HIGH/LOW on TF

input  group               "2. EXIT TRADE"
input  uint                InpSLDistPnt                      = 3000;                             // 2.SL.D: Stop Loss Distance, point
input  uint                InpTPDistPnt                      = 4500;                             // 2.TP.D: Take Profit Distance, point
input  uint                InpBEDistPnt                      = 2000;                             // 2.BE.D: Distance to Move SL to BE, point

input  group               "10. MISC"
sinput LogLevel            InpLL                             = LogLevel(INFO);                   // 10.LL: Log Level
sinput int                 InpMGC                            = 20240509;                         // 10.MGC: Magic
       int                 InpAUP                            = 32*24*60*60;                      // 10.AUP: Allowed usage period, sec
       string              InpGP                             = "DS.ADX";                         // 10.GP: Global Prefix


int                        ADXHandle;
DKLogger                   logger;
CDKTrade                   trade;
CDSADXBot                  bot;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit() {
  //Check dev/test allowed period
  if (CheckExpiredAndShowMessage(InpAUP)) return(INIT_FAILED);  

  // Logger init
  logger.Name   = InpGP;
  logger.Level  = InpLL;
  logger.Format = "%name%:[%level%] %message%";
  
  if (InpSLDistPnt <= 0 || InpTPDistPnt <= 0) {
    logger.Error("SL and TP distance must be possitive", true);
    return(INIT_PARAMETERS_INCORRECT);
  }  
  
  ADXHandle = iADX(Symbol(), Period(), InpADXPeriod);
  if (ADXHandle <= 0) {
    logger.Error("ADX indicator init error", true);
    return(INIT_PARAMETERS_INCORRECT);
  }
  
  trade.SetExpertMagicNumber(InpMGC);
  trade.SetMarginMode();
  trade.SetTypeFillingBySymbol(Symbol());
  trade.SetDeviationInPoints(InpSLP);  
  trade.LogLevel(LOG_LEVEL_NO);
  trade.SetLogger(logger);
  
  bot.Sym = Symbol();
  bot.BuyEnabled = InpTRBuy;
  bot.SellEnabled = InpTRSell;
  bot.MMType = InpMMT;
  bot.MMValue = InpMMV;
  bot.ADXBarShift = InpADXBarShift;
  bot.ADXTradingValue = InpADXTV;
  bot.EntryPriceExtremePeriod = InpEPExtPeriod;
  bot.EntryPriceExtremeTF = InpEPExtTF;
  bot.SLDistPnt = InpSLDistPnt;
  bot.TPDistPnt = InpTPDistPnt;
  bot.BEDistPnt = InpBEDistPnt;
  
  bot.ADXHandle = ADXHandle;
  bot.Trade = trade;
  bot.Magic = InpMGC;
  bot.logger = GetPointer(logger);
  
  EventSetTimer(5);
  
  return(INIT_SUCCEEDED);
}
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason) {
}

//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick() {
  bot.OnTick();
}
//+------------------------------------------------------------------+
//| OnTimer                                                   |
//+------------------------------------------------------------------+
void OnTimer() {
}
//+------------------------------------------------------------------+
//| Trade function                                                   |
//+------------------------------------------------------------------+
void OnTrade() {

}
//+------------------------------------------------------------------+
//| TradeTransaction function                                        |
//+------------------------------------------------------------------+
void OnTradeTransaction(const MqlTradeTransaction& trans,
                        const MqlTradeRequest& request,
                        const MqlTradeResult& result) {
}
