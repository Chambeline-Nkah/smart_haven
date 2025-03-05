#ifdef ESP32
#include <WiFi.h>
#include <HTTPClient.h>
#include <DHT.h>
#elif ESP8266
#include <ESP8266WiFi.h>
#include <ESP8266HTTPClient.h>
#endif
#include <ArduinoJson.h>

// Wi-Fi credentials
#define SSID               "Manasse Home"
#define PASSWORD           "home@2022!"

#define supabaseUrl       "https://piqibqznseldxcowxpsb.supabase.co"
#define supabaseKey       "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InBpcWlicXpuc2VsZHhjb3d4cHNiIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzUzNzMyNDAsImV4cCI6MjA1MDk0OTI0MH0.ZzAYZ9pHDIrx2sqkHgIJfUzhtHuBlfnG6hQoGx4dYnE"
#define tableName         "sensor_data"

// DHT pin number
#define DHTPIN 4
#define DHTTYPE DHT22
DHT dht(DHTPIN, DHTTYPE);


void setup()
{
  Serial.begin(115200);
  dht.begin();

  // Connect to Wi-Fi
  WiFi.begin(SSID, PASSWORD);
  Serial.print("Connecting to WiFi...");
  while (WiFi.status() != WL_CONNECTED)
  {
    delay(1000);
    Serial.print(".");
  }
  Serial.println("\nConnected to WiFi\n");
}

void loop()
{
  sendData();         // Update Record of id=1
  getData();          // Read Record of id=1
  delay(5000);        // Wait 5 Seconds
}

void sendData()
{
  if (WiFi.status() != WL_CONNECTED)
  {
    Serial.println("WiFi not connected. Attempting to reconnect...");
    while (!WiFi.reconnect())
    {
      Serial.println("Reconnecting to WiFi...");
      delay(500);
    }
    Serial.println("WiFi reconnected.");
  }
 
  // Read temperature and humidity
  float temperature = dht.readTemperature();
  float humidity = dht.readHumidity();

  // Check if readings are valid
  if (isnan(temperature) || isnan(humidity)) {
    Serial.println("Failed to read from DHT sensor!");
    return;
  }

  Serial.println("Temperature: " + String(temperature) + "°C");
  Serial.println("Humidity: " + String(humidity) + "%");

  // Create a JSON object with data
  StaticJsonDocument<200> jsonDoc;
  JsonObject data = jsonDoc.createNestedObject("data");
  data["temperature"] = temperature;
  data["humidity"] = humidity;
  jsonDoc["created_at"] = "NOW()";

  // Serialize JSON to a string
  String jsonString;
  serializeJson(jsonDoc, jsonString);

  // Send HTTP POST request to Supabase to insert a new row
#ifdef ESP32
  HTTPClient http;
  String endpoint = String(supabaseUrl) + "/rest/v1/" + tableName;
  http.begin(endpoint);
#elif ESP8266
  WiFiClientSecure client;
  client.setInsecure();
  HTTPClient http;
  String endpoint = String(supabaseUrl) + "/rest/v1/" + tableName;
  http.begin(client, endpoint);
#endif

  http.addHeader("Content-Type", "application/json");
  http.addHeader("apikey", supabaseKey);
  http.addHeader("Authorization", "Bearer " + String(supabaseKey));
  http.addHeader("Prefer", "return=representation");

  // Insert the new row
  int httpResponseCode = http.POST(jsonString);
  if (httpResponseCode > 0)
  {
    Serial.println("Data Sent:");
    String response = http.getString();
    Serial.println("HTTP Response code: " + String(httpResponseCode));
    Serial.println("Response: " + response);
  }
  else
  {
    Serial.println("Error in HTTP request");
    Serial.println("HTTP Response code: " + String(httpResponseCode));
    String response = http.getString();
    Serial.println("Response: " + response);
  }
  http.end();
}

void getData()
{
  if (WiFi.status() != WL_CONNECTED)
  {
    Serial.println("WiFi not connected. Attempting to reconnect...");
    while (!WiFi.reconnect())
    {
      Serial.println("Reconnecting to WiFi...");
      delay(500);
    }
    Serial.println("WiFi reconnected.");
  }

  // GET request
#ifdef ESP32
  HTTPClient http;
  String endpoint = String(supabaseUrl) + "/rest/v1/" + tableName + "?order=created_at.desc&limit=1"; // Get latest entry
  http.begin(endpoint);
#elif ESP8266
  WiFiClientSecure client;
  client.setInsecure();
  HTTPClient http;
  String endpoint = String(supabaseUrl) + "/rest/v1/" + tableName + "?order=created_at.desc&limit=1";
  http.begin(client, endpoint);
#endif

  http.addHeader("apikey", supabaseKey);
  http.addHeader("Authorization", "Bearer " + String(supabaseKey));

  int httpResponseCode = http.GET();
  if (httpResponseCode > 0)
  {
    Serial.println("\nReceiving:");
    String response = http.getString();
    Serial.println("HTTP Response code: " + String(httpResponseCode));
    Serial.println("Response: " + response);
  }
  else
  {
    Serial.println("Error in HTTP request");
    Serial.println("HTTP Response code: " + String(httpResponseCode));
    String response = http.getString();
    Serial.println("Response: " + response);
  }
  http.end();
  Serial.println("\n============================================\n");
}