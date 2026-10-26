# Road Accident DBMS - Backend API

A minimal Node.js Express backend using raw SQL parameterised queries, MySQL connection pooling (`mysql2/promise`), and transaction management for the **Road Accident Hotspot Analysis and Severity Prediction System**.

---

## Prerequisites

1. **Node.js** (v18+ recommended)
2. **MySQL 8.0+** running with the `accident_db` database initialized using `../sql/schema.sql`, `../sql/data.sql`, and `../sql/queries.sql`.

---

## Setup & Run Steps

### 1. Install Dependencies
```bash
cd accident-dbms/backend
npm install
```

### 2. Configure Environment Variables
Copy `.env.example` to `.env` (or adjust the values if your MySQL configuration differs):
```bash
cp .env.example .env
```

Default configuration in `.env`:
```env
DB_HOST=127.0.0.1
DB_PORT=3306
DB_USER=root
DB_PASSWORD=
DB_NAME=accident_db
PORT=5000
```

### 3. Start the Server
- **Production / Standard Mode**:
  ```bash
  npm start
  ```
- **Development Mode** (with automatic file reload via Node's native watcher):
  ```bash
  npm run dev
  ```

Server will be running at `http://127.0.0.1:5000`.

---

## API Endpoints

| Method | Endpoint | Description |
| :--- | :--- | :--- |
| `GET` | `/api/hotspots` | Returns rows from database view `v_hotspot_ranking` (includes coordinates). |
| `GET` | `/api/stats` | Returns aggregations grouped by cause, weather, month, and hour band. |
| `GET` | `/api/lookups` | Returns catalogs (road types, weather, causes, severities, vehicles, locations, roads) for form dropdowns. |
| `POST` | `/api/predict` | Invokes stored procedure `sp_predict_severity` to predict severity level and probabilities. |
| `POST` | `/api/accidents` | Inserts an accident, junction vehicles, and victims within an ACID transaction. |

---

## Sample Testing Commands (curl)

### 1. Hotspots
```bash
curl -s http://127.0.0.1:5000/api/hotspots
```

### 2. Aggregation Statistics
```bash
curl -s http://127.0.0.1:5000/api/stats
```

### 3. Form Dropdowns / Lookups
```bash
curl -s http://127.0.0.1:5000/api/lookups
```

### 4. Severity Prediction (Highway, Rain, Over-speeding, Night)
```bash
curl -s -X POST http://127.0.0.1:5000/api/predict \
  -H "Content-Type: application/json" \
  -d '{
    "road_type": "Highway",
    "weather_id": 2,
    "cause_id": 1,
    "hour_band": "Night"
  }'
```

### 5. Record New Accident (Transactional Insert)
```bash
curl -s -X POST http://127.0.0.1:5000/api/accidents \
  -H "Content-Type: application/json" \
  -d '{
    "accident_date": "2025-03-01",
    "accident_time": "22:15:00",
    "description": "Late evening highway sideswipe near overpass",
    "location_id": 1,
    "road_id": 1,
    "weather_id": 2,
    "severity_id": 2,
    "cause_id": 1,
    "vehicle_type_ids": [1, 2],
    "victims": [
      {
        "age": 28,
        "gender": "Male",
        "person_type": "Driver",
        "hospitalized": true,
        "injury_severity_id": 2
      }
    ]
  }'
```
