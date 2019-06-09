#include "dht.h"
#include <ESP8266WiFi.h>
#include <FirebaseArduino.h>
#define DHTTYPE DHT11
#define FIREBASE_HOST "smartfarm-8f129.firebaseio.com"
#define FIREBASE_AUTH "gp838AU2oGwMxQ1fYQ01ESkDoc7KoaKzWGjzeRwV"
#define WIFI_SSID "hosta"
#define WIFI_PASSWORD "sauravsinghal"
#define ANALOG_HUMID 0

#define D6_DHT 12
dht DHT;
float h;
int per, x, y, z;
float humid, soilTemp;
void setup() {
  //dht.begin();
  Serial.begin(9600);
  // connect to wifi.
  WiFi.begin(WIFI_SSID, WIFI_PASSWORD);
  Serial.print("connecting");
  while (WiFi.status() != WL_CONNECTED) {
    Serial.print(".");
    delay(500);
  }
  Serial.println();
  Serial.print("connected: ");
  Serial.println(WiFi.localIP());
  Firebase.begin(FIREBASE_HOST, FIREBASE_AUTH);
  delay(500);
}
void loop() {
  if (WiFi.status() == WL_CONNECTED) {
    h = analogRead(ANALOG_HUMID);
    per = map(h, 0, 1024, 100, 0);
    Serial.println("moisture:"+per);
    Firebase.setInt("realtime/moisture", per);
    if (Firebase.failed()) {
      Serial.println(Firebase.error());
      return;
    }
    DynamicJsonBuffer jsonBuffer;
    JsonObject& moistureObject = jsonBuffer.createObject();
    JsonObject& moisTime = moistureObject.createNestedObject("timestamp");
    moistureObject["moisture"] = per;
    moistureObject["soilTemp"]=soilTemp;
    moistureObject["humid"]=humid;
    moisTime[".sv"] = "timestamp";
    Firebase.push("store", moistureObject);
    DHT.read11(D6_DHT);
    humid=DHT.humidity;
    soilTemp=DHT.temperature;
    Firebase.setFloat("realtime/soilTemp", soilTemp);
    Firebase.setFloat("realtime/humid", humid);
    delay(1000);
  }
  else
  {
    WiFi.begin(WIFI_SSID, WIFI_PASSWORD);
    Serial.print("connecting");
    while (WiFi.status() != WL_CONNECTED) {
      Serial.print(".");
      delay(500);
    }
    Serial.println();
    Serial.print("connected: ");
    Serial.println(WiFi.localIP());
    Firebase.begin(FIREBASE_HOST, FIREBASE_AUTH);
    delay(500);
  }
}

