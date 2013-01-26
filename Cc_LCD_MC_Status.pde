//---------------------------------------------------------//
/* Update the LCD Set Point screen                         */
//---------------------------------------------------------//
// Line spacing should be 9 away because each line takes 8.  Charachter spacing is 6 because each is 5?
void lcd_mc_status(){
  myGLCD.setColor(0, 255, 0);
  
  myGLCD.print("PB1 to dump EEPROM", CENTER, 30);
  
  myGLCD.print("Power Cycles: ", LEFT, 95);
  myGLCD.printNumI(PCC, 84, 95);
  
}
//---------------------------------------------------------//
/* Serial History Dump                                     */
//---------------------------------------------------------//
void serial_history_dump(){
  int i = 0;
  uint8_t temp[10];
  uint8_t error_count = 0;
  unsigned int skip_count = 0;
  Serial.print("Data logged every ");
  Serial.print((log_every + 1), DEC);
  Serial.print(" minutes.\n\r");
  
  Wire.beginTransmission(chipAdress);    // chip address on the TWI bus, not chip memory address.
                  //Set up the chip Internal Address Pointer to the beginning of memory
  Wire.send(0x00);      
  Wire.send(0x00);    
  Wire.endTransmission(); // sends Wire buffer to chip, sets Internal Address Pointer to '0'
 
  for(uint16_t pointer = 0x0000; pointer < 0x7F60; pointer+=10){  //v6.3 changed loop to end at current DL_Address
//  for(uint16_t pointer = 0x0000; pointer < 0x0060; pointer+=10){  //v6.3 changed loop to end at current DL_Address
    i = 0;
    
    Wire.requestFrom(chipAdress, 10);          // requests 32 Bytes of data in a packet, maximum string size.
    while(Wire.available()){                   // 'while loop' start, Checks to see if data is waiting      
      temp[i] = Wire.receive();     
      i++;
    }                                          // end bracket for 'while loop'
    Wire.endTransmission();                    // when 'while loop' is finished (no more data available) 'closes' chip

    for(int k = 0; k < 10; k++){
      if(temp[k] == 255) error_count++;
    }
//    Serial.print(error_count, DEC);
    
    if(error_count == 0){     
      if(highByte(pointer)<0x10) Serial.print("0");
      Serial.print(highByte(pointer), HEX);
      if(lowByte(pointer)<0x10) Serial.print("0");
      Serial.print(lowByte(pointer), HEX); 
      
      for(int j = 0; j<10; j++){
        if(j<8){
          Serial.print(",  ");                   // space to format packets on serial monitor    
          Serial.print(temp[j], DEC);               // print the values received on the serial monitor
        }
        else if (j == 8){
          Serial.print(",  ");                   // space to format packets on serial monitor    
          Serial.print((temp[j]-20), DEC);               // print the values received on the serial monitor
        }
        else{
          //Serial.print(", ");
          //Serial.print(temp[j], BIN);
          
          uint8_t hvac_spare_state = (temp[j] >> 7) & 0x01;  //Bit 7                 //Information is located at the 7th bit of temp[j]. sets hvac's bit 0 = to temp[j]'s bit 7
          //Serial.print(", ");                   //Spare bit not used but working   //Since only bit 0 is relevant mask the others to 0
          //Serial.print(hvac_spare_state, BIN);  //Spare bit not used but working  
          
          uint8_t hvac_heat_state = (temp[j] >> 6) & 0x01;   //Bit 6
          Serial.print(", ");
          Serial.print(hvac_heat_state, BIN);
          
          uint8_t hvac_ac_state = (temp[j] >> 5) & 0x01;     //Bit 5
          Serial.print(", ");
          Serial.print(hvac_ac_state, BIN);
          
          uint8_t hvac_fan_state = (temp[j] >> 4) & 0x01;    //Bit 4
          Serial.print(", ");
          Serial.print(hvac_fan_state, BIN);
               
          uint8_t opmode = (temp[j] >> 2) & 0x03;            //Bit 2 & 3
          Serial.print(", ");
          Serial.print(opmode, DEC);
          
          uint8_t sfstate = (temp[j] >> 1) & 0x01;           //Bit 1  
          Serial.print(", ");
          Serial.print(sfstate, BIN);
          
          uint8_t hfstate = temp[j] & 0x01;         //Bit 0
          Serial.print(", ");
          Serial.print(hfstate, BIN);
          
          
          /*  WORKS
          //created the above code just to make it more compact.  serves same function.
          uint8_t hvac_spare_state = temp[j] >> 7;  //Bit 7    //Information is located at the 7th bit of temp[j]. sets hvac's bit 0 = to temp[j]'s bit 7
          hvac_spare_state &= 0x01;                              //Since only bit 0 is relevant mask the others to 0
          Serial.print(", ");
          Serial.print(hvac_spare_state, BIN);           //Print as decimal
          
          uint8_t hvac_heat_state = temp[j] >> 6;   //Bit 6
          hvac_heat_state &= 0x01;
          Serial.print(", ");
          Serial.print(hvac_heat_state, BIN);
          
          uint8_t hvac_ac_state = temp[j] >> 5;     //Bit 5
          hvac_ac_state &= 0x01;
          Serial.print(", ");
          Serial.print(hvac_ac_state, BIN);
          
          uint8_t hvac_fan_state = temp[j] >> 4;    //Bit 4
          hvac_fan_state &= 0x01;
          Serial.print(", ");
          Serial.print(hvac_fan_state, BIN);
          
          
          uint8_t opmode = temp[j] >> 2;            //Bit 2 & 3
          opmode &= 0x03;
          Serial.print(", ");
          Serial.print(opmode, DEC);
          
          uint8_t sfstate = temp[j] >> 1;           //Bit 1        
          sfstate &=0x01;
          Serial.print(", ");
          Serial.print(sfstate, BIN);
          
          uint8_t hfstate = temp[j] & 0x01;         //Bit 0
          Serial.print(", ");
          Serial.print(hfstate, BIN);
          */

/*          uint8_t opmode = temp[j] >> 4;
          opmode &= 0x07;
          Serial.print(", ");
          Serial.print(opmode, DEC);
          uint8_t sfstate = temp[j] >> 2;
          sfstate &= 0x03;
          Serial.print(", ");
          Serial.print(sfstate, DEC);
          uint8_t hfstate = temp[j] & 0x03;
          Serial.print(", ");
          Serial.print(hfstate, DEC);  */
        }
      }
     Serial.print("\n\r");
     
    }
    else{
     error_count = 0;
     skip_count++;
    }
  }
  
  Serial.print(skip_count, DEC);
//  Serial.print(", 10 byte blocks contained an error.\n\r");
  Serial.print(", End of History.\n\r");
  myGLCD.clrScr();                                          //Clear LCD Screen
  MC_Mode = 0;
  
}
