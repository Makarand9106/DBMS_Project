-- ============================================================================
-- Project: Road Accident Hotspot Analysis and Severity Prediction System
-- Component: Sample Dataset (DML)
-- Target RDBMS: MySQL 8.0+
-- Description: Hand-crafted realistic benchmark dataset reflecting 3NF schema,
--              hotspot distribution, highway/weather/speeding severity correlation,
--              and night-time severity skew.
-- ============================================================================

USE accident_db;

-- ----------------------------------------------------------------------------
-- 1. Insert Master Locations (8 locations)
-- ----------------------------------------------------------------------------
INSERT INTO location (location_id, location_name, district, latitude, longitude) VALUES
(1, 'Silk Board Interchange Junction', 'South Urban Sector', 12.917641, 77.623412),
(2, 'Kaggalipura Ghat Curve NH-48', 'Peripheral Valley', 12.783419, 77.512398),
(3, 'Trinity Metro Overpass Boulevard', 'Central Metro District', 12.973215, 77.620184),
(4, 'Airport Toll Plaza North Approach', 'North Corridor', 13.198920, 77.706810),
(5, 'Greenwood Village Crossing', 'Eastern Rural Belt', 12.934810, 77.749120),
(6, 'West End Industrial Gate 4', 'West Industrial Zone', 12.981240, 77.491280),
(7, 'Sunrise Valley Forest Road', 'Eastern Rural Belt', 12.894510, 77.721490),
(8, 'Lakeview Promenade South Bend', 'Central Metro District', 12.942180, 77.581930);

-- ----------------------------------------------------------------------------
-- 2. Insert Master Roads (6 roads: 2 Highways, 2 Urban, 2 Rural)
-- ----------------------------------------------------------------------------
INSERT INTO road (road_id, road_name, road_type, lanes, surface_type, speed_limit) VALUES
(1, 'NH-48 Express Highway', 'Highway', 6, 'Asphalt', 100),
(2, 'Eastern Bypass Expressway', 'Highway', 4, 'Concrete', 90),
(3, 'MG Arterial Corridor', 'Urban', 4, 'Asphalt', 50),
(4, 'Inner Ring Boulevard', 'Urban', 6, 'Asphalt', 60),
(5, 'Valley Foothills Pass', 'Rural', 2, 'Asphalt', 40),
(6, 'Riverside Country Lane', 'Rural', 2, 'Gravel', 35);

-- ----------------------------------------------------------------------------
-- 3. Insert Weather Conditions (5 conditions)
-- ----------------------------------------------------------------------------
INSERT INTO weather_condition (weather_id, condition_name) VALUES
(1, 'Clear'),
(2, 'Rain'),
(3, 'Fog'),
(4, 'Snow'),
(5, 'High Winds');

-- ----------------------------------------------------------------------------
-- 4. Insert Severities (3 standardized levels)
-- ----------------------------------------------------------------------------
INSERT INTO severity (severity_id, level_name, level_rank, description) VALUES
(1, 'Minor', 1, 'Minor injuries or vehicular cosmetic damage only; no hospitalization'),
(2, 'Serious', 2, 'Severe non-fatal injuries requiring emergency trauma care and hospitalization'),
(3, 'Fatal', 3, 'Fatalities confirmed at collision scene or during emergency transport');

-- ----------------------------------------------------------------------------
-- 5. Insert Accident Causes (6 causes across categories)
-- ----------------------------------------------------------------------------
INSERT INTO accident_cause (cause_id, cause_name, category) VALUES
(1, 'Over-speeding', 'Traffic Violation'),
(2, 'Drunk Driving', 'Human Error'),
(3, 'Distracted Driving', 'Human Error'),
(4, 'Poor Road Condition', 'Environmental'),
(5, 'Brake Failure', 'Mechanical'),
(6, 'Weather Hazard', 'Environmental');

-- ----------------------------------------------------------------------------
-- 6. Insert Vehicle Types (5 types)
-- ----------------------------------------------------------------------------
INSERT INTO vehicle_type (vehicle_type_id, type_name) VALUES
(1, 'Sedan'),
(2, 'SUV'),
(3, 'Motorcycle'),
(4, 'Truck'),
(5, 'Bus');

