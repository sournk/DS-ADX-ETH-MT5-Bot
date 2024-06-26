//+------------------------------------------------------------------+
//|                                                  DKChartDraw.mqh |
//|                                                  Denis Kislitsyn |
//|                                             https://kislitsyn.me |
//+------------------------------------------------------------------+
#property copyright "Denis Kislitsyn"
#property link      "https://kislitsyn.me"

class CColorRotator {
  int             Index;
public:
  color           Colors[];

  void            CColorRotator::CColorRotator() { 
    ArrayResize(Colors, 9);
    Colors[0] = clrLavender;
    Colors[1] = clrMistyRose; 
    Colors[2] = clrHoneydew;
    Colors[3] = clrOldLace;
    Colors[4] = clrWhiteSmoke;
    Colors[5] = clrSeashell;
    Colors[6] = clrIvory;
    Colors[7] = clrAliceBlue;
    Colors[8] = clrLightSkyBlue;
    
    Index = 0;
  }
  
  void            CColorRotator::Reset() { Index = 0; };
  color           CColorRotator::Next()  { 
    int res_idx = Index;
    Index = (Index < ArraySize(Colors) - 1) ? Index + 1 : 0;
    return Colors[res_idx];
  };
};

//+------------------------------------------------------------------+ 
//| Функция получает номер первого видимого бара на графике.         | 
//| Индексация как в таймсерии, последние бары имеют меньшие индексы.| 
//+------------------------------------------------------------------+ 
int ChartFirstVisibleBar(const long chart_ID=0) { 
//--- подготовим переменную для получения значения свойства 
   long result=-1; 
//--- сбросим значение ошибки 
   ResetLastError(); 
//--- получим значение свойства 
   if(!ChartGetInteger(chart_ID,CHART_FIRST_VISIBLE_BAR,0,result)) 
     { 
      //--- выведем сообщение об ошибке в журнал "Эксперты" 
      Print(__FUNCTION__+", Error Code = ",GetLastError()); 
     } 
//--- вернем значение свойства графика 
   return((int)result); 
}

//+------------------------------------------------------------------+
//| Create a trend line by the given coordinates                     |
//+------------------------------------------------------------------+
bool TrendLineCreate(const long            chart_ID = 0,      // chart's ID
                     const string          name = "TrendLine", // line name
                     const string          descr = "TrendLine", // line name
                     const int             sub_window = 0,    // subwindow index
                     datetime              time1 = 0,         // first point time
                     double                price1 = 0,        // first point price
                     datetime              time2 = 0,         // second point time
                     double                price2 = 0,        // second point price
                     const color           clr = clrRed,      // line color
                     const ENUM_LINE_STYLE style = STYLE_SOLID, // line style
                     const int             width = 1,         // line width
                     const bool            back = false,      // in the background
                     const bool            selection = true,  // highlight to move
                     const bool            ray_left = false,  // line's continuation to the left
                     const bool            ray_right = false, // line's continuation to the right
                     const bool            hidden = true,     // hidden in the object list
                     const long            z_order = 0) {     // priority for mouse click
//--- reset the error value
  ResetLastError();
//--- create a trend line by the given coordinates
  if(!ObjectCreate(chart_ID, name, OBJ_TREND, sub_window, time1, price1, time2, price2)) {
    Print(__FUNCTION__,
          ": failed to create a trend line! Error code = ", GetLastError());
    return(false);
  }
//--- set line color
  ObjectSetInteger(chart_ID, name, OBJPROP_COLOR, clr);
//--- set line display style
  ObjectSetInteger(chart_ID, name, OBJPROP_STYLE, style);
//--- set line width
  ObjectSetInteger(chart_ID, name, OBJPROP_WIDTH, width);
//--- display in the foreground (false) or background (true)
  ObjectSetInteger(chart_ID, name, OBJPROP_BACK, back);
//--- enable (true) or disable (false) the mode of moving the line by mouse
//--- when creating a graphical object using ObjectCreate function, the object cannot be
//--- highlighted and moved by default. Inside this method, selection parameter
//--- is true by default making it possible to highlight and move the object
  ObjectSetInteger(chart_ID, name, OBJPROP_SELECTABLE, selection);
  ObjectSetInteger(chart_ID, name, OBJPROP_SELECTED, selection);
//--- enable (true) or disable (false) the mode of continuation of the line's display to the left
  ObjectSetInteger(chart_ID, name, OBJPROP_RAY_LEFT, ray_left);
//--- enable (true) or disable (false) the mode of continuation of the line's display to the right
  ObjectSetInteger(chart_ID, name, OBJPROP_RAY_RIGHT, ray_right);
//--- hide (true) or display (false) graphical object name in the object list
  ObjectSetInteger(chart_ID, name, OBJPROP_HIDDEN, hidden);
//--- set the priority for receiving the event of a mouse click in the chart
  ObjectSetInteger(chart_ID, name, OBJPROP_ZORDER, z_order);
//--- successful execution
  ObjectSetString(chart_ID, name, OBJPROP_TEXT, descr);
  ObjectSetString(chart_ID, name, OBJPROP_TOOLTIP, name + "\n" + descr);
  return(true);
}

