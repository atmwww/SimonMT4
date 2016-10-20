//+------------------------------------------------------------------+
//|                                              FullConstellate.mqh |
//|                                                            Simon |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Simon"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

#include "Gann.mqh"

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+


class FullConstellate : public Gann
  {
private:
                  int mRunType;
                  double mBeginValue;
                  double mStep;
                  int mParts;
                  bool mArrangeResult;
                  void ArrangeConstellate(bool run_type, GannValue* &src_array[]);
                  void ConstellateArraySort(GannValue* &src_array[], int count,int start_idx, int sort_dir );
                  void ConsArrayToDoubleArray(double &des_array[][], GannValue* &src_array[]);
                  GannValue* GetMinimumConstellate(GannValue* &src_array[]);
                  GannValue* GetMaximumConstellate(GannValue* &src_array[]);
public:
                     FullConstellate();
                    ~FullConstellate();
                    virtual void Run(GannValue* &values[]);
                    void SetDatas(int run_type, double begin_value, double step, double parts, bool arrange_result);
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
FullConstellate::FullConstellate()
  {
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
FullConstellate::~FullConstellate()
  {
  }
//+------------------------------------------------------------------+
void FullConstellate::SetDatas(int run_type, double begin_value, double step, double parts, bool arrange_result){
   mRunType = run_type;
   mBeginValue = begin_value;
   mStep = step;
   mParts = parts;
   mArrangeResult = arrange_result;
}
void FullConstellate::Run(GannValue* &values[]){
   double Null[];
   GannValue *TempBefore1[];
   GannValue *TempBefore2[];
   GannValue *TempNow[];
   GannValue *ReturnArray[];
   int size_temp_b1 = ArraySize(TempBefore1);
   ArrayResize(TempBefore1, ++size_temp_b1);
   GannValue *cons0 = new GannValue();
   cons0.part = 0;
   cons0.value=mBeginValue;
   TempBefore1[0]=cons0;
   
   for(int i = 0; i<mParts; i++){
      int partNow = i+1;
      //開始跑前一段的90度
      for(int j = 0; j < ArraySize(TempBefore1); j++){ 
         int size_temp_now = ArraySize(TempNow);
         ArrayResize(TempNow, ++size_temp_now);
         double value = RunAngle(mRunType, TempBefore1[j].value, Null);
         GannValue *cons = new GannValue();
         cons.part = partNow;
         cons.value=value;
         TempNow[size_temp_now-1] = cons;
         //Alert("temp now => "+j+" value: "+value); 
         
         //同時放一份到欲回傳陣列         
         int size_returnarray = ArraySize(ReturnArray);
         ArrayResize(ReturnArray, ++size_returnarray);
         ReturnArray[size_returnarray-1]=cons;
      }
      
      //開始跑前二段的180度
      for(int k = 0; k < ArraySize(TempBefore2); k++){ 
         int size_temp_now = ArraySize(TempNow);
         ArrayResize(TempNow, ++size_temp_now);
         double value = RunCross(mRunType, TempBefore2[k].value, mStep, Null);
         GannValue *cons = new GannValue();
         cons.part = partNow;
         cons.value = value;
         TempNow[size_temp_now-1] = cons;
         //Alert("temp now => "+k+" value: "+value); 
         
         //同時放一份到欲回傳陣列         
         int size_returnarray = ArraySize(ReturnArray);
         ArrayResize(ReturnArray, ++size_returnarray);
         ReturnArray[size_returnarray-1]=cons;
      }
      ArrayFree(TempBefore2);
      ArrayCopy(TempBefore2, TempBefore1, 0, 0, WHOLE_ARRAY);
      ArrayCopy(TempBefore1, TempNow, 0, 0, WHOLE_ARRAY);
      ArrayFree(TempNow);
     
   }
   
   bool run_bool = FALSE;
   if(mRunType==RUN_HIGH){
      run_bool = TRUE;
   }
   // 篩選掉相近值
   if(mArrangeResult)ArrangeConstellate(run_bool, ReturnArray);
   //Debug::PrintArray("ReturnArray", ReturnArray);
   ArrayCopy(values, ReturnArray, 0, 0 , WHOLE_ARRAY);
}

void FullConstellate::ArrangeConstellate(bool run_type, GannValue* &src_array[])
{  //diff = 3
   // 1 2 3  8  9  10 ==> 9跟10比，小於3  留9
   //Alert("===ArrangeConstellate===");
   if(run_type){
      ConstellateArraySort(src_array, WHOLE_ARRAY, 0, MODE_ASCEND);
   }else{
      ConstellateArraySort(src_array, WHOLE_ARRAY, 0, MODE_DESCEND);
   }

   //PrintArray("AfterConstellateArraySort", src_array);
   
   int size_srcarray = ArraySize(src_array);
   //Alert("size_srcarray: "+size_srcarray);
   
   GannValue *returnarray[];
   GannValue* temp[];
   int distance = 10;
   
   
   for(int i=0; i<size_srcarray; i++){
      
      double valueNow = src_array[i].value;
      double valueNext = EMPTY_VALUE;
      if(i<size_srcarray-1)valueNext = src_array[i+1].value;
      //Alert("valueNow = "+valueNow+ " <==> valueNext = "+valueNext);
      if(MathAbs(valueNow-valueNext)<distance){
         int size_temp1 = ArraySize(temp);
         ArrayResize(temp, ++size_temp1, 0);
         temp[size_temp1-1]=src_array[i];
         int size_temp2 = ArraySize(temp);
         ArrayResize(temp, ++size_temp2, 0);
         temp[size_temp2-1]=src_array[i+1]; 
         //Alert("into src_array["+i+"]"+src_array[i].value+" - src_array["+(i+1)+"]"+src_array[i+1].value+" < diff "+distance);        
      }else{
         if(ArraySize(temp)>0){
            //1.先將之前的接近數整理出來
             
            ConstellateArraySort(temp, WHOLE_ARRAY, 0, MODE_ASCEND);
            
            GannValue* cons;
            if(run_type){
               //PrintArray("GetMaxFromArray", temp);
               cons = GetMaximumConstellate(temp);
               //Alert("Max is "+cons.value);
            }else{
               //PrintArray("GetMinFromArray", temp);
               cons = GetMinimumConstellate(temp);
               //Alert("Min is "+cons.value);
            }
            int size_returnarray = ArraySize(returnarray);
            ArrayResize(returnarray, ++size_returnarray, 0);
            returnarray[size_returnarray-1]=cons;
            //Alert("into add value "+value+" to returnarray["+(size_returnarray-1)+"]");
            ArrayFree(temp);
            //如果篩選出值，下一個值需跳過避免重覆比對
            continue;
         }
         
         //2.再將當下的新的非連續數值存入
         int size_returnarray3 = ArraySize(returnarray);
         ArrayResize(returnarray, ++size_returnarray3, 0);
         returnarray[size_returnarray3-1]=src_array[i];
         //Alert("returnarray["+(size_returnarray3-1)+"]"+" is "+src_array[i]);

      }
   }
   ArrayFree(src_array);
   ArrayCopy(src_array, returnarray, 0, 0, WHOLE_ARRAY);

}

void FullConstellate::ConsArrayToDoubleArray(double &des_array[][], GannValue* &src_array[]){
   int size_src2 = ArraySize(src_array);
   //Alert("size_src2: "+size_src2);
   ArrayResize(des_array, size_src2, 0);
          
   for(int i = 0; i<size_src2;i++){
      des_array[i][0]=src_array[i].value;
      des_array[i][1]=i;
      //Alert("des_array ["+des_array[i][0]+"]["+des_array[i][1]+"]");
   }
}

void FullConstellate::ConstellateArraySort(GannValue* &src_array[], int count,int start_idx, int sort_dir )
{
   double doubleArray[][2];
   int size_src1 = ArraySize(src_array);
   //Alert("size_src1: "+size_src1);
   //PrintArray("BeforeConsArrayToDoubleArray", src_array);
   ConsArrayToDoubleArray(doubleArray, src_array);
   //PrintArray("AfterConsArrayToDoubleArray", doubleArray);
   
   // 做到這裡20161009
   ArraySort(doubleArray, count, start_idx, sort_dir);
   //PrintArray("AfterSortDoubleArray", doubleArray);
   
   int size_src = ArraySize(src_array);
   //Alert("size_src", size_src);
   GannValue* temp[];
   for(int i = 0; i <size_src;i++){
      int size_temp = ArraySize(temp);
      ArrayResize(temp, ++size_temp);
      //Alert("size_temp"+size_temp);
      int idxFromDoubleArray = doubleArray[i][1];
      //Alert("doubleArray["+i+"][1]="+(doubleArray[i][1]));
     
      temp[size_temp-1]=src_array[idxFromDoubleArray];
      //Alert("temp["+(size_temp-1)+"]="+(temp[size_temp-1].value));
   }
   ArrayFree(src_array);
   ArrayCopy(src_array, temp, 0, 0, WHOLE_ARRAY);
   ArrayFree(temp);
}

GannValue* FullConstellate::GetMinimumConstellate(GannValue* &src_array[])
{
   GannValue *minConstellate = NULL;
   
   double doubleArray[][2];
   ConsArrayToDoubleArray( doubleArray, src_array);
   int MinIdx = ArrayMinimum(doubleArray, WHOLE_ARRAY, 0);
   double MinValue = doubleArray[MinIdx][0];
   int SrcIdx = doubleArray[MinIdx][1];
   //Alert("MinValue: "+MinValue+", value is: "+MinValue+", SrcIdx is: "+SrcIdx);
   if(MinIdx>=0){
      minConstellate = src_array[SrcIdx];
   }else{
      minConstellate = NULL;;
   }
   return minConstellate;
}

GannValue* FullConstellate::GetMaximumConstellate(GannValue* &src_array[])
{
   GannValue *maxConstellate = NULL;
   
   double doubleArray[][2];
   ConsArrayToDoubleArray( doubleArray, src_array);
   int MaxIdx = ArrayMaximum(doubleArray, WHOLE_ARRAY, 0);
   double MaxValue = doubleArray[MaxIdx][0];
   int SrcIdx = doubleArray[MaxIdx][1];
   //Alert("MaxIdx: "+MaxIdx+", value is: "+MaxValue+", SrcIdx is: "+SrcIdx);
   if(MaxIdx>=0){
      maxConstellate = src_array[SrcIdx];
   }else{
      maxConstellate = NULL;
   }
   return maxConstellate;
}