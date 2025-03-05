#include <driver/i2s.h>
#include <DHT.h>
#include <WiFi.h>
#include <HTTPClient.h>
#include <WiFiClientSecure.h>
#include <ArduinoJson.h>
#include <SPI.h>
#include <SD.h>


//--- DHT sensor definitions ---
#define DHTPIN 4          
#define DHTTYPE DHT22     
DHT dht(DHTPIN, DHTTYPE);

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

// Audio Sensor Variables
#define I2S_WS 25
#define I2S_SD 32
#define I2S_SCK 33
#define I2S_PORT I2S_NUM_0
#define I2S_SAMPLE_RATE   (16000)
#define I2S_SAMPLE_BITS   (16)
#define I2S_READ_LEN      1024
#define RECORD_TIME       (20) //Seconds
#define I2S_CHANNEL_NUM   (1)
#define RECORD_SIZE (I2S_CHANNEL_NUM * I2S_SAMPLE_RATE * I2S_SAMPLE_BITS / 8 * RECORD_TIME)

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
  
  i2sInit();
  // Create task for audio recording
  xTaskCreatePinnedToCore(i2s_adc, "i2s_adc", 8192, NULL, 1, NULL, 1);

// Check if the file exists
  if (!SD.exists(filename)) {
      Serial.println("Recording file does not exist on SD card!");
  } else {
      Serial.println("Recording file found!");
  }

}


void loop() {
    sendData();         // Update Record of id=1
    getData();

    Serial.println("Starting upload process...");
    String audioUrl = uploadAudioToSupabase();
    if (audioUrl != "") {
        sendAudioData(audioUrl);
    }
    delay(60000); // Wait 1 minute before the next upload
}


void i2sInit(){
  i2s_config_t i2s_config = {
    .mode = (i2s_mode_t)(I2S_MODE_MASTER | I2S_MODE_RX),
    .sample_rate = I2S_SAMPLE_RATE,
    .bits_per_sample = i2s_bits_per_sample_t(I2S_SAMPLE_BITS),
    .channel_format = I2S_CHANNEL_FMT_ONLY_LEFT,
    .communication_format = i2s_comm_format_t(I2S_COMM_FORMAT_I2S | I2S_COMM_FORMAT_I2S_MSB),
    .intr_alloc_flags = 0,
    .dma_buf_count = 64,
    .dma_buf_len = 1024,
    .use_apll = 1
  };

  i2s_driver_install(I2S_PORT, &i2s_config, 0, NULL);

  const i2s_pin_config_t pin_config = {
    .bck_io_num = I2S_SCK,
    .ws_io_num = I2S_WS,
    .data_out_num = -1,
    .data_in_num = I2S_SD
  };

  i2s_set_pin(I2S_PORT, &pin_config);
}

void i2s_adc(void *arg) {
    int i2s_read_len = I2S_READ_LEN;
    int flash_wr_size = 0;
    size_t bytes_read;

    static char i2s_read_buff[I2S_READ_LEN];
    static uint8_t flash_write_buff[I2S_READ_LEN];

    Serial.println(" *** Recording Start *** ");

    // Open file on SD card
    file = SD.open(filename, FILE_WRITE);
    if (!file) {
        Serial.println("Failed to open file on SD card!");
        vTaskDelete(NULL);
        return;
    }

    // Write WAV header
    byte header[headerSize];
    wavHeader(header, RECORD_SIZE);
    file.write(header, headerSize);

    while (flash_wr_size < RECORD_SIZE) {
        i2s_read(I2S_PORT, (void*)i2s_read_buff, i2s_read_len, &bytes_read, portMAX_DELAY);
        
        if (bytes_read > 0) {
            i2s_adc_data_scale(flash_write_buff, (uint8_t*)i2s_read_buff, i2s_read_len);
            file.write((const byte*)flash_write_buff, i2s_read_len);
            flash_wr_size += i2s_read_len;
            Serial.printf("Recording %u%% complete\n", (flash_wr_size * 100) / RECORD_SIZE);
        } else {
            Serial.println("I2S read error");
        }
    }

    file.close();

    Serial.println(" *** Recording Finished *** ");
    vTaskDelete(NULL);
}

void i2s_adc_data_scale(uint8_t * d_buff, uint8_t* s_buff, uint32_t len) {
    uint32_t j = 0;
    uint32_t dac_value = 0;
    for (int i = 0; i < len; i += 2) {
        dac_value = ((((uint16_t) (s_buff[i + 1] & 0xf) << 8) | ((s_buff[i + 0]))));
        d_buff[j++] = 0;
        d_buff[j++] = dac_value * 256 / 2048;
    }
}

void wavHeader(byte* header, int wavSize) {
  header[0] = 'R';
  header[1] = 'I';
  header[2] = 'F';
  header[3] = 'F';
  unsigned int fileSize = wavSize + headerSize - 8;
  header[4] = (byte)(fileSize & 0xFF);
  header[5] = (byte)((fileSize >> 8) & 0xFF);
  header[6] = (byte)((fileSize >> 16) & 0xFF);
  header[7] = (byte)((fileSize >> 24) & 0xFF);
  header[8] = 'W';
  header[9] = 'A';
  header[10] = 'V';
  header[11] = 'E';
  header[12] = 'f';
  header[13] = 'm';
  header[14] = 't';
  header[15] = ' ';
  header[16] = 0x10;
  header[17] = 0x00;
  header[18] = 0x00;
  header[19] = 0x00;
  header[20] = 0x01;
  header[21] = 0x00;
  header[22] = 0x01;
  header[23] = 0x00;
  header[24] = 0x80;
  header[25] = 0x3E;
  header[26] = 0x00;
  header[27] = 0x00;
  header[28] = 0x00;
  header[29] = 0x7D;
  header[30] = 0x00;
  header[31] = 0x00;
  header[32] = 0x02;
  header[33] = 0x00;
  header[34] = 0x10;
  header[35] = 0x00;
  header[36] = 'd';
  header[37] = 'a';
  header[38] = 't';
  header[39] = 'a';
  header[40] = (byte)(wavSize & 0xFF);
  header[41] = (byte)((wavSize >> 8) & 0xFF);
  header[42] = (byte)((wavSize >> 16) & 0xFF);
  header[43] = (byte)((wavSize >> 24) & 0xFF);
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
  String endpoint = String(supabaseUrl) + "/rest/v1/" + tableName + "?order=created_at.desc&limit=1";
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
    jsonDoc["status"] = "pending";
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

