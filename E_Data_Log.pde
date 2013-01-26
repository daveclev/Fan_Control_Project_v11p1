//---------------------------------------------------------//
/* EEPROM Data logger                                      */
//---------------------------------------------------------//
void data_log(){
  bool function_debug = 1;    //Serial debug of function being called
  bool debug = 0;             //Serial debug of EEPROM data log address pointer
  
  log_every = 4;              //Log data every X minutes (normally 4)
  
  bool error = 0;              //Once a block has been written it is then read back and compared to the data that was supposed to be written.  If there is a missmatch flag is flipped to TRUE (1)
  
  int minute_current = int(rtc.getMinute());
  if((minute_last != minute_current) || (DL_Error > 0)){
    minutes++;
    if((minutes > log_every) || (DL_Error > 0)){
      minutes = 0;
      byte varMSB = 0x00;
      byte varLSB = 0x00;
      uint8_t columns[10];
      rtc.getDate();                       //Must call .getDate before using getYear/Month/Day because getDate loads the private variables that are returned by getYear/Month/Day
      columns[0] = rtc.getMonth();    //rtc functions return "byte"
      columns[1] = rtc.getDay();      //returns day of the month.  rtc.getWeekday() returns day of the week.
      columns[2] = rtc.getHour();
      columns[3] = minute_current;
      columns[4] = Temperature_Hall;
      columns[5] = Temperature_Basement;
      columns[6] = Humidity_Basement;
      columns[7] = Temperature_Vent;
      columns[8] = Temperature_Outside + 20;

//      HVAC_SPARE = 1;      //Bit 7
//      HVAC_HEAT = 0;       //Bit 6
//      HVAC_AC = 0;         //Bit 5
//      HVAC_FAN = 1;        //Bit 4
//      Operating_Mode = 3;  //Bit 2 & 3  
//      SF_Mode = 0;         //Bit 1
//      HF_Mode = 0;         //Bit 0
      
      columns[9] = 0;                     //Zero out byte
      columns[9] |= HVAC_SPARE << 7;       //Bit 7
      columns[9] |= HVAC_HEAT << 6;        //Bit 6
      columns[9] |= HVAC_AC << 5;          //Bit 5
      columns[9] |= HVAC_FAN << 4;         //Bit 4
      columns[9] |= Operating_Mode << 2;   //Bit 2 & 3
      columns[9] |= SF_Mode <<1;          //Bit 1
      columns[9] |= HF_Mode;              //Bit 0         
      
      
      //Serial.println(columns[9], BIN);
      
      Wire.beginTransmission(chipAdress);    // chip address on the TWI bus, not chip memory address
      //Set up the chip Internal Address Pointer 
      Wire.send(0x7F);   //Address MSB   
      Wire.send(0xFD);   //Address LSB
      Wire.endTransmission(); // sends Wire buffer to chip, sets Internal Address Pointer to '0'
      
      Wire.requestFrom(chipAdress, 1);          // requests up to 32 Bytes of data in a packet, maximum string size.
      while(Wire.available()){                // 'while loop' start, Checks to see if data is waiting
        varMSB = Wire.receive();
        if(debug) Serial.print(varMSB, HEX);  // print the values received on the serial monitor
      }                                    // end bracket for 'while loop'
      Wire.endTransmission(); 
      
      delay(10);
      
      if(debug) Serial.print(".");
      
      Wire.beginTransmission(chipAdress);    // chip address on the TWI bus, not chip memory address
      //Set up the chip Internal Address Pointer
      Wire.send(0x7F);   //Address MSB   
      Wire.send(0xFE);   //Address LSB
      Wire.endTransmission(); // sends Wire buffer to chip, sets Internal Address Pointer to '0'
      
      Wire.requestFrom(chipAdress, 1);          // requests up to 32 Bytes of data in a packet, maximum string size.
      while(Wire.available()){                // 'while loop' start, Checks to see if data is waiting
        varLSB = Wire.receive();
        if(debug) Serial.print(varLSB, HEX);  // print the values received on the serial monitor
      }                                    // end bracket for 'while loop'
      Wire.endTransmission(); 
        
      delay(10);
        
      Wire.beginTransmission(chipAdress);    // chip address on the TWI bus, not chip memory address
      Wire.send(varMSB);
      Wire.send(varLSB);
      Wire.send(columns[0]);
      Wire.send(columns[1]);
      Wire.send(columns[2]);
      Wire.send(columns[3]);
      Wire.send(columns[4]);
      Wire.send(columns[5]);
      Wire.send(columns[6]);
      Wire.send(columns[7]);
      Wire.send(columns[8]);
      Wire.send(columns[9]);   
      Wire.endTransmission(); // sends Wire buffer to chip, sets Internal Address Pointer to '0'
      
      delay(10);
 
      //Error checking -----------------------------
      delay(10);
      Wire.beginTransmission(chipAdress);    // chip address on the TWI bus, not chip memory address
      //Set up the chip Internal Address Pointer
      Wire.send(varMSB);   //Address MSB   
      Wire.send(varLSB);   //Address LSB
      Wire.endTransmission(); // sends Wire buffer to chip, sets Internal Address Pointer to '0'
      
      DL_Address = varMSB << 8;
      //DL_Address <<8;
      DL_Address |= varLSB;  
      if(DL_Address > 0x7F61) DL_Address = 0x0000;  //new in version 6p3.
      
      int i = 0;
      uint8_t temp;
      Wire.requestFrom(chipAdress, 10);          // requests up to 32 Bytes of data in a packet, maximum string size.
      while(Wire.available()){                // 'while loop' start, Checks to see if data is waiting
        temp = Wire.receive();
        if (columns[i] != temp){
          error = 1;
        }
        i++;    
      }                                    // end bracket for 'while loop'
      Wire.endTransmission(); 
        
      delay(10);
      //-----------------------------

      if(debug){
        Serial.print(" = ");
        if(highByte(DL_Address)<0x10) Serial.print("0");
        Serial.print(highByte(DL_Address), HEX);
        Serial.print(".");
        if(lowByte(DL_Address)<0x10) Serial.print("0");
        Serial.print(lowByte(DL_Address), HEX);
        Serial.print(" ");
      }
      
      //Error flagging++++++++++++++++++++++++++++++
      if(DL_Error > 4){
        DL_Error = 0;
        delay(10);        
        Wire.beginTransmission(chipAdress);    // chip address on the TWI bus, not chip memory address
        Wire.send(varMSB);
        Wire.send(varLSB);
        Wire.send(0xFF);
        Wire.send(0xFF);
        Wire.send(0xFF);
        Wire.send(0xFF);
        Wire.send(0xFF);
        Wire.send(0xFF);
        Wire.send(0xFF);
        Wire.send(0xFF);
        Wire.send(0xFF);
        Wire.send(0xFF);   
        Wire.endTransmission(); // sends Wire buffer to chip, sets Internal Address Pointer to '0'      
        delay(10);
        if(function_debug) Serial.print("\n\rBad ");
      }    
      else if(error){
//       if(debug) Serial.print("Error ");
       DL_Error++;  //Incr
       return;
      }
      //++++++++++++++++++++++++++++++++++++++++++++++++
      
      DL_Address = DL_Address + 10;
      
      varMSB = highByte(DL_Address);
      varLSB = lowByte(DL_Address);
      
      Wire.beginTransmission(chipAdress);    // chip address on the TWI bus, not chip memory address
      //Set up the chip Internal Address Pointer to the beginning of memory
      Wire.send(0x7F);                       //Memory Address MSB
      Wire.send(0xFD);                       //Memory Address LSB
      Wire.send(varMSB);
      Wire.send(varLSB);
      Wire.endTransmission(); // sends Wire buffer to chip, sets Internal Address Pointer to '0'
           
//      if(function_debug){           
//        Serial.print("Data logged at minute ");
//        Serial.print(minute_current);
//        Serial.print(".");
//      }
//      if(debug){
//        Serial.print(" Next DL_Address 0x");
//        if(highByte(DL_Address)<0x10) Serial.print("0");
//        Serial.print(highByte(DL_Address), HEX);
//        Serial.print(".");
//        if(lowByte(DL_Address)<0x10) Serial.print("0");
//        Serial.print(lowByte(DL_Address), HEX);
//      }
//      if(function_debug) Serial.print("\n\r");
    }
  } 
  minute_last = minute_current; 
}


      
  
