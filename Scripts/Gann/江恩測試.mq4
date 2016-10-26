//+------------------------------------------------------------------+
//|                                                        江恩 V1.mq4 |
//|                                                            Simon |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Simon"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

#include "..\..\Experts\Utils\GannScale.mqh"
#include "..\..\Experts\Instance\GannSquare\Windmill.mqh"
#include "..\..\Experts\Instance\GannSquare\FourAngles.mqh"
#include "..\..\Experts\Instance\GannSquare\FullConstellate.mqh"
#include "..\..\Experts\Instance\GannSquare\GannTime.mqh"
//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart()
  {
//---

   //double beginValue = 1235;//美日現今空頭司令
   //double beginValue = GannScale::ConvertToGannValue(Symbol(),100.075);
   //Alert("beginValue: "+beginValue);


   // 角線測試
   //double Angles[];
   //int angle = gann.RunAngle(RUN_LOW, beginValue, Angles);
   //Debug::PrintArray("Angles",Angles, 0);
   //Alert(beginValue+"'s HIGH Angle is: "+angle);
   
   // 十字線測試
   //double Crosses[];
   //int cross = gann.RunCross(RUN_LOW, beginValue, step, Crosses);
   //Alert(beginValue+"'s RUN_LOW Cross is: "+cross);
   
   // 同位階測試
   //double sameLevel = gann.RunSameLevel(beginValue, IS_LOW, step);
   //Alert(beginValue+"'s sameLevel is: "+sameLevel);  
   
   // 測試價位轉換
   //double gannValue = GannScale::ConvertToGannValue(Symbol(), iLow(Symbol(), Period(), 1));
   //double value = GannScale::ConvertToValue(Symbol(), gannValue);
 

   // Constellate完整跑圖
   //FullConstellate* gannFlCons = new FullConstellate();
   //double baseValue = 1;
   //double beginValue = 200;
   //int step = 1;
   //// 詢問建議圈數
   //int recommandSize = gannFlCons.GetRecommandSize(baseValue, beginValue, step, 2);
   //Alert("recommandSize: "+recommandSize);
   //gannFlCons.DrawSquare(baseValue, step, recommandSize, DRAW_CW);  // CW為順時針
   //int parts = 10;
   //gannFlCons.SetDatas(RUN_HIGH, beginValue, step, parts, false);  
   //GannValue *Constellates[];
   //gannFlCons.Run(Constellates);
   //Debug::PrintArray("Constellates", Constellates);
    
   // Constellate 四角推圖
   //FourAngles* gann1 = new FourAngles();
   // // 詢問建議圈數
   //int recommandSize = gann1.GetRecommandSize(baseValue, beginValue, step, 2);
   ////Alert("recommandSize: "+recommandSize);
   //gann1.DrawSquare(baseValue, step, recommandSize, DRAW_CW);  // CW為順時針
   //int parts = 10;
   //gann1.SetDatas(RUN_LOW, beginValue, step, parts);
   //GannValue* gannValues[];
   //gann1.Run(gannValues);

   
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

   //所屬圈數運算
   //double searchValue = 25;
   //double circlenum = gann.GetCircleNumByValue(searchValue);
   //Alert(searchValue+"'s circle num is : "+circlenum);   
   
   //風車位推圖
   //double baseValue = 1;
   //double beginValue = 126;
   //double step = 1;
   //Windmill* gann = new Windmill();
   //// 詢問建議圈數
   //int recommandSize = gann.GetRecommandSize(baseValue, beginValue, step, 2);
   //Alert("recommandSize: "+recommandSize);
   //gann.DrawSquare(baseValue, step, recommandSize, DRAW_CW);  // CW為順時針
   //int run_type = RUN_LOW;
   //gann.SetDatas(run_type, baseValue, beginValue);
   //Alert("[跑風車位]:::baseValue: "+baseValue+", beginValue: "+beginValue+", RUN_HIGH/LOW: "+run_type);
   //GannValue* gannValue[];
   //gann.Run(gannValue);
   //Debug::PrintArray("WindmillValue",gannValue);
   
   //江恩時間推圖法
   double baseValue = 1;
   double beginValue = 31;
   double step = 1;
   int size = 13;
   GannTime* gann = new GannTime();
   gann.DrawSquare(baseValue, step, size, DRAW_CW);
   gann.SetDatas(beginValue);
   GannValue* gannValue[];
   gann.Run(gannValue);
   Debug::PrintArray("GannTime",gannValue);
   double actValue = gannValue[0].value;
   //actValue = 29;
   gann.ConvertValueToDatetime(actValue);
  }
//+------------------------------------------------------------------+
