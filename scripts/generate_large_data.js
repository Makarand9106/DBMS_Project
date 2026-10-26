// ============================================================================
// Script: generate_large_data.js
// Description: Generates realistic, non-uniform dataset with CLEAR VISIBLE
//              DIFFERENCES across causes, weathers, locations, and monthly trends,
//              while guaranteeing 100% coverage of all 360 condition combinations.
// ============================================================================

const fs = require('fs');
const path = require('path');

const targetSqlFile = path.join(__dirname, '..', 'sql', 'data.sql');

// Master Catalogs
const locations = [
  { id: 1, name: 'Silk Board Interchange Junction', district: 'South Urban Sector', lat: 12.917641, lon: 77.623412 },
  { id: 2, name: 'Kaggalipura Ghat Curve NH-48', district: 'Peripheral Valley', lat: 12.783419, lon: 77.512398 },
  { id: 3, name: 'Trinity Metro Overpass Boulevard', district: 'Central Metro District', lat: 12.973215, lon: 77.620184 },
  { id: 4, name: 'Airport Toll Plaza North Approach', district: 'North Corridor', lat: 13.198920, lon: 77.706810 },
  { id: 5, name: 'Greenwood Village Crossing', district: 'Eastern Rural Belt', lat: 12.934810, lon: 77.749120 },
  { id: 6, name: 'West End Industrial Gate 4', district: 'West Industrial Zone', lat: 12.981240, lon: 77.491280 },
  { id: 7, name: 'Sunrise Valley Forest Road', district: 'Eastern Rural Belt', lat: 12.894510, lon: 77.721490 },
  { id: 8, name: 'Lakeview Promenade South Bend', district: 'Central Metro District', lat: 12.942180, lon: 77.581930 },
  { id: 9, name: 'Electronic City Elevated Expressway', district: 'South Urban Sector', lat: 12.845210, lon: 77.660190 },
  { id: 10, name: 'Nelamangala Highway Flyover Split', district: 'North Corridor', lat: 13.098420, lon: 77.387610 }
];

const roads = [
  { id: 1, name: 'NH-48 Express Highway', type: 'Highway', lanes: 6, surface: 'Asphalt', speed: 100 },
  { id: 2, name: 'Eastern Bypass Expressway', type: 'Highway', lanes: 4, surface: 'Concrete', speed: 90 },
  { id: 3, name: 'MG Arterial Corridor', type: 'Urban', lanes: 4, surface: 'Asphalt', speed: 50 },
  { id: 4, name: 'Inner Ring Boulevard', type: 'Urban', lanes: 6, surface: 'Asphalt', speed: 60 },
  { id: 5, name: 'Valley Foothills Pass', type: 'Rural', lanes: 2, surface: 'Asphalt', speed: 40 },
  { id: 6, name: 'Riverside Country Lane', type: 'Rural', lanes: 2, surface: 'Gravel', speed: 35 },
  { id: 7, name: 'Elevated Expressway Flyover Sect', type: 'Highway', lanes: 4, surface: 'Asphalt', speed: 80 },
  { id: 8, name: 'Old Suburb Industrial Arterial', type: 'Urban', lanes: 2, surface: 'Concrete', speed: 45 }
];

const weathers = [
  { id: 1, name: 'Clear' },
  { id: 2, name: 'Rain' },
  { id: 3, name: 'Fog' },
  { id: 4, name: 'Snow' },
  { id: 5, name: 'High Winds' }
];

const causes = [
  { id: 1, name: 'Over-speeding', category: 'Traffic Violation' },
  { id: 2, name: 'Drunk Driving', category: 'Human Error' },
  { id: 3, name: 'Distracted Driving', category: 'Human Error' },
  { id: 4, name: 'Poor Road Condition', category: 'Environmental' },
  { id: 5, name: 'Brake Failure', category: 'Mechanical' },
  { id: 6, name: 'Weather Hazard', category: 'Environmental' }
];

const hourBands = [
  { band: 'Morning', times: ['07:15:00', '08:30:00', '09:45:00', '10:50:00', '11:20:00'] },
  { band: 'Afternoon', times: ['12:30:00', '13:45:00', '14:20:00', '15:15:00', '16:40:00'] },
  { band: 'Evening', times: ['17:10:00', '18:25:00', '19:15:00', '19:50:00', '20:35:00'] },
  { band: 'Night', times: ['21:40:00', '22:50:00', '23:35:00', '01:20:00', '02:45:00', '03:15:00', '04:30:00'] }
];

