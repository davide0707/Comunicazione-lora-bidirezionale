// database.js
const { Pool } = require("pg");

// Configurazione connessione database
const pool = new Pool({
  host: process.env.DB_HOST || "timescaledb",
  port: process.env.DB_PORT || 5432,
  user: process.env.DB_USER || "admin",
  password: process.env.DB_PASSWORD || "admin",
  database: process.env.DB_NAME || "prova", // <-- Database "prova"
});

// Crea la tabella se non esiste (solo x, y, z, temp)
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

// Esporta il pool per uso in server.cjs
module.exports = pool;