//+------------------------------------------------------------------+
//| Create a rectangle by the given coordinates                      |
//+------------------------------------------------------------------+
bool RectangleCreate(const long            chart_ID=0,        // ID графика
                     const string          name="Rectangle",  // имя прямоугольника
                     const string          descr="Rectangle", // описание прямоугольника
                     const int             sub_window=0,      // номер подокна 
                     datetime              time1=0,           // время первой точки
                     double                price1=0,          // цена первой точки
                     datetime              time2=0,           // время второй точки
                     double                price2=0,          // цена второй точки
                     const color           clr=clrRed,        // цвет прямоугольника
                     const ENUM_LINE_STYLE style=STYLE_SOLID, // стиль линий прямоугольника
                     const int             width=1,           // толщина линий прямоугольника
                     const bool            fill=false,        // заливка прямоугольника цветом
                     const bool            back=false,        // на заднем плане
                     const bool            selection=true,    // выделить для перемещений
                     const bool            hidden=true,       // скрыт в списке объектов
                     const long            z_order=0)         // приоритет на нажатие мышью
  {
//--- сбросим значение ошибки
   ResetLastError();
//--- создадим прямоугольник по заданным координатам
   if(!ObjectCreate(chart_ID,name,OBJ_RECTANGLE,sub_window,time1,price1,time2,price2))
     {
      Print(__FUNCTION__,
            ": не удалось создать прямоугольник! Код ошибки = ",GetLastError());
      return(false);
     }
//--- установим цвет прямоугольника
   ObjectSetInteger(chart_ID,name,OBJPROP_COLOR,clr);
//--- установим стиль линий прямоугольника
   ObjectSetInteger(chart_ID,name,OBJPROP_STYLE,style);
//--- установим толщину линий прямоугольника
   ObjectSetInteger(chart_ID,name,OBJPROP_WIDTH,width);
//--- включим (true) или отключим (false) режим заливки прямоугольника
   ObjectSetInteger(chart_ID,name,OBJPROP_FILL,fill);
//--- отобразим на переднем (false) или заднем (true) плане
   ObjectSetInteger(chart_ID,name,OBJPROP_BACK,back);
//--- включим (true) или отключим (false) режим выделения прямоугольника для перемещений
//--- при создании графического объекта функцией ObjectCreate, по умолчанию объект
//--- нельзя выделить и перемещать. Внутри же этого метода параметр selection
//--- по умолчанию равен true, что позволяет выделять и перемещать этот объект
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTABLE,selection);
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTED,selection);
//--- скроем (true) или отобразим (false) имя графического объекта в списке объектов
   ObjectSetInteger(chart_ID,name,OBJPROP_HIDDEN,hidden);
//--- установим приоритет на получение события нажатия мыши на графике
   ObjectSetInteger(chart_ID,name,OBJPROP_ZORDER,z_order);
   
   ObjectSetString(chart_ID, name, OBJPROP_TEXT, descr);
   ObjectSetString(chart_ID, name, OBJPROP_TOOLTIP, name + "\n" + descr);   
//--- успешное выполнение
   return(true);
  }
  