// Helper to choose road for a given roadType
function getRoadForType(roadType, seed) {
  const eligible = roads.filter(r => r.type === roadType);
  return eligible[seed % eligible.length];
}

// Pseudo-random with seed
function seededRandom(seed) {
  const x = Math.sin(seed) * 10000;
  return x - Math.floor(x);
}

// Risk calculation determining severity probabilities
function computeSeverity(roadType, weatherId, causeId, hourBand, seed) {
  let risk = 0;
  if (roadType === 'Highway') risk += 35;
  else if (roadType === 'Rural') risk += 20;
  else risk += 10;

  if (weatherId === 3 || weatherId === 4) risk += 30; // Fog, Snow
  else if (weatherId === 2 || weatherId === 5) risk += 20; // Rain, High Winds
  else risk += 5; // Clear

  if (causeId === 1 || causeId === 2) risk += 35; // Over-speeding, Drunk Driving
  else if (causeId === 5 || causeId === 6) risk += 20; // Brake Failure, Weather Hazard
  else risk += 5; // Distracted Driving, Poor Road

  if (hourBand === 'Night') risk += 30;
  else if (hourBand === 'Evening') risk += 15;
  else if (hourBand === 'Afternoon') risk += 10;
  else risk += 0;

  // Total risk between 20 and 130
  const rand = seededRandom(seed) * 100;
  if (risk >= 85) {
    // Mostly Fatal, some Serious
    if (rand < 75) return 3; // Fatal
    if (rand < 95) return 2; // Serious
    return 1; // Minor
  } else if (risk >= 55) {
    // Mostly Serious, mixed Fatal & Minor
    if (rand < 30) return 3; // Fatal
    if (rand < 80) return 2; // Serious
    return 1; // Minor
  } else {
    // Mostly Minor
    if (rand < 10) return 3; // Fatal
    if (rand < 35) return 2; // Serious
    return 1; // Minor
  }
}

// Pick location matching road type with clear hotspot clustering
function pickLocation(roadType, seed) {
  const r = seededRandom(seed);
  if (roadType === 'Highway') {
    // Hotspots: Kaggalipura Ghat (2) 35%, Silk Board (1) 30%, Electronic City (9) 15%, Airport Toll (4) 10%, Nelamangala (10) 10%
    if (r < 0.35) return 2;
    if (r < 0.65) return 1;
    if (r < 0.80) return 9;
    if (r < 0.90) return 4;
    return 10;
  } else if (roadType === 'Urban') {
    // Silk Board (1) 40%, Trinity Metro (3) 35%, West End (6) 15%, Lakeview (8) 10%
    if (r < 0.40) return 1;
    if (r < 0.75) return 3;
    if (r < 0.90) return 6;
    return 8;
  } else {
    // Rural: Greenwood (5) 45%, Sunrise Valley (7) 35%, Kaggalipura (2) 20%
    if (r < 0.45) return 5;
    if (r < 0.80) return 7;
    return 2;
  }
}

// Generate organic date with realistic monthly seasonality (Peaks in Monsoon Jul/Aug and Winter Dec/Jan)
function pickSeasonalDate(weatherId, seed) {
  const yearOptions = [2023, 2024, 2025];
  const year = yearOptions[Math.floor(seededRandom(seed * 3) * yearOptions.length)];

  let month;
  const randM = seededRandom(seed * 7);

  // Weather-driven seasonal alignment
  if (weatherId === 2) {
    // Rain concentrated in monsoon (June to October)
    const monsoonMonths = [6, 7, 7, 8, 8, 9, 10];
    month = monsoonMonths[Math.floor(randM * monsoonMonths.length)];
  } else if (weatherId === 3 || weatherId === 4) {
    // Fog / Snow concentrated in winter (Nov, Dec, Jan, Feb)
    const winterMonths = [11, 12, 12, 1, 1, 2];
    month = winterMonths[Math.floor(randM * winterMonths.length)];
  } else {
    // General distribution with natural seasonal curve:
    // Jan(1.2), Feb(0.6), Mar(0.6), Apr(0.7), May(0.9), Jun(1.5), Jul(1.8), Aug(1.4), Sep(1.0), Oct(1.3), Nov(1.4), Dec(1.7)
    const seasonalWeights = [
      1, 1,
      2,
      3,
      4,
      5, 5,
      6, 6, 6,
      7, 7, 7, 7,
      8, 8, 8,
      9, 9,
      10, 10, 10,
      11, 11, 11,
      12, 12, 12, 12
    ];
    month = seasonalWeights[Math.floor(randM * seasonalWeights.length)];
  }

  const day = 1 + Math.floor(seededRandom(seed * 11) * 28);
  return `${year}-${String(month).padStart(2, '0')}-${String(day).padStart(2, '0')}`;
}

