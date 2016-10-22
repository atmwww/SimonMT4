//+------------------------------------------------------------------+
//|                                                       MyMath.mqh |
//|                        Copyright 2016, MetaQuotes Software Corp. |
//|                                              http://www.mql4.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2016, MetaQuotes Software Corp."
#property link      "http://www.mql4.com"
#property version   "1.00"
#property strict

#include "../instance/GannValue.mqh"
#include "../instance/CursorValue.mqh"
//#include "Debug.mqh"


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class MyMath
  {
private:
                   
                    static void PrintArray(string msg, GannValue* &array[]);
                    static void PrintArray(string msg, double &array[][1]);
public:
                     MyMath();
                    ~MyMath();
                    static double FindClosestIdx(double &array[], double value);
                    static double FindClosestValue(double &array[], double value);
                    static double FindClosestValue(CursorValue* &array[], double value);
                    static void ReverseArray(double &src_array[], double & des_array[]);
                    static int FindIdxByValue(CursorValue* &src_array[], double value);
                    static int FindIdxByValue(double &src_array[], double value);
                    static double GetMinimumValue(double &src_array[]);
                    static double GetMaximumValue(double &src_array[]);
                    static int GetDecimalBits(double target);
                    static bool HasDecimalBits(double target);
                    static double GetHighestPrice(int count, int start_shift);
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
MyMath::MyMath()
  {
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
MyMath::~MyMath()
  {
  }
//+------------------------------------------------------------------+
static double MyMath::FindClosestIdx(double &array[],double value)
{
    double min = EMPTY_VALUE;
    double closestIdx = -1;

    for(int i = 0; i < ArraySize(array); i ++){
       double v = array[i];
       double diff = MathAbs(v - value);
       if (diff < min) {
            min = diff;
            closestIdx = i;
       }
    }

    return closestIdx;
}
static double MyMath::FindClosestValue(double &array[],double value)
{
    int idx = FindClosestIdx(array, value);
    return array[idx];
}
static double MyMath::FindClosestValue(CursorValue* &array[],double value)
{
    double min = EMPTY_VALUE;
    double closest = value;

    for (CursorValue* v : array) {
        double diff = MathAbs(v.value - value);

        if (diff < min) {
            min = diff;
            closest = v.value;
        }
    }

    return closest;
}

static void MyMath::ReverseArray(double &src_array[], double &des_array[])
{
   int src_array_size = ArraySize(src_array);
   ArrayResize(des_array, src_array_size, 0);
   for( int i = src_array_size - 1; i >= 0; i-- ) {
      int desIdx = src_array_size - i - 1;
      des_array[desIdx] = src_array[i];
      //Alert("reverse::: src i = "+i+" => des i = "+desIdx);
   }
}

static int MyMath::FindIdxByValue(double &src_array[], double value)
{
    int found_idx = -1;
    int size = ArraySize(src_array);
    //Alert("size src_array is : "+size);
    for(int i =0;i<size;i++){
      //Alert("i: "+i+" is "+src_array[i]+", want to find: "+value);
      if(src_array[i]==value){
         found_idx = i;
         break;
      }
    }
    return found_idx;
}

static int MyMath::FindIdxByValue(CursorValue* &src_array[], double value)
{
    int found_idx = -1;
    for(int i =0;i<ArraySize(src_array);i++){
      //Alert("i: "+i+" is "+src_array[i]);
      if(src_array[i].value==value){
         found_idx = i;
         break;
      }
    }
    return found_idx;
}



static double MyMath::GetMinimumValue(double &src_array[])
{
   double minValue = EMPTY_VALUE;
   int MinIdx = ArrayMinimum(src_array, WHOLE_ARRAY, 0);
   //Alert("MnIdx: "+MinIdx);
   if(MinIdx>=0){
      minValue = src_array[MinIdx];
   }else{
      minValue = EMPTY_VALUE;
   }
   return minValue;
}

static double MyMath::GetMaximumValue(double &src_array[])
{
   double maxValue = EMPTY_VALUE;
   int MaxIdx = ArrayMaximum(src_array, WHOLE_ARRAY, 0);
   //Alert("MaxIdx: "+MaxIdx);
   if(MaxIdx>=0){
      maxValue = src_array[MaxIdx];
   }else{
      maxValue = EMPTY_VALUE;
   }
   return maxValue;
}

static int MyMath::GetDecimalBits(double target) {
    int decimalbits = 0;
    
    if(HasDecimalBits(target)){
        double testingTarget = target;
        for(int i = 1; i< 20; i++){
            double pow = MathPow(10, i);
            double testingTarget = testingTarget * pow;
            if(HasDecimalBits(testingTarget) == FALSE){
               //Alert("testingTarget "+testingTarget+" ,pow "+pow);
               decimalbits = i;
               break;
            }
        }
    }
    return decimalbits;
}

static bool MyMath::HasDecimalBits(double target)
{  
   bool hasDecimal = (0.0 != MathMod(target, 1));
   if(hasDecimal == FALSE){
      //Alert(target+ " has no DecimalBits");
   }
   return hasDecimal;
}


static void MyMath::PrintArray(string msg, double &array[][1])
{
   int size_array = ArraySize(array);
   Alert("PrintArray=>size_array: "+size_array);
   for(int i =0; i<ArraySize(array);i++)
   {
      Alert(msg+":::"+"["+i+"] "+array[i][0]);
      //Alert(msg+":::"+"["+i+"] "+array[i][1]);
   }
}

static void MyMath::PrintArray(string msg, GannValue* &array[])
{
   string temp[];
   for(int i =0;i<ArraySize(array);i++){
      int size = ArraySize(temp);
      ArrayResize(temp, ++size);
      temp[size-1] = "第"+array[i].part+"段:::"+array[i].value;
      
      Alert(msg+":::"+"["+i+"] "+temp[i]);
   }
}

 static double MyMath::GetHighestPrice(int count, int start_shift){
   int shift = iHighest(Symbol(), Period(), MODE_HIGH, count, start_shift);
   double price = High[shift];
   Alert("highest price shift is: "+shift+", price is "+price);
   return price;
 }