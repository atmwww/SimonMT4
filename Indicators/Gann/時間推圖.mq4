//+------------------------------------------------------------------+
//|                                                          風車位.mq4 |
//|                                                            Simon |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Simon"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
//#property indicator_chart_window

#include "../../Experts/Instance/GannSquare/GannTime.mqh"
#include "../../Experts/Utils/GannScale.mqh"


//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
   IndicatorSetString(INDICATOR_SHORTNAME,"GANNTIME");
   DeleteObjects(false);
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
   //--- Show the event parameters on the chart
   //Comment(__FUNCTION__,": id=",id," lparam=",lparam," dparam=",dparam," sparam=",sparam);
     if(id==CHARTEVENT_CHART_CHANGE){
       //Alert("CHARTEVENT_CHART_CHANGE");
       DrawButton("GANNTIME_BUTTON_DEL", "刪除", 60, 50, ChartGetInteger(0,CHART_WIDTH_IN_PIXELS,0)-80, 25);
       DrawButton("GANNTIME_BUTTON_REFRESH", "重推", 60, 50,  (ChartGetInteger(0,CHART_WIDTH_IN_PIXELS,0)-80-60),25);
     }
     
     if(id==CHARTEVENT_OBJECT_CLICK){
        //Alert(__FUNCTION__, " CHARTEVENT_OBJECT_CLICK");
            if(sparam=="GANNTIME_BUTTON_DEL"){
            int window=ChartWindowFind();
            ChartIndicatorDelete(0, window, "GANNTIME");
        }else if(sparam=="GANNTIME_BUTTON_REFRESH"){
            DeleteObjects(false);
           
        }
     }
     
      if(id==CHARTEVENT_CLICK)
     {  
         
         //Alert(__FUNCTION__, " PURE_CHARTEVENT_CLICK");
         //--- Prepare variables
         int      x     =(int)lparam;
         int      y     =(int)dparam;
         datetime dt    =0;
         double   price =0;
         int      window=0;
         //Alert("x: "+x+", y: "+y);
         
        //---如果觸控發生在Button則ignore
        if(IsButton(x,y)){
           //Alert("InButton");
           return;
        }else{
           //Alert("In not Button");
           ObjectSetInteger(0, "GANNTIME_BUTTON_REFRESH", OBJPROP_STATE, FALSE);
        }
        
         //--- Convert the X and Y coordinates in terms of date/time
         if(ChartXYToTimePrice(0,x,y,window,dt,price))
           {
            //Alert("price: "+price);
            PrintFormat("Window=%d X=%d  Y=%d  =>  Time=%s  Price=%G",window,x,y,TimeToString(dt),price);
            //--- Perform reverse conversion: (X,Y) => (Time,Price)
            if(ChartTimePriceToXY(0,window,dt,price,x,y))
               PrintFormat("Time=%s  Price=%G  =>  X=%d  Y=%d",TimeToString(dt),price,x,y);
            else
               Print("ChartTimePriceToXY return error code: ",GetLastError()); 
               
            Comment(__FUNCTION__,": dt=",dt," Price1=",DoubleToStr(price, Digits));
            DrawTimeLine(window, dt, clrRed, dt, price);
            
            //Alert("time: "+TimeToStr(dt, TIME_DATE|TIME_MINUTES));
            RunGannTime(dt);
            
           }
         else
            Print("ChartXYToTimePrice return error code: ",GetLastError());
            Print("+--------------------------------------------------------------+");
        
     }
      
     
 
  }
  void RunGannTime(datetime time){
     //Alert("inro RunGannTime");  
     
     int step = 1;
     //Alert("GannValue1: "+gannValue1+", gannValue2: "+gannValue2+", step: "+step);
     GannTime *gann = new GannTime();
     GannValue* gannValue = gann.ConvertDatetimeToGannValue(time);
     int recommand = gann.GetRecommandSize(1, gannValue.value, step, 2);
     //Alert("recommand size is: "+recommand);
     gann.DrawSquare(1, step, recommand, DRAW_CW);
     //Debug::PrintArray("crValues",cursor);
     
     gann.SetDatas(gannValue.value);
     GannValue* ganns[];
     gann.Run(ganns);
     //Debug::PrintArray("Windmill",ganns);
     
     DrawLines(ganns);
  }
  
  bool IsButton(int x, int y){
        bool returnValue = false;
        int found_window = ObjectFind(0,"GANNTIME_BUTTON_REFRESH");
        //Alert("found_window: "+found_window);
        int BtnBottom;
        int BtnLeft;
        if(found_window>=0){
            BtnBottom =ObjectGetInteger(found_window, "GANNTIME_BUTTON_REFRESH", OBJPROP_YDISTANCE, 0)+ObjectGetInteger(found_window, "GANNTIME_BUTTON_REFRESH", OBJPROP_YSIZE, 0);
            BtnLeft = ObjectGetInteger(found_window, "GANNTIME_BUTTON_REFRESH", OBJPROP_XDISTANCE, 0);
            //Alert("GANNTIME_BUTTON_REFRESH BtnBottom: "+BtnBottom+", BtnLeft: "+BtnLeft+", x: "+x+", y: "+y);
            if(y<=BtnBottom & x >=BtnLeft)returnValue = true;
        }
        return returnValue;   
  }
  