const accidents = [];
const vehicleRows = [];
const victimRows = [];

let accId = 1;
let vicId = 1;
let globalSeed = 100;

// ============================================================================
// PHASE 1: Mandatory Full 360 Combination Coverage (1 baseline case each)
// Guarantees that every possible dropdown combination finds a match!
// ============================================================================
for (const roadType of ['Highway', 'Urban', 'Rural']) {
  for (const weather of weathers) {
    for (const cause of causes) {
      for (const hb of hourBands) {
        globalSeed++;
        const currentAccId = accId++;
        const sevId = computeSeverity(roadType, weather.id, cause.id, hb.band, globalSeed);
        const road = getRoadForType(roadType, globalSeed);
        const locId = pickLocation(roadType, globalSeed);
        const accDate = pickSeasonalDate(weather.id, globalSeed);
        const accTime = hb.times[globalSeed % hb.times.length];
        const desc = `${hb.band} collision on ${road.name} under ${weather.name} conditions (${cause.name})`;

        accidents.push({
          id: currentAccId,
          date: accDate,
          time: accTime,
          desc,
          locId,
          roadId: road.id,
          roadType,
          weatherId: weather.id,
          sevId,
          causeId: cause.id,
          hb: hb.band
        });

        // Vehicles
        const vCount = 1 + Math.floor(seededRandom(globalSeed * 5) * 3);
        const vSet = new Set();
        vSet.add(roadType === 'Highway' ? 4 : (roadType === 'Urban' ? 1 : 3));
        if (vCount >= 2) vSet.add((globalSeed % 5) + 1);
        if (vCount >= 3) vSet.add(((globalSeed + 2) % 5) + 1);
        vSet.forEach(vId => vehicleRows.push(`(${currentAccId}, ${vId})`));

        // Victims
        const vAge = 18 + Math.floor(seededRandom(globalSeed * 13) * 50);
        const vGender = seededRandom(globalSeed * 17) > 0.4 ? 'Male' : 'Female';
        const pType = sevId === 3 && seededRandom(globalSeed * 19) > 0.7 ? 'Pedestrian' : 'Driver';
        victimRows.push(`(${vicId++}, ${currentAccId}, ${vAge}, '${vGender}', '${pType}', ${sevId >= 2 ? 'TRUE' : 'FALSE'}, ${sevId})`);

        if (sevId >= 2 && seededRandom(globalSeed * 23) > 0.4) {
          const v2Age = 19 + Math.floor(seededRandom(globalSeed * 29) * 45);
          victimRows.push(`(${vicId++}, ${currentAccId}, ${v2Age}, '${vGender === 'Male' ? 'Female' : 'Male'}', 'Passenger', TRUE, ${sevId})`);
        }
      }
    }
  }
}

console.log(`Phase 1 complete: ${accidents.length} baseline cases covering all 360 combinations.`);

// ============================================================================
// PHASE 2: Proportional Realistic Additions to Create Prominent Visual Differences
// Adds ~480 extra cases with realistic disparities in:
// - Weather volume (Clear >> Rain > Fog >> High Winds / Snow)
// - Causes (Over-speeding & Distracted Driving dominate total counts; Drunk driving has high fatal ratio)
// - Hotspot clustering (Silk Board & Kaggalipura dominate)
// - Monthly seasonality peaks (Monsoon Jul/Aug and Winter Dec/Jan)
// ============================================================================

