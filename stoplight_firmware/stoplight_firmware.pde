#include <Ethernet.h>

byte mac[] = { 0x00, 0x26, 0x4a, 0x14, 0x7F, 0x9F };
byte ip[] = { 192,168,1,147 };
byte server[] = {128,122,157,177}; // itp.nyu.edu //{ 66,102,7,104 }; // Google



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
    Serial.print(c);
  }
  
  if (!client.connected()) {
    Serial.println();
    Serial.println("disconnecting.");
    client.stop();
    for(;;)
      ;
  }
}
