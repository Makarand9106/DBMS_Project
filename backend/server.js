// ============================================================================
// File: server.js
// Project: Road Accident Hotspot Analysis and Severity Prediction System
// Description: Minimal Express backend with Raw SQL & Parameterised Queries.
// ============================================================================

const express = require('express');
const cors = require('cors');
require('dotenv').config();

const pool = require('./db');

const app = express();
const PORT = process.env.PORT || 5000;

// Enable CORS and JSON body parser middleware
app.use(cors());
app.use(express.json());

// ----------------------------------------------------------------------------
// 1. GET /api/hotspots
// Query the database view `v_hotspot_ranking` to return prioritized accident hotspots
// along with coordinates for mapping and geospatial visualization.
// ----------------------------------------------------------------------------
app.get('/api/hotspots', async (req, res) => {
  try {
    const query = `
      SELECT 
        location_id,
        location_name,
        district,
        latitude,
        longitude,
        total_accidents,
        fatal_count,
        risk_score
      FROM v_hotspot_ranking;
    `;
    const [rows] = await pool.query(query);
    res.json(rows);
  } catch (error) {
    console.error('Error fetching hotspots:', error);
    res.status(500).json({ error: 'Failed to retrieve hotspots' });
  }
});

// 2. GET /api/stats
// Returns multi-dimensional aggregations: by cause, by weather, by month, and by hour band.

app.get('/api/stats', async (req, res) => {
  try {
    // 2a. Accidents grouped by cause
    const causeQuery = `
      SELECT 
        ac.cause_id,
        ac.cause_name,
        ac.category,
        COUNT(a.accident_id) AS total_accidents,
        ROUND(COUNT(a.accident_id) * 100.0 / (SELECT COUNT(*) FROM accident), 2) AS percentage_of_total,
        SUM(CASE WHEN s.level_name = 'Fatal' THEN 1 ELSE 0 END) AS fatal_count,
        ROUND(AVG(s.level_rank), 2) AS avg_severity_rank
      FROM accident_cause ac
      LEFT JOIN accident a ON ac.cause_id = a.cause_id
      LEFT JOIN severity s ON a.severity_id = s.severity_id
      GROUP BY ac.cause_id, ac.cause_name, ac.category
      ORDER BY total_accidents DESC;
    `;

    // 2b. Accidents grouped by weather condition
    const weatherQuery = `
      SELECT 
        wc.weather_id,
        wc.condition_name,
        COUNT(a.accident_id) AS total_accidents,
        ROUND(COUNT(a.accident_id) * 100.0 / (SELECT COUNT(*) FROM accident), 2) AS percentage_of_total,
        SUM(CASE WHEN s.level_name = 'Minor' THEN 1 ELSE 0 END) AS minor_count,
        SUM(CASE WHEN s.level_name = 'Serious' THEN 1 ELSE 0 END) AS serious_count,
        SUM(CASE WHEN s.level_name = 'Fatal' THEN 1 ELSE 0 END) AS fatal_count,
        ROUND(AVG(s.level_rank), 2) AS avg_severity_rank
      FROM weather_condition wc
      LEFT JOIN accident a ON wc.weather_id = a.weather_id
      LEFT JOIN severity s ON a.severity_id = s.severity_id
      GROUP BY wc.weather_id, wc.condition_name
      ORDER BY total_accidents DESC;
    `;

    // 2c. Accidents grouped chronologically by month
    const monthQuery = `
      SELECT 
        DATE_FORMAT(a.accident_date, '%Y-%m') AS accident_month,
        COUNT(a.accident_id) AS total_accidents,
        SUM(CASE WHEN s.level_name = 'Minor' THEN 1 ELSE 0 END) AS minor_count,
        SUM(CASE WHEN s.level_name = 'Serious' THEN 1 ELSE 0 END) AS serious_count,
        SUM(CASE WHEN s.level_name = 'Fatal' THEN 1 ELSE 0 END) AS fatal_count
      FROM accident a
      JOIN severity s ON a.severity_id = s.severity_id
      GROUP BY DATE_FORMAT(a.accident_date, '%Y-%m')
      ORDER BY accident_month ASC;
    `;

    // 2d. Accidents grouped by hour band using SQL CASE
    const hourBandQuery = `
      SELECT 
        CASE
          WHEN HOUR(a.accident_time) BETWEEN 6 AND 11 THEN 'Morning'
          WHEN HOUR(a.accident_time) BETWEEN 12 AND 16 THEN 'Afternoon'
          WHEN HOUR(a.accident_time) BETWEEN 17 AND 20 THEN 'Evening'
          ELSE 'Night'
        END AS hour_band,
        COUNT(a.accident_id) AS total_accidents,
        SUM(CASE WHEN s.level_name = 'Minor' THEN 1 ELSE 0 END) AS minor_count,
        SUM(CASE WHEN s.level_name = 'Serious' THEN 1 ELSE 0 END) AS serious_count,
        SUM(CASE WHEN s.level_name = 'Fatal' THEN 1 ELSE 0 END) AS fatal_count,
        ROUND(AVG(s.level_rank), 2) AS avg_severity_rank
      FROM accident a
      JOIN severity s ON a.severity_id = s.severity_id
      GROUP BY hour_band
      ORDER BY avg_severity_rank DESC;
    `;

    // Execute queries in parallel using connection pool
    const [
      [byCause],
      [byWeather],
      [byMonth],
      [byHourBand]
    ] = await Promise.all([
      pool.query(causeQuery),
      pool.query(weatherQuery),
      pool.query(monthQuery),
      pool.query(hourBandQuery)
    ]);

    res.json({
      by_cause: byCause,
      by_weather: byWeather,
      by_month: byMonth,
      by_hour_band: byHourBand
    });
  } catch (error) {
    console.error('Error fetching statistics:', error);
    res.status(500).json({ error: 'Failed to retrieve statistical aggregations' });
  }
});