// Realistic extra quotas
const extraDistributions = [
  // 1. Over-speeding on Highways (High Fatal, huge volume)
  { count: 120, roadType: 'Highway', weatherIds: [1, 2, 3], causeId: 1, hourBands: ['Night', 'Evening', 'Night'] },
  // 2. Distracted Driving in Urban Areas (Huge volume, mostly Minor, low fatal!)
  { count: 110, roadType: 'Urban', weatherIds: [1, 1, 2], causeId: 3, hourBands: ['Morning', 'Afternoon', 'Evening'] },
  // 3. Clear Weather Urban Traffic (Fender benders, peak rush hour)
  { count: 90, roadType: 'Urban', weatherIds: [1], causeId: 3, hourBands: ['Morning', 'Afternoon'] },
  // 4. Drunk Driving at Night (High severity, moderate volume)
  { count: 65, roadType: 'Highway', weatherIds: [1, 2, 3], causeId: 2, hourBands: ['Night'] },
  // 5. Rain Monsoon Crashes (Heavy July/August spike)
  { count: 60, roadType: 'Highway', weatherIds: [2], causeId: 1, hourBands: ['Night', 'Evening'] },
  // 6. Poor Road Condition / Potholes (Rural & Industrial roads)
  { count: 35, roadType: 'Rural', weatherIds: [1, 2], causeId: 4, hourBands: ['Afternoon', 'Evening'] }
];

for (const group of extraDistributions) {
  for (let i = 0; i < group.count; i++) {
    globalSeed++;
    const currentAccId = accId++;
    const weatherId = group.weatherIds[i % group.weatherIds.length];
    const hb = group.hourBands[i % group.hourBands.length];
    const hbObj = hourBands.find(h => h.band === hb);
    const sevId = computeSeverity(group.roadType, weatherId, group.causeId, hb, globalSeed);
    const road = getRoadForType(group.roadType, globalSeed);
    const locId = pickLocation(group.roadType, globalSeed);
    const accDate = pickSeasonalDate(weatherId, globalSeed);
    const accTime = hbObj.times[globalSeed % hbObj.times.length];
    const weatherObj = weathers.find(w => w.id === weatherId);
    const causeObj = causes.find(c => c.id === group.causeId);
    const desc = `${hb} incident on ${road.name} (${causeObj.name})`;

    accidents.push({
      id: currentAccId,
      date: accDate,
      time: accTime,
      desc,
      locId,
      roadId: road.id,
      roadType: group.roadType,
      weatherId,
      sevId,
      causeId: group.causeId,
      hb
    });

    // Vehicles
    const vSet = new Set();
    vSet.add(group.roadType === 'Highway' ? (i % 2 === 0 ? 4 : 2) : 1);
    if (i % 2 === 1) vSet.add((globalSeed % 5) + 1);
    vSet.forEach(vId => vehicleRows.push(`(${currentAccId}, ${vId})`));

    // Victims
    const vAge = 20 + Math.floor(seededRandom(globalSeed * 13) * 45);
    const vGender = i % 2 === 0 ? 'Male' : 'Female';
    victimRows.push(`(${vicId++}, ${currentAccId}, ${vAge}, '${vGender}', 'Driver', ${sevId >= 2 ? 'TRUE' : 'FALSE'}, ${sevId})`);

    if (sevId >= 2 && i % 3 === 0) {
      victimRows.push(`(${vicId++}, ${currentAccId}, ${vAge + 4}, '${vGender === 'Male' ? 'Female' : 'Male'}', 'Passenger', TRUE, ${sevId})`);
    }
  }
}

console.log(`Total generated accidents: ${accidents.length}`);
console.log(`Total vehicles: ${vehicleRows.length}, Total victims: ${victimRows.length}`);

// Print statistical summary to verify visual differences
const causeCounts = {};
causes.forEach(c => causeCounts[c.name] = { total: 0, fatal: 0 });
accidents.forEach(a => {
  const cName = causes.find(c => c.id === a.causeId).name;
  causeCounts[cName].total++;
  if (a.sevId === 3) causeCounts[cName].fatal++;
});

console.log('\n--- ACCIDENTS BY CAUSE (Clear Disparities) ---');
console.table(causeCounts);

