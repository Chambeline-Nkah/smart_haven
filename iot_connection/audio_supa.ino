#include <driver/i2s.h>
#include <DHT.h>
#include <WiFi.h>
#include <HTTPClient.h>
#include <WiFiClientSecure.h>
#include <ArduinoJson.h>
#include <SPI.h>
#include <SD.h>

// unsigned long previousSensorMillis = 0;
// unsigned long previousAudioMillis = 0;
// const long sensorInterval = 60000; // 1 minute
// const long audioInterval = 120000; // 10 minutes

// //--- DHT sensor definitions ---
// #define DHTPIN 4          
// #define DHTTYPE DHT22     
// DHT dht(DHTPIN, DHTTYPE);

#define SD_CS 5

//--- WiFi and Supabase definitions ---
const char* ssid = "Manasse Home";
const char* password = "home@2022!";

// Supabase credentials
#define supabaseUrl "https://piqibqznseldxcowxpsb.supabase.co"
#define supabaseKey "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InBpcWlicXpuc2VsZHhjb3d4cHNiIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzUzNzMyNDAsImV4cCI6MjA1MDk0OTI0MH0.ZzAYZ9pHDIrx2sqkHgIJfUzhtHuBlfnG6hQoGx4dYnE"
#define storageBucket "audio-recordings"
#define tableName "sensor_data"
#define tableName2 "recordings"


File file;
const char filename[] = "/recording.wav";

const int headerSize = 44;

void setup() {

  Serial.begin(115200);
  dht.begin();

// Connect to Wi-Fi
  WiFi.begin(ssid, password);
  Serial.print("Connecting to WiFi...");
  while (WiFi.status() != WL_CONNECTED)
  {
    delay(1000);
    Serial.print(".");
  }
  Serial.println("\nConnected to WiFi\n");


  // Initialize SD card
  if (!SD.begin(SD_CS)) {
        Serial.println("SD card initialization failed!");
        while (1);
    }
    Serial.println("SD card initialized.");
  
// Check if the file exists
  if (!SD.exists(filename)) {
      Serial.println("Recording file does not exist on SD card!");
  } else {
      Serial.println("Recording file found!");
  }

}

void loop() {
    Serial.println("Starting upload process...");
    String audioUrl = uploadAudioToSupabase();
    if (audioUrl != "") {
        sendAudioData(audioUrl);
    }
    delay(60000); // Wait 1 minute before the next upload
}


String uploadAudioToSupabase() {

  if (!SD.exists(filename)) {
        Serial.println("Error: WAV file does not exist!");
        return "";
    }

    File audioFile = SD.open(filename, "r");
    if (!audioFile) {
        Serial.println("Failed to open WAV file!");
        return "";
    }


#ifdef ESP32
    HTTPClient http;
    String filePath = "recordings/" + String(millis()) + ".wav";
    String storageEndpoint = String(supabaseUrl) + "/storage/v1/object/" + storageBucket + "/" + filePath;
    WiFiClientSecure client;
    client.setInsecure();
    http.begin(client, storageEndpoint);
#elif ESP8266
    WiFiClientSecure client;
    client.setInsecure();
    HTTPClient http;
    String filePath = "recordings/" + String(millis()) + ".wav";
    String storageEndpoint = String(supabaseUrl) + "/storage/v1/object/" + storageBucket + "/" + filePath;
    http.begin(client, storageEndpoint);
#endif

    http.addHeader("Content-Type", "application/octet-stream");
    http.addHeader("apikey", supabaseKey);
    http.addHeader("Authorization", "Bearer " + String(supabaseKey));

  //   File audioFile = SD.open(filename, "r");  // Updated to open from SD card instead of SPIFFS
  // if (!audioFile) {
  //   Serial.println("Failed to open WAV file!");
  //   return "";
  // }

    Serial.println("Uploading file...");
    size_t fileSize = audioFile.size();
    Serial.println("File size: " + String(fileSize) + " bytes");

    // Stream file upload
    int httpResponseCode = http.sendRequest("POST", &audioFile, fileSize);
    audioFile.close();

    if (httpResponseCode > 0) {
        Serial.println("Upload Success!");

        // Generate public URL, matching Flutter logic
        String publicUrl = String(supabaseUrl) + "/storage/v1/object/public/audio-recordings/" + filePath;
        Serial.println("Public URL: " + publicUrl);

        http.end();
        return publicUrl;
    } else {
        Serial.println("Upload Failed: " + String(httpResponseCode));
        http.end();
        return "";
    }
}


void sendAudioData(String audioUrl) {
#ifdef ESP32
    HTTPClient http;
    String endpoint = String(supabaseUrl) + "/rest/v1/" + tableName2;
    http.begin(endpoint);
#elif ESP8266
    WiFiClientSecure client;
    client.setInsecure();
    HTTPClient http;
    String endpoint = String(supabaseUrl) + "/rest/v1/" + tableName2;
    http.begin(client, endpoint);
#endif

    http.addHeader("Content-Type", "application/json");
    http.addHeader("apikey", supabaseKey);
    http.addHeader("Authorization", "Bearer " + String(supabaseKey));
    http.addHeader("Prefer", "return=representation");

    // Create JSON payload
    StaticJsonDocument<256> jsonDoc;
    jsonDoc["url"] = audioUrl;
    jsonDoc["status"] = "pending";  // Default status
    jsonDoc["is_from_phone"] = false;
    jsonDoc["created_at"] = "NOW()"; 

    String jsonString;
    serializeJson(jsonDoc, jsonString);

    int httpResponseCode = http.POST(jsonString);
    if (httpResponseCode > 0) {
        Serial.println("Audio Data Sent:");
        Serial.println("Response: " + http.getString());
    } else {
        Serial.println("Error sending audio data: " + String(httpResponseCode));
    }
    http.end();
}


