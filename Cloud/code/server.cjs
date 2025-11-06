// server.js
// Bridge MQTT <-> WebSocket + API comandi + Database + Animazioni

const express = require("express");
const http = require("http");
const WebSocket = require("ws");
const mqtt = require("mqtt");
const cors = require("cors");
const bodyParser = require("body-parser");
const { Pool } = require("pg");

// ========================
// CONFIG
// ========================

// ⚙️ Inserisci qui i tuoi parametri reali
const HTTP_PORT = 8082;           // porta web interfaccia
const WS_PORT = 8081;             // porta WebSocket
const MQTT_HOST = "localhost";    // IP o hostname del broker
const MQTT_PORT = 1884;
const MQTT_USERNAME = "mqtt_user";
const MQTT_PASSWORD = "mqtt_pass";

const MQTT_TOPIC_UPLINK = "application/TestComV2/device/0080e115063862f2/rx";
const MQTT_TOPIC_DOWNLINK = "application/TestComV2/device/0080e115063862f2/tx";

// ========================
// DATABASE (PostgreSQL)
// ========================
const pool = new Pool({
  host: process.env.DB_HOST || "timescaledb",
  port: process.env.DB_PORT || 5432,
  user: process.env.DB_USER || "admin",
  password: process.env.DB_PASSWORD || "admin",
  database: process.env.DB_NAME || "prova",
});

// Crea tabella se non esiste
(async () => {
  try {
    await pool.query(`
      CREATE TABLE IF NOT EXISTS prova (
        id SERIAL PRIMARY KEY,
        timestamp TIMESTAMPTZ DEFAULT NOW(),
        x DOUBLE PRECISION,
        y DOUBLE PRECISION,
        z DOUBLE PRECISION,
        temp DOUBLE PRECISION
      );
    `);
    console.log("✅ Tabella 'prova' pronta");
  } catch (err) {
    console.error("❌ Errore creazione tabella:", err);
  }
})();

// ========================
// EXPRESS HTTP
// ========================
const app = express();
app.use(cors());
app.use(bodyParser.json());
app.use(express.static(__dirname));

// API di test
app.get("/api/ping", (req, res) => {
  res.json({ ok: true, msg: "pong" });
});

// API per inviare comandi Downlink
app.post("/api/command", async (req, res) => {
  const { command } = req.body;

  if (!command) return res.status(400).json({ error: "No command provided" });

  const payload = {
    confirmed: false,
    fPort: 2,
    data: Buffer.from(command, "utf8").toString("base64"),
  };

  try {
    mqttClient.publish(MQTT_TOPIC_DOWNLINK, JSON.stringify(payload));
    console.log("MQTT downlink sent:", payload);

    // 🔹 Notifica frontend per log e animazione
    broadcastAll({
      type: "downlink_sent",
      command,
      dataB64: payload.data,
    });

    broadcastLog(
      "downlink",
      `Downlink sent: "${command}" (base64=${payload.data})`
    );

    res.json({ ok: true });
  } catch (err) {
    console.error("MQTT send error:", err);
    broadcastLog("error", `MQTT send error: ${err.message}`);
    res.status(500).json({ error: "MQTT send error" });
  }
});

// ========================
// HTTP SERVER
// ========================
const httpServer = http.createServer(app);
httpServer.listen(HTTP_PORT, () => {
  console.log(`HTTP server on http://localhost:${HTTP_PORT}`);
});

// ========================
// WEBSOCKET SERVER
// ========================
const wss = new WebSocket.Server({ port: WS_PORT }, () => {
  console.log(`WebSocket bridge on ws://localhost:${WS_PORT}`);
});

function broadcastAll(obj) {
  const data = JSON.stringify(obj);
  wss.clients.forEach((client) => {
    if (client.readyState === WebSocket.OPEN) client.send(data);
  });
}

function broadcastLog(level, message) {
  const logMsg = {
    type: "log",
    level,
    message,
    timestamp: Date.now(),
  };

  // Invia ai client
  broadcastAll(logMsg);

  // (Facoltativo) salva i log nel DB se vuoi renderli persistenti
  /*
  pool.query(
    `INSERT INTO logs (level, message, source) VALUES ($1, $2, $3)`,
    [level, message, "server"]
  ).catch(() => {});
  */
}

