/*
By Dave Clevenstine
Version 2 utilizes the MCP23017 IO Expander for Pushbutton inputs and relay control.
Version 3 jumped into Tabs and continued implementing the IOexpander
Version 4 blew up the LCD Arduino Remap (below), added Set points screen.
6 -> 9
5 -> 8
4 -> 7
3 -> 6
2 -> A1
Version 5 Added functions needed to support SD data logging but didn't actually implement SD due to space.
  Note: On the Atmega328, it looks like the size maximum is 28672==0x7000
Version 5p1 tries to decrease space used
Version 5p2 implemented array based data logging on the Atmel chip (no EEPROM)
Version 5p3 refined control code and heartbeat code
Version 6 Added 256kbit EEPROM power cycle counter (PCC) located at EEPROM address 0x0000.
Version 6p1 moved PCC to 0x7FFF on EEPROM and added Operating Mode recall at 0x7FFA on EEPROM.  Implemented Data logger
version 6p2 Added Outdoor temperature sensor.
Version 6p3 refined the fan control a little more and added a loop to the data log address so it would start over.  It also increased the size of the serial dump.
  -Serial EEPROM dump now unpacks the Operating_Mode, SF_State and HF_State to column 10, 11 and 12 respectively.
Version 6p4 adds error checking to Data Log
Version 7 adds the touch switch basic input.
Version 7p1 House Fan sleep switch coupled to the touch switch input.  SOFTWARE LOCKS up on 5 minutes at the 00.
Version 7p2 Fixes lock up by not using a new variable to track seconds.  Ended up breaking HF_Auto on though.
Version 7p3 Fixes the broken HF_Auto on.
Version 7p4 LED feedback from the MCP23017 for the HF Sleep timer.  Uses delay() function.  Future work: remove delay function and use interrupts instead, or utilize MCP interrupt out.  Version 7p4 works very well.
Version 8   Frees up SRAM, by removing lots of Serial.print lines
Version 8p1 Turns PCC into a 16bit variable and moved it to screen3.  Also moved HF, SF counter display to above state.
Version 8p2 Moves the sleep timer into it's own function called right before the house fan pin is set.
Version 8p3 changed outdoor temp to basement Freezer temp
Version 9   Created a Time & Date Set function!
Version 9p1
Version 10 added graphic history of temperature to LCD but would fail due to RAM max out.
Version 11 based on version 9p1 adds Thermostat monitoring to data logging but doesn't unpack it in data dump.
Version 11p1 builds on very stable v11 trying to fix data log for thermostat monitoring. (very stable!)

Notes: 
  & sets zeros, | sets ones.
*/
// Libraries
#include <MsTimer2.h>                          //Easy access to Timer2 ISR from: http://arduino.cc/playground/Main/MsTimer2
#include <OneWire.h>                           //Dallas temperature sensors (Maxim 1 wire)
#include <DallasTemperature.h>                 //Obtained from: http://www.milesburton.com/?title=Dallas_Temperature_Control_Library
#include <RGB_GLCD.h>                          //RGB LCD (the number 2 is added to access my edited .h file)
#include <DHT22.h>                             //DHT22 Temperature & Humidity Sensor
#include <Wire.h>                              //I2C Bus.  Uses SCL - A4, SDA - A5
#include <Rtc_Pcf8563.h>                       //Real-time clock calendar chip PCF8563
#include <Centipede.h>                         //16bit IO Expander MCP23017

// Arduino Pin definitions
#define DHT22_PIN A3
#define GLOBAL_STATUS_PIN 5
#define ONE_WIRE_BUS A2                        //For Maxim (Dallas) 1 Wire devices

