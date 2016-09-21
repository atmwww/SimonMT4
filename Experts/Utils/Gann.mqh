//+------------------------------------------------------------------+
//|                                                         Gann.mqh |
//|                                                            Simon |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Simon"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

#include "Cursor.mqh"
#include "MyMath.mqh"
#include "Debug.mqh"

extern int RUN_BOTH = 0; //
extern int RUN_HIGH = 1; //往上求高點
extern int RUN_LOW  = 2; //往下求低點

extern int IS_HIGH = 1; //求同位階時的起始位置
extern int IS_LOW  = 2; //求同位階時的起始位置

extern int DRAW_CW = 0;  //順時針
extern int DRAW_CCW = 1; //逆時針

Cursor cursor;

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class Gann
  {
private:
                    int NowInsertIdx;
                    double OriValues[];
                    void GenerateValues(double &values[], double begin, double step, int size);
                    void InsertValues(double &values[], int size, int draw_type);
                    void InsertValueLeftToRight(double &values[]);
                    void InsertValueBottomToTop(double &values[]);
                    void InsertValueRightToLeft(double &values[]);
                    void InsertValueTopToBottom(double &values[]);
                    bool IsCursorOnCenter();
                    void GetAngleNums(int run_type, double value, double &values[]);
                    void GetCrossNums(int run_type, double value, double &values[]);
                    bool IsAngleNum(double base_num, double compare_num);
                    bool IsCrossNum(double base_num, double compare_num);
                    
public:
                     Gann();
                    ~Gann();
                    void DrawSquare(double begin, double step, int size, int draw_type); //CW 順時針
                    void RunCycle(int run_type, double begin_value, double &cycles[]);
                    double RunAngle(int run_type, double begin_value, double &angles[]);
                    double RunCross(int run_type, double begin_value, double step, double &crosses[]);
                    double RunSameLevel(double begin_value, int begin_value_type, double step);
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
//+------------------------------------------------------------------+
Gann::DrawSquare(double begin, double step, int size, int draw_type)
{
     
   GenerateValues(OriValues, begin, step, size);
   InsertValues(OriValues, size, draw_type); // run clockwise順時針 / counterclockwise逆時針
   
  
}
void Gann::GenerateValues(double &values[], double begin, double step, int size)
{
   int length = MathPow(((1+size)+size),2);// 總數=(size+1)+(size)的平方
   ArrayResize(values, length);
   
   for(int i = 0;i<ArraySize(values);i++){
      if(i==0){
         values[i]=begin;
      }else{
         values[i] = values[i-1]+step;
      }
  
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
   cursor.SetValue(values[NowInsertIdx]);
   
   // 再用迴圈將江恩值由外圍向內圍塞完
   if(draw_type == DRAW_CW){ // 順時針
      
      do{
         InsertValueLeftToRight(values);
         InsertValueBottomToTop(values);
         InsertValueRightToLeft(values);
         InsertValueTopToBottom(values);
      }
      while(IsCursorOnCenter() == FALSE);
   }else{  //逆時針
      do{
         InsertValueRightToLeft(values);
         InsertValueBottomToTop(values);
         InsertValueLeftToRight(values);
         InsertValueTopToBottom(values);
      }
      while(IsCursorOnCenter() == FALSE);
   }
 

   //Debug::PrintArray(cursor);

}

void Gann::InsertValueLeftToRight(double &values[])
{  

 //Alert("InsertValueLeftToRight, Start From InsertIdx: "+NowInsertIdx);
    while(cursor.GetCursorIdx()!=cursor.GetCenterIdx() && cursor.Right())
    {
         if(cursor.HasValue()==FALSE)
         {
            cursor.SetValue(values[--NowInsertIdx]); 
         
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

void Gann::InsertValueBottomToTop(double &values[])
{  
      //Alert("InsertValueBottomToTop, Start From InsertIdx: "+NowInsertIdx);
   
    while(cursor.GetCursorIdx()!=cursor.GetCenterIdx() && cursor.Up())
    {
         if(cursor.HasValue()==FALSE)
         {
             cursor.SetValue(values[--NowInsertIdx]); 
         
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

void Gann::InsertValueRightToLeft(double &values[])
{  
      //Alert("InsertValueRightToLeft, Start From InsertIdx: "+NowInsertIdx);
      while(cursor.GetCursorIdx()!=cursor.GetCenterIdx() && cursor.Left())
       {
            if(cursor.HasValue()==FALSE)
            {
               cursor.SetValue(values[--NowInsertIdx]); 
            
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

void Gann::InsertValueTopToBottom(double &values[])
{  
    //Alert("InsertValueTopToBottom, Start From InsertIdx: "+NowInsertIdx);
       while(cursor.GetCursorIdx()!=cursor.GetCenterIdx() && cursor.Down())
       {
            if(cursor.HasValue()==FALSE){
               cursor.SetValue(values[--NowInsertIdx]); 
            
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

bool Gann::IsCursorOnCenter(void)
{
   return cursor.GetCursorIdx() == cursor.GetCenterIdx();
}
// 開始跑循環
void Gann::RunCycle(int run_type, double begin_value, double &cycles[])
{
   double closestValue = MyMath::FindClosest(OriValues, begin_value);
   
   int found_idx = MyMath::FindIdxByValue(OriValues, closestValue);
   //Debug::PrintArray(OriValues); 
   //Alert("closestValue value: "+closestValue+", found_idx: "+found_idx);
   
   if(run_type == RUN_BOTH){
      ArrayCopy(cycles, OriValues, 0, 0, WHOLE_ARRAY);
   }else{

      
      //取出前半段
      double FirstHalfArray[];
      ArrayCopy(FirstHalfArray, OriValues, 0, found_idx+1, WHOLE_ARRAY);
      double minValueInFtHf = MyMath::GetMinimumValue(FirstHalfArray);
      //Alert("MinValue in FtHf: "+minValueInFtHf);
      //Debug::PrintArray("FirstHalfArray", FirstHalfArray);
      
      //取出後半段
      double SecondHalfAray[];
      double temp[];
      ArrayCopy(temp, OriValues, 0, 0, found_idx);
      MyMath::ReverseArray(temp, SecondHalfAray);
      double minValueInSdHf = MyMath::GetMinimumValue(SecondHalfAray);
      //Alert("MinValue in SdHf: "+minValueInSdHf);
      //Debug::PrintArray(SecondHalfAray);
      
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

void Gann::GetAngleNums(int run_type, double value, double &values[])
{
   double BeginValue = MyMath::FindClosest(OriValues, value);
   
   double Cycle[];
   RunCycle(run_type, BeginValue, Cycle);
   for(int i = 0; i < ArraySize(Cycle); i++){
      double cyclenum = Cycle[i];
      if(IsAngleNum(BeginValue, cyclenum))
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
   double BeginValue = MyMath::FindClosest(OriValues, value);
   
   double Cycle[];
   RunCycle(run_type, BeginValue, Cycle);
   for(int i = 0; i < ArraySize(Cycle); i++){
      double cyclenum = Cycle[i];
      if(IsCrossNum(BeginValue, cyclenum))
      {
         //Alert(cyclenum+" is "+BeginValue+"'s Cross Num.");
         int size = ArraySize(values);
         ArrayResize(values, ++size, 0);
         int idx = size - 1;
         values[idx]=cyclenum;
      }
   }
}                

bool Gann::IsAngleNum(double base_num, double compare_num)
{
   bool isAngleNum = false;
   
   if(base_num != compare_num){
      int BasePosition[2];
      cursor.GetPositionByValue(base_num, BasePosition);
      int basepositionX = BasePosition[0];
      int basepositionY = BasePosition[1];
      //Debug::PrintPosition(cursor, BasePosition);
      
      int ComparePosition[2];
      cursor.GetPositionByValue(compare_num, ComparePosition);
      int comparepositionX = ComparePosition[0];
      int comparepositionY = ComparePosition[1];
      
      int diffX = comparepositionX - basepositionX;
      int diffY = comparepositionY - basepositionY;
      
      if(diffX + diffY == 0 | diffX - diffY ==0)
      {
         isAngleNum = true;
      }   
   }

   return isAngleNum;
}

bool Gann::IsCrossNum(double base_num, double compare_num)
{
   bool isCrossNum = false;
   
   if(base_num != compare_num){
      int BasePosition[2];
      cursor.GetPositionByValue(base_num, BasePosition);
      int basepositionX = BasePosition[0];
      int basepositionY = BasePosition[1];
      //Debug::PrintPosition(cursor, BasePosition);
      
      int ComparePosition[2];
      cursor.GetPositionByValue(compare_num, ComparePosition);
      int comparepositionX = ComparePosition[0];
      int comparepositionY = ComparePosition[1];
      
      if(basepositionX == comparepositionX | basepositionY == comparepositionY)
      {
         isCrossNum = true;
      }   
   }

   return isCrossNum;
}
                    
double Gann::RunAngle(int run_type, double begin_value, double &angles[])
{
   double returnValue = EMPTY_VALUE;
   
   // 1.在整份圖表上，找出相近值當臨活基數
   double closestValue = MyMath::FindClosest(OriValues, begin_value);
   //Alert("closestValue is: "+closestValue);
   
   // 2.取出所有角線上的目標值
   double Angles[];
   GetAngleNums(run_type, closestValue, Angles); 
   //Debug::PrintArray(Angles);

   ArrayCopy(angles, Angles, 0, 0, WHOLE_ARRAY);
   
   if(ArraySize(Angles)>0){
      returnValue = Angles[0];
   }
   return returnValue;
}

double Gann::RunCross(int run_type, double begin_value, double step, double &crosses[]){
   double returnValue = EMPTY_VALUE;
   
   // 1.在整份圖表上，找出相近值當臨活基數
   double closestValue = MyMath::FindClosest(OriValues, begin_value);
   //Alert("closestValue is: "+closestValue);
   
   // 2.取出所有十字線上的目標值
   double Crosses[];
   GetCrossNums(run_type, closestValue, Crosses); 
   //Debug::PrintArray(Crosses);

   // 3.刪除連續數，連續數不能為十字線的目標值
   MyMath::DeleteConsecutiveNums(Crosses, begin_value, step);
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
      sameLevel = cross_1;
   }
   return sameLevel;
}