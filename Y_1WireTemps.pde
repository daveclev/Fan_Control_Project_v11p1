//---------------------------------------------------------//
/* 1 Wire Temperature - Maxim (Dallas)                     */
//---------------------------------------------------------//
void get_temperatures(){
  float holder0 = sensors.getTempF(DallasThermometer0);    //Send command to read result of the temperature conversion
  float holder1 = sensors.getTempF(DallasThermometer1);    //Send command to read result of the temperature conversion
  float holder2 = sensors.getTempF(DallasThermometer2);    //Send command to read result of the temperature conversion  
//  if (holder0 > 10) Temperature_Vent = holder0;
//  if (holder1 < 120) Temperature_Hall = holder1;
//  Temperature_Outside = 9;

  if(millis() > 5000)              //Fixes start up bug by not recording the first readings
    first_loops = 0;
    
  if(first_loops == 0){
    if (holder0 > 10) Temperature_Vent = holder0;
    if (holder1 < 120) Temperature_Hall = holder2;
    Temperature_Outside = holder1;
  }
  
  sensors.requestTemperatures();                           //Send the command for all devices to begin temperature conversion
//  if(0){                                                 //Debug if statement
//    Serial.print("DONE. ");
//    Serial.print("Vent Temperature: ");
//    Serial.print(Temperature_Vent);
//    Serial.print("F. Board Temperature: ");
//    Serial.print(Temperature_Hall); 
//    Serial.println("F.");
//    Serial.print("Converting Temp... ");
//  }
}