// IO Expander Pin definitions                 //Pin on IOE [0..15]
#define SF_PIN 4
#define HF_PIN 5
#define PB1 0                                  //Pin on IOE [0..15]
#define PB2 1                                  //Pin on IOE [0..15]
#define PB3 2                                  //Pin on IOE [0..15]
#define PB4 3                                  //Pin on IOE [0..15]
#define LED_IOE 6                              //IOE Heart beat
#define TS1 7                                  //Touch switch
#define HFSLED 8                               //House Fan Sleeper LED Feedback
#define HVAC_FAN_SENSE 9                       //Thermostat Fan input
#define HVAC_AC_SENSE 10                       //Thermostat AC Compressor input
#define HVAC_HEAT_SENSE 11                     //Thermostat Heat input
#define HVAC_SPARE_SENSE 12                    //Thermostat Spare (leave flexibility for five wire systems)

// Class setups. Must be after Pin definitions!
OneWire oneWire(ONE_WIRE_BUS);                 //Setup a oneWire instance to communicate with any OneWire devices (not just Maxim/Dallas temperature ICs)
DallasTemperature sensors(&oneWire);           //Pass our oneWire reference to Dallas Temperature. 
DeviceAddress DallasThermometer0, DallasThermometer1, DallasThermometer2;  //arrays to hold device addresses
DHT22 myDHT22(DHT22_PIN);                      //Setup a DHT22 instance to communicate with the Temperature & Humidity sensor
GLCD myGLCD;                                   //Define an object myGLCD of class GLCD for LCD functions
Rtc_Pcf8563 rtc;                               //Real time clock
Centipede IOE;                                 //Create Centipede object In Out Expander (IOE)

// Global variables
bool reset_RTC = 0;                            //Flag for Real-time clock time set.  0: Don't reset time.  1: Reset time.
char brightness = 0;                           //how bright the LED is               
char fadeAmount = 3;                           //how many points to fade the LED by
unsigned char one_second_mscounter = 0;        //Holder for a flag that will increment every time the millisecond_holder gets reset
unsigned char two_second_mscounter = 0;        //Holder for a flag that will increment every time the millisecond_holder gets reset
float Temperature_Outside = 70.01;                     //Maxim Sensor Data value
float Temperature_Vent = 70.01;                        //Maxim Sensor Data value
float Temperature_Hall = 70.01;                        //Maxim Sensor Data value
float Temperature_Basement = 70.01;                    //DHT22 Sensor Data value
float Humidity_Basement = 35.00;                       //DHT22 Sensor Data value
bool PB1_State;                                //the current reading from the input pin
bool PB1_Last_State = LOW;                     //the previous reading from the input pin
bool PB2_State;                                //the current reading from the input pin
bool PB2_Last_State = LOW;                     //the previous reading from the input pin
bool PB3_State;                                //the current reading from the input pin
bool PB3_Last_State = LOW;                     //the previous reading from the input pin
bool PB4_State;                                //the current reading from the input pin
bool PB4_Last_State = LOW;                     //the previous reading from the input pin
bool TS1_State;                                //the current reading from the input pin
bool TS1_Last_State = LOW;                     //the previous reading from the input pin
bool HVAC_FAN;                                 //State of the house fan read from the thermostat wires
bool HVAC_AC;                                  //State of the Furnace AC Compressor read from the thermostat wires
bool HVAC_HEAT;                                //State of the Furnace Heater read from the thermostat wires
bool HVAC_SPARE;                               //State of the house fan read from the thermostat wires
uint8_t Operating_Mode = 0;                        //Variable to be incremented by PB1
uint8_t SF_Mode = 0;                               //Variable to be incremented by PB2
uint8_t HF_Mode = 0;                               //Variable to be incremented by PB3
uint8_t MC_Mode = 0;                               //Variable to be incremented by PB4
uint8_t RC_Mode = 0;                               //Variable to be incremented by TS1
char* Operating_Mode_Names[]={"Off", "Man.", "Autoff", "Auto"};       //Assign names to the modes
char* SF_Mode_Names[]={"Off", "On", "3"};      //Assign names to the modes
char* HF_Mode_Names[]={"Off", "On", "3", "4"}; //Assign names to the modes
bool Auto_Off_Flag = 0;                        //Flag for marking when the vent temp goes above 85 for auto off enable
bool PB1_Flag = 0;                             //Used to controll variable incrementing
bool PB2_Flag = 0;                             //Used to controll variable incrementing
bool PB3_Flag = 0;                             //Used to controll variable incrementing
bool PB4_Flag = 0;                             //Used to controll variable incrementing
bool TS1_Flag = 0;                             //Used to controll variable incrementing
bool PB1_enable = 1;                           //Used to enable/disable input
bool PB2_enable = 0;                           //Used to enable/disable input
bool PB3_enable = 0;                           //Used to enable/disable input
bool PB4_enable = 1;                           //Used to enable/disable input
bool TS1_enable = 1;                           //Used to enable/disable input
bool PB_global_state_change = 0;               //Used to keep track of if ANY button has been pressed so LCD can be properly updated
bool high_to_low_temp_flag = 0;                //Used to clear a line when the temp drops below 100 for vent temp.
bool IOE_Heartbeat = 1;                        //Holds the state of the LED
bool sleep_timer_flag = 0;                     //used to reset sleeper_seconds the first time through the function
uint16_t sleeper_seconds = 0;                  //counts seconds.
uint8_t minute_last;                               //holds last recorded minute from the real time clock.  Used to make sure we only record data when it changes.
uint8_t minutes;
uint8_t log_every;
uint8_t DL_Error;                                  //keeps track of # of errors trying to write to the current bank (bank = 10byte slot whose 1st byte is at DL_Address)

