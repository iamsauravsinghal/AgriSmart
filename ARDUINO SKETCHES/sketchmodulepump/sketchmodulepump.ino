#include <ESP8266WiFi.h>
#include <FirebaseArduino.h>
#define FIREBASE_HOST "smartfarm-8f129.firebaseio.com"
#define FIREBASE_AUTH "gp838AU2oGwMxQ1fYQ01ESkDoc7KoaKzWGjzeRwV"
#define WIFI_SSID "hosta"
#define WIFI_PASSWORD "sauravsinghal"
#define D6_WATERPIN 12
#define D7_PUMPIN 13
#define D0_PINGPIN 16 //trigger
#define D1_ECHOPIN 5 //echo
int st = HIGH, st1 = HIGH;
int x, y, z;
long duration, cm;
void setup() {
  Serial.begin(9600);
  pinMode(D7_PUMPIN, OUTPUT);
  pinMode(D6_WATERPIN, OUTPUT);
  digitalWrite(D7_PUMPIN, st);
  digitalWrite(D6_WATERPIN, st1);
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
long microsecondsToCentimeters(long microseconds) {
  return microseconds / 29 / 2;
}
void loop() {
  if (WiFi.status() == WL_CONNECTED) {
    pinMode(D0_PINGPIN, OUTPUT);
    pinMode(D1_ECHOPIN, INPUT);
    digitalWrite(D0_PINGPIN, LOW);
    delayMicroseconds(2);
    digitalWrite(D0_PINGPIN, HIGH);
    delayMicroseconds(10);
    digitalWrite(D0_PINGPIN, LOW);
    duration = pulseIn(D1_ECHOPIN, HIGH);
    cm=duration*0.034/2;
    Serial.println(cm+"%");
    Firebase.setInt("realtime/water", cm);
    if (Firebase.failed()) {
      Serial.println(Firebase.error());
      return;
    }
    x = Firebase.getFloat ("realtime/moisture");
    Serial.println(x);
    y = Firebase.getInt("realtime/status");
    if (y == 1 && st == HIGH)
    {
      st = LOW;
      digitalWrite(D7_PUMPIN, st);
      delay(100);
    }
    else if (y == 0 && st == LOW)
    {
      st = HIGH;
      digitalWrite(D7_PUMPIN, st);
    }
    z = Firebase.getInt("realtime/wtstatus");
    if (z == 1 && st1 == HIGH)
    {
      st1 = LOW;
      digitalWrite(D6_WATERPIN, st1);
    }
    else if (z == 0 && st1 == LOW)
    {
      st1 = HIGH;
      digitalWrite(D6_WATERPIN, st1);
    }
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

