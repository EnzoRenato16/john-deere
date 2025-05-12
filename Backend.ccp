#include "esp_camera.h"
#include <WiFi.h>
#include <Adafruit_Sensor.h>
#include <DHT.h>

// --- Configurações da câmera (AI-Thinker) ---
#define PWDN_GPIO_NUM    -1
#define RESET_GPIO_NUM   -1
#define XCLK_GPIO_NUM     0
#define SIOD_GPIO_NUM    26
#define SIOC_GPIO_NUM    27
#define Y9_GPIO_NUM      35
#define Y8_GPIO_NUM      34
#define Y7_GPIO_NUM      39
#define Y6_GPIO_NUM      36
#define Y5_GPIO_NUM      21
#define Y4_GPIO_NUM      19
#define Y3_GPIO_NUM      18
#define Y2_GPIO_NUM       5
#define VSYNC_GPIO_NUM   25
#define HREF_GPIO_NUM    23
#define PCLK_GPIO_NUM    22

// --- DHT22 ---
#define DHTPIN 14
#define DHTTYPE DHT22
DHT dht(DHTPIN, DHTTYPE);

// --- Wi-Fi ---
const char* ssid = "SEU_WIFI";
const char* password = "SENHA_WIFI";

// --- Função de inicialização da câmera ---
void startCamera() {
  camera_config_t config;
  config.ledc_channel = LEDC_CHANNEL_0;
  config.ledc_timer   = LEDC_TIMER_0;
  config.pin_d0       = Y2_GPIO_NUM;
  config.pin_d1       = Y3_GPIO_NUM;
  config.pin_d2       = Y4_GPIO_NUM;
  config.pin_d3       = Y5_GPIO_NUM;
  config.pin_d4       = Y6_GPIO_NUM;
  config.pin_d5       = Y7_GPIO_NUM;
  config.pin_d6       = Y8_GPIO_NUM;
  config.pin_d7       = Y9_GPIO_NUM;
  config.pin_xclk     = XCLK_GPIO_NUM;
  config.pin_pclk     = PCLK_GPIO_NUM;
  config.pin_vsync    = VSYNC_GPIO_NUM;
  config.pin_href     = HREF_GPIO_NUM;
  config.pin_sscb_sda = SIOD_GPIO_NUM;
  config.pin_sscb_scl = SIOC_GPIO_NUM;
  config.pin_pwdn     = PWDN_GPIO_NUM;
  config.pin_reset    = RESET_GPIO_NUM;
  config.xclk_freq_hz = 20000000;
  config.pixel_format = PIXFORMAT_JPEG;

  if(psramFound()) {
    config.frame_size = FRAMESIZE_VGA;
    config.jpeg_quality = 10;
    config.fb_count = 2;
  } else {
    config.frame_size = FRAMESIZE_CIF;
    config.jpeg_quality = 12;
    config.fb_count = 1;
  }

  // Inicializa câmera
  esp_err_t err = esp_camera_init(&config);
  if (err != ESP_OK) {
    Serial.printf("Erro ao iniciar câmera: 0x%x", err);
    return;
  }
}

// --- Página HTML ---
String getWebPage(float temp, float hum) {
  return String(R"rawliteral(
<!DOCTYPE html>
<html>
<head>
  <title>Monitoramento de Madeira</title>
  <meta charset="utf-8">
  <style>
    body { font-family: Arial; text-align: center; background: #f0f0f0; }
    .card { background: white; padding: 20px; margin: 20px auto; width: 80%; border-radius: 10px; box-shadow: 0 0 10px rgba(0,0,0,0.1); }
    h1 { color: #333; }
  </style>
</head>
<body>
  <div class="card">
    <h1>Monitoramento de Madeira</h1>
    <img src="/cam" style="width:100%; max-width:500px;">
    <p><strong>Temperatura:</strong> )rawliteral" + String(temp) + R"rawliteral( °C</p>
    <p><strong>Umidade:</strong> )rawliteral" + String(hum) + R"rawliteral( %</p>
  </div>
</body>
</html>
)rawliteral";
}

// --- Rota da câmera ---
void handleJPGStream(void *pvParameters) {
  WiFiServer *server = (WiFiServer *)pvParameters;
  WiFiClient client = server->available();
  if (!client) return;

  String req = client.readStringUntil('\r');
  client.flush();
  if (req.indexOf("GET /cam") != -1) {
    camera_fb_t *fb = NULL;
    fb = esp_camera_fb_get();
    if (!fb) {
      Serial.println("Falha ao capturar imagem");
      return;
    }

    client.println("HTTP/1.1 200 OK");
    client.println("Content-Type: image/jpeg");
    client.println("Content-Length: " + String(fb->len));
    client.println();
    client.write(fb->buf, fb->len);
    esp_camera_fb_return(fb);
  } else {
    float temp = dht.readTemperature();
    float hum = dht.readHumidity();

    client.println("HTTP/1.1 200 OK");
    client.println("Content-Type: text/html");
    client.println();
    client.print(getWebPage(temp, hum));
  }

  delay(1);
  client.stop();
}

// --- Setup ---
void setup() {
  Serial.begin(115200);
  dht.begin();

  WiFi.begin(ssid, password);
  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
    Serial.print(".");
  }
  Serial.println("");
  Serial.println("WiFi conectado");
  Serial.println(WiFi.localIP());

  startCamera();
}

// --- Loop ---
void loop() {
  static WiFiServer server(80);
  server.begin();
  handleJPGStream(&server);
}
