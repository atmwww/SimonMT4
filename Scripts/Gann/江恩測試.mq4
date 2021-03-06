//+------------------------------------------------------------------+
//|                                                        江恩 V1.mq4 |
//|                                                            Simon |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Simon"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

#include "..\..\Experts\Utils\Gann.mqh"
#include "..\..\Experts\Utils\GannScale.mqh"
Gann gann;

//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart()
  {
//---
   
   double baseValue = 1;
   //double beginValue = 1235;//美日現今空頭司令
   //double beginValue = GannScale::ConvertToGannValue(Symbol(),100.075);
   //Alert("beginValue: "+beginValue);
   double beginValue = 922;
   double step = 1;
   // 詢問建議圈數
   int recommandSize = gann.GetRecommandSize(baseValue, beginValue, step, 2);
   gann.DrawSquare(1, step, recommandSize, DRAW_CW);  // CW為順時針
   
   
   // 角線測試
   //double Angles[];
   //int angle = gann.RunAngle(RUN_LOW, beginValue, Angles);
   //Alert(beginValue+"'s HIGH Angle is: "+angle);
   
   // 十字線測試
   //double Crosses[];
   //int cross = gann.RunCross(RUN_LOW, beginValue, step, Crosses);
   //Alert(beginValue+"'s HIGH Cross is: "+cross);
   
   // 同位階測試
   //double sameLevel = gann.RunSameLevel(beginValue, IS_LOW, step);
   //Alert(beginValue+"'s sameLevel is: "+sameLevel);  
   
   // 測試價位轉換
   //double gannValue = GannScale::ConvertToGannValue(Symbol(), iLow(Symbol(), Period(), 1));
   //double value = GannScale::ConvertToValue(Symbol(), gannValue);
 

   // Constellate完整跑圖
   Constellate *Constellates[];
   gann.RunFullConstellate(RUN_LOW, 922, step, 5, true, Constellates);
   Debug::PrintConstellateArray("Constellates", Constellates);
     
      
   // 實算美日同位階
//   int days = 200; 
//   for(int i = 0; i< days; i++){
//       //單位轉換測試
//       string time1 = TimeToStr(iTime(Symbol(), Period(), i), TIME_DATE);
//       double value1 = iLow(Symbol(), Period(), i);
//       double beginValue = GannScale::ConvertToGannValue(Symbol(), value1);
//      
//       //同位階測試
//       double sameLevel = gann.RunSameLevel(beginValue, IS_LOW, step);
//      
//       for(int j = 0; j <days; j++){
//          //單位轉換測試
//          string time2 = TimeToStr(iTime(Symbol(), Period(), j), TIME_DATE);
//          double gannValue = GannScale::ConvertToGannValue(Symbol(), iLow(Symbol(), Period(), j));
//          if(gannValue == sameLevel){
//             double value2 = GannScale::ConvertToValue(Symbol(), sameLevel);
//             Alert("====== ["+time1+"] "+DoubleToStr(value1, Digits)+" 出現同位階 ,對應點位 ["+time2+"] "+DoubleToStr(value2, Digits)+" ======");   
//             break;
//          }
//       }
//      //if(sameLevel!=EMPTY_VALUE)
//         //Alert("=========== "+beginValue+" 's sameLevel is: "+sameLevel+" ===========");   
//   }


      
  }
//+------------------------------------------------------------------+
