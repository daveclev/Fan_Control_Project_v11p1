//---------------------------------------------------------//
/* Update the LCD Set Point screen                         */
//---------------------------------------------------------//
// Line spacing should be 9 away because each line takes 8.  Charachter spacing is 6 because each is 5?
// Horizontal lines start at 1.
void lcd_setpoints(){
  PB_global_state_change = 0;                              //This is set to 1 every time a button state changes.  This is essential to prevent overwriting a screen change with the rest of this funtion.
  
  myGLCD.print("SetPoints", CENTER, 1);                    //Screen Name
  myGLCD.setColor(255, 255, 255);
  myGLCD.print("In Auto Off Mode:", CENTER, 19);           //Heading
  myGLCD.setColor(0, 255, 255);
  myGLCD.print("After vent temp is >", LEFT, 28);          //Body
  myGLCD.printNumI(AutoOff_VentAbove, LEFT, 37); IOEcheck_pushbuttons(); if(PB_global_state_change) return; 
  myGLCD.print("Stove Fan turns", 18, 37);
  myGLCD.print("off when vent is < ", LEFT, 46);
  myGLCD.printNumI(AutoOff_VentBelow, 114, 46);   IOEcheck_pushbuttons(); if(PB_global_state_change) return; 
  
  myGLCD.setColor(255, 255, 255);
  myGLCD.print("In Auto Mode:", CENTER,64);                 //Heading
  myGLCD.setColor(0, 255, 255);
  myGLCD.print("SF off if vent < ", LEFT, 73);              //Body
  myGLCD.printNumI(AutoSF_VentBelow, 102, 73); IOEcheck_pushbuttons(); if(PB_global_state_change) return; 
  myGLCD.print("or the hall > ", LEFT, 82);
  myGLCD.printNumI(AutoSF_HallAbove, 84, 82); IOEcheck_pushbuttons(); if(PB_global_state_change) return; 
  myGLCD.print("SF on if vent > ", LEFT, 91);
  myGLCD.printNumI(AutoSF_VentAbove, 96, 91); IOEcheck_pushbuttons(); if(PB_global_state_change) return; 
  myGLCD.print("HF on if vent > ", LEFT, 100);
  myGLCD.printNumI(AutoHF_VentAbove, 96, 100); IOEcheck_pushbuttons(); if(PB_global_state_change) return; 
  myGLCD.print("and if hall < ", LEFT, 109);
  myGLCD.printNumI(AutoHF_HallAbove, 84, 109); IOEcheck_pushbuttons(); if(PB_global_state_change) return; 
  
}

/*  For Reference.  These are all initialized in the first tab
int AutoOff_VentAbove = 95;                    //In Auto Off Mode: Turn Stove Fan on if Vent temp is above
int AutoOff_VentBelow = 90;                    //In Auto Off Mode: Turn Stove Fan off if Vent temp is below
int AutoSF_VentBelow = 85;                     //In Auto Mode: Turn Stove fan off if Vent temp is below
int AutoSF_HallAbove = 75;                     //In Auto Mode: Turn Stove fan off if Hall Temp is above
int AutoSF_VentAbove = 88;                     //In Auto Mode: Turn Stove fan on if Vent temp is above
int AutoHF_VentAbove = 120;                    //In Auto Mode: Turn House fan on if Vent temp is above YY and
int AutoHF_HallAbove = 72;                     //In Auto Mode: Turn House fan on if Hall temp is above XX and
*/
