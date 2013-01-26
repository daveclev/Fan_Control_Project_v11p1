/***********************************************************/
/*                    Main Loop                            */
/***********************************************************/
void loop()  {   
  if (one_second_mscounter > 33){                           //Loop is true every .99 seconds
    one_second_mscounter = 0;
    //Place any functions in here
    lcd_main();                                             //Updates The LCD screen depending on current mode
    get_temperatures();                                     //Updates temperature variables for sensors on Dallas 1 wire bus    
    //Serial.println("one second loop");                    //Debug line
    current_time();                                         //Gets current time from 
    IOEheartbeat();                                         //Flips the state of the heartbeat pin every time it is called
    AutoHF_seconds++;
    AutoSF_seconds++;
    sleeper_seconds++;
    
  }
  if (two_second_mscounter > 67){                           //Loop is true every 2.01 seconds
    two_second_mscounter = 0;
    //Place any functions in here
    temperature_humidity_DHT22();                           //Updates the Temperature & Humidity of on the DHT22 sensor
    //Serial.println("two second loop");                    //Debug line
    
  }
  IOEcheck_pushbuttons();                                   //Checks if a pushbutton has been pressed and also increments appropriate variable
  fan_control();                                            //Controls when the house fan and the stove fan are on/off
  data_log();

  
}


//---------------------------------------------------------//
/* Current Time                                            */
//---------------------------------------------------------//
void current_time(){
//  Serial.print(int(rtc.getSecond()));
//  Serial.print(" ");
//  Serial.print(int(rtc.getMinute()));
//  Serial.print("\r\n");
//  if(0){    //Serial Debug
//    Serial.print(rtc.formatTime());
//    Serial.print(",  ");
//    Serial.print(rtc.formatDate());
//    Serial.print("\r\n");
//  }
  
}

//---------------------------------------------------------//
/* IO Expander Heartbeat                                   */
//---------------------------------------------------------//
//Flips the state of the IO Expander pin specified in the 
//pin definitions ever time the function is called.
void IOEheartbeat(){
  if(IOE_Heartbeat) IOE.digitalWrite(LED_IOE, HIGH); 
  else IOE.digitalWrite(LED_IOE, LOW); 
  IOE_Heartbeat = !IOE_Heartbeat;
}

//---------------------------------------------------------//
/* Operating Mode Recall                                   */
//---------------------------------------------------------//
//Stores current Operating Mode onto the EEPROM so that on 
//restart system will boot into last used Operating Mode
void store_operating_mode(){
  Wire.beginTransmission(chipAdress);    // chip address on the TWI bus, not chip memory address
  //Set up the chip Internal Address Pointer to the beginning of memory
  Wire.send(0x7F);      //Address MSB
  Wire.send(0xFA);      //Address LSB
  Wire.send(Operating_Mode);
  Wire.endTransmission(); // sends Wire buffer to chip, sets Internal Address Pointer to '0'
}
