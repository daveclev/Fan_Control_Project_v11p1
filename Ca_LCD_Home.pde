//---------------------------------------------------------//
/* Update the LCD home screen                              */
//---------------------------------------------------------//
// Line spacing should be 9 away because each line takes 8.  Charachter spacing is 6 because each is 5?
void lcd_home(){
  
  int pline_title =         1;                               //Set Line numbers for information to be displayed on
  int pline_vent_temp =    32;
  int pline_hall_temp =    41;
  int pline_board_temp =   50;
  int pline_humidity =     59;
  int pline_outside_temp = 68;
  int pline_clock =        10;
  int pline_hvac =         77;
  
  /*
  
  myGLCD.print("HVAC: ", LEFT, pline_hvac);
  myGLCD.setColor(255, 0, 0);
  if(HVAC_FAN) myGLCD.print("F", 36, pline_hvac);
  else myGLCD.print("   ", 35, pline_hvac);
  if(HVAC_AC) myGLCD.print("A", 48, pline_hvac);
  else myGLCD.print("   ", 47, pline_hvac);
  if(HVAC_HEAT) myGLCD.print("H", 60, pline_hvac);
  else myGLCD.print("   ", 49, pline_hvac);
  if(HVAC_SPARE) myGLCD.print("S", 72, pline_hvac);
  else myGLCD.print("   ", 61, pline_hvac);
  myGLCD.setColor(0, 255, 255);
  
  */
    
  myGLCD.setColor(80, 80, 80);
  myGLCD.print("        ", CENTER, 102);                      //Debug the Stove fan control
  myGLCD.printNumI(AutoSF_seconds, CENTER, 102);              //Debug the Stove fan control
  myGLCD.print("        ", RIGHT, 102);                       //Debug the House fan control
  myGLCD.printNumI(AutoHF_seconds, RIGHT, 102);               //Debug the House fan control
  myGLCD.setColor(0, 255, 255);
  
//  myGLCD.printNumI(PCC,LEFT, 95);
  
  PB_global_state_change = 0;                              //This is set to 1 every time a button state changes.  This is essential to prevent overwriting a screen change with the rest of this funtion.
  
  myGLCD.print("Dave's Screen v11p1", CENTER, pline_title);                          //Screen Name----------------------------------
                                                                                  //Vent Temperature-----------------------------
  myGLCD.print("Vent Temp: ", LEFT, pline_vent_temp); IOEcheck_pushbuttons(); if(PB_global_state_change) return;      
  myGLCD.setColor(255, 0, 0);
  if (Temperature_Vent > 100){
    high_to_low_temp_flag = 1;                                                    //Set flag high so when temp goes below 100 we can clear the line
    myGLCD.printNumF(Temperature_Vent, 2, 63, pline_vent_temp);                   //Float, Decimal points, hpos, vpos
    myGLCD.setColor(0, 255, 255);  IOEcheck_pushbuttons(); if(PB_global_state_change) return;
    myGLCD.print("F", 100, pline_vent_temp);
  }
  else{
    if(high_to_low_temp_flag){
      high_to_low_temp_flag = 0;
      myGLCD.print("        ", 63, pline_vent_temp);
    }
    myGLCD.printNumF(Temperature_Vent, 2, 69, pline_vent_temp);                   //Float, Decimal points, hpos, vpos
    myGLCD.setColor(0, 255, 255);  IOEcheck_pushbuttons();
    myGLCD.print("F", 100, pline_vent_temp);
  }
                                                                                  //Hall Temperature-------------------------------
  myGLCD.print("Hall Temp: ", LEFT, pline_hall_temp);  IOEcheck_pushbuttons(); if(PB_global_state_change) return;    
  myGLCD.setColor(255, 0, 0);
  myGLCD.printNumF(Temperature_Hall, 2, 69, pline_hall_temp);  
  myGLCD.setColor(0, 255, 255);  IOEcheck_pushbuttons(); if(PB_global_state_change) return;
  myGLCD.print("F", 100, pline_hall_temp);
                                                                                  //Basement Temperature---------------------------
  myGLCD.print("Bsmnt Temp: ", LEFT, pline_board_temp);  IOEcheck_pushbuttons(); if(PB_global_state_change) return; 
  myGLCD.setColor(255, 0, 0);
  myGLCD.printNumF(Temperature_Basement, 2, 69, pline_board_temp);                //Float, Decimal points, hpos, vpos
  myGLCD.setColor(0, 255, 255);  IOEcheck_pushbuttons(); if(PB_global_state_change) return;
  myGLCD.print("F", 100, pline_board_temp);
                                                                                  //Humidity---------------------------------------
  myGLCD.print("Bsmnt Hmty: ", LEFT, pline_humidity);  IOEcheck_pushbuttons(); if(PB_global_state_change) return;       
  myGLCD.setColor(255, 0, 0);
  myGLCD.printNumF(Humidity_Basement, 2, 69, pline_humidity);  
  myGLCD.setColor(0, 255, 255);  IOEcheck_pushbuttons(); if(PB_global_state_change) return;
  myGLCD.print("%", 100, pline_humidity); IOEcheck_pushbuttons(); if(PB_global_state_change) return;
                                                                                  //Outside Temperature----------------------------
  myGLCD.print("Outside: ", LEFT, pline_outside_temp);  IOEcheck_pushbuttons(); if(PB_global_state_change) return;       
  myGLCD.setColor(255, 0, 0);
  myGLCD.printNumF(Temperature_Outside, 2, 69, pline_outside_temp);  
  myGLCD.setColor(0, 255, 255);  IOEcheck_pushbuttons(); if(PB_global_state_change) return;
  myGLCD.print("F", 100, pline_outside_temp); IOEcheck_pushbuttons(); if(PB_global_state_change) return;  

  myGLCD.setColor(255, 255, 255);                                                 //Clock------------------------------------------
  myGLCD.print(rtc.formatTime(), CENTER, pline_clock);  
  myGLCD.setColor(0, 255, 255);  IOEcheck_pushbuttons(); if(PB_global_state_change) return;

  myGLCD.print("Mode", LEFT, 111);                                                //Button Names-----------------------------------
  myGLCD.print("SFan", CENTER, 111);
  myGLCD.print("HFan", RIGHT, 111); IOEcheck_pushbuttons(); if(PB_global_state_change) return;
  myGLCD.setColor(0, 255, 0);    
  myGLCD.print(Operating_Mode_Names[Operating_Mode], LEFT, 120);                  //Current States---------------------------------
  myGLCD.print(SF_Mode_Names[SF_Mode], CENTER, 120);  
  myGLCD.print(HF_Mode_Names[HF_Mode], RIGHT, 120);
  myGLCD.setColor(0, 255, 255);  IOEcheck_pushbuttons(); if(PB_global_state_change) return;
  
  clocksetter_next = 0;
}
//---------------------------------------------------------//
/* Spot update the LCD home screen                         */
//---------------------------------------------------------//
/* This function assures quick screen response when a button is pressed.
It is a short function to make sure quick button presses are able to be read.
*/
void lcd_home_buttons(){
  myGLCD.print("                         ",LEFT,120);                             //Erase old states------------------------------
  myGLCD.print("                         ",RIGHT,120);
  myGLCD.setColor(0, 255, 0);  
  myGLCD.print(Operating_Mode_Names[Operating_Mode], LEFT, 120);                  //Write current States--------------------------
  myGLCD.print(SF_Mode_Names[SF_Mode], CENTER, 120);  
  myGLCD.print(HF_Mode_Names[HF_Mode], RIGHT, 120);
  myGLCD.setColor(0, 255, 255);
}
