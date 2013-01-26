//---------------------------------------------------------//
/* Check Push Buttons & Set desired mode                   */
//---------------------------------------------------------//
void IOEcheck_pushbuttons(){
  int Operating_Mode_Max = 3;                               //Set the number of available modes 0-XX
  int SF_Mode_Max = 1;                                      //Set the number of available modes
  int HF_Mode_Max = 1;                                      //Set the number of available modes
  int MC_Mode_Max = 3;                                      //
  int RC_Mode_Max = 1;
  
  // read the state of the switch into the global variable
    PB1_State  = IOE.digitalRead(PB1);
    PB2_State  = IOE.digitalRead(PB2);
    PB3_State  = IOE.digitalRead(PB3);
    PB4_State  = IOE.digitalRead(PB4);
    TS1_State  = IOE.digitalRead(TS1);
    HVAC_FAN   = IOE.digitalRead(HVAC_FAN_SENSE);         //Bit 4
    HVAC_AC    = IOE.digitalRead(HVAC_AC_SENSE);          //Bit 5
    HVAC_HEAT  = IOE.digitalRead(HVAC_HEAT_SENSE);        //Bit 6   
    HVAC_SPARE = IOE.digitalRead(HVAC_SPARE_SENSE);       //Bit 7   
   
  // Rolls the modes
  if ((PB1_State == 1) && (PB1_Flag == 0)){                  // For PB1
    PB1_Flag = 1;
    
    if(MC_Mode == 2){
      serial_history_dump();
    }
    else if(MC_Mode == 3){
      clocksetter += 10;
    }
    else{
      Operating_Mode++;
      store_operating_mode();
      if (Operating_Mode > Operating_Mode_Max){ 
        if(fadeAmount < 0){                                    //Fixes Global Status Flash problem when
          fadeAmount = -fadeAmount;                            //Fixes Global Status Flash problem when 
          delay(40);                                           //Fixes Global Status Flash problem when
        }
        Operating_Mode = 0;
      }
      update_lcd_mode_line(1);
    }
  }
  if (PB1_State == 0) PB1_Flag = 0;
  
  if ((PB2_State == 1) && (PB2_Flag == 0) && PB2_enable){    // For PB2
    PB2_Flag = 1;
    if(MC_Mode == 3){
      clocksetter += 1;
    }
    else{    
      SF_Mode++;
      if (SF_Mode > SF_Mode_Max) SF_Mode = 0;
      update_lcd_mode_line(2);
    }
  }
  if (PB2_State == 0) PB2_Flag = 0;    
  
  if ((PB3_State == 1) && (PB3_Flag == 0) && PB3_enable){    // For PB3
    PB3_Flag = 1;
    if(MC_Mode == 3){
      clocksetter_next++;
      if(clocksetter_next > 5) clocksetter_next = 0;
  }
    else{
      HF_Mode++;
      if (HF_Mode > HF_Mode_Max){
        HF_Mode = 0;
        clocksetter_next = 0; // because clock set is the last MC Mode.  
        if(MC_Mode == 3) myGLCD.clrScr();      // because clock set is the last MC Mode
      }
      update_lcd_mode_line(3);
    }
  }
  if (PB3_State == 0) PB3_Flag = 0;  
  
  if ((PB4_State == 1) && (PB4_Flag == 0) && PB4_enable){    // For PB4
    PB4_Flag = 1;
    MC_Mode++;
    if (MC_Mode > MC_Mode_Max) MC_Mode = 0;
    update_lcd_mode_line(4);
  }
  if (PB4_State == 0) PB4_Flag = 0;  
  
  if ((TS1_State == 1) && (TS1_Flag == 0) && TS1_enable){    // For TS1
    TS1_Flag = 1;
    RC_Mode++;
    if (RC_Mode > RC_Mode_Max) RC_Mode = 0;
    update_lcd_mode_line(5);
    IOEheartbeat();
  }
  if (TS1_State == 0) TS1_Flag = 0;  
  
  if ((PB1_Flag == 1) || (PB2_Flag == 1) || (PB3_Flag == 1) || (PB4_Flag == 1)) PB_global_state_change = 1;

  // save the reading.  Next time through the loop,
  // it'll be the lastButtonState:  
  PB1_Last_State = PB1_State;
  PB2_Last_State = PB2_State;
  PB3_Last_State = PB3_State;
  PB4_Last_State = PB4_State;
  
//  if(0){                              //Serial Debug
//    Serial.print("Global Mode:");
//    Serial.print(Operating_Mode);
//    Serial.print("  SF_Mode:");
//    Serial.print(SF_Mode);
//    Serial.print("  HF_Mode:");
//    Serial.print(HF_Mode);
//    Serial.print("  MC_Mode:");
//    Serial.print(MC_Mode);
//    
//    Serial.print("     PB1:");
//    Serial.print(PB1_State);
//    Serial.print("  PB2:");
//    Serial.print(PB2_State);
//    Serial.print("  PB3:");
//    Serial.println(PB3_State);
//    Serial.print("  PB4:");
//    Serial.println(PB4_State);
//  }
}