-- ----------------------------------------------------------------------------
-- 7. Insert Accidents (42 accidents across 2023-2025)
-- Hotspots: Location 1 (11 acc), Location 2 (10 acc), Location 3 (8 acc)
-- Correlation: Fatal accidents heavily skew to Highway (1,2), Rain/Fog (2,3), Over-speeding (1)
-- Night-time accidents skew to Serious (2) and Fatal (3)
-- ----------------------------------------------------------------------------
INSERT INTO accident (accident_id, accident_date, accident_time, description, location_id, road_id, weather_id, severity_id, cause_id) VALUES
-- Location 1: Silk Board Interchange Junction (Hotspot 1 - 11 accidents)
(1,  '2023-01-14', '23:35:00', 'Night multi-car collision at interchange ramp in dense fog', 1, 1, 3, 3, 1),
(2,  '2023-03-22', '02:15:00', 'High speed rollover off flyover entry in heavy rain', 1, 1, 2, 3, 1),
(3,  '2023-05-19', '18:45:00', 'Peak hour rear-end pileup on flyover approach', 1, 4, 1, 2, 3),
(4,  '2023-08-11', '08:30:00', 'Morning commuter sideswipe during sudden lane merge', 1, 4, 1, 1, 3),
(5,  '2023-11-04', '22:10:00', 'Late night speed-related crash involving freight truck', 1, 1, 2, 3, 1),
(6,  '2024-01-29', '01:50:00', 'Intoxicated driver struck median barrier at ramp', 1, 1, 3, 3, 2),
(7,  '2024-04-16', '14:20:00', 'Afternoon commercial vehicle brake failure on decline', 1, 4, 1, 2, 5),
(8,  '2024-07-09', '21:40:00', 'Night speeding collision on wet highway surface', 1, 1, 2, 3, 1),
(9,  '2024-10-02', '11:15:00', 'Daytime fender bender due to distracted navigation', 1, 4, 1, 1, 3),
(10, '2025-01-18', '23:05:00', 'Late evening severe head-on crash on slip road', 1, 1, 3, 3, 1),
(11, '2025-02-27', '19:30:00', 'Evening bus rear-ends stationary car in stop-and-go traffic', 1, 4, 2, 2, 1),

-- Location 2: Kaggalipura Ghat Curve NH-48 (Hotspot 2 - 10 accidents, high fatality)
(12, '2023-02-05', '03:10:00', 'Night truck lost control on sharp hairpin in thick fog', 2, 1, 3, 3, 1),
(13, '2023-04-18', '22:45:00', 'Speeding SUV plummeted off highway bend during monsoon rain', 2, 1, 2, 3, 1),
(14, '2023-07-23', '01:30:00', 'Night head-on collision between tanker and bus', 2, 1, 2, 3, 1),
(15, '2023-09-12', '15:40:00', 'Daytime brake failure on steep downhill slope', 2, 1, 1, 2, 5),
(16, '2023-12-30', '23:55:00', 'New year eve high-speed crash in dense winter fog', 2, 1, 3, 3, 1),
(17, '2024-03-08', '04:15:00', 'Early morning driver asleep at wheel on curved highway section', 2, 1, 3, 3, 2),
(18, '2024-06-21', '21:15:00', 'Torrential downpour aquaplaning into rock face', 2, 1, 2, 3, 1),
(19, '2024-09-14', '16:10:00', 'Late afternoon collision with livestock on ghat curve', 2, 5, 1, 2, 4),
(20, '2024-11-28', '02:40:00', 'Late night high-speed overturn in cold fog', 2, 1, 3, 3, 1),
(21, '2025-01-05', '20:50:00', 'Evening severe pileup on highway bend during flash rain', 2, 1, 2, 3, 1),

-- Location 3: Trinity Metro Overpass Boulevard (Hotspot 3 - 8 accidents)
(22, '2023-02-28', '09:10:00', 'Morning rush-hour collision near metro pillar base', 3, 3, 1, 1, 3),
(23, '2023-06-15', '17:25:00', 'Evening rain slippery road pedestrian impact', 3, 3, 2, 2, 4),
(24, '2023-10-10', '22:00:00', 'Night speeding motorcyclist clipped curb barrier', 3, 3, 1, 2, 1),
(25, '2024-02-14', '13:45:00', 'Afternoon delivery scooter sideswiped by urban transit bus', 3, 3, 1, 1, 3),
(26, '2024-05-30', '23:20:00', 'Late night intoxicated driver collision at metro intersection', 3, 3, 1, 2, 2),
(27, '2024-08-22', '08:45:00', 'Morning peak rear bumper damage in crawl traffic', 3, 3, 1, 1, 3),
(28, '2024-12-19', '19:15:00', 'Evening rain caused skidding into bridge support', 3, 3, 2, 2, 1),
(29, '2025-02-10', '18:10:00', 'Evening rush multi-vehicle minor squeeze', 3, 3, 1, 1, 3),

