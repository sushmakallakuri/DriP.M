#include<Metro.h>
#include "WiFi.h"
#include <FirebaseESP32.h>
#include<EEPROM.h>
#include <Servo.h>
#include<string.h>
#include <SPI.h>
#include <Wire.h>
#include <Adafruit_GFX.h>
#include <Adafruit_SSD1306.h>
#include <Preferences.h>

#define FIREBASE_HOST "mydrip-1b87b.firebaseio.com"
#define FIREBASE_AUTH "pKrCyAzqhnzcck1IRWRthC8qDdILTHhllP4JPMPG"

#define SCREEN_WIDTH 128
#define SCREEN_HEIGHT 64
#define OLED_RESET -1
#define Oled_SDA 21
#define Oled_SCL 22
#define Mac_ID 123456
#define START  4
#define RESET  3
#define SET  12
#define SETVOL  5
#define IR 13
#define buzz 14
#define dripper 27

#if defined(ARDUINO_ARCH_ESP8266)
#include <ESP8266WiFi.h>
#include <ESP8266WebServer.h>
#elif defined(ARDUINO_ARCH_ESP32)
#include <WiFi.h>
#include <WebServer.h>
#endif
#include <AutoConnect.h>
#include <AutoConnectCredential.h>
#include <PageBuilder.h>

#if defined(ARDUINO_ARCH_ESP8266)
ESP8266WebServer Server;
#elif defined(ARDUINO_ARCH_ESP32)
WebServer Server;
#endif

AutoConnect      Portal(Server);
String viewCredential(PageArgument&);
String delCredential(PageArgument&);

#define CREDENTIAL_OFFSET 0
//#define CREDENTIAL_OFFSET 64
static const char PROGMEM html[] = R"*lit(
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8" name="viewport" content="width=device-width, initial-scale=1">
  <style>
  html {
  font-family:Helvetica,Arial,sans-serif;
  -ms-text-size-adjust:100%;
  -webkit-text-size-adjust:100%;
  }
  .menu > a:link {
    position: absolute;
    display: inline-block;
    right: 12px;
    padding: 0 6px;
    text-decoration: none;
  }
  </style>
</head>
<body>
<div class="menu">{{AUTOCONNECT_MENU}}</div>
<form action="/del" method="POST">
  <ol>
  {{SSID}}
  </ol>
  <p>Enter deleting entry:</p>
  <input type="number" min="1" name="num">
  <input type="submit">
</form>
</body>
</html>
)*lit";

static const char PROGMEM autoconnectMenu[] = { AUTOCONNECT_LINK(BAR_24) };

// URL path as '/'
PageElement elmList(html,
  {{ "SSID", viewCredential },
   { "AUTOCONNECT_MENU", [](PageArgument& args) {
                            return String(FPSTR(autoconnectMenu));} }
  });
PageBuilder rootPage("/", { elmList });

// URL path as '/del'
PageElement elmDel("{{DEL}}", {{ "DEL", delCredential }});
PageBuilder delPage("/del", { elmDel });

String viewCredential(PageArgument& args) {
  AutoConnectCredential  ac(CREDENTIAL_OFFSET);
  struct station_config  entry;
  String content = "";
  uint8_t  count = ac.entries();          // Get number of entries.

  for (int8_t i = 0; i < count; i++) {    // Loads all entries.
    ac.load(i, &entry);
    // Build a SSID line of an HTML.
    content += String("<li>") + String((char *)entry.ssid) + String("</li>");
  }

  // Returns the '<li>SSID</li>' container.
  return content;
}

String delCredential(PageArgument& args) {
  AutoConnectCredential  ac(CREDENTIAL_OFFSET);
  if (args.hasArg("num")) {
    int8_t  e = args.arg("num").toInt();
    Serial.printf("Request deletion #%d\n", e);
    if (e > 0) {
      struct  station_config entry;

      // If the input number is valid, delete that entry.
      int8_t  de = ac.load(e - 1, &entry);  // A base of entry num is 0.
      if (de > 0) {
        Serial.printf("Delete for %s ", (char *)entry.ssid);
        Serial.printf("%s\n", ac.del((char *)entry.ssid) ? "completed" : "failed");

        Server.sendHeader("Location", String("http://") + Server.client().localIP().toString() + String("/"));
        Server.send(302, "text/plain", "");
        Server.client().flush();
        Server.client().stop();

        // Cancel automatic submission by PageBuilder.
        delPage.cancel();
      }
    }
  }
  return "";
}

