//---------------------------------------------------------//
/* House Fan Sleep Timer                                   */
//---------------------------------------------------------//
//Returns a 1 if the house fan is supposed to be on and a 0 if it isn't
bool hf_sleeper(){
  bool sleep_on_off;
  switch(RC_Mode){
    case 1:  //The ON case
      //Start timer
      if(sleep_timer_flag == 0){
        sleep_timer_flag = 1;
        sleeper_seconds = 0;          // START TIMER
      }
      //Check timer
      if(sleeper_seconds > 600){
        RC_Mode = 0;
      }
      //This is the 'On' case so we turn on the feedback and the fan even when the if statement above has set RC_Mode to 0;
      house_fan_sleeper_feedback();
      sleep_on_off = 1;              //Main house fan variable
      break;
      
    case 0:  //The OFF case
      sleep_timer_flag = 0;
      sleep_on_off = 0;
      break;

  }
  return sleep_on_off;
}
    
//---------------------------------------------------------//
/* House Fan Sleep timer LED feedback                      */
//---------------------------------------------------------//
//Currently holds up program.  Improve by removing the 'delay();' function.
void house_fan_sleeper_feedback(){
  uint8_t ontime = 50;
  uint8_t offtime = 100;
  if(sleeper_seconds < 360){
    IOE.digitalWrite(HFSLED, HIGH); 
    delay(ontime);
    IOE.digitalWrite(HFSLED, LOW); 
    delay(offtime);
    
    IOE.digitalWrite(HFSLED, HIGH); 
    delay(ontime);
    IOE.digitalWrite(HFSLED, LOW); 
    delay(offtime);
    
    IOE.digitalWrite(HFSLED, HIGH); 
    delay(ontime);
    IOE.digitalWrite(HFSLED, LOW); 
    delay(offtime);
 
    IOE.digitalWrite(HFSLED, HIGH); 
    delay(ontime);
    IOE.digitalWrite(HFSLED, LOW); 
    delay(offtime); 

    IOE.digitalWrite(HFSLED, HIGH); 
    delay(ontime);
    IOE.digitalWrite(HFSLED, LOW); 
  }
  else if(sleeper_seconds < 420){
    IOE.digitalWrite(HFSLED, HIGH); 
    delay(ontime);
    IOE.digitalWrite(HFSLED, LOW); 
    delay(offtime);
    
    IOE.digitalWrite(HFSLED, HIGH); 
    delay(ontime);
    IOE.digitalWrite(HFSLED, LOW); 
    delay(offtime);
    
    IOE.digitalWrite(HFSLED, HIGH); 
    delay(ontime);
    IOE.digitalWrite(HFSLED, LOW); 
    delay(offtime);
 
    IOE.digitalWrite(HFSLED, HIGH); 
    delay(ontime);
    IOE.digitalWrite(HFSLED, LOW); 
  }
  else if(sleeper_seconds < 480){
    IOE.digitalWrite(HFSLED, HIGH); 
    delay(ontime);
    IOE.digitalWrite(HFSLED, LOW); 
    delay(offtime);
    
    IOE.digitalWrite(HFSLED, HIGH); 
    delay(ontime);
    IOE.digitalWrite(HFSLED, LOW); 
    delay(offtime);
    
    IOE.digitalWrite(HFSLED, HIGH); 
    delay(ontime);
    IOE.digitalWrite(HFSLED, LOW); 
  }
  else if(sleeper_seconds < 540){
    IOE.digitalWrite(HFSLED, HIGH); 
    delay(ontime);
    IOE.digitalWrite(HFSLED, LOW); 
    delay(offtime);
    
    IOE.digitalWrite(HFSLED, HIGH); 
    delay(ontime);
    IOE.digitalWrite(HFSLED, LOW); 
  }
  else {
    IOE.digitalWrite(HFSLED, HIGH); 
    delay(ontime);
    IOE.digitalWrite(HFSLED, LOW); 
  }
}

