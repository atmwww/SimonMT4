//+------------------------------------------------------------------+
//|                                                         test.mq4 |
//|                                                            Simon |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Simon"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
#property indicator_chart_window

#include "..\..\Experts\Utils\Gann.mqh"
#include "..\..\Experts\Utils\GannScale.mqh"

enum ENUM_RUNMODE
{
   求接下來低點,
   求接下來高點
};

extern ENUM_RUNMODE RunMode;//跑圖方向
extern int parts = 6;//欲跑段數

Gann gann;
GannValue* GannValues[];
bool iscomputing = false;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   if(RunMode==求接下來低點){
      Alert("請在圖表視窗選擇一根 \"至高點\" K棒。");
   }else{
      Alert("請在圖表視窗選擇一根 \"至低點\" K棒。");
   }
   
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
//---
   //Alert("OnCalculate");
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
//| ChartEvent function                                              |
//+------------------------------------------------------------------+
void OnChartEvent(const int id,
                  const long &lparam,
                  const double &dparam,
                  const string &sparam)
  {
   if(iscomputing==TRUE){
      Alert("背景仍在作業中，請稍候再試");
      return;
   }
   
   //--- If this is an event of a mouse click on the chart
   if( id==CHARTEVENT_CLICK)
     {
      //--- Prepare variables
      int      x     =(int)lparam;
      int      y     =(int)dparam;
      datetime dt    =0;
      double   price =0;
      int      window=0;


      //--- Convert the X and Y coordinates in terms of date/time
      if(ChartXYToTimePrice(0,x,y,window,dt,price))
        {
         //PrintFormat("Window=%d X=%d  Y=%d  =>  Time=%s  Price=%G",window,x,y,TimeToString(dt),price);
         
         int shift = iBarShift(Symbol(), Period(), dt, false);
         double      price_high = High[shift];
         double      price_low  = Low[shift];
         
         //--- Show the event parameters on the chart
         Comment(__FUNCTION__,": dt=",dt," High=",DoubleToStr(price_high, Digits)," Low=",DoubleToStr(price_low, Digits));
         //--- 繪製十字線
         DrawCross(window, dt, clrGreen, price, price_high, price_low);
         //--- 繪製跑圖結果
         RunFourAngles(shift);  
         
           
        }
      else
         Print("ChartXYToTimePrice return error code: ",GetLastError());
      Print("+--------------------------------------------------------------+");
      
     }
    
  }
//+------------------------------------------------------------------+

  int deinit()
  {
//----
   ObjectDelete(0, "H Line");
   ObjectDelete(0, "V Line");
   //ObjectsDeleteAll();
//----
   return(0);
  }
  
  void DrawCross(int window, datetime dt, color clr, double price, double price_high, double price_low){
        //--- delete lines
      ObjectDelete(0,"V Line");
      ObjectDelete(0,"H Line");
      //--- create horizontal and vertical lines of the crosshair
      ObjectCreate(0,"H Line",OBJ_HLINE,window,dt,price_high);
      ObjectSetInteger(0,"H Line",OBJPROP_COLOR,clr);
      ObjectCreate(0,"V Line",OBJ_VLINE,window,dt,price);
      ObjectSetInteger(0,"V Line",OBJPROP_COLOR,clr);
      ChartRedraw(0);

  }
  
  // Constellate 四角推圖
  void RunFourAngles(int  shift){
  Alert("shift: "+shift);
      iscomputing = true;
      
      double      price_high = High[shift];
      double      price_low  = Low[shift];
      Alert("price_high: "+price_high);
       
      double gannValue = GannScale::ConvertToGannValue(Symbol(), price_high);
      Alert("gannValue: "+gannValue);
      
      //---繪製江恩矩陣
      double baseValue = 1;
      double beginValue = gannValue;
      double step = 1;
      // 詢問建議圈數
      int recommandSize = gann.GetRecommandSize(baseValue, beginValue, step, 2);
      Alert("baseValue: "+baseValue+", beginValue: "+beginValue+", step: "+step+", recommandSize: "+recommandSize);
      gann.DrawSquare(baseValue, step, recommandSize, DRAW_CW);  // CW為順時針
      
      //---開始四角推圖
      int run_type = RUN_HIGH;
      if(RunMode==求接下來低點){
         run_type = RUN_LOW;
      }
      GannValue* FourAngles[];
      gann.RunFourAngles(run_type, beginValue, step, parts, FourAngles);
      
      iscomputing = false;
  }