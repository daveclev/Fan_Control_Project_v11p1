//---------------------------------------------------------//
/* Update the LCD Set Point screen                         */
//---------------------------------------------------------//
void lcd_set_rtc(){

  if(Hold_RTC == 1){
    Hold_RTC = 0;
    clocksetter_next = 0;    //Resets position in case the another time the process was aborted
    rtc.getDate();                       //Must call .getDate before using getYear/Month/Day because getDate loads the private variables that are returned by getYear/Month/Day
    set_year = rtc.getYear();
    set_month = rtc.getMonth();    //rtc functions return "byte"
    set_day = rtc.getDay();      //returns day of the month.  rtc.getWeekday() returns day of the week.
    set_hour = rtc.getHour();
    set_minutes = rtc.getMinute(); 
  }
  
  myGLCD.print("Set Clock", CENTER, 1);                       
  myGLCD.setColor(255, 255, 255);                                                 //Clock------------------------------------------
  myGLCD.print(rtc.formatTime(), CENTER, 10);  
  myGLCD.setColor(0, 255, 255);  IOEcheck_pushbuttons();
  
  myGLCD.printNumI(set_year, LEFT, 19); myGLCD.print(clock_set_names[0], 18, 19);
  myGLCD.printNumI(set_month, LEFT, 28); myGLCD.print(clock_set_names[1], 18, 28);
  myGLCD.printNumI(set_day, LEFT, 37); myGLCD.print(clock_set_names[2], 18, 37);
  myGLCD.printNumI(set_hour, LEFT, 46); myGLCD.print(clock_set_names[3], 18, 46);
  myGLCD.printNumI(set_minutes, LEFT, 55); myGLCD.print(clock_set_names[4], 18, 55);
  
  myGLCD.print("+10", LEFT, 120); myGLCD.print("+1", 36, 120); myGLCD.print("Abort", RIGHT, 120);
  if(clocksetter_next < 4) myGLCD.print("Next", 66, 120);
  
  myGLCD.setColor(255, 0, 0);
  switch(clocksetter_next){
    case 0:
    set_year += clocksetter;
    myGLCD.print(clock_set_names[0], 54, 73);
    myGLCD.printNumI(set_year, LEFT, 19); myGLCD.print(clock_set_names[0], 18, 19);
    break;
    
    case 1:
    set_month += clocksetter;
    if(set_month > 12){
      set_month = 1;
      myGLCD.print(clock_set_names[5], LEFT, 28); //clear number
    }
    myGLCD.print(clock_set_names[1], 54, 73);
    myGLCD.printNumI(set_month, LEFT, 28); myGLCD.print(clock_set_names[1], 18, 28);
    break;
    
    case 2:
    set_day += clocksetter;    
    if(set_day > 31){
      set_day = 1;
      myGLCD.print(clock_set_names[5], LEFT, 37); //clear number
    }
    myGLCD.print(clock_set_names[2], 54, 73);
    myGLCD.printNumI(set_day, LEFT, 37); myGLCD.print(clock_set_names[2], 18, 37);
    break;
    
    case 3:
    set_hour += clocksetter;
    if(set_hour > 24){
      set_hour = 0;
      myGLCD.print(clock_set_names[5], LEFT, 46); //clear number
    } 
    myGLCD.print(clock_set_names[3], 54, 73);
    myGLCD.printNumI(set_hour, LEFT, 46); myGLCD.print(clock_set_names[3], 18, 46);
    break;
    
    case 4:
    set_minutes += clocksetter;
    if(set_minutes > 59){
      set_minutes = 0;
      myGLCD.print(clock_set_names[5], LEFT, 55); //clear number
    }
    myGLCD.print(clock_set_names[4], 54, 73);
    myGLCD.printNumI(set_minutes, LEFT, 55); myGLCD.print(clock_set_names[4], 18, 55);
    myGLCD.print("Set ", 66, 120);
    break;
  }
  clocksetter = 0;
  myGLCD.setColor(0, 255, 255);
  

  
  myGLCD.print("Setting:", LEFT, 73);

  if(clocksetter_next == 5){  
    rtc.initClock();
    rtc.setDate(set_day, 1, set_month, 0, 12);          //day, weekday(sun=1), month, century(1=1900, 0=2000), year(0-99)
    rtc.setTime(set_hour, set_minutes, 0);               //hr, min, sec
    Hold_RTC = 1;
    MC_Mode = 0;
    clocksetter_next = 0;
    myGLCD.clrScr();
  }
}
  
  
  
  
  
  
  
  
  /*
  char* clock_set_names[]={"Year", "Month", "Day", "Minute", "Second"};       //Assign names to the modes
  
  rtc.getDate();                       //Must call .getDate before using getYear/Month/Day because getDate loads the private variables that are returned by getYear/Month/Day
      columns[0] = rtc.getMonth();    //rtc functions return "byte"
      columns[1] = rtc.getDay();      //returns day of the month.  rtc.getWeekday() returns day of the week.
      columns[2] = rtc.getHour();
  
  
  uint8_t clocksetter = 0;    //rtc functions return "byte"
uint8_t clocksetter_next = 0;
  */
