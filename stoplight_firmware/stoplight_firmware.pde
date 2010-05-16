#include <Ethernet.h>
#include <WString.h>

byte mac[] = { 0x00, 0x26, 0x4a, 0x14, 0x7F, 0x9F };
byte ip[] = { 192,168,1,147 };
byte server[] = {128,122,157,177}; // itp.nyu.edu //{ 66,102,7,104 }; // Google

#define maxResponseLength 1000

String response = String(maxResponseLength);

Client client(server, 80);

void setup()
{
  Ethernet.begin(mac, ip);
  Serial.begin(9600);
  
  delay(1000);
  
  Serial.println("connecting...");
  
  if (client.connect()) {
    Serial.println("connected");
    client.println("GET /~gab305/github_test_fail.html HTTP/1.0");
    client.println();
  } else {
    Serial.println("connection failed");
  }
}

void loop()
{
  if (client.available()) {
    char c = client.read();
    //Serial.print(c);
    response.append(c);
  }
  
  if (!client.connected()) {
    // TODO: change this to 412
    if(response.contains("HTTP/1.1 404")){
      if(response.contains("building")){
        Serial.println("YELLOW - 412");
      } else {
        Serial.println("RED - 412");      
      }

    } else if(response.contains("HTTP/1.1 200")){
      Serial.println("GREEN - 200");    
    }
    Serial.println();
    Serial.println("disconnecting.");
    client.stop();
    for(;;)
      ;
  }
}
