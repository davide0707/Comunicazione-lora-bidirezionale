# Sistema di Comunicazione LoRa Bidirezionale con SCL3300
## Implementazione embedded su STM32WLE5 (LoRa-E5 Mini), gateway LoRaWAN e dashboard web

## Abstract

Progetto end-to-end che realizza una comunicazione LoRaWAN bidirezionale tra una scheda **LoRa-E5 Mini (STM32WLE5)** e un gateway (es. RAK7268V2 o ChirpStack), con una dashboard web in tempo reale per monitorare il sensore **Murata SCL3300** e inviare comandi remoti. Il firmware personalizzato in **C (STM32CubeIDE)** sostituisce il vecchio firmware AT: esegue il join OTAA, gestisce uplink e downlink, acquisisce gli angoli dal SCL3300 tramite SPI e applica filtri EMA adattivi prima di impacchettare i dati in payload binari compatti.

La parte di backend usa un broker MQTT, un bridge Node.js che traduce MQTT in WebSocket e decodifica i payload, mentre il frontend (HTML/CSS/JS con Chart.js) offre grafici, log, storico e pannello comandi. Con chiavi OTAA e topic MQTT corretti, il sistema parte in modo plug & play.

---

## Caratteristiche principali

- Comunicazione LoRaWAN bidirezionale (EU868) con join OTAA gestito nel firmware, senza comandi AT.
- Driver SPI proprietario per il sensore Murata SCL3300 con verifica WHOAMI e gestione banche.
- Calibrazione automatica iniziale (100 campioni) per offset X, Y, Z.
- Filtraggio EMA adattivo:
  - angoli filtrati con EMA circolare che gestisce il wrap a +/-180 gradi;
  - temperatura filtrata con EMA scalare;
  - coefficiente alpha dinamico tra 0.001 e 0.2.
- Payload uplink binario compatto: 16 byte, quattro float32 little-endian (X, Y, Z, Temp).
- Bridge Node.js (`server.js`) che:
  - sottoscrive il topic MQTT di uplink;
  - decodifica Base64 -> float32;
  - espone WebSocket (porta 8081) e API REST per i comandi downlink.
- Dashboard web (`/Web`) con grafici live, log, storico, esportazioni PNG/CSV, autosalvataggio locale e chip di comandi rapidi.

---

## Architettura di sistema

```text
[SCL3300 (SPI)] --SPI--> [LoRa-E5 Mini MCU]
                          | Firmware C custom
                          | Filtri EMA + LoRaWAN OTAA
                          v
                  [Gateway LoRaWAN]
                          |
                          v
                     [Broker MQTT]
                          |
                          v
                 [server.js bridge]
                     | MQTT <-> WS
                     | WS: 8081
                     | HTTP: 8082
                          |
                          v
                 [Dashboard Web]
                 index.html + app.js
```

---

## Requisiti tecnici

### Hardware

- Scheda **LoRa-E5 Mini (STM32WLE5)**.
- Sensore **Murata SCL3300** su bus SPI.
- Gateway LoRaWAN compatibile (RAK7268V2, ChirpStack o equivalente).
- Interfaccia **ST-Link** (o simile) per flash e debug.
- PCB personalizzato opzionale con dimensioni indicative 40 x 20 mm.

### Software

- **STM32CubeIDE** con toolchain GCC ARM integrata.
- **Node.js >= 18** e **npm** per bridge e dashboard.
- Broker MQTT (Mosquitto, ChirpStack MQTT, ecc.).
- Browser moderno (Chrome, Edge, Firefox).
- Strumenti facoltativi: monitor seriale (es. PuTTY) e client MQTT grafico (es. MQTTX).

---

## Struttura del repository

```text
/Firmware
  |- progetto STM32CubeIDE
  |- scl3300.c / scl3300.h
  |- ema_adaptive.h
  |- file applicativi LoRaWAN

/Web
  |- index.html
  |- style.css
  |- app.js
  |- EnergyFlow.svg
  |- server.js (bridge MQTT/WebSocket + API REST)

/Docs
  |- documentazione extra (schemi, note, immagini)

/LICENSE
/README.md
```

---

## Firmware STM32WLE5

### Sequenza di avvio

1. **Setup MCU**
   - configurazione clock, GPIO, SPI, UART di debug e LED di stato.
2. **Stack LoRaWAN**
   - caricamento DevEUI, JoinEUI/AppEUI e AppKey;
   - join OTAA con feedback su LED/log.
3. **Inizializzazione SCL3300**
   - setup SPI e chip-select;
   - lettura registri WHOAMI e configurazione banchi.
4. **Calibrazione offset**
   - raccolta di 100 campioni;
   - media per X, Y, Z e memorizzazione degli offset;
   - log progressivo su UART ogni 10%.