//+------------------------------------------------------------------+ 
//| Создает объект "Текст"                                           | 
//+------------------------------------------------------------------+ 
bool TextCreate(const long              chart_ID=0,               // ID графика 
                const string            name="Text",              // имя объекта 
                const int               sub_window=0,             // номер подокна 
                datetime                time=0,                   // время точки привязки 
                double                  price=0,                  // цена точки привязки 
                const string            text="Text",              // сам текст 
                const string            font="Arial",             // шрифт 
                const int               font_size=10,             // размер шрифта 
                const color             clr=clrRed,               // цвет 
                const double            angle=0.0,                // наклон текста 
                const ENUM_ANCHOR_POINT anchor=ANCHOR_LEFT_UPPER, // способ привязки 
                const bool              back=false,               // на заднем плане 
                const bool              selection=false,          // выделить для перемещений 
                const bool              hidden=true,              // скрыт в списке объектов 
                const long              z_order=0)                // приоритет на нажатие мышью 
  { 
//--- сбросим значение ошибки 
   ResetLastError(); 
//--- создадим объект "Текст" 
   if(!ObjectCreate(chart_ID,name,OBJ_TEXT,sub_window,time,price)) 
     { 
      Print(__FUNCTION__, 
            ": не удалось создать объект \"Текст\"! Код ошибки = ",GetLastError()); 
      return(false); 
     } 
//--- установим текст 
   ObjectSetString(chart_ID,name,OBJPROP_TEXT,text); 
//--- установим шрифт текста 
   ObjectSetString(chart_ID,name,OBJPROP_FONT,font); 
//--- установим размер шрифта 
   ObjectSetInteger(chart_ID,name,OBJPROP_FONTSIZE,font_size); 
//--- установим угол наклона текста 
   ObjectSetDouble(chart_ID,name,OBJPROP_ANGLE,angle); 
//--- установим способ привязки 
   ObjectSetInteger(chart_ID,name,OBJPROP_ANCHOR,anchor); 
//--- установим цвет 
   ObjectSetInteger(chart_ID,name,OBJPROP_COLOR,clr); 
//--- отобразим на переднем (false) или заднем (true) плане 
   ObjectSetInteger(chart_ID,name,OBJPROP_BACK,back); 
//--- включим (true) или отключим (false) режим перемещения объекта мышью 
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTABLE,selection); 
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTED,selection); 
//--- скроем (true) или отобразим (false) имя графического объекта в списке объектов 
   ObjectSetInteger(chart_ID,name,OBJPROP_HIDDEN,hidden); 
//--- установим приоритет на получение события нажатия мыши на графике 
   ObjectSetInteger(chart_ID,name,OBJPROP_ZORDER,z_order); 
//--- успешное выполнение 
   return(true); 
  }  
  
//+------------------------------------------------------------------+ 
//| Создает горизонтальную линию                                     | 
//+------------------------------------------------------------------+ 
bool HLineCreate(const long            chart_ID=0,        // ID графика 
                 const string          name="HLine",      // имя линии 
                 const int             sub_window=0,      // номер подокна 
                 double                price=0,           // цена линии 
                 const color           clr=clrRed,        // цвет линии 
                 const ENUM_LINE_STYLE style=STYLE_SOLID, // стиль линии 
                 const int             width=1,           // толщина линии 
                 const bool            back=false,        // на заднем плане 
                 const bool            selection=true,    // выделить для перемещений 
                 const bool            hidden=true,       // скрыт в списке объектов 
                 const long            z_order=0)         // приоритет на нажатие мышью 
  { 
   ResetLastError(); 
//--- создадим горизонтальную линию 
   if(!ObjectCreate(chart_ID,name,OBJ_HLINE,sub_window,0,price)) 
     { 
      Print(__FUNCTION__, 
            ": не удалось создать горизонтальную линию! Код ошибки = ",GetLastError()); 
      return(false); 
     } 
//--- установим цвет линии 
   ObjectSetInteger(chart_ID,name,OBJPROP_COLOR,clr); 
//--- установим стиль отображения линии 
   ObjectSetInteger(chart_ID,name,OBJPROP_STYLE,style); 
//--- установим толщину линии 
   ObjectSetInteger(chart_ID,name,OBJPROP_WIDTH,width); 
//--- отобразим на переднем (false) или заднем (true) плане 
   ObjectSetInteger(chart_ID,name,OBJPROP_BACK,back); 
//--- включим (true) или отключим (false) режим перемещения линии мышью 
//--- при создании графического объекта функцией ObjectCreate, по умолчанию объект 
//--- нельзя выделить и перемещать. Внутри же этого метода параметр selection 
//--- по умолчанию равен true, что позволяет выделять и перемещать этот объект 
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTABLE,selection); 
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTED,selection); 
//--- скроем (true) или отобразим (false) имя графического объекта в списке объектов 
   ObjectSetInteger(chart_ID,name,OBJPROP_HIDDEN,hidden); 
//--- установим приоритет на получение события нажатия мыши на графике 
   ObjectSetInteger(chart_ID,name,OBJPROP_ZORDER,z_order); 
//--- успешное выполнение 
   return(true); 
  } 
  