// 3. GET /api/lookups
// Catalog of master entities required for populating client-side UI forms.

app.get('/api/lookups', async (req, res) => {
  try {
    const [
      [weatherRows],
      [causeRows],
      [severityRows],
      [vehicleTypeRows],
      [locationRows],
      [roadRows]
    ] = await Promise.all([
      pool.query('SELECT weather_id, condition_name FROM weather_condition ORDER BY weather_id;'),
      pool.query('SELECT cause_id, cause_name, category FROM accident_cause ORDER BY cause_id;'),
      pool.query('SELECT severity_id, level_name, level_rank, description FROM severity ORDER BY level_rank;'),
      pool.query('SELECT vehicle_type_id, type_name FROM vehicle_type ORDER BY vehicle_type_id;'),
      pool.query('SELECT location_id, location_name, district, latitude, longitude FROM location ORDER BY location_name;'),
      pool.query('SELECT road_id, road_name, road_type, lanes, surface_type, speed_limit FROM road ORDER BY road_name;')
    ]);

    res.json({
      road_types: ['Highway', 'Urban', 'Rural'],
      weather_conditions: weatherRows,
      causes: causeRows,
      severities: severityRows,
      vehicle_types: vehicleTypeRows,
      locations: locationRows,
      roads: roadRows
    });
  } catch (error) {
    console.error('Error fetching lookups:', error);
    res.status(500).json({ error: 'Failed to retrieve lookup values' });
  }
});

// 4. POST /api/predict
// Invokes the MySQL stored procedure `sp_predict_severity` using raw SQL.
// Returns the modal predicted severity and the probability distribution across all levels.

app.post('/api/predict', async (req, res) => {
  try {
    const { road_type, weather_id, cause_id, hour_band } = req.body;

    // Validate required inputs
    const validRoadTypes = ['Highway', 'Urban', 'Rural'];
    const validHourBands = ['Morning', 'Afternoon', 'Evening', 'Night'];

    if (!road_type || !validRoadTypes.includes(road_type)) {
      return res.status(400).json({
        error: `Invalid road_type. Expected one of: ${validRoadTypes.join(', ')}`
      });
    }

    if (!weather_id || isNaN(Number(weather_id))) {
      return res.status(400).json({ error: 'weather_id must be a valid integer' });
    }

    if (!cause_id || isNaN(Number(cause_id))) {
      return res.status(400).json({ error: 'cause_id must be a valid integer' });
    }

    if (!hour_band || !validHourBands.includes(hour_band)) {
      return res.status(400).json({
        error: `Invalid hour_band. Expected one of: ${validHourBands.join(', ')}`
      });
    }

    // Call stored procedure with parameterised values.

    const [results] = await pool.query('CALL sp_predict_severity(?, ?, ?, ?);', [
      road_type,
      Number(weather_id),
      Number(cause_id),
      hour_band
    ]);

    const rows = results[0] || [];
    if (rows.length === 0) {
      return res.status(500).json({ error: 'No output received from prediction procedure' });
    }

    // Find the predicted severity level marked by the procedure
    const predictedRow = rows.find(r => r.prediction_flag && r.prediction_flag.includes('PREDICTED')) || rows[0];

    res.json({
      predicted_severity: predictedRow.severity_level,
      predicted_level_rank: predictedRow.level_rank,
      prediction_status: predictedRow.prediction_flag,
      data_source: rows[0].data_source,
      sample_size: rows[0].sample_size,
      breakdown: rows.map(r => ({
        severity_level: r.severity_level,
        level_rank: r.level_rank,
        accident_count: Number(r.accident_count),
        percentage: Number(r.percentage),
        is_predicted: Boolean(r.prediction_flag && r.prediction_flag.includes('PREDICTED'))
      }))
    });
  } catch (error) {
    console.error('Error running severity prediction:', error);
    res.status(500).json({ error: 'Failed to compute severity prediction' });
  }
});

