//---------------------------------------------------------//
/* Temp & Humity sensor - DHT22                            */
//---------------------------------------------------------//
// Get temperature & humidity.  Note! Device will not return a value if called more than once every two seconds
void temperature_humidity_DHT22(){
//  bool serial_print_good_data = 0;                         //Debug Serial print
  DHT22_ERROR_t errorCode;
//  if(serial_print_good_data) Serial.print("Requesting data...");
  errorCode = myDHT22.readData();
  switch(errorCode)
  {
    case DHT_ERROR_NONE:
      Temperature_Basement = myDHT22.getTemperatureC()*9/5+32; //Celsius to Fahrenheit conversion
      Humidity_Basement = myDHT22.getHumidity();
//      if(serial_print_good_data){                           //Debug Serial print
//        Serial.print("Got Data ");
//        Serial.print(Temperature_Basement);
//        Serial.print("F ");
//        Serial.print(Humidity_Basement);
//        Serial.println("%");
//      }
      break;
    case DHT_ERROR_CHECKSUM:
//      Serial.print("check sum error ");
//      Serial.print(myDHT22.getTemperatureC());
//      Serial.print("C ");
//      Serial.print(myDHT22.getHumidity());
//      Serial.println("%");
      break;
    case DHT_BUS_HUNG:
      //Serial.println("BUS Hung ");
      break;
    case DHT_ERROR_NOT_PRESENT:
      //Serial.println("Not Present ");
      break;
    case DHT_ERROR_ACK_TOO_LONG:
      //Serial.println("ACK time out ");
      break;
    case DHT_ERROR_SYNC_TIMEOUT:
      //Serial.println("Sync Timeout ");
      break;
    case DHT_ERROR_DATA_TIMEOUT:
      //Serial.println("Data Timeout ");
      break;
    case DHT_ERROR_TOOQUICK:
      //Serial.println("Polled to quick ");
      break;
  }
}

