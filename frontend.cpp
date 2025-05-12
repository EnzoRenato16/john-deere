String getWebPage(float temp, float hum) {
  return String(R"rawliteral(
<!DOCTYPE html>
<html>
<head>
  <title>Monitoramento de Madeira</title>
  <meta charset="utf-8">
  <style>
    body {
      font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
      background: url('https://images.unsplash.com/photo-1506765515384-028b60a970df?auto=format&fit=crop&w=1470&q=80') no-repeat center center fixed;
      background-size: cover;
      color: #fff;
      text-align: center;
      margin: 0;
      padding: 0;
    }

    .overlay {
      background-color: rgba(0, 50, 0, 0.7);
      padding: 40px 20px;
      min-height: 100vh;
    }

    .card {
      background: rgba(255, 255, 255, 0.15);
      border: 1px solid #ffffff30;
      border-radius: 20px;
      padding: 20px;
      max-width: 600px;
      margin: 20px auto;
      box-shadow: 0 4px 20px rgba(0, 0, 0, 0.3);
    }

    h1 {
      font-size: 2.5rem;
      color: #e0ffe0;
      margin-bottom: 20px;
    }

    p {
      font-size: 1.2rem;
      margin: 10px 0;
      color: #ffffffcc;
    }

    img {
      width: 100%;
      border-radius: 10px;
      margin-top: 10px;
      box-shadow: 0 2px 10px rgba(0,0,0,0.4);
    }
  </style>
</head>
<body>
  <div class="overlay">
    <div class="card">
      <h1>🌲 Monitoramento de Madeira 🌲</h1>
      <img src="/cam">
      <p><strong>🌡️ Temperatura:</strong> )rawliteral" + String(temp) + R"rawliteral( °C</p>
      <p><strong>💧 Umidade:</strong> )rawliteral" + String(hum) + R"rawliteral( %</p>
    </div>
  </div>
</body>
</html>
)rawliteral";
}