// ----------------------------------------------------------------------------
// 5. POST /api/accidents
// Inserts a new accident event along with associated vehicle types and victims.
// Uses an explicit database TRANSACTION (ACID) to ensure atomicity across tables.
// ----------------------------------------------------------------------------
app.post('/api/accidents', async (req, res) => {
  let connection;
  try {
    const {
      accident_date,
      accident_time,
      description,
      location_id,
      road_id,
      weather_id,
      severity_id,
      cause_id,
      vehicle_type_ids,
      victims
    } = req.body;

    // Validation: Mandatory fields
    if (!accident_date || !/^\d{4}-\d{2}-\d{2}$/.test(accident_date)) {
      return res.status(400).json({ error: 'Invalid or missing accident_date (format: YYYY-MM-DD)' });
    }

    if (!accident_time) {
      return res.status(400).json({ error: 'accident_time is required (format: HH:MM:SS)' });
    }

    if (!location_id || isNaN(Number(location_id))) {
      return res.status(400).json({ error: 'Valid location_id integer is required' });
    }

    if (!road_id || isNaN(Number(road_id))) {
      return res.status(400).json({ error: 'Valid road_id integer is required' });
    }

    if (!weather_id || isNaN(Number(weather_id))) {
      return res.status(400).json({ error: 'Valid weather_id integer is required' });
    }

    if (!severity_id || isNaN(Number(severity_id))) {
      return res.status(400).json({ error: 'Valid severity_id integer is required' });
    }

    if (!cause_id || isNaN(Number(cause_id))) {
      return res.status(400).json({ error: 'Valid cause_id integer is required' });
    }

    if (!Array.isArray(vehicle_type_ids) || vehicle_type_ids.length === 0) {
      return res.status(400).json({ error: 'vehicle_type_ids must be a non-empty array of vehicle IDs' });
    }

    // Validate optional victims array if present
    if (victims !== undefined) {
      if (!Array.isArray(victims)) {
        return res.status(400).json({ error: 'victims must be an array of victim objects' });
      }
      for (let i = 0; i < victims.length; i++) {
        const v = victims[i];
        if (v.age === undefined || isNaN(Number(v.age)) || v.age < 0 || v.age > 125) {
          return res.status(400).json({ error: `Victim at index ${i} has invalid age (0-125)` });
        }
        if (!['Male', 'Female', 'Other'].includes(v.gender)) {
          return res.status(400).json({ error: `Victim at index ${i} has invalid gender ('Male', 'Female', 'Other')` });
        }
        if (!['Driver', 'Passenger', 'Pedestrian'].includes(v.person_type)) {
          return res.status(400).json({ error: `Victim at index ${i} has invalid person_type ('Driver', 'Passenger', 'Pedestrian')` });
        }
        if (!v.injury_severity_id || isNaN(Number(v.injury_severity_id))) {
          return res.status(400).json({ error: `Victim at index ${i} requires valid injury_severity_id` });
        }
      }
    }

    // Acquire dedicated connection from the pool for transactional safety
    connection = await pool.getConnection();
    await connection.beginTransaction();

    // 1. Insert core accident entity
    const insertAccidentSql = `
      INSERT INTO accident (
        accident_date,
        accident_time,
        description,
        location_id,
        road_id,
        weather_id,
        severity_id,
        cause_id
      ) VALUES (?, ?, ?, ?, ?, ?, ?, ?);
    `;
    const [accidentResult] = await connection.query(insertAccidentSql, [
      accident_date,
      accident_time,
      description || null,
      Number(location_id),
      Number(road_id),
      Number(weather_id),
      Number(severity_id),
      Number(cause_id)
    ]);

    const newAccidentId = accidentResult.insertId;

    // 2. Insert into accident_vehicle junction table
    const insertVehicleSql = `
      INSERT INTO accident_vehicle (accident_id, vehicle_type_id)
      VALUES (?, ?);
    `;
    for (const vTypeId of vehicle_type_ids) {
      await connection.query(insertVehicleSql, [newAccidentId, Number(vTypeId)]);
    }

    // 3. Insert victim records if provided
    if (victims && victims.length > 0) {
      const insertVictimSql = `
        INSERT INTO victim (
          accident_id,
          age,
          gender,
          person_type,
          hospitalized,
          injury_severity_id
        ) VALUES (?, ?, ?, ?, ?, ?);
      `;
      for (const v of victims) {
        await connection.query(insertVictimSql, [
          newAccidentId,
          Number(v.age),
          v.gender,
          v.person_type,
          Boolean(v.hospitalized),
          Number(v.injury_severity_id)
        ]);
      }
    }

    // Commit transaction: All writes become permanent together
    await connection.commit();

    res.status(201).json({
      message: 'Accident recorded successfully',
      accident_id: newAccidentId,
      vehicles_recorded: vehicle_type_ids.length,
      victims_recorded: (victims && victims.length) || 0
    });
  } catch (error) {
    // If any statement failed, rollback any partial changes to keep database consistent
    if (connection) {
      await connection.rollback();
    }
    console.error('Error inserting accident record:', error);
    res.status(500).json({ error: 'Database transaction failed while inserting accident' });
  } finally {
    // Release connection back to pool
    if (connection) {
      connection.release();
    }
  }
});

// Start listening on IPv4 loopback (avoids macOS AirPlay Receiver conflict on ::1)
app.listen(PORT, '127.0.0.1', () => {
  console.log(`Server running at http://127.0.0.1:${PORT}`);
});
