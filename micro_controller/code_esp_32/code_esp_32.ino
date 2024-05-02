#include <WiFi.h>
#include <WiFiClient.h>
#include <ESP32Servo.h> // Sử dụng thư viện ESP32Servo

const char* ssid = "Nha Nghi Hoang Gia 2";
const char* password = "0905630612";
WiFiServer server(80);

Servo servo; // Khai báo đối tượng servo
String rac = "";

void setup() {
  Serial.begin(115200);
  WiFi.begin(ssid, password);
  while (WiFi.status() != WL_CONNECTED) {
    delay(1000);
    Serial.println("Connecting to WiFi...");
  }
  Serial.println("Connected to WiFi");
  Serial.print("IP Address: ");
  Serial.println(WiFi.localIP()); // In địa chỉ IP ra Serial Monitor
  server.begin();

  servo.attach(5); // Servo được nối với chân GPIO 5 của ESP32
  servo.write(0);
}

void loop() {
  WiFiClient client = server.available();
  if (client) {
    rac = "";
    Serial.println("New client connected");
    while (client.connected()) {
      if (client.available()) {
        rac = client.readStringUntil('\r');
        Serial.println("Received command: " + rac);
        // Xử lý dữ liệu nhận được ở đây
        if (rac != "") { // Nếu nhận được lệnh mở nắp
          openLid(); // Gọi hàm mở nắp
        }
      }
    }
    Serial.println("Client disconnected");
    client.stop();
  }
}

void openLid() {
  int pos; // Biến lưu trữ góc xoay của servo
  for (pos = 0; pos <= 90; pos += 5) { // Xoay servo từ 0 đến 90 độ
    servo.write(pos); // Gửi góc xoay tới servo
    delay(15); // Chờ 15ms để servo di chuyển
  }
  delay(3500); // Chờ 3,5 giây
  for (pos = 90; pos >= 0; pos -= 5) { // Xoay servo từ 90 đến 0 độ
    servo.write(pos); // Gửi góc xoay tới servo
    delay(15); // Chờ 15ms để servo di chuyển
  }
}