5. **Setup filtri EMA**
   - tre filtri circolari per angoli (strutture `EMA1_CircularDeg`);
   - filtro scalare `EMA1_Adaptive` per temperatura.
6. **Loop operativo**
   - acquisizione periodica del sensore;
   - applicazione offset e filtri;
   - packing dei quattro float in 16 byte;
   - invio uplink con periodo configurabile;
   - gestione callback di downlink (es. comando `calibration`, reset, cambio parametri).

### Filtro EMA adattivo (`ema_adaptive.h`)

- Alpha dinamico con limiti `EMA_ALPHA_MIN = 0.001` e `EMA_ALPHA_MAX = 0.2`.
- Stima interna della varianza per regolare la rapidita del filtro.
- Per gli angoli, l'EMA lavora su seno e coseno per garantire continuita attorno a +/-180 gradi; wrapper `wrap_deg()` riporta il risultato nell'intervallo corretto.

---

## Formato dati uplink

| Offset | Tipo        | Campo | Descrizione                         |
| ------ | ----------- | ----- | ----------------------------------- |
| 0-3    | `float32` LE | X     | Angolo filtrato asse X (gradi)      |
| 4-7    | `float32` LE | Y     | Angolo filtrato asse Y (gradi)      |
| 8-11   | `float32` LE | Z     | Angolo filtrato asse Z (gradi)      |
| 12-15  | `float32` LE | Temp  | Temperatura filtrata (gradi Celsius)|

Workflow:

1. Il nodo LoRa invia il payload binario di 16 byte.
2. Il network server/gateway lo pubblica su MQTT come campo `data` codificato Base64.
3. `server.js` decodifica i 16 byte e produce `{ x, y, z, t }`, con meta-dati RF (RSSI, SNR, frequenza, frame counter).
4. La dashboard riceve il messaggio via WebSocket e aggiorna indicatori, grafici, storico e log.

Snippet di decodifica in Node.js:

```js
const buf = Buffer.from(dataB64, "base64");
const x = buf.readFloatLE(0);
const y = buf.readFloatLE(4);
const z = buf.readFloatLE(8);
const t = buf.readFloatLE(12);
```

---

## Comandi remoti (downlink)

1. L'utente invia un comando testuale dalla dashboard (es. `calibration`).
2. La dashboard chiama `POST /api/command` con JSON `{ "command": "calibration" }`.
3. `server.js` converte la stringa in Base64 e pubblica sul topic di downlink:

```js
const payload = {
  confirmed: false,
  fPort: 2,
  data: Buffer.from(command, "utf8").toString("base64"),
};
```

4. Il network server inoltra il downlink al dispositivo.
5. Il firmware gestisce il comando nella callback dedicata.

Comandi tipici implementabili: `calibration`, `RESET`, `LEDON`/`LEDOFF`, variazione periodo uplink, ripristino parametri.

---

## Configurazione gateway LoRaWAN (OTAA)

1. Creare una application nel network server e registrare il dispositivo in OTAA.
2. Annotare DevEUI, JoinEUI/AppEUI e AppKey.
3. Impostare la regione EU868 e un data rate coerente.
4. Abilitare l'output MQTT con host, porta, credenziali e topic:
   - uplink: `application/<AppName>/device/<DevEUI>/rx`
   - downlink: `application/<AppName>/device/<DevEUI>/tx`
5. Aggiornare in `server.js`:
   - `MQTT_HOST`, `MQTT_PORT`, `MQTT_USERNAME`, `MQTT_PASSWORD`;
   - `MQTT_TOPIC_UPLINK` e `TOPIC_DOWN`.
6. Allineare le stesse chiavi in `Firmware/app_config.h`.
7. Riavviare il nodo e verificare la conferma del join.

---

## Bridge Node.js (`/Web/server.js`)

- Serve contenuti statici su HTTP (8082) e API REST (`/api/ping`, `/api/command`).
- Gestisce WebSocket su 8081 con broadcast di:
  - stato MQTT;
  - messaggi `uplink` con dati decodificati e meta LoRa;
  - log (`info`, `uplink`, `downlink`, `error`);
  - conferma locale `downlink_sent`.
- Client MQTT integrato con gestione riconnessione e log di eventuali errori.

---

## Dashboard web (`/Web`)

### Stack

- HTML/CSS/JS vanilla.
- Chart.js 4 con `chartjs-adapter-date-fns` e `chartjs-plugin-zoom`.
- Icone Lucide.

### Funzionalita

- **Top bar**: stato WebSocket, stato MQTT, pulsanti Connect e Reset.
- **Pannello flusso dati**: SVG animato (EnergyFlow) per visualizzare uplink/downlink e statistiche istantanee (X, Y, Z, Temp, RSSI, SNR, frequenza, frame counter).
- **Grafici**:
  - vista singola con quattro dataset;
  - vista alternativa con quattro grafici separati;
  - zoom/pan e reset;
  - esportazione PNG.