uint8_t AutoOff_VentAbove = 95;                    //In Auto Off Mode: Turn Stove Fan on if Vent temp is above
uint8_t AutoOff_VentBelow = 90;                    //In Auto Off Mode: Turn Stove Fan off if Vent temp is below
uint8_t AutoSF_VentBelow = 78;                     //In Auto Mode: Turn Stove fan off if Vent temp is below
uint8_t AutoSF_HallAbove = 75;                     //In Auto Mode: Turn Stove fan off if Hall Temp is above
uint8_t AutoSF_VentAbove = 88;                     //In Auto Mode: Turn Stove fan on if Vent temp is above
uint8_t AutoHF_VentAbove = 120;                    //In Auto Mode: Turn House fan on if Vent temp is above YY and
uint8_t AutoHF_HallAbove = 72;                     //In Auto Mode: Turn House fan on if Hall temp is above XX and

unsigned int AutoHF_seconds = 0;                        //Seconds elapsed since HF on.
unsigned int AutoSF_seconds = 0;
bool first_loops = 1;                              //Used to force stove fan off first time through loop.

uint8_t clocksetter = 0;    //rtc functions return "byte"
uint8_t clocksetter_next = 0;
bool Hold_RTC = 1;
  uint8_t set_year = 0;
  uint8_t set_month = 0;    //rtc functions return "byte"
  uint8_t set_day = 0;      //returns day of the month.  rtc.getWeekday() returns day of the week.
  uint8_t set_hour = 0;
  uint8_t set_minutes = 0; 
  char* clock_set_names[]={"Year", "Month", "Day  ", "Hour ", "Minute", "  "};       //Assign names to the modes

//---------------------------EEPROM
char chipAdress=0x50;        // Binary 10100000 . Three bits after 1010 (currently 000) are used to specify to what A2, A1, A0 are connected to, ground or vcc. See comment above.
			    // Last bit specifies the opertation - 0 for write, 1 for read. This is controlled for you by the Wire library. :)
//int block = 0;
uint16_t PCC;               //Power Cycle Counter
uint16_t DL_Address;        //Next address to write Data log to.  Range 0x0000 - 0x7F6B
uint16_t SS_Address;        //Next address to write 128point storage to.  Range 0x7F6C - 0x7FEC
//---------------------------EEPROM