//+------------------------------------------------------------------+
  void DeleteObjects(bool cleanAll){    
     if(cleanAll){
         ObjectsDeleteAll(0, "GANNTIME_", -1, -1);
         Comment("");
     }else{
         ObjectsDeleteAll(0, "GANNTIME_LINE_", -1, -1);
         Comment("請選擇一個時間點");
     }
     
  }
  
 void DrawTimeLine(int window, datetime dt, color clr, double x, double y){
 
      //--- create vertical line
      string VERTICAL_LINE   = "GANNTIME_LINE_V_"+TimeToStr(dt, TIME_DATE|TIME_MINUTES);
      ObjectCreate(0,VERTICAL_LINE,OBJ_VLINE,window,dt,0);
      ObjectSetInteger(0,VERTICAL_LINE,OBJPROP_COLOR,clr);
      ChartRedraw(0);

  }

void DrawLines(GannValue* &ganns[]){
   int unique_id = MathRand();
   //Alert("Unique_id: "+unique_id);
   for(int i = 0; i <ArraySize(ganns);i++){
      double value = GannScale::ConvertToValue(Symbol(),ganns[i].value);
      DrawLine("GANNTIME_LINE_"+unique_id+"_"+i,value);
   }
  
} 
void DrawLine(string obj_name, double positionY){
   ObjectCreate(obj_name, OBJ_HLINE , 0, Time[0], positionY);
   //ObjectSet(obj_name, OBJPROP_STYLE, STYLE_DASH);
   ObjectSet(obj_name, OBJPROP_COLOR, clrLavender);
   ObjectSet(obj_name, OBJPROP_WIDTH, 2);
   //ObjectSetText(obj_name, "What you want to call your line", 8, "Arial", Orange); 
}

void DrawButton(string obj_name, string text, int width, int height, int x, int y){
    ObjectCreate(0,obj_name,OBJ_BUTTON,0,0,0);
    ObjectSetInteger(0,obj_name,OBJPROP_XDISTANCE,x);
    ObjectSetInteger(0,obj_name,OBJPROP_YDISTANCE,y);
    ObjectSetInteger(0,obj_name,OBJPROP_XSIZE,width);
    ObjectSetInteger(0,obj_name,OBJPROP_YSIZE,height);
    ObjectSetString(0,obj_name,OBJPROP_TEXT,text);
    ObjectSetInteger(0,obj_name,OBJPROP_SELECTED,false);
}

void OnDeinit(const int reason)
  {
  //----
   //Alert("OnDeinit reason: "+reason);
   if(reason == REASON_REMOVE){
       DeleteObjects(true);
}
  

//----
   
  }