- **Log e comandi**:
  - log con tag colorati (UP, DN, ERR, INFO);
  - input comando + chip rapidi;
  - pannello JSON raw per il payload MQTT.
- **Storico avanzato**:
  - lista cronologica dei campioni con meta LoRa;
  - calcolo on demand dei valori min/max per X, Y, Z, Temp;
  - export CSV (`storico_<timestamp>.csv`) con separatore `;`.
- **Autosalvataggio locale**:
  - `saveToLocal()` salva storico e log in `localStorage`;
  - `loadFromLocal()` ripristina i dati all'avvio e mostra un badge di conferma.

---

## Build e flashing del firmware

1. Importare il progetto in STM32CubeIDE (`File -> Import -> Existing Projects into Workspace`) puntando a `/Firmware`.
2. Aggiornare `app_config.h` con chiavi OTAA e parametri operativi (periodo uplink, data rate, potenza TX).
3. Controllare la configurazione pin per SPI (MOSI, MISO, SCK, CS), UART di log e LED.
4. Compilare in modalita Release.
5. Collegare ST-Link ed eseguire `Run` o `Debug`.
6. (Opzionale) Abilitare log UART e diagnostica dettagliata (`SCL3300_DebugDump()`).

---

## Installazione e avvio rapidi

1. **Firmware**
   - Flash su LoRa-E5 Mini.
   - Collegare SCL3300 come da schemi in `/Docs`.
2. **Broker MQTT**
   - Avviare Mosquitto o equivalente, configurare credenziali se richieste.
3. **Gateway / Network server**
   - Configurare applicazione OTAA e abilitare i topic MQTT concordati.
4. **Bridge + dashboard**
   - Nella cartella `/Web` eseguire:
     ```bash
     npm install
     npm start
     ```
   - Aprire il browser su `http://localhost:8082/`.
5. **Start del sistema**
   - Alimentare il nodo (join OTAA, calibrazione iniziale, uplink periodici).
   - In dashboard premere **Connect** e verificare arrivo dati e log.

---

## Prestazioni e linee guida

- **Filtro EMA adattivo**: alpha dinamico offre equilibrio tra riduzione rumore (alpha piccolo) e risposta rapida (alpha grande). La versione circolare elimina discontinuita attorno ai limiti angolari.
- **Consumo energetico**: per nodi a batteria aumentare il periodo di acquisizione, usare data rate LoRaWAN piu alto e valutare sleep MCU/sensore tra le misure.
- **Affidabilita**: monitorare `fCnt`, configurare retry, conferme ACK e politiche di rejoin lato network server.
- **Sicurezza**: proteggere le chiavi OTAA, abilitare TLS su MQTT in ambienti non fidati, limitare l'accesso alla dashboard di comando remoto.

---

## PCB e cablaggio

- PCB custom con LoRa-E5 e SCL3300, dimensioni tipiche 40 x 20 mm.
- Suggerimenti layout:
  - tracce SPI corte e schermate;
  - piano di massa continuo;
  - separazione zona RF da digitale e sensore;
  - posizionamento accurato dell'antenna.
- Riferimenti aggiuntivi in `/Docs/schematic.pdf` e `/Docs/pcb_layout.png` se presenti.

---

## Troubleshooting

- **Join non riuscito**
  - verificare regione EU868 e chiavi DevEUI/JoinEUI/AppKey;
  - controllare copertura radio e antenna.
- **WHOAMI del SCL3300 fallito**
  - controllare cablaggio SPI, polarita clock e alimentazione;
  - assicurarsi che il chip-select venga gestito correttamente.
- **Dati rumorosi o saturi**
  - effettuare la calibrazione con sensore fermo;
  - verificare fattori di scala e unita;
  - ripetere `calibration` via comando downlink.
- **Dashboard senza dati**
  - verificare stato WebSocket e MQTT;
  - controllare topic configurati in `server.js`;
  - ispezionare la console browser e i log di `server.js`.
- **Downlink ignorati**
  - confermare topic di downlink e fPort;
  - verificare nel firmware la gestione del comando ricevuto;
  - controllare gli ACK nel network server.

---

## Licenza

Distribuito con licenza **MIT**. Vedere il file `LICENSE` per i dettagli.

---

## Autore

- **Davide Di Filippo**
- GitHub: [github.com/davide0707](https://github.com/davide0707)
- Email: `difilippodavide.github@gmail.com`
- **Qyrani Matteo**
- GitHub: [github.com/Qyranico](https://github.com/Qyranico)
- Anno: 2025