-- Location 4: Airport Toll Plaza North Approach (4 accidents)
(30, '2023-04-03', '03:40:00', 'High speed toll queue rear-end impact in early morning fog', 4, 2, 3, 3, 1),
(31, '2023-11-17', '12:15:00', 'Daytime lane divider grazing at high-speed ETC lane', 4, 2, 1, 1, 3),
(32, '2024-07-25', '22:30:00', 'Night speeding sedan spun on wet expressway asphalt', 4, 2, 2, 2, 1),
(33, '2025-01-22', '05:10:00', 'Predawn fog caused truck to strike toll barrier crash attenuator', 4, 2, 3, 2, 6),

-- Location 5: Greenwood Village Crossing (3 accidents)
(34, '2023-05-09', '14:50:00', 'Tractor cross-traffic collision with rural commuter bus', 5, 5, 1, 2, 4),
(35, '2024-03-24', '10:30:00', 'Morning pothole avoidance maneuver overturned small car', 5, 5, 1, 1, 4),
(36, '2024-10-18', '20:15:00', 'Night motorcycle collision with unlit bullock cart', 5, 5, 1, 2, 2),

-- Location 6: West End Industrial Gate 4 (3 accidents)
(37, '2023-06-30', '07:15:00', 'Morning shift change forklift and pickup truck impact', 6, 4, 1, 1, 3),
(38, '2024-02-02', '21:50:00', 'Heavy freight hauler brake failure on factory ring road', 6, 4, 2, 2, 5),
(39, '2024-11-12', '16:00:00', 'Afternoon cargo van reversed into pedestrian worker', 6, 4, 1, 1, 3),

-- Location 7: Sunrise Valley Forest Road (2 accidents)
(40, '2023-08-28', '23:15:00', 'Midnight rural road overturn during severe thunderstorm wind', 7, 6, 5, 2, 6),
(41, '2024-09-05', '06:30:00', 'Morning animal darted across rural road causing tree impact', 7, 6, 1, 1, 4),

-- Location 8: Lakeview Promenade South Bend (1 accident)
(42, '2024-04-09', '11:45:00', 'Midday bicycle and hatchback minor mirror strike on curve', 8, 3, 1, 1, 3);

-- ----------------------------------------------------------------------------
-- 8. Insert Accident-Vehicles (Junction Table: 1 to 3 vehicles per accident)
-- Total rows: 84 vehicle-accident associations
-- ----------------------------------------------------------------------------
INSERT INTO accident_vehicle (accident_id, vehicle_type_id) VALUES
-- Acc 1 (3 vehicles: Sedan, SUV, Truck)
(1, 1), (1, 2), (1, 4),
-- Acc 2 (1 vehicle: SUV)
(2, 2),
-- Acc 3 (3 vehicles: Sedan, SUV, Bus)
(3, 1), (3, 2), (3, 5),
-- Acc 4 (2 vehicles: Sedan, Motorcycle)
(4, 1), (4, 3),
-- Acc 5 (2 vehicles: Truck, Sedan)
(5, 4), (5, 1),
-- Acc 6 (1 vehicle: Sedan)
(6, 1),
-- Acc 7 (2 vehicles: Truck, Bus)
(7, 4), (7, 5),
-- Acc 8 (2 vehicles: SUV, Motorcycle)
(8, 2), (8, 3),
-- Acc 9 (2 vehicles: Sedan, Sedan) -> distinct type_id in junction: Sedan, SUV
(9, 1), (9, 2),
-- Acc 10 (2 vehicles: Truck, SUV)
(10, 4), (10, 2),
-- Acc 11 (2 vehicles: Bus, Sedan)
(11, 5), (11, 1),
-- Acc 12 (1 vehicle: Truck)
(12, 4),
-- Acc 13 (1 vehicle: SUV)
(13, 2),
-- Acc 14 (2 vehicles: Truck, Bus)
(14, 4), (14, 5),
-- Acc 15 (1 vehicle: Truck)
(15, 4),
-- Acc 16 (2 vehicles: SUV, Sedan)
(16, 2), (16, 1),
-- Acc 17 (1 vehicle: Sedan)
(17, 1),
-- Acc 18 (1 vehicle: SUV)
(18, 2),
-- Acc 19 (2 vehicles: Motorcycle, SUV)
(19, 3), (19, 2),
-- Acc 20 (1 vehicle: Sedan)
(20, 1),
-- Acc 21 (3 vehicles: SUV, Truck, Sedan)
(21, 2), (21, 4), (21, 1),
-- Acc 22 (2 vehicles: Sedan, Motorcycle)
(22, 1), (22, 3),
-- Acc 23 (1 vehicle: Sedan)
(23, 1),
-- Acc 24 (1 vehicle: Motorcycle)
(24, 3),
-- Acc 25 (2 vehicles: Motorcycle, Bus)
(25, 3), (25, 5),
-- Acc 26 (2 vehicles: Sedan, SUV)
(26, 1), (26, 2),
-- Acc 27 (2 vehicles: Sedan, Sedan) -> Sedan, SUV
(27, 1), (27, 2),
-- Acc 28 (1 vehicle: Sedan)
(28, 1),
-- Acc 29 (2 vehicles: Sedan, Motorcycle)
(29, 1), (29, 3),
-- Acc 30 (2 vehicles: Sedan, Truck)
(30, 1), (30, 4),
-- Acc 31 (1 vehicle: SUV)
(31, 2),
-- Acc 32 (1 vehicle: Sedan)
(32, 1),
-- Acc 33 (1 vehicle: Truck)
(33, 4),
-- Acc 34 (2 vehicles: Bus, Truck)
(34, 5), (34, 4),
-- Acc 35 (1 vehicle: Sedan)
(35, 1),
-- Acc 36 (2 vehicles: Motorcycle, Truck)
(36, 3), (36, 4),
-- Acc 37 (2 vehicles: Truck, Sedan)
(37, 4), (37, 1),
-- Acc 38 (1 vehicle: Truck)
(38, 4),
-- Acc 39 (1 vehicle: Truck)
(39, 4),
-- Acc 40 (1 vehicle: SUV)
(40, 2),
-- Acc 41 (1 vehicle: Sedan)
(41, 1),
-- Acc 42 (2 vehicles: Sedan, Motorcycle)
(42, 1), (42, 3);

