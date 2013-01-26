//---------------------------------------------------------//
/* LCD Main                                                */
//---------------------------------------------------------//
/*
lcd_main() updates the LCD display according to the current mode of operation
*/
void lcd_main(){
  switch(MC_Mode){
    case 0:
    
      lcd_home();                                             //Updates The LCD home screen
      
      break;
    case 1:
      lcd_setpoints();
      break;
    case 2:
      lcd_mc_status();
      break;
    case 3:
      lcd_set_rtc();
      break;
  }
}  

//---------------------------------------------------------//
/* Change the LCD line that reflects the current state     */
//---------------------------------------------------------//
// active_button contains the number of the pushbutton pressed
void update_lcd_mode_line(int active_button){
  fan_control();
  if(active_button == 4) myGLCD.clrScr();                  //Clear the screen whenever the Micro Controller Mode is rolled. (PB4)  
  switch(MC_Mode){
    case 0:
      lcd_home_buttons();                                  //located at the bottom of the LCD_Home tab
//      myGLCD.lcdOn();                                    //Hardware Debug (it worked after moving the pins!)
      break;
    case 1:
//      myGLCD.lcdOff();                                   //Hardware Debug (it worked after moving the pins!)
      break;
  } 
}