//+------------------------------------------------------------------+ 
//| Создает вертикальную линию                                       | 
//+------------------------------------------------------------------+ 
bool VLineCreate(const long            chart_ID=0,        // ID графика 
                 const string          name="VLine",      // имя линии 
                 const int             sub_window=0,      // номер подокна 
                 datetime              time=0,            // время линии 
                 const color           clr=clrRed,        // цвет линии 
                 const ENUM_LINE_STYLE style=STYLE_SOLID, // стиль линии 
                 const int             width=1,           // толщина линии 
                 const bool            back=false,        // на заднем плане 
                 const bool            selection=true,    // выделить для перемещений 
                 const bool            ray=true,          // продолжение линии вниз 
                 const bool            hidden=true,       // скрыт в списке объектов 
                 const long            z_order=0)         // приоритет на нажатие мышью 
  { 
//--- сбросим значение ошибки 
   ResetLastError(); 
//--- создадим вертикальную линию 
   if(!ObjectCreate(chart_ID,name,OBJ_VLINE,sub_window,time,0)) 
     { 
      Print(__FUNCTION__, 
            ": не удалось создать вертикальную линию! Код ошибки = ",GetLastError()); 
      return(false); 
     } 
//--- установим цвет линии 
   ObjectSetInteger(chart_ID,name,OBJPROP_COLOR,clr); 
//--- установим стиль отображения линии 
   ObjectSetInteger(chart_ID,name,OBJPROP_STYLE,style); 
//--- установим толщину линии 
   ObjectSetInteger(chart_ID,name,OBJPROP_WIDTH,width); 
//--- отобразим на переднем (false) или заднем (true) плане 
   ObjectSetInteger(chart_ID,name,OBJPROP_BACK,back); 
//--- включим (true) или отключим (false) режим перемещения линии мышью 
//--- при создании графического объекта функцией ObjectCreate, по умолчанию объект 
//--- нельзя выделить и перемещать. Внутри же этого метода параметр selection 
//--- по умолчанию равен true, что позволяет выделять и перемещать этот объект 
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTABLE,selection); 
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTED,selection); 
//--- включим (true) или отключим (false) режим отображения линии в подокнах графика 
   ObjectSetInteger(chart_ID,name,OBJPROP_RAY,ray); 
//--- скроем (true) или отобразим (false) имя графического объекта в списке объектов 
   ObjectSetInteger(chart_ID,name,OBJPROP_HIDDEN,hidden); 
//--- установим приоритет на получение события нажатия мыши на графике 
   ObjectSetInteger(chart_ID,name,OBJPROP_ZORDER,z_order); 
//--- успешное выполнение 
   return(true); 
  }  
  
//+------------------------------------------------------------------+
//| Создает знак "Buy"                                               |
//+------------------------------------------------------------------+
bool ArrowCreate(const long            chart_ID=0,        // ID графика
                 const string          name="ArrowBuy",   // имя знака
                 const int             sub_window=0,      // номер подокна
                 const ENUM_OBJECT     arrow=OBJ_ARROW_BUY,
                 datetime              time=0,            // время точки привязки
                 double                price=0,           // цена точки привязки
                 const color           clr=C'3,95,172',   // цвет знака
                 const ENUM_LINE_STYLE style=STYLE_SOLID, // стиль линии (при выделении)
                 const int             width=1,           // размер линии (при выделении)
                 const bool            back=false,        // на заднем плане
                 const bool            selection=false,   // выделить для перемещений
                 const bool            hidden=true,       // скрыт в списке объектов
                 const long            z_order=0)         // приоритет на нажатие мышью
  {
//--- сбросим значение ошибки
   ResetLastError();
//--- создадим знак
   if(!ObjectCreate(chart_ID,name,arrow,sub_window,time,price))
     {
      Print(__FUNCTION__,
            ": не удалось создать знак \"Buy\"! Код ошибки = ",GetLastError());
      return(false);
     }
//--- установим цвет знака
   ObjectSetInteger(chart_ID,name,OBJPROP_COLOR,clr);
//--- установим стиль линии (при выделении)
   ObjectSetInteger(chart_ID,name,OBJPROP_STYLE,style);
//--- установим размер линии (при выделении)
   ObjectSetInteger(chart_ID,name,OBJPROP_WIDTH,width);
//--- отобразим на переднем (false) или заднем (true) плане
   ObjectSetInteger(chart_ID,name,OBJPROP_BACK,back);
//--- включим (true) или отключим (false) режим перемещения знака мышью
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTABLE,selection);
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTED,selection);
//--- скроем (true) или отобразим (false) имя графического объекта в списке объектов
   ObjectSetInteger(chart_ID,name,OBJPROP_HIDDEN,hidden);
//--- установи приоритет на получение события нажатия мыши на графике
   ObjectSetInteger(chart_ID,name,OBJPROP_ZORDER,z_order);
//--- успешное выполнение
   return(true);
  }  

//+------------------------------------------------------------------+
//| Find subwindow number for indicator with IndicatorHandle                                                                 
//+------------------------------------------------------------------+
int FindSubwindowByIndicatorHandle(const int aChart, const int aIndicatorHandle) {
  int windows=(int)ChartGetInteger(aChart, CHART_WINDOWS_TOTAL);

  for(int w=0;w<windows;w++) {
    int total=ChartIndicatorsTotal(0,w);
    for(int i=0;i<total;i++) {
       string name=ChartIndicatorName(0,w,i);
       int handle=ChartIndicatorGet(0,w,name);
       if (handle == aIndicatorHandle) 
         return w;
      }
  }
  return -1; 
}