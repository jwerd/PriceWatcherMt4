//+------------------------------------------------------------------+
//|                                                 PriceWatcher.mq4 |
//|                                             Copyright 2016, Jake |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2016, Jake"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
#property indicator_chart_window

extern int AlertMicroPipRange=10;

input int      obj_type = 1; // horizontal line by default
double current_obj_count = 0;
string current_objects[];
string current_object = "none";
double current_price_line;
double current_price;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
{
//--- indicator buffers mapping
   current_obj_count = get_object_count();
//---
   return(INIT_SUCCEEDED);
}

int start()
{
   current_price = iClose(NULL, 0, 0);
   
   if(get_object_count() != current_obj_count) {
      Print("Current object count: ",get_object_count());
      Print("New Price line added.");
      current_obj_count = get_object_count();
      set_last_object();
      ignore_all_but_last_object(current_object);
      Print("Last object", (string)current_object);
   }
   
   if((string)current_object != "none") {
      double above = current_price+AlertMicroPipRange*Point;
      double below = current_price-AlertMicroPipRange*Point;
      
      current_price_line = get_current_price_line(current_object);
      //Print("current price line: "+current_price_line);
      //Print("current price: "+current_price);
      //Print("above: "+above);
      //Print("below: "+below);
      //Print("Last object", (string)current_object);
      if (below <= current_price_line && above >= current_price_line && StringSubstr(current_object, 0, 8) != "_ignore_") {
         Alert("PRICE WITHIN RANGE OF LINE on ",Symbol()," TimeFrame: ",Period(), " at ",TimeToStr(TimeCurrent(),TIME_SECONDS));
         Print("PRICE WITHIN RANGE OF LINE on ",Symbol()," TimeFrame: ",Period(), " at ",TimeToStr(TimeCurrent(),TIME_SECONDS));
         ignore_object(current_object);
      }
   }
   return(0);
}

double get_current_price_line(string object)
{
   return ObjectGet(object, OBJPROP_PRICE1);
}

void set_last_object()
{
   int obj_total=ObjectsTotal();
   
   string name;
   for(int i=0;i<obj_total;i++) {
      name = ObjectName(i);
      if(ObjectType(name) == obj_type && StringSubstr(name, 0, 8) != "_ignore_") {
         current_object = name;
      }
   }
}

bool ignore_object(string object)
{
   // make sure we are getting the right type
   if(ObjectType(object) == obj_type) {
      ObjectSetString(0,object,OBJPROP_NAME,"_ignore_"+(string)MathRand());
      return true;
   }
   
   return false;
}


void ignore_all_but_last_object(string last)
{
   int obj_total=ObjectsTotal();
   
   string name;
   for(int i=0;i<obj_total;i++) {
      name = ObjectName(i);
      if(ObjectType(name) == obj_type) {
         if(last != name && StringSubstr(name, 0, 8) != "_ignore_") {
            Print("DEBUG: Now ignoring previously set line: ",name);
            ObjectSetString(0,name,OBJPROP_NAME,"_ignore_"+(string)MathRand());
         }
      }
   }
}

int get_object_count()
{
   int count = 0;
   int obj_total = ObjectsTotal();
   string name;
   
   for(int i=0;i<obj_total;i++) {
      name = ObjectName(i);
      if(ObjectType(name) == obj_type) {
         count++;
      }
   }
   return count;
}