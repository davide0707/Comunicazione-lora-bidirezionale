# ==========================
# Dockerfile - LoRa Dashboard + Mosquitto
# ==========================
FROM node:20-slim

# --- Installazione Mosquitto + utilities ---
RUN apt-get update && \
    apt-get install -y mosquitto mosquitto-clients && \
    mkdir -p /mosquitto/config /mosquitto/data /mosquitto/log && \
    rm -rf /var/lib/apt/lists/*

# --- Configurazione base Mosquitto (broker locale, no loop) ---
RUN echo "listener 1884" > /mosquitto/config/mosquitto.conf && \
    echo "allow_anonymous true" >> /mosquitto/config/mosquitto.conf && \
    echo "persistence true" >> /mosquitto/config/mosquitto.conf && \
    echo "persistence_location /mosquitto/data/" >> /mosquitto/config/mosquitto.conf && \
    echo "log_dest file /mosquitto/log/mosquitto.log" >> /mosquitto/config/mosquitto.conf && \
    echo "" >> /mosquitto/config/mosquitto.conf && \
    echo "# Impostazioni ottimizzate" >> /mosquitto/config/mosquitto.conf && \
    echo "max_keepalive 120" >> /mosquitto/config/mosquitto.conf && \
    echo "autosave_interval 1800" >> /mosquitto/config/mosquitto.conf && \
    echo "connection_messages true" >> /mosquitto/config/mosquitto.conf && \
    echo "retained_persistence false" >> /mosquitto/config/mosquitto.conf && \
    echo "allow_zero_length_clientid true" >> /mosquitto/config/mosquitto.conf

# --- Nessun bridge attivo ---
# (Il modem MQTT si collega direttamente a 10.6.9.26:1883)
# --- Fine configurazione Mosquitto ---

# --- Preparazione app Node.js ---
WORKDIR /app

COPY package*.json ./
RUN npm install && npm install pg # Aggiunta pg per PostgreSQL
COPY . .

# --- Esponi porte ---
EXPOSE 1884 8081 8082

# --- Permessi log Mosquitto ---
RUN mkdir -p /mosquitto/log && chmod -R 777 /mosquitto

# --- Avvio simultaneo di Mosquitto e del server Node.js ---
CMD mosquitto -c /mosquitto/config/mosquitto.conf & node server.cjs
# ==========================
