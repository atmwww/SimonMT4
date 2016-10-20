//+------------------------------------------------------------------+
//|                                                         Gann.mqh |
//|                                                            Simon |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Simon"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

#include "../../Utils/Cursor.mqh"
#include "../../Utils/MyMath.mqh"
#include "../../Utils/Debug.mqh"
#include "../GannValue.mqh"
#include "../CursorValue.mqh"
#include "../../Utils/MyAngle.mqh"

int RUN_BOTH = 0; // 上下都跑
int RUN_HIGH = 1; //往上求高點
int RUN_LOW  = 2; //往下求低點

int IS_HIGH = 1; //求同位階時的起始位置
int IS_LOW  = 2; //求同位階時的起始位置

int DRAW_CW = 0;  //順時針
int DRAW_CCW = 1; //逆時針


Cursor cursor;


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class Gann
  {
private:
                    int NowInsertIdx;
                    double OriValues[];
                    void GenerateValues(double &values[], double begin, double step, int circle_size);
                    void InsertValues(double &values[], int circle_size, int draw_type);
                    void InsertValueLeftToRight(int circlenum,double &values[]);
                    void InsertValueBottomToTop(int circlenum,double &values[]);
                    void InsertValueRightToLeft(int circlenum,double &values[]);
                    void InsertValueTopToBottom(int circlenum,double &values[]);
                    bool IsCursorOnCenter();
                    bool IsAngleNum(double compare_num , double base_num );
                    bool IsCrossNum(double compare_num , double base_num );
                    void DeleteConsecutiveNums(double &src_array[], double begin_value, double step);
                    
protected:
                    void GetAngleNums(int run_type, double value, double &values[]);
                    void GetCrossNums(int run_type, double value, double &values[]);
                   
public:
                     Gann();
                    ~Gann();
                    int GetRecommandSize(double base, double begin, double step, int add_cycle);
                    void DrawSquare(double begin, double step, int size, int draw_type); //CW 順時針
                    void RunCycle(int run_type, double begin_value, double &cycles[]);
                    double RunAngle(int run_type, double begin_value, double &angles[]);
                    double RunCross(int run_type, double begin_value, double step, double &crosses[]);
                    double RunSameLevel(double begin_value, int begin_value_type, double step);
                    double GetCircleNumByValue(double value);
                    virtual void Run(GannValue* &values[]);
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
Gann::Gann()
  {
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
Gann::~Gann()
  {
  }
int Gann::GetRecommandSize(double base, double begin, double step, int add_cycle)
{
   int RecommandSize = NULL;
   double temp[];
   //int loop = 1.7 * MathPow(10,308);
   int loop = 200;
   // 暫用200次的循環找出建議繪製的江恩圈數
   for(int i = 1; i <loop; i++){
      GenerateValues(temp, base, step, i);
      //Alert("目前圈數: "+i+", size temp: "+ArraySize(temp));
      int findIdx = MyMath::FindIdxByValue(temp, begin);
      ArrayFree(temp);
      if(findIdx!=-1){
        
         RecommandSize = i + add_cycle;
         //Alert("矩陣圖建議圈數為"+RecommandSize+" 圈");
         break;
      }
    
   }
   if(RecommandSize == NULL){
        Alert("找不到建議圈數");
   }
   return RecommandSize;
   
}
//+------------------------------------------------------------------+
//begin 基數值
//step  每個目標價間的間隔
Gann::DrawSquare(double begin, double step, int size, int draw_type)
{
   ArrayFree(OriValues);
   GenerateValues(OriValues, begin, step, size);
   //Debug::PrintArray("OriValues", OriValues);
   InsertValues(OriValues, size, draw_type); // run clockwise順時針 / counterclockwise逆時針
   
  
}

void Gann::GenerateValues(double &values[], double begin, double step, int size)
{
   
   int length = MathPow(((1+size)+size),2);// 總數=(size+1)+(size)的平方
   ArrayResize(values, length);
   //Alert("size: "+size+", GenerateValues length: "+length);
   //Alert("step: "+step);
   
   int DecimalBits = MyMath::GetDecimalBits(step);
   //Alert("DecimalBits: "+DecimalBits);
   
   for(int i = 0;i<ArraySize(values);i++){
      double value = EMPTY_VALUE;
      if(i==0){
         value = begin;
      }else{
         
         double tmpValue = values[i-1]+step;
         value = NormalizeDouble(tmpValue, DecimalBits);
         //Alert("value["+i+"]: "+DoubleToStr(value, DecimalBits));
         
      }
      values[i] = value;
   }
}

void Gann::InsertValues(double &values[], int size, int draw_type)
{
   // 開出一個空白江恩矩形的矩陣
   cursor.InitSquareArray(size);
 
 //=========開始將產生出來的值塞入江恩矩陣================
   int position[2];
   // 先將指標移至最後一筆
   int last = cursor.GetLastIdxOnChart(draw_type==DRAW_CW);
   cursor.SetCursorTo(last);
   NowInsertIdx = ArraySize(values)-1;
   int NowCircleNum = size +1; //現正繪製的江恩圈數
   cursor.SetValue(NowCircleNum, values[NowInsertIdx]);

   // 再用迴圈將江恩值由外圍向內圍塞完
   if(draw_type == DRAW_CW){ // 順時針
      
      do{
         
         InsertValueLeftToRight(NowCircleNum, values);
         InsertValueBottomToTop(NowCircleNum, values);
         InsertValueRightToLeft(NowCircleNum, values);
         InsertValueTopToBottom(NowCircleNum, values);
         
         NowCircleNum--;
      }
      while(IsCursorOnCenter() == FALSE);
   }else{  //逆時針
      do{
         
         InsertValueRightToLeft(NowCircleNum, values);
         InsertValueBottomToTop(NowCircleNum, values);
         InsertValueLeftToRight(NowCircleNum, values);
         InsertValueTopToBottom(NowCircleNum, values);
         
         NowCircleNum--;
      }
      while(IsCursorOnCenter() == FALSE);
   }
 
   //Debug::PrintArray("cursor", cursor);

}

void Gann::InsertValueLeftToRight(int circlenum, double &values[])
{  

 //Alert("InsertValueLeftToRight, Start From InsertIdx: "+NowInsertIdx);
    while(cursor.GetCursorIdx()!=cursor.GetCenterIdx() && cursor.Right())
    {
         if(cursor.HasValue()==FALSE)
         {
            cursor.SetValue(circlenum, values[--NowInsertIdx]); 
         
            int positions[2];
            cursor.GetCursorPosition(positions);
            //Alert("NowCursorIdx: ["+positions[0]+","+positions[1]+"], value: "+cursor.GetValueByIdx(cursor.GetCursorIdx()));
         }else{
            if(IsCursorOnCenter() == FALSE){
               cursor.Left();//因為已填值，因此將指針移回前一位置
            }
            break;
            
         }
         
    }
}

void Gann::InsertValueBottomToTop(int circlenum,double &values[])
{  
      //Alert("InsertValueBottomToTop, Start From InsertIdx: "+NowInsertIdx);
   
    while(cursor.GetCursorIdx()!=cursor.GetCenterIdx() && cursor.Up())
    {
         if(cursor.HasValue()==FALSE)
         {
             cursor.SetValue(circlenum, values[--NowInsertIdx]); 
         
             int positions[2];
             cursor.GetCursorPosition(positions);
             //Alert("NowCursorIdx: ["+positions[0]+","+positions[1]+"], value: "+cursor.GetValueByIdx(cursor.GetCursorIdx()));
         }else{
               if(IsCursorOnCenter() == FALSE){
                  cursor.Down();//因為已填值，因此將指針移回前一位置
               }
               break;
         }
    }
}

void Gann::InsertValueRightToLeft(int circlenum,double &values[])
{  
      //Alert("InsertValueRightToLeft, Start From InsertIdx: "+NowInsertIdx);
      while(cursor.GetCursorIdx()!=cursor.GetCenterIdx() && cursor.Left())
       {
            if(cursor.HasValue()==FALSE)
            {
               cursor.SetValue(circlenum, values[--NowInsertIdx]); 
            
               int positions[2];
               cursor.GetCursorPosition(positions);
               //Alert("NowCursorIdx: ["+positions[0]+","+positions[1]+"], value: "+cursor.GetValueByIdx(cursor.GetCursorIdx()));     
            }else{
               if(IsCursorOnCenter() == FALSE){
                  cursor.Right();//因為已填值，因此將指針移回前一位置
               }
               break;
            }
            
       }
}

void Gann::InsertValueTopToBottom(int circlenum,double &values[])
{  
    //Alert("InsertValueTopToBottom, Start From InsertIdx: "+NowInsertIdx);
       while(cursor.GetCursorIdx()!=cursor.GetCenterIdx() && cursor.Down())
       {
            if(cursor.HasValue()==FALSE){
               cursor.SetValue(circlenum, values[--NowInsertIdx]); 
            
               int positions[2];
               cursor.GetCursorPosition(positions);
               //Alert("NowCursorIdx: ["+positions[0]+","+positions[1]+"], value: "+cursor.GetValueByIdx(cursor.GetCursorIdx()));  
            }else{
               if(IsCursorOnCenter() == FALSE){
                  cursor.Up();//因為已填值，因此將指針移回前一位置
               }
               break;
            }
         
       }
}

void Gann::DeleteConsecutiveNums(double &src_array[], double begin_value, double step)
{
   // 1.將啟始值帶進來，目的預防漏算第1筆目標值是否為連續值
   double compute_array[];
   int src_size = ArraySize(src_array);
   ArrayResize(compute_array, ++src_size, 0);
   compute_array[0]=begin_value;
   for(int i = 0 ; i<ArraySize(src_array);i++){
      compute_array[i+1] = src_array[i];
   }
   
   // 2.將不是連續數的值存進暫存temp array
   double temp[];
   int compute_array_size = ArraySize(compute_array);
   for(int j = 1; j < compute_array_size; j++){
      //Alert("j is: "+j +", diff is: "+MathAbs(compute_array[j]-compute_array[j-1]));
      if(MathAbs(compute_array[j]-compute_array[j-1]) != MathAbs(step)){
         //Alert("j is: "+j);
         int tmp_size = ArraySize(temp);
         ArrayResize(temp, ++tmp_size);
         temp[tmp_size-1]=compute_array[j];
         //Alert("add: "+temp[tmp_size-1]);
      }
   }
   
   // 3.將temp array存回src_array
   ArrayResize(src_array, ArraySize(temp), 0);
   ArrayCopy(src_array, temp, 0, 0, WHOLE_ARRAY);
}


double Gann::GetCircleNumByValue(double value){
   return cursor.GetCircleNumByValue(value);
}

bool Gann::IsCursorOnCenter(void)
{
   return cursor.GetCursorIdx() == cursor.GetCenterIdx();
}
// 開始跑循環
void Gann::RunCycle(int run_type, double begin_value, double &cycles[])
{
   //Alert("RunCycle");
   double closestValue = MyMath::FindClosest(OriValues, begin_value);
   
   int found_idx = MyMath::FindIdxByValue(OriValues, closestValue);
   //Debug::PrintArray("OriValues", OriValues); 
   //Alert("closestValue value: "+closestValue+", found_idx: "+found_idx);
   
   if(run_type == RUN_BOTH){
      ArrayCopy(cycles, OriValues, 0, 0, WHOLE_ARRAY);
   }else{

      
      //取出前半段
      double FirstHalfArray[];
      ArrayCopy(FirstHalfArray, OriValues, 0, found_idx+1, WHOLE_ARRAY);
      //Debug::PrintArray(begin_value+" ,FirstHalfArray", FirstHalfArray);
      double minValueInFtHf = MyMath::GetMinimumValue(FirstHalfArray);
      //Alert("MinValue in FtHf: "+minValueInFtHf);
      
      
      //取出後半段
      double SecondHalfAray[];
      double temp[];
      ArrayCopy(temp, OriValues, 0, 0, found_idx);
      MyMath::ReverseArray(temp, SecondHalfAray);
      //Debug::PrintArray(begin_value+" ,SecondHalfAray", SecondHalfAray);
      double minValueInSdHf = MyMath::GetMinimumValue(SecondHalfAray);
      //Alert("MinValue in SdHf: "+minValueInSdHf);
      
      if(minValueInFtHf != EMPTY_VALUE & minValueInSdHf != EMPTY_VALUE){
         //分辨高、低循環
         double LowArray[];
         double HighArray[];   
         if(minValueInFtHf<closestValue){
            ArrayCopy(LowArray, FirstHalfArray, 0, 0, WHOLE_ARRAY);
            ArrayCopy(HighArray, SecondHalfAray, 0, 0, WHOLE_ARRAY);
         }else{
            ArrayCopy(HighArray, FirstHalfArray, 0, 0, WHOLE_ARRAY);
            ArrayCopy(LowArray, SecondHalfAray, 0, 0, WHOLE_ARRAY);
         }
         
         if(run_type == RUN_HIGH){
             ArrayCopy(cycles, HighArray, 0, 0, WHOLE_ARRAY);
         }else if(run_type == RUN_LOW){
             ArrayCopy(cycles, LowArray, 0, 0, WHOLE_ARRAY);
         } 
      } 
   }

}

void Gann::GetAngleNums(int run_type, double value, double &values[])
{
   double BeginValue = MyMath::FindClosest(OriValues, value);
   
   double Cycle[];
   RunCycle(run_type, BeginValue, Cycle);
   for(int i = 0; i < ArraySize(Cycle); i++){
      double cyclenum = Cycle[i];
      if(IsAngleNum(cyclenum, BeginValue))
      {
         //Alert(cyclenum+" is "+BeginValue+"'s Angle Num.");
         int size = ArraySize(values);
         ArrayResize(values, ++size, 0);
         int idx = size - 1;
         values[idx]=cyclenum;
      }
   }
}

void Gann::GetCrossNums(int run_type, double value, double &values[])
{
   //Alert("GetCrossNum");
   double BeginValue = MyMath::FindClosest(OriValues, value);
   
   double Cycle[];
   RunCycle(run_type, BeginValue, Cycle);
   //Alert("size cycle: "+ArraySize(Cycle));
   for(int i = 0; i < ArraySize(Cycle); i++){
      //Alert("into for: "+i);
      double cyclenum = Cycle[i];
      if(IsCrossNum(cyclenum, BeginValue))
      {
         //Alert(cyclenum+" is "+BeginValue+"'s Cross Num.");
         int size = ArraySize(values);
         ArrayResize(values, ++size, 0);
         int idx = size - 1;
         values[idx]=cyclenum;
      }
   }
}                

bool Gann::IsAngleNum(double compare_num , double base_num )
{
   bool IsAngle = FALSE;
   
   if(base_num != compare_num){
      int BasePosition[2];
      cursor.GetPositionByValue(base_num, BasePosition);
      
      int ComparePosition[2];
      cursor.GetPositionByValue(compare_num, ComparePosition);
      
      IsAngle = MyAngle::IsAngleNum(ComparePosition,BasePosition);
   }

   return IsAngle;
}

bool Gann::IsCrossNum(double compare_num , double base_num )
{
   bool IsCross = FALSE;
   
   if(base_num != compare_num){
      int BasePosition[2];
      cursor.GetPositionByValue(base_num, BasePosition);
      //int basepositionX = BasePosition[0];
      //int basepositionY = BasePosition[1];
      //Debug::PrintPosition(cursor, BasePosition);
      
      int ComparePosition[2];
      cursor.GetPositionByValue(compare_num, ComparePosition);
      //int comparepositionX = ComparePosition[0];
      //int comparepositionY = ComparePosition[1];
      
      //if(basepositionX == comparepositionX | basepositionY == comparepositionY)
      //{
      //   isCrossNum = true;
     // }   
      IsCross = MyAngle::IsCrossNum(ComparePosition,BasePosition);
   }

   return IsCross;
  
}
                    
double Gann::RunAngle(int run_type, double begin_value, double &angles[])
{
   double returnValue = EMPTY_VALUE;
   //Debug::PrintArray("RunAngle => "+begin_value+": ", OriValues);
   // 1.在整份圖表上，找出相近值當臨活基數
   double closestValue = MyMath::FindClosest(OriValues, begin_value);
   //Alert("closestValue is: "+closestValue);
   
   // 2.取出所有角線上的目標值
   double Angles[];
   GetAngleNums(run_type, closestValue, Angles); 
   ArrayCopy(angles, Angles, 0, 0, WHOLE_ARRAY);
   //Debug::PrintArray("Angles", Angles);
      
   if(ArraySize(Angles)>0){
      returnValue = Angles[0];
   }
   ArrayFree(Angles);
   return returnValue;
}

double Gann::RunCross(int run_type, double begin_value, double step, double &crosses[]){
   //Alert("RunCross");
   double returnValue = EMPTY_VALUE;
   
   // 1.在整份圖表上，找出相近值當臨活基數
   double closestValue = MyMath::FindClosest(OriValues, begin_value);
   //Alert("closestValue is: "+closestValue);
   
   // 2.取出所有十字線上的目標值
   double Crosses[];
   GetCrossNums(run_type, closestValue, Crosses); 
   //Debug::PrintArray(Crosses);

   // 3.刪除連續數，連續數不能為十字線的目標值
   DeleteConsecutiveNums(Crosses, begin_value, step);
   //Debug::PrintArray("Crosses", Crosses);
      
   ArrayCopy(crosses, Crosses, 0, 0, WHOLE_ARRAY);
   
   if(ArraySize(Crosses)>0){
      returnValue = Crosses[0];
   }
   return returnValue;
}

double Gann::RunSameLevel(double begin_value, int begin_value_type, double step){
   double sameLevel = EMPTY_VALUE;
   
   int first_run_type = RUN_HIGH;
   if(begin_value_type==IS_HIGH){
      first_run_type = RUN_LOW; //如果起始值是在高點，就先run低點
   }
   int second_run_type = begin_value_type;
   
   double Arrays[];
   // 1.先算起始值的角角十
   double angel_1_1 = RunAngle(first_run_type, begin_value, Arrays);
   //Alert(begin_value+"'s angle is: "+angel_1_1);
   double angel_1_2 = RunAngle(first_run_type, angel_1_1, Arrays);
   //Alert(angel_1_1+"'s angle is: "+angel_1_2);
   double cross_1 = RunCross(second_run_type, angel_1_2, step, Arrays);
   //Alert(angel_1_2+"'s cross is: "+cross_1);
   
   // 2.再算起始值的十角角
   double cross_2 = RunCross(first_run_type, begin_value, step, Arrays);
   //Alert(begin_value+"'s cross is: "+cross_2);
   double angel_2_1 = RunAngle(second_run_type, cross_2, Arrays);
   //Alert(cross_2+"'s angle is: "+angel_2_1);
   double angel_2_2 = RunAngle(second_run_type, angel_2_1, Arrays);
   //Alert(angel_2_1+"'s angle is: "+angel_2_2);
   
   if(cross_1 == angel_2_2){
      if(begin_value!=cross_1){
          sameLevel = cross_1;
      }
     
   }
   
   int DecimalBits = MyMath::GetDecimalBits(step);
   //Alert(DoubleToStr(begin_value, DecimalBits)+" 's Same Level: "+"["+DoubleToStr(cross_1, DecimalBits)+"],["+DoubleToStr(angel_2_2, DecimalBits)+"] => "+DoubleToStr(sameLevel,DecimalBits));
   return sameLevel;
}