/*Timer2 Overlflow*******************************************
Any code placed in timer2_overflow() will be executed every at the frequency set in the the setup portion of the code*/
void timer2_overflow() {
  //Counters-------------------------------------------------
  one_second_mscounter++;                                  //increments the variable for the 1+ second loop
  two_second_mscounter++;                                  //Increments the variable for the 2 second loop
  //Global Status Indicator----------------------------------
  analogWrite(GLOBAL_STATUS_PIN, int(brightness));         // set the brightness of the Global Status Pin:
  if (Operating_Mode != 0){
    brightness = brightness + fadeAmount;                    // change the brightness for next time through the loop:
    if (brightness < 1 || brightness > 254)                  // reverse the direction of the fading at the ends of the fade: 
      fadeAmount = -fadeAmount ;          
  }    
  //Any other code can be placed here.


}
//***********************************************************


/***********************************************************/
/*                       SETUP                             */
/***********************************************************/
void setup()  { 
  Serial.begin(19200);                                       //For Serial Communication
  Serial.print("\r\nStarting...\n\r");                               //For debug

  myGLCD.initLCD();                                         //Initialize LCD
  MsTimer2::set(30, timer2_overflow);                       //(30ms period, function call) function is located above void setup()
  MsTimer2::start();                                        //Starts Interrupt service routine
  IOE.initialize();                                          //Set all registers to default
  
  sensors.begin();                                          //For Maxim 1 Wire temperature sensors
  sensors.setWaitForConversion(0);                          //For Maxim 1 Wire. When 0 request.Temperature() function returns conversion immediately
  if (!sensors.getAddress(DallasThermometer0, 0)) Serial.println("Unable to find address for Thermometer 0"); 
  if (!sensors.getAddress(DallasThermometer1, 1)) Serial.println("Unable to find address for Thermometer 1"); 
  if (!sensors.getAddress(DallasThermometer2, 2)) Serial.println("Unable to find address for Thermometer 2"); 
 
  pinMode(GLOBAL_STATUS_PIN, OUTPUT);                       //Sets output mode for Global Status pin
  
  IOE.pinMode(PB1, INPUT);
  IOE.pinMode(PB2, INPUT);
  IOE.pinMode(PB3, INPUT);
  IOE.pinMode(PB4, INPUT);
  IOE.pinMode(TS1, INPUT);
  IOE.pinMode(SF_PIN, OUTPUT);                                   //Set Centipede pin 4 to output
  IOE.pinMode(HF_PIN, OUTPUT);                                   //Set Centipede pin 5 to output
  IOE.pinMode(LED_IOE, OUTPUT);  
  IOE.pinMode(HFSLED, OUTPUT);
  IOE.pinMode(HVAC_FAN_SENSE, INPUT);
  IOE.pinMode(HVAC_AC_SENSE, INPUT);
  IOE.pinMode(HVAC_HEAT_SENSE, INPUT);
  IOE.pinMode(HVAC_SPARE_SENSE, INPUT);
  
  IOE.digitalWrite(SF_PIN, LOW);                                //Start Stove fan off
  IOE.digitalWrite(HF_PIN, LOW);                                //Start House fan off
  IOE.digitalWrite(HFSLED, LOW);                                //Start House Fan Sleep timer LED feedback off.
  
  myGLCD.setColor(0, 255, 255);                             //Sets color for subsequent LCD print lines
  myGLCD.clrScr();                                          //Clear LCD Screen

  if(reset_RTC){                                            //set a time to start the Real-time Clock Calendar chip with
    rtc.initClock();                                        //clear out the registers
    rtc.setDate(19, 1, 2, 0, 12);                           //day, weekday(sun=1), month, century(1=1900, 0=2000), year(0-99)
    rtc.setTime(20, 31, 30);                                 //hr, min, sec
  }
  
  
  //----------EEPROM------------------------------------------------------------------------------------------------------------------------------
 
  //++++++++++Power Cyle Counter++++++++++++++++++++++++++++++++++++++++++++
  Serial.print("Updating PCC from ");
  byte temp[2];
  
  // Get last power cycle counter value.....................................
  Wire.beginTransmission(chipAdress);    // chip address on the TWI bus, not chip memory address
  //Set up the chip Internal Address Pointer to the beginning of memory
  Wire.send(0x7F);   //Address MSB   
  Wire.send(0xF8);   //Address LSB
  Wire.endTransmission(); // sends Wire buffer to chip, sets Internal Address Pointer to '0'
  int i = 0;
  Wire.requestFrom(chipAdress, 2);          // requests up to 32 Bytes of data in a packet, maximum string size.
    while(Wire.available()){                   // 'while loop' start, Checks to see if data is waiting      
      temp[i] = Wire.receive();     
      i++;
    }                                // end bracket for 'while loop'
  Wire.endTransmission();

  // Merge PCC_MSB & PCC_LSB onto PCC........................................  
  PCC = temp[0] << 8;
  PCC |= temp[1];    
  Serial.print(PCC, DEC);  // print the values received on the serial monitor 
  Serial.print(" to ");
  PCC++;                   // Create new power cycle counter value
  Serial.print(PCC, DEC);

  //Update EEPROM with new power cycle count..................................
  Wire.beginTransmission(chipAdress);    // chip address on the TWI bus, not chip memory address
  //Set up the chip Internal Address Pointer to the beginning of memory
  Wire.send(0x7F);      //Address MSB
  Wire.send(0xF8);      //Address LSB
  Wire.send(highByte(PCC));
  Wire.send(lowByte(PCC));
  Wire.endTransmission(); // sends Wire buffer to chip, sets Internal Address Pointer to '0'

  //++++++++++Mode Recal+++++++++++++++++++++++++++++++++++++++++++++++++++++++
  // get last operating mode
  Serial.print(". \n\rMode Recal = ");
  if(1){ //setting to zero didn't allow board to load/boot properly last time.  Hung after "Starting..."
    Wire.beginTransmission(chipAdress);    // chip address on the TWI bus, not chip memory address
    //Set up the chip Internal Address Pointer to the beginning of memory
    Wire.send(0x7F);   //Address MSB   
    Wire.send(0xFA);   //Address LSB
    Wire.endTransmission(); // sends Wire buffer to chip, sets Internal Address Pointer to '0'
    
    Wire.requestFrom(chipAdress, 1);          // requests up to 32 Bytes of data in a packet, maximum string size.
    while(Wire.available()){                // 'while loop' start, Checks to see if data is waiting
      Serial.print(" ");    // space to format packets on serial monitor
      Operating_Mode = Wire.receive();
      Serial.print(Operating_Mode, DEC);  // print the values received on the serial monitor
    }                                    // end bracket for 'while loop'
    Wire.endTransmission();   
  }
  //else Serial.print("Disabled");
    
  //+++++++++++Zero Out Mmemory Pointers UTILITY ONLY++++++++++++++++++++++++++++
//    Wire.beginTransmission(chipAdress);    // chip address on the TWI bus, not chip memory address
//    //Set up the chip Internal Address Pointer to the beginning of memory
//    Wire.send(0x7F);                       //Memory Address MSB
//    Wire.send(0xFB);                       //Memory Address LSB
//    Wire.send(0);                          //Contents of 0x7FFB  SS_Address_MSB
//    Wire.send(0);                          //Contents of 0x7FFC  SS_Address_LSB
//    Wire.send(0);                          //Contents of 0x7FFD  DL_Address_MSB
//    Wire.send(0);                          //Contents of 0x7FFE  DL_Address_LSB
//    Wire.endTransmission(); // sends Wire buffer to chip, sets Internal Address Pointer to '0'

  //-----------EEPROM------------------------------------------------------------------------------------------------------------------
     
  Serial.print(". \n\rSetup Complete.\r\n");                       //Debug
} 


