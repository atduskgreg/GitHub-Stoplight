#include <Ethernet.h>
#include <WString.h>

int red = 2;
int yellow = 3;
int green = 4;

byte mac[] = { 
  0x00, 0x26, 0x4a, 0x14, 0x7F, 0x9F };
byte ip[] = { 
  192,168,1,147 };
byte server[] = {
  207,97,227,239}; // github.com

#define maxResponseLength 1000

String response = String(maxResponseLength);

int notConnectedMode = 0;
int connectedMode = 1;
int mode = 0;

int pingInterval = 10 * 1000;
unsigned long lastPingTime = 0;

int currentLight = red;


Client client(server, 80);

void setup()
{

  pinMode(red, OUTPUT);
  pinMode(yellow, OUTPUT);
  pinMode(green, OUTPUT);

  Ethernet.begin(mac, ip);
  Serial.begin(9600);

  delay(1000);
}

void loop()
{
  digitalWrite(currentLight, HIGH);
  
  if((millis() - lastPingTime) >= pingInterval){
    // time to ping
    doCheck(); 
  }
  
  
  
 
}

void doCheck(){
   if(mode == notConnectedMode){
    // try to connect
     Serial.println("connecting...");
    if (client.connect()) {
      Serial.println("connected");
      client.println("GET /site/stoplight/ HTTP/1.0");
      client.println();
      mode = connectedMode;
    } 
    else {
      Serial.println("connection failed");
      delay(2000);
      Serial.println("trying again...");  
    }
   
  } 
  // in connectedMode 
  else { 
    if (client.available()) {
      char c = client.read();
      Serial.print(c);
      response.append(c);
    }

    if (!client.connected()) {
      lastPingTime = millis();
      // TODO: change this to 412
      if(response.contains("HTTP/1.1 412 ")){
        if(response.contains("building")){
          Serial.println("YELLOW - 412");
          currentLight = yellow;
          digitalWrite(yellow, HIGH);
          digitalWrite(red, LOW);
          digitalWrite(green, LOW);
        } 
        else {
          Serial.println("RED - 412");   
          currentLight = red;
          digitalWrite(red, HIGH);
          digitalWrite(yellow, LOW);
          digitalWrite(green, LOW);   
        }

      } 
      else if(response.contains("HTTP/1.1 200")){
        Serial.println("GREEN - 200");  
        currentLight = yellow;
        digitalWrite(green, HIGH);
        digitalWrite(red, LOW);
        digitalWrite(yellow, LOW);
      }
      Serial.println();
      Serial.println("disconnecting.");
      client.stop();

      response = "";
      mode = notConnectedMode;
      delay(5000);
    }
  }

}
