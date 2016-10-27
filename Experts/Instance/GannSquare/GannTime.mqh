//+------------------------------------------------------------------+
//|                                                     GannTime.mqh |
//|                                                            Simon |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Simon"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
#property description "江恩時間跑圖法"

#include "FullConstellate.mqh"

class EvMonth{
   public:
   string name;
   int days;
   int preMonthsDaysCount;
};

EvMonth* months[12];
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class GannTime : public FullConstellate
  {
private:
                    string year;
                    void initEvMonths();
public:
                     GannTime();
                    ~GannTime();
                    
                    void SetDatas(double begin_value);
                    datetime ConvertGannValueToDatetime(GannValue* gannValue);
                    datetime ConvertValueToDatetime(double Value);
                    GannValue* ConvertDatetimeToGannValue(datetime time);
               
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
GannTime::GannTime()
  {
     year = "2016";
     initEvMonths();
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
GannTime::~GannTime()
  {
  }
//+------------------------------------------------------------------+
void GannTime::initEvMonths(void){
   EvMonth* evMonth_01 = new EvMonth();
   evMonth_01.name="01";
   evMonth_01.days=31;
   evMonth_01.preMonthsDaysCount=0;
   months[0]=evMonth_01;
   
   EvMonth* evMonth_02 = new EvMonth();
   evMonth_02.name="02";
   evMonth_02.days=28;
   evMonth_02.preMonthsDaysCount=31;
   months[1]=evMonth_02;
   
   EvMonth* evMonth_03 = new EvMonth();
   evMonth_03.name="03";
   evMonth_03.days=31;
   evMonth_03.preMonthsDaysCount=59;
   months[2]=evMonth_03;
   
   EvMonth* evMonth_04 = new EvMonth();
   evMonth_04.name="04";
   evMonth_04.days=30;
   evMonth_04.preMonthsDaysCount=90;
   months[3]=evMonth_04;
   
   EvMonth* evMonth_05 = new EvMonth();
   evMonth_05.name="05";
   evMonth_05.days=31;
   evMonth_05.preMonthsDaysCount=120;
   months[4]=evMonth_05;
   
   EvMonth* evMonth_06 = new EvMonth();
   evMonth_06.name="06";
   evMonth_06.days=30;
   evMonth_06.preMonthsDaysCount=151;
   months[5]=evMonth_06;
   
   EvMonth* evMonth_07 = new EvMonth();
   evMonth_07.name="07";
   evMonth_07.days=31;
   evMonth_07.preMonthsDaysCount=181;
   months[6]=evMonth_07;   
   
   EvMonth* evMonth_08 = new EvMonth();
   evMonth_08.name="08";
   evMonth_08.days=31;
   evMonth_08.preMonthsDaysCount=212;
   months[7]=evMonth_08;  
   
   EvMonth* evMonth_09 = new EvMonth();
   evMonth_09.name="09";
   evMonth_09.days=30;
   evMonth_09.preMonthsDaysCount=243;
   months[8]=evMonth_09;      
   
   EvMonth* evMonth_10 = new EvMonth();
   evMonth_10.name="10";
   evMonth_10.days=31;
   evMonth_10.preMonthsDaysCount=273;
   months[9]=evMonth_10;    
   
   EvMonth* evMonth_11 = new EvMonth();
   evMonth_11.name="11";
   evMonth_11.days=30;
   evMonth_11.preMonthsDaysCount=304;
   months[10]=evMonth_11;
   
   EvMonth* evMonth_12 = new EvMonth();
   evMonth_12.name="12";
   evMonth_12.days=31;
   evMonth_12.preMonthsDaysCount=334;
   months[11]=evMonth_12;          
}

void GannTime::SetDatas(double begin_value){
   FullConstellate::SetDatas(RUN_HIGH,begin_value,1,4,true);
}

GannValue* GannTime::ConvertDatetimeToGannValue(datetime time){
   return NULL;
}

datetime GannTime::ConvertGannValueToDatetime(GannValue *gannValue){
   return ConvertValueToDatetime(gannValue.value);
}

datetime GannTime::ConvertValueToDatetime(double Value){
   string monthS;
   string dayS;
   
   if(Value>365){
      Alert("傳入值: "+Value+" 不可大於365");
      return NULL;
   }
   int size_month = ArraySize(months);
   for(int i = 0; i < size_month; i ++){
      if(Value>months[size_month-1].preMonthsDaysCount){
         monthS = months[size_month-1].name;
         dayS = Value-months[size_month-1].preMonthsDaysCount;
         break;
      }else if(Value<months[0].preMonthsDaysCount){
         monthS = months[0].name;
         dayS = Value;
         break;
      }
      else{
         if(Value>months[i].preMonthsDaysCount & Value<=months[i+1].preMonthsDaysCount){
            monthS = months[i].name;
            int day = Value-months[i].preMonthsDaysCount;
            dayS = IntegerToString(day, 2, "");
            break;
         }
      }
      
   }
   Alert("Value: "+Value+" => month: "+monthS+", dayS: "+dayS);
   return NULL;
}