-- ----------------------------------------------------------------------------
-- 9. Insert Victims (63 victims across the 42 accidents)
-- Realistic demographic distribution, injured personas, hospitalization, and severity
-- ----------------------------------------------------------------------------
INSERT INTO victim (victim_id, accident_id, age, gender, person_type, hospitalized, injury_severity_id) VALUES
-- Acc 1: Fatal (2 fatalities, 1 serious)
(1,  1,  34, 'Male',   'Driver',     TRUE,  3),
(2,  1,  29, 'Female', 'Passenger',  TRUE,  3),
(3,  1,  45, 'Male',   'Passenger',  TRUE,  2),
-- Acc 2: Fatal (1 fatality, 1 serious)
(4,  2,  27, 'Male',   'Driver',     TRUE,  3),
(5,  2,  25, 'Female', 'Passenger',  TRUE,  2),
-- Acc 3: Serious (2 serious)
(6,  3,  42, 'Male',   'Driver',     TRUE,  2),
(7,  3,  38, 'Female', 'Passenger',  TRUE,  2),
-- Acc 4: Minor (1 minor)
(8,  4,  23, 'Male',   'Driver',     FALSE, 1),
-- Acc 5: Fatal (1 fatality, 1 serious)
(9,  5,  51, 'Male',   'Driver',     TRUE,  3),
(10, 5,  30, 'Male',   'Passenger',  TRUE,  2),
-- Acc 6: Fatal (1 fatality)
(11, 6,  28, 'Male',   'Driver',     TRUE,  3),
-- Acc 7: Serious (1 serious, 1 minor)
(12, 7,  49, 'Male',   'Driver',     TRUE,  2),
(13, 7,  32, 'Female', 'Passenger',  FALSE, 1),
-- Acc 8: Fatal (1 fatality)
(14, 8,  24, 'Male',   'Driver',     TRUE,  3),
-- Acc 9: Minor (1 minor)
(15, 9,  36, 'Female', 'Driver',     FALSE, 1),
-- Acc 10: Fatal (2 fatalities)
(16, 10, 39, 'Male',   'Driver',     TRUE,  3),
(17, 10, 37, 'Female', 'Passenger',  TRUE,  3),
-- Acc 11: Serious (1 serious)
(18, 11, 56, 'Male',   'Passenger',  TRUE,  2),
-- Acc 12: Fatal (1 fatality, 1 serious)
(19, 12, 43, 'Male',   'Driver',     TRUE,  3),
(20, 12, 38, 'Male',   'Passenger',  TRUE,  2),
-- Acc 13: Fatal (2 fatalities)
(21, 13, 31, 'Male',   'Driver',     TRUE,  3),
(22, 13, 28, 'Female', 'Passenger',  TRUE,  3),
-- Acc 14: Fatal (2 fatalities, 2 serious)
(23, 14, 48, 'Male',   'Driver',     TRUE,  3),
(24, 14, 52, 'Male',   'Driver',     TRUE,  3),
(25, 14, 22, 'Female', 'Passenger',  TRUE,  2),
(26, 14, 35, 'Male',   'Passenger',  TRUE,  2),
-- Acc 15: Serious (1 serious)
(27, 15, 41, 'Male',   'Driver',     TRUE,  2),
-- Acc 16: Fatal (1 fatality, 1 serious)
(28, 16, 26, 'Male',   'Driver',     TRUE,  3),
(29, 16, 24, 'Male',   'Passenger',  TRUE,  2),
-- Acc 17: Fatal (1 fatality)
(30, 17, 33, 'Male',   'Driver',     TRUE,  3),
-- Acc 18: Fatal (1 fatality, 1 serious)
(31, 18, 40, 'Female', 'Driver',     TRUE,  3),
(32, 18, 19, 'Male',   'Passenger',  TRUE,  2),
-- Acc 19: Serious (1 serious)
(33, 19, 29, 'Male',   'Driver',     TRUE,  2),
-- Acc 20: Fatal (1 fatality)
(34, 20, 35, 'Male',   'Driver',     TRUE,  3),
-- Acc 21: Fatal (2 fatalities, 1 serious)
(35, 21, 46, 'Male',   'Driver',     TRUE,  3),
(36, 21, 44, 'Female', 'Passenger',  TRUE,  3),
(37, 21, 12, 'Male',   'Passenger',  TRUE,  2),
-- Acc 22: Minor (1 minor)
(38, 22, 27, 'Male',   'Driver',     FALSE, 1),
-- Acc 23: Serious (1 pedestrian serious)
(39, 23, 62, 'Female', 'Pedestrian', TRUE,  2),
-- Acc 24: Serious (1 driver serious)
(40, 24, 21, 'Male',   'Driver',     TRUE,  2),
-- Acc 25: Minor (1 minor)
(41, 25, 25, 'Male',   'Driver',     FALSE, 1),
-- Acc 26: Serious (1 serious)
(42, 26, 33, 'Male',   'Driver',     TRUE,  2),
-- Acc 27: Minor (1 minor)
(43, 27, 44, 'Male',   'Driver',     FALSE, 1),
-- Acc 28: Serious (1 driver serious, 1 passenger minor)
(44, 28, 38, 'Female', 'Driver',     TRUE,  2),
(45, 28, 15, 'Female', 'Passenger',  FALSE, 1),
-- Acc 29: Minor (1 minor)
(46, 29, 31, 'Male',   'Driver',     FALSE, 1),
-- Acc 30: Fatal (1 fatality, 1 serious)
(47, 30, 29, 'Male',   'Driver',     TRUE,  3),
(48, 30, 27, 'Female', 'Passenger',  TRUE,  2),
-- Acc 31: Minor (1 minor)
(49, 31, 50, 'Male',   'Driver',     FALSE, 1),
-- Acc 32: Serious (1 serious)
(50, 32, 34, 'Male',   'Driver',     TRUE,  2),
-- Acc 33: Serious (1 serious)
(51, 33, 47, 'Male',   'Driver',     TRUE,  2),
-- Acc 34: Serious (2 serious)
(52, 34, 55, 'Male',   'Driver',     TRUE,  2),
(53, 34, 40, 'Female', 'Passenger',  TRUE,  2),
-- Acc 35: Minor (1 minor)
(54, 35, 36, 'Female', 'Driver',     FALSE, 1),
-- Acc 36: Serious (1 serious)
(55, 36, 23, 'Male',   'Driver',     TRUE,  2),
-- Acc 37: Minor (1 minor)
(56, 37, 42, 'Male',   'Driver',     FALSE, 1),
-- Acc 38: Serious (1 serious)
(57, 38, 53, 'Male',   'Driver',     TRUE,  2),
-- Acc 39: Minor (1 pedestrian minor)
(58, 39, 30, 'Male',   'Pedestrian', FALSE, 1),
-- Acc 40: Serious (1 serious)
(59, 40, 37, 'Female', 'Driver',     TRUE,  2),
-- Acc 41: Minor (1 minor)
(60, 41, 48, 'Male',   'Driver',     FALSE, 1),
-- Acc 42: Minor (1 minor, 1 pedestrian minor)
(61, 42, 26, 'Female', 'Driver',     FALSE, 1),
(62, 42, 19, 'Male',   'Pedestrian', FALSE, 1);