wss.on("connection", (ws) => {
  console.log("Client WebSocket connected");
  ws.send(
    JSON.stringify({
      type: "status",
      message: "WebSocket connected to server",
      timestamp: Date.now(),
    })
  );
});

wss.on("close", () => {
  console.log("Client WebSocket disconnected");
});

// ========================
// MQTT CLIENT
// ========================
const mqttUrl = `mqtt://${MQTT_HOST}:${MQTT_PORT}`;
const mqttOptions = { username: MQTT_USERNAME, password: MQTT_PASSWORD };
const mqttClient = mqtt.connect(mqttUrl, mqttOptions);

mqttClient.on("connect", () => {
  console.log(`Connected to MQTT broker ${MQTT_HOST}:${MQTT_PORT}`);
  broadcastLog("info", `Connected to MQTT ${MQTT_HOST}:${MQTT_PORT}`);

  mqttClient.subscribe(MQTT_TOPIC_UPLINK, (err) => {
    if (err) {
      console.error("Error subscribing to uplink:", err);
      broadcastLog("error", `Error subscribing to uplink: ${err.message}`);
    } else {
      console.log("Subscribed to", MQTT_TOPIC_UPLINK);
      broadcastLog("info", `Listening on ${MQTT_TOPIC_UPLINK}`);
    }
  });
});

mqttClient.on("error", (err) => {
  console.error("MQTT error:", err);
  broadcastLog("error", `MQTT error: ${err.message}`);
});

mqttClient.on("close", () => {
  console.log("MQTT disconnected");
  broadcastLog("error", "MQTT disconnected");
});

// ========================
// PAYLOAD DECODER (4 float32)
// ========================
function decodePayloadFloats(dataB64) {
  try {
    const buf = Buffer.from(dataB64, "base64");
    if (buf.length !== 16) return null;
    const x = buf.readFloatLE(0);
    const y = buf.readFloatLE(4);
    const z = buf.readFloatLE(8);
    const t = buf.readFloatLE(12);
    return { x, y, z, t };
  } catch {
    return null;
  }
}

// ========================
// MQTT MESSAGE HANDLER
// ========================
mqttClient.on("message", async (topic, messageBuf) => {
  try {
    const msgStr = messageBuf.toString("utf-8");
    let payload = JSON.parse(msgStr);

    if (topic === MQTT_TOPIC_UPLINK) {
      const dataB64 = payload.data;
      const decoded = decodePayloadFloats(dataB64);
      const timestamp = payload.timestamp
        ? new Date(payload.timestamp * 1000)
        : new Date();

      const meta = {
        fCnt: payload.fCnt,
        rssi: payload.rxInfo?.[0]?.rssi,
        snr: payload.rxInfo?.[0]?.loRaSNR,
      };

      if (decoded) {
        const { x, y, z, t } = decoded;
        console.log(
          `Uplink X=${x.toFixed(2)} Y=${y.toFixed(2)} Z=${z.toFixed(
            2
          )} T=${t.toFixed(2)}`
        );

        // 🔹 Salva nel DB
        await pool.query(
          `INSERT INTO prova (x, y, z, temp)
           VALUES ($1, $2, $3, $4)`,
          [x, y, z, t]
        );

        // 🔹 Invia al frontend per grafico + pallina + log
        broadcastAll({
          type: "uplink",
          timestamp,
          x,
          y,
          z,
          temp: t,
          meta,
          raw: payload,
        });

        broadcastLog(
          "uplink",
          `Uplink fCnt=${meta.fCnt ?? "?"} X=${x.toFixed(2)} Y=${y.toFixed(
            2
          )} Z=${z.toFixed(2)} T=${t.toFixed(2)}`
        );
      } else {
        broadcastLog("error", `Invalid uplink payload (base64=${dataB64})`);
      }
    }
  } catch (e) {
    console.error("Error processing MQTT message:", e);
    broadcastLog("error", `MQTT message error: ${e.message}`);
  }
});
