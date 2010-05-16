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
  128,122,157,177}; // itp.nyu.edu //{ 66,102,7,104 }; // Google

#define maxResponseLength 1000

String response = String(maxResponseLength);

// 0 => not connected
// 1 => connected
int notConnectedMode = 0;
int connectedMode = 1;
int mode = 0;

Client client(server, 80);

void setup()
{

  pinMode(red, OUTPUT);
  pinMode(yellow, OUTPUT);
  pinMode(green, OUTPUT);

  Ethernet.begin(mac, ip);
  // Serial.begin(9600);

  delay(1000);
}

void loop()
{
  if(mode == notConnectedMode){
    // try to connect
     // Serial.println("connecting...");
    if (client.connect()) {
      // Serial.println("connected");
      client.println("GET /~gab305/github_test_fail.html HTTP/1.0");
      client.println();
      mode = connectedMode;
    } 
    else {
      // Serial.println("connection failed");
      delay(2000);
      // Serial.println("trying again...");  
    }
   
  } 
  // in connectedMode 
  else { 
    if (client.available()) {
      char c = client.read();
      // Serial.print(c);
      response.append(c);
    }

    if (!client.connected()) {
      // TODO: change this to 412
      if(response.contains("HTTP/1.1 404")){
        if(response.contains("building")){
          // Serial.println("YELLOW - 412");
          digitalWrite(yellow, HIGH);
          delay(1000);
          digitalWrite(yellow, LOW);
        } 
        else {
          // Serial.println("RED - 412");   
          digitalWrite(red, HIGH);
          delay(1000);
          digitalWrite(red, LOW);   
        }

      } 
      else if(response.contains("HTTP/1.1 200")){
        // Serial.println("GREEN - 200");  
        digitalWrite(green, HIGH);
        delay(1000);
        digitalWrite(green, LOW);  
      }
      // Serial.println();
      // Serial.println("disconnecting.");
      client.stop();

      response = "";
      mode = notConnectedMode;
      delay(5000);
    }
  }
}

