//+------------------------------------------------------------------+
//|                                                  Constellate.mqh |
//|                                                            Simon |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Simon"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class GannValue
  {
private:

public:
                     GannValue();
                    ~GannValue();
                
   double value;
   string part;
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
GannValue::GannValue()
  {
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
GannValue::~GannValue()
  {
  }
//+------------------------------------------------------------------+