TaskHandle_t Task2;

FirebaseData firebaseData;

void printJsonObjectContent(FirebaseData &data);

Servo servo;

Metro voltime = Metro(5000);

Adafruit_SSD1306 display(SCREEN_WIDTH, SCREEN_HEIGHT, &Wire, OLED_RESET);

bool flowstate=true;
bool mobilestate;
int pre = 0;
bool preFlow;
int pre1 = 0;
int pre2 = 0;
int count1 = 0;
int count2 = 0;
int dval = 0;
int count = 0;
int con = 1;
float vol = 0;
float amount = 0;
float time1;
int prev = 0;
int starts = 0;
int setvalue1 = 0;
int startvalue = 0;
int resetvalue = 0;
int setvalue = 0;
int totvol = 100;
int prevc = 0;
int setvol = 0;
int pre3 = 0;
int latest = 1;
String ssid, pass;
int flowcon = 0;
String bedNo = "104";

void setup() {
  Serial.begin(9600);
  delay(1000);
  pinMode(2, OUTPUT);
  initialize_Buttons();
  initilize_Display();
  initilize_Firebase();
  initilize_Servo();
  initilize_Wifi();
  initilize_Smartconnect();
  Firebase.begin(FIREBASE_HOST, FIREBASE_AUTH);
  starts = EEPROM.read(0);
  count = EEPROM.read(5);
  Serial.println("hoihoi:");
Serial.println(starts);
Serial.println("hoihoi:");
Serial.println(count);
  xTaskCreatePinnedToCore(
    Task2code,   /* Task function. */
    "Task2",     /* name of task. */
    10000,       /* Stack size of task */
    NULL,        /* parameter of the task */
    1,           /* priority of the task */
    &Task2,      /* Task handle to keep track of created task */
    1);          /* pin task to core 1 */
  delay(500);

}
/*
  Harsha function for displaying starts
*/
void shaw(float volume , float speed1, float time1)
{ Serial.print("Display function");
  display.clearDisplay();
  display.setCursor(0, 0);
  display.setTextSize(3);
  display.print(volume, 1);
  display.setTextSize(2);
  display.setCursor(80, 8);
  display.print("ml");
  display.setCursor(0, 40);
  display.setTextSize(2);
  display.println(speed1, 1);
  display.setTextSize(1);
  display.print("ml/hr");
  display.setCursor(60, 40);
  display.setTextSize(2);
  display.println(time1, 1);
  display.setTextSize(1);
  display.setCursor(60, 55);
  display.print("min");
  display.display();
}
//###################################
void setscreen(int speed1)
{
  display.clearDisplay();
  display.setCursor(0, 0);
  display.setTextSize(2);
  display.println("Set Volume");
  display.setTextSize(3);
  display.print(speed1);
  display.display();
}
/*
   Harsha function for display ends
*/
void initialize_Buttons()
{
  pinMode(START, INPUT_PULLUP);
  pinMode(RESET, INPUT_PULLUP);
  pinMode(SET, INPUT_PULLUP);
  pinMode(SETVOL, INPUT_PULLUP);
  pinMode(IR, INPUT);
  pinMode(buzz, OUTPUT);
  pinMode(dripper, INPUT);
}

void initilize_Display()
{ if (!display.begin(SSD1306_SWITCHCAPVCC, 0x3C)) { // Address 0x3C for 128x32
    Serial.println(F("SSD1306 allocation failed"));
    // Don't proceed, loop forever
  }
  //void setAutoTransitionBackwards();
  //  display.setContrast(255);
  display.clearDisplay();
  display.drawPixel(10, 10, WHITE);
  display.setTextSize(2);             // Normal 1:1 pixel scale
  display.setTextColor(WHITE);        // Draw white text
  display.clearDisplay();
  display.setTextSize(2);
  display.setCursor(16 ,16);
  display.println("COMRADES");
  display.display();
  delay(2000);
  display.clearDisplay();
  display.display();
  Serial.print("Screen Test");
  //  display.drawLogBuffer(0, 0);
  //  display.display();
}

void initilize_Firebase()
{

}

void initilize_Servo()
{
  servo.attach(2);

}

void initilize_Wifi()
{

}

void initilize_Smartconnect()
{

}

void read_Button_state()
{
  startvalue = digitalRead(START);
  resetvalue = digitalRead(RESET);
  setvalue = digitalRead(SET);
  setvol = digitalRead(SETVOL);
}

void check_Button_state()
{ /*
    Cheching For Start Button To be Pressed
  */
  if (startvalue == LOW && pre == 0)
  { Serial.print("Start entered");
    pre = 1;
    display.clearDisplay();
    display.setTextSize(3);
    display.setCursor(16, 16);
    display.println("START ");
    display.display();
    delay(1000);
    display.clearDisplay();
    starts = 1;
    shaw(vol, amount, time1);
    EEPROM.write(0, (byte)1);
    EEPROM.commit();
    flowstate = true;
    //Firebase.setBool(firebaseData, "/patients/"+bedNo+"/state", flowstate);
    //pass('z',1);
  }
  /*
    If Start Button Not pressed
  */
  if (startvalue == HIGH && pre == 1)
  {
    pre = 0;
  }
  /*
     If Reset Button is pressed
  */
  if (resetvalue == LOW && pre1 == 0)
  {
    servo.write(0);
    digitalWrite(buzz, LOW);
    pre1 = 1;
    display.setTextSize(3);
    display.clearDisplay();
    display.setCursor(16, 16);
    display.println("RESET");
    Serial.println("RESET");
    display.display();
    delay(1000);
    display.clearDisplay();
    display.display();
    display.setTextSize(2);
    display.setCursor(16, 5);
    display.println("  Press");
    display.println();
    display.println("   Start");
    display.display();
    display.clearDisplay();
    starts = 0;
    dval = 0;
    count = 0;
    con = 1;
    vol = 0;
    amount = 0;
    time1 = 0;
    prev = 0;
    flowstate = true;
    for (int i = 0 ; i < EEPROM.length() ; i++) {
      if (EEPROM.read(i) != 0)
      {
        EEPROM.write(i, 0);
      }
    }
    //Firebase.setBool(firebaseData, "/patients/"+bedNo+"/state", flowstate);
  }
  /*
     If Reset Button is not pressed
  */
  if (resetvalue == HIGH && pre1 == 1)
  {
    pre1 = 0;
  }
  /*
     If Set Value Button is pressed
  */
  if (setvalue == LOW && pre2 == 0)
  { display.setTextSize(2);
    pre2 = 1;
    Serial.print(count1);
    if (count1 % 3 == 0)
    {
      Serial.println("10ml/hr");
      setscreen(10);
      setvalue1 = 10;
    }
    else if (count1 % 3 == 1)
    {
      Serial.println("30ml/hr");
      setscreen(30);
      setvalue1 = 30;
    }
    else if (count1 % 3 == 2)
    {
      Serial.println("50ml/hr");
      setscreen(50);
      setvalue1 = 50;
    }
    count1 = count1 + 1;
  }
  /*
     If Setvalue is not pressed
  */
  if (setvalue == HIGH && pre2 == 1)
  {
    pre2 = 0;
  }
  /*
    If Set Volume Button is pressed
  */
  if (setvol == LOW && pre3 == 0)
  {
    display.setTextSize(2);
    pre3 = 1;
    if (count2 % 3 == 0)
    {
      Serial.println("100ml");
      setscreen(100);
      totvol = 100;
    }
    else if (count2 % 3 == 1)
    {
      Serial.println("250ml");
      setscreen(250);
      totvol = 250;
    }
    else if (count2 % 3 == 2)
    {
      Serial.println("500ml");
      setscreen(500);
      totvol = 500;
    }
    count2 = count2 + 1;
  }
  /*
    If Set volume is not pressed
  */
  if (setvol == HIGH && pre3 == 1)
  {
    pre3 = 0;
  }
}
void check_start_state()
{
  if (starts == 1)
  {
    dval = digitalRead(dripper);
    if (dval == LOW && con == 1)
    {

      ++count;
      Serial.println(count);
      vol = ((float)count) / 20;
      shaw(vol, amount, time1);
      con = 0;
    }
    if (dval == HIGH && con == 0)
    {
      con = 1;
    }
    if (vol == totvol)
    {
      prevc = count;
    }

    if ((vol > totvol) || (latest == 0))
    {
      //servo.write(60 + count - prevc);
      //flowstate = false;
      digitalWrite(buzz, HIGH);
      delay(100);

    }
    if(mobilestate==true){
    if (digitalRead(IR) == HIGH)
    {
      digitalWrite(buzz, LOW);
     // servo.write(60);
      flowstate = true;
    }
    else
    {
      digitalWrite(buzz, HIGH);
      //servo.write(0);
      flowstate = false;
    }
    }
  }
}

void Button_Check()
{ /*Check for the Selected Button
    Check for the Start Button
    Do The messuring calculation
  */
  read_Button_state();
  check_Button_state();
  check_start_state();

}

void Safe_Check()
{

}

void Task2code( void * pvParameters ) {
  delay(1000);
  rootPage.insert(Server);    // Instead of Server.on("/", ...);
  delPage.insert(Server);     // Instead of Server.on("/del", ...);

  // Set an address of the credential area.
  AutoConnectConfig Config;
  Config.boundaryOffset = CREDENTIAL_OFFSET;
  Portal.config(Config);

  // Start
  if (Portal.begin()) {
    Serial.println("WiFi connected: " + WiFi.localIP().toString());
    display.clearDisplay();
    display.setTextSize(2);
    display.setCursor(16 ,16);
    display.println("  WiFi");
    display.println(" Connected");
    display.display();
    delay(2000);
    display.clearDisplay();
    display.display();
    display.setTextSize(2);
    display.setCursor(16, 5);
    display.println("  Press");
    display.println();
    display.println("   Start");
    display.display();
    display.clearDisplay();
    //display.println("SHAW");
  }
  int b = 0;
   Portal.handleClient();
  while (true) {
   
    delay(500);
    if(starts == 1){
      Serial.println("############################################");
       Firebase.setBool(firebaseData, "/patients/"+bedNo+"/state", flowstate);
      Firebase.setString(firebaseData, "/patients/"+bedNo+"/Vol",String(vol));
      Serial.print(totvol - vol);
      Firebase.setString(firebaseData, "/patients/"+bedNo+"/percent",String(totvol)) ;
      Serial.print(totvol);
      Firebase.setString(firebaseData, "/patients/"+bedNo+"/estime",String(time1 ));
      Serial.print(time1);
      Firebase.setString(firebaseData, "/patients/"+bedNo+"/flow",String(amount ));
      Serial.print(amount);
      if(Firebase.getBool(firebaseData, "/patients/"+bedNo+"/state")){
        preFlow = flowstate;
        flowstate = firebaseData.boolData();
        
          if(flowstate==false)
          {
            mobilestate=false;
            }
            else{
              mobilestate=true;
              
              }
          
        
      }
      if(Firebase.getString(firebaseData, "/patients/"+bedNo+"/speed")){
        setvalue1 = (firebaseData.stringData()).toInt();
      }
      Serial.println(flowstate);
      Serial.println(setvalue1);
    }
    
  }
}


void loop() {

  Button_Check();
  if (voltime.check() == 1 && starts == 1)
  {
    amount = (((float)(count - prev)) / 20) * 12;
    if (amount == 0)
    {
      time1 = 0;
    }
    else
    {
      //time1 = 20 * 4 * (totvol - vol) / ((((float)(count - prev) * 60)));
      time1 = (totvol - vol) / amount;
    }
    Serial.print(amount);
    Serial.print("ml/min      time left to empty bottle :");
    Serial.print(time1);
    Serial.println("min");
    Serial.println(prev);
    Serial.println(count);
    Serial.println(amount);
    Serial.println(time1);
    EEPROM.write(5, (byte)count);
    EEPROM.commit();
    prev = count;
  }

  if(flowstate == false && flowcon == 0){
    flowcon = 1;
    prevc = count;
  }
  if(flowstate == false){
    servo.write(175 + count - prevc);
    //Firebase.setBool(firebaseData, "/patients/"+bedNo+"/state", flowstate);
  }
  else{
    //Firebase.setBool(firebaseData, "/patients/"+bedNo+"/state", flowstate);
    flowcon = 0;
    servo.write(0);
  }

}