const weatherCounts = {};
weathers.forEach(w => weatherCounts[w.name] = { total: 0, fatal: 0, minor: 0, serious: 0 });
accidents.forEach(a => {
  const wName = weathers.find(w => w.id === a.weatherId).name;
  weatherCounts[wName].total++;
  if (a.sevId === 3) weatherCounts[wName].fatal++;
  if (a.sevId === 2) weatherCounts[wName].serious++;
  if (a.sevId === 1) weatherCounts[wName].minor++;
});

console.log('\n--- ACCIDENTS BY WEATHER (Clear Disparities) ---');
console.table(weatherCounts);

// Write SQL File
const accidentSqlValues = accidents.map(a =>
  `(${a.id}, '${a.date}', '${a.time}', '${a.desc.replace(/'/g, "''")}', ${a.locId}, ${a.roadId}, ${a.weatherId}, ${a.sevId}, ${a.causeId})`
).join(',\n');

const sqlOutput = `-- ============================================================================
-- Project: Road Accident Hotspot Analysis and Severity Prediction System
-- Component: Dynamic Benchmark Dataset (DML) with Real-world Variation
-- Total Accidents: ${accidents.length} (Full 360-case coverage + prominent variations)
-- ============================================================================

USE accident_db;

SET FOREIGN_KEY_CHECKS = 0;
TRUNCATE TABLE victim;
TRUNCATE TABLE accident_vehicle;
TRUNCATE TABLE accident;
TRUNCATE TABLE vehicle_type;
TRUNCATE TABLE accident_cause;
TRUNCATE TABLE severity;
TRUNCATE TABLE weather_condition;
TRUNCATE TABLE road;
TRUNCATE TABLE location;
SET FOREIGN_KEY_CHECKS = 1;

-- 1. Master Locations (10 locations)
INSERT INTO location (location_id, location_name, district, latitude, longitude) VALUES
${locations.map(l => `(${l.id}, '${l.name}', '${l.district}', ${l.lat}, ${l.lon})`).join(',\n')};

-- 2. Master Roads (8 roadways)
INSERT INTO road (road_id, road_name, road_type, lanes, surface_type, speed_limit) VALUES
${roads.map(r => `(${r.id}, '${r.name}', '${r.type}', ${r.lanes}, '${r.surface}', ${r.speed})`).join(',\n')};

-- 3. Weather Conditions (5 standard conditions)
INSERT INTO weather_condition (weather_id, condition_name) VALUES
${weathers.map(w => `(${w.id}, '${w.name}')`).join(',\n')};

-- 4. Severities (3 standardized levels)
INSERT INTO severity (severity_id, level_name, level_rank, description) VALUES
(1, 'Minor', 1, 'Minor injuries or vehicular cosmetic damage only; no hospitalization'),
(2, 'Serious', 2, 'Severe non-fatal injuries requiring emergency trauma care and hospitalization'),
(3, 'Fatal', 3, 'Fatalities confirmed at collision scene or during emergency transport');

-- 5. Accident Causes (6 standardized causes)
INSERT INTO accident_cause (cause_id, cause_name, category) VALUES
${causes.map(c => `(${c.id}, '${c.name}', '${c.category}')`).join(',\n')};

-- 6. Vehicle Types (5 types)
INSERT INTO vehicle_type (vehicle_type_id, type_name) VALUES
(1, 'Sedan'),
(2, 'SUV'),
(3, 'Motorcycle'),
(4, 'Truck'),
(5, 'Bus');

-- 7. Accidents (${accidents.length} incidents)
INSERT INTO accident (accident_id, accident_date, accident_time, description, location_id, road_id, weather_id, severity_id, cause_id) VALUES
${accidentSqlValues};

-- 8. Accident-Vehicles (${vehicleRows.length} junction rows)
INSERT INTO accident_vehicle (accident_id, vehicle_type_id) VALUES
${vehicleRows.join(',\n')};

-- 9. Victims (${victimRows.length} victim records)
INSERT INTO victim (victim_id, accident_id, age, gender, person_type, hospitalized, injury_severity_id) VALUES
${victimRows.join(',\n')};
`;

fs.writeFileSync(targetSqlFile, sqlOutput, 'utf8');
console.log('\nSuccessfully generated and saved to:', targetSqlFile);
