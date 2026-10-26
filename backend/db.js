// ============================================================================
// File: db.js
// Description: MySQL 8 Connection Pool using mysql2 Promise API.
// Educational Note: Connection pools reuse active connections rather than
// opening and closing socket handshakes on every HTTP request, improving throughput.
// ============================================================================

const mysql = require('mysql2/promise');
require('dotenv').config();

// Create connection pool using environment variables
const pool = mysql.createPool({
  host: process.env.DB_HOST || '127.0.0.1',
  port: Number(process.env.DB_PORT) || 3306,
  user: process.env.DB_USER || 'root',
  password: process.env.DB_PASSWORD || '',
  database: process.env.DB_NAME || 'accident_db',
  waitForConnections: true,
  connectionLimit: 10,
  queueLimit: 0,
  decimalNumbers: true // Return DECIMAL columns as JS numbers for accurate JSON formatting
});

module.exports = pool;
