# LoRa + SCL3300 — Calibrazione, Filtraggio EMA Adattivo e Pipeline Dati

## Scopo

Questo README spiega in modo **ultra-dettagliato** la matematica applicata e come il codice la realizza, passo per passo.  
È pensato per essere **copiato/incollato nel progetto come `README.md`**.

---

## Indice

1. [Panoramica della pipeline](#panoramica-della-pipeline)  
2. [Calibrazione degli offset (media statica)](#calibrazione-degli-offset-media-statica)  
3. [Filtraggio esponenziale adattivo (EMA1_Adaptive)](#filtraggio-esponenziale-adattivo-ema1_adaptive)  
   - [Ricorrenza EMA base](#ricorrenza-ema-base)  
   - [Innovazione, media/varianza esponenziale](#innovazione-mediavarianza-esponenziale)  
   - [Stima di “significatività” e mappatura in alpha](#stima-di-significatività-e-mappatura-in-alpha)  
   - [Aggiornamento dello stato EMA](#aggiornamento-dello-stato-ema)  
4. [Filtraggio esponenziale adattivo circolare (angoli in gradi)](#filtraggio-esponenziale-adattivo-circolare-angoli-in-gradi)  
5. [Parametri, significato e trade-off](#parametri-significato-e-trade-off)  
6. [Mappatura codice ⇄ matematica](#mappatura-codice--matematica)  
7. [Sequenza di inizializzazione e calibrazione](#sequenza-di-inizializzazione-e-calibrazione)  
8. [Aggiornamento periodico e filtro](#aggiornamento-periodico-e-filtro)  
9. [Considerazioni numeriche e temporali](#considerazioni-numeriche-e-temporali)  
10. [Cosa finisce nel log e (opz.) nel payload LoRa](#cosa-finisce-nel-log-e-opz-nel-payload-lora)

---

## Panoramica della pipeline

**Obiettivo:** dal sensore SCL3300 ottenere angoli stabili (X, Y, Z) e temperatura T, compensando l’offset fisso e smussando il rumore con un **EMA adattivo** (gain `α` variabile in base all’attività del segnale).

### Catena di elaborazione per ciascun campione

1. **Campionamento:** lettura dei registri (`READ_ANG_X/Y/Z`, `READ_TEMPERATURE`).
2. **Compensazione offset:**  
   \\( \tilde{x} = x - o \\)
3. **Filtraggio EMA adattivo:**
   - Temperatura → EMA scalare  
   - Angoli → EMA circolare (wrap ±180°)
4. **Output:** valori filtrati su UART (e opzionalmente inviati via LoRa).

---

## Calibrazione degli offset (media statica)

### Matematica

Si acquisiscono N campioni “a fermo” per ciascun asse (X, Y, Z):

\\[
o_X = \frac{1}{N}\sum_{i=1}^N x_i,\quad
o_Y = \frac{1}{N}\sum_{i=1}^N y_i,\quad
o_Z = \frac{1}{N}\sum_{i=1}^N z_i
\\]

Questi valori vengono poi sottratti ad ogni misura successiva:

\\[
\tilde{x}_k = x_k - o_X,\quad
\tilde{y}_k = y_k - o_Y,\quad
\tilde{z}_k = z_k - o_Z
\\]

### Codice (concettuale)

```c
Calibra_Offset() {
    for (i = 0; i < N; i++) {
        read_sensor();
        sumX += x; sumY += y; sumZ += z;
    }
    oX = sumX / N;
    oY = sumY / N;
    oZ = sumZ / N;
    printf("Offset set to X:%f | Y:%f | Z:%f", oX, oY, oZ);
}
