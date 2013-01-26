//---------------------------------------------------------//
/* Fan control                                            */
//---------------------------------------------------------//
void fan_control(){
  int varHF = 0;
  int varSF = 0;
  
  //Off....................................................
  if(Operating_Mode == 0){
    if(MC_Mode == 1){
      PB2_enable = 0;
      PB3_enable = 0;
    }
    else{
      PB2_enable = 1;
      PB3_enable = 1;
    }

    HF_Mode = 0;
    SF_Mode = 0;

    brightness = 0;                                        // Turn Global status light off
  }
    
  //Manual.................................................
  if(Operating_Mode == 1){
    PB2_enable = 1;
    PB3_enable = 1;
  } 
  
  //Auto Off...............................................
  if(Operating_Mode == 2){
    PB2_enable = 1;
    PB3_enable = 1;
    if(Temperature_Vent > AutoOff_VentAbove) Auto_Off_Flag = 1;
    if((Auto_Off_Flag == 1) && (Temperature_Vent < AutoOff_VentBelow)){
      Auto_Off_Flag = 0;
      HF_Mode = 0;
      SF_Mode = 0;
    }
  }
  
  //Auto..................................................
  if(Operating_Mode == 3){
    if(MC_Mode == 1){
      PB2_enable = 0;
      PB3_enable = 0;
    }
    else{
      PB2_enable = 1;
      PB3_enable = 1;
    }
      

    //Auto On House Fan
    if((Temperature_Vent > AutoHF_VentAbove) && (Temperature_Hall < AutoHF_HallAbove) && (AutoHF_seconds > 300)){
      if(HF_Mode == 0) varHF = 1;
      HF_Mode = 1;
      if(varHF){
        varHF = 0;
        lcd_home_buttons();
      }
      AutoHF_seconds = 0;
//      if(debug_serial) Serial.println("Auto On House Fan");
    }
    //Auto Off House Fan
    else if(((Temperature_Vent < (AutoHF_VentAbove-30)) || (Temperature_Hall > (AutoHF_HallAbove-2))) && (AutoHF_seconds > 300)){
      HF_Mode = 0;
      AutoHF_seconds = 0;  //New
    }
    //Auto Off both
    if(((Temperature_Vent < AutoSF_VentBelow) || (Temperature_Hall > AutoSF_HallAbove)) && (AutoSF_seconds > 300)){
      HF_Mode = 0;
      SF_Mode = 0;
      AutoHF_seconds = 0; //New
    }
    //Auto On Stove Fan
    else if(Temperature_Vent > AutoSF_VentAbove){
      if(SF_Mode == 0) varSF = 1;
      SF_Mode = 1;
      if(varSF){
        varSF = 0;
        lcd_home_buttons();
      }
      AutoSF_seconds = 0;
    }
  }
  
  HF_Mode |= hf_sleeper();

  //Set pin states ---------------------------------------
  if(HF_Mode == 0) IOE.digitalWrite(HF_PIN, LOW);
  if(HF_Mode == 1) IOE.digitalWrite(HF_PIN, HIGH);
  if(SF_Mode == 0) IOE.digitalWrite(SF_PIN, LOW);
  if(SF_Mode == 1) IOE.digitalWrite(SF_PIN, HIGH);
  
}
