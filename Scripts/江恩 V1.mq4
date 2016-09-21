//+------------------------------------------------------------------+
//|                                                        江恩 V1.mq4 |
//|                                                            Simon |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Simon"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

#include "..\Experts\Utils\Gann.mqh"

Gann gann;
//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart()
  {
//---
   double step = 1;
   gann.DrawSquare(1,step,14, DRAW_CW);  // CW為順時針
   double beginValue = 686;
   
   //double Angles[];
   //int angle = gann.RunAngle(RUN_HIGH, beginValue, Angles);
   //Alert(beginValue+"'s HIGH Angle is: "+angle);
   
   //double Crosses[];
   //int cross = gann.RunCross(RUN_LOW, beginValue, step, Crosses);
   //Alert(beginValue+"'s HIGH Cross is: "+cross);
   
   double sameLevel = gann.RunSameLevel(RUN_HIGH, beginValue, step);
   Alert(beginValue+"'s sameLevel is: "+sameLevel);
  }
//+------------------------------------------------------------------+
