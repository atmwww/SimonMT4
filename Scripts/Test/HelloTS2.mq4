//+------------------------------------------------------------------+
//|                                                     HelloTS2.mq4 |
//|                                                            Simon |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Simon"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
#property script_show_inputs

#include "..\..\Experts\Transaction\MyTradeHelper.mqh"
MyTradeHelper tradeHelper;
input int MAGIC_NUM = 11111;
input int 追蹤步數 = 10;
//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart()
  {
      //tradeHelper.TrailingStop(追蹤步數);
      tradeHelper.Hello();
  }
//+------------------------------------------------------------------+
