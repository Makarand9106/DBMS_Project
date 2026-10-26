-- ============================================================================
-- Project: Road Accident Hotspot Analysis and Severity Prediction System
-- Component: Sample Dataset (DML) - Extended Benchmark Dataset
-- Target RDBMS: MySQL 8.0+
-- Description: Realistic benchmark dataset reflecting 3NF schema, 10 locations,
--              8 roadways, 100 detailed accidents spread across 2023-2025,
--              distinct hotspot rankings, high correlation with weather/speeding,
--              and night-time severity skew.
-- ============================================================================

USE accident_db;

-- Clear previous data in correct foreign-key reverse dependency order
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

-- ----------------------------------------------------------------------------
-- 1. Insert Master Locations (10 locations)
-- ----------------------------------------------------------------------------
INSERT INTO location (location_id, location_name, district, latitude, longitude) VALUES
(1,  'Silk Board Interchange Junction',      'South Urban Sector',    12.917641, 77.623412),
(2,  'Kaggalipura Ghat Curve NH-48',         'Peripheral Valley',     12.783419, 77.512398),
(3,  'Trinity Metro Overpass Boulevard',     'Central Metro District',12.973215, 77.620184),
(4,  'Airport Toll Plaza North Approach',    'North Corridor',        13.198920, 77.706810),
(5,  'Greenwood Village Crossing',           'Eastern Rural Belt',    12.934810, 77.749120),
(6,  'West End Industrial Gate 4',           'West Industrial Zone',  12.981240, 77.491280),
(7,  'Sunrise Valley Forest Road',           'Eastern Rural Belt',    12.894510, 77.721490),
(8,  'Lakeview Promenade South Bend',        'Central Metro District',12.942180, 77.581930),
(9,  'Electronic City Elevated Expressway',  'South Urban Sector',    12.845210, 77.660190),
(10, 'Nelamangala Highway Flyover Split',    'North Corridor',        13.098420, 77.387610);

-- ----------------------------------------------------------------------------
-- 2. Insert Master Roads (8 roads: Highways, Urban, Rural)
-- ----------------------------------------------------------------------------
INSERT INTO road (road_id, road_name, road_type, lanes, surface_type, speed_limit) VALUES
(1, 'NH-48 Express Highway',            'Highway', 6, 'Asphalt',  100),
(2, 'Eastern Bypass Expressway',        'Highway', 4, 'Concrete',  90),
(3, 'MG Arterial Corridor',             'Urban',   4, 'Asphalt',   50),
(4, 'Inner Ring Boulevard',             'Urban',   6, 'Asphalt',   60),
(5, 'Valley Foothills Pass',            'Rural',   2, 'Asphalt',   40),
(6, 'Riverside Country Lane',           'Rural',   2, 'Gravel',    35),
(7, 'Elevated Expressway Flyover Sect', 'Highway', 4, 'Asphalt',   80),
(8, 'Old Suburb Industrial Arterial',   'Urban',   2, 'Concrete',  45);

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
(1, 'Minor',   1, 'Minor injuries or vehicular cosmetic damage only; no hospitalization'),
(2, 'Serious', 2, 'Severe non-fatal injuries requiring emergency trauma care and hospitalization'),
(3, 'Fatal',   3, 'Fatalities confirmed at collision scene or during emergency transport');

-- ----------------------------------------------------------------------------
-- 5. Insert Accident Causes (6 causes across categories)
-- ----------------------------------------------------------------------------
INSERT INTO accident_cause (cause_id, cause_name, category) VALUES
(1, 'Over-speeding',         'Traffic Violation'),
(2, 'Drunk Driving',         'Human Error'),
(3, 'Distracted Driving',    'Human Error'),
(4, 'Poor Road Condition',   'Environmental'),
(5, 'Brake Failure',         'Mechanical'),
(6, 'Weather Hazard',        'Environmental');

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
-- 7. Insert 100 Accidents (Spread across 2023 - 2025)
-- Hotspot Distribution:
--   Location 2 (Kaggalipura Ghat): ~24 accidents (heavy fatal, High Risk #1)
--   Location 1 (Silk Board): ~22 accidents (heavy volume, serious/fatal #2)
--   Location 3 (Trinity Metro): ~16 accidents (urban congestion, minor/serious #3)
--   Location 9 (Electronic City Expressway): ~10 accidents (#4)
--   Location 10 (Nelamangala Split): ~8 accidents (#5)
--   Locations 4-8: 20 accidents distributed
-- ----------------------------------------------------------------------------
INSERT INTO accident (accident_id, accident_date, accident_time, description, location_id, road_id, weather_id, severity_id, cause_id) VALUES
-- Location 1: Silk Board Interchange Junction (22 accidents)
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
(12, '2023-02-12', '22:50:00', 'Sedan sideswipes truck during aggressive overtaking', 1, 1, 1, 2, 1),
(13, '2023-06-25', '17:40:00', 'Monsoon rain caused vehicle pileup near bus stop', 1, 4, 2, 2, 4),
(14, '2023-09-18', '08:15:00', 'Commuter motorcycle skid on oil spill', 1, 4, 1, 1, 4),
(15, '2023-12-05', '23:25:00', 'Truck rammed safety guardrail in foggy night', 1, 1, 3, 3, 1),
(16, '2024-03-14', '03:10:00', 'Late night speeding SUV overturned at ramp junction', 1, 1, 1, 3, 1),
(17, '2024-06-19', '18:50:00', 'Evening bumper scrape in congested exit lane', 1, 4, 1, 1, 3),
(18, '2024-08-30', '21:15:00', 'Drunk driver crossed painted chevron into truck path', 1, 1, 2, 3, 2),
(19, '2024-11-22', '13:30:00', 'Delivery van brake failure at toll queue', 1, 4, 1, 2, 5),
(20, '2025-01-28', '22:40:00', 'Two motorcycles collided head on during road work', 1, 4, 2, 2, 1),
(21, '2025-02-15', '00:30:00', 'Midnight speeding vehicle missed elevated turn', 1, 1, 3, 3, 1),
(22, '2025-03-02', '10:45:00', 'Midday sideswipe between taxi and auto rickshaw', 1, 4, 1, 1, 3),

-- Location 2: Kaggalipura Ghat Curve NH-48 (24 accidents - Top Hazard Zone)
(23, '2023-02-05', '03:10:00', 'Night truck lost control on sharp hairpin in thick fog', 2, 1, 3, 3, 1),
(24, '2023-04-18', '22:45:00', 'Speeding SUV plummeted off highway bend during monsoon rain', 2, 1, 2, 3, 1),
(25, '2023-07-23', '01:30:00', 'Night head-on collision between tanker and bus', 2, 1, 2, 3, 1),
(26, '2023-09-12', '15:40:00', 'Daytime brake failure on steep downhill slope', 2, 1, 1, 2, 5),
(27, '2023-12-30', '23:55:00', 'New year eve high-speed crash in dense winter fog', 2, 1, 3, 3, 1),
(28, '2024-03-08', '04:15:00', 'Early morning driver asleep at wheel on curved highway section', 2, 1, 3, 3, 2),
(29, '2024-06-21', '21:15:00', 'Torrential downpour aquaplaning into rock face', 2, 1, 2, 3, 1),
(30, '2024-09-14', '16:10:00', 'Late afternoon collision with livestock on ghat curve', 2, 5, 1, 2, 4),
(31, '2024-11-28', '02:40:00', 'Late night high-speed overturn in cold fog', 2, 1, 3, 3, 1),
(32, '2025-01-05', '20:50:00', 'Evening severe pileup on highway bend during flash rain', 2, 1, 2, 3, 1),
(33, '2023-01-22', '01:10:00', 'Cement truck lost brakes on sharp hairpin curve', 2, 1, 3, 3, 5),
(34, '2023-03-15', '23:45:00', 'Monsoon rain caused head-on impact between two cars', 2, 1, 2, 3, 1),
(35, '2023-05-28', '04:00:00', 'Predawn fog collision with boulder on shoulder', 2, 1, 3, 3, 6),
(36, '2023-08-04', '22:20:00', 'Reckless passenger bus speeding around hairpin turn', 2, 1, 2, 3, 1),
(37, '2023-10-19', '14:35:00', 'Daytime motorcycle overturned due to gravel gravel patch', 2, 5, 1, 2, 4),
(38, '2024-01-10', '02:50:00', 'Dense morning fog caused blind-spot truck crash', 2, 1, 3, 3, 1),
(39, '2024-04-05', '21:30:00', 'Drunk driver drifted off highway into valley ditch', 2, 1, 2, 3, 2),
(40, '2024-07-18', '23:10:00', 'Speeding luxury SUV hydroplaned into rock wall', 2, 1, 2, 3, 1),
(41, '2024-10-25', '03:20:00', 'Cargo container toppled over guardrail in fog', 2, 1, 3, 3, 1),
(42, '2024-12-14', '20:45:00', 'Multi-car pileup during sudden winter squall', 2, 1, 5, 2, 6),
(43, '2025-01-12', '01:40:00', 'High speed collision between interstate sleeper bus and van', 2, 1, 3, 3, 1),
(44, '2025-02-04', '22:15:00', 'Night speeding motorbike struck by overtaking truck', 2, 1, 2, 3, 1),
(45, '2025-02-22', '16:00:00', 'Downhill brake fading forced truck onto escape ramp', 2, 1, 1, 2, 5),
(46, '2025-03-10', '00:25:00', 'Late night fatal head-on collision on curved divider', 2, 1, 3, 3, 1),

-- Location 3: Trinity Metro Overpass Boulevard (16 accidents)
(47, '2023-02-28', '09:10:00', 'Morning rush-hour collision near metro pillar base', 3, 3, 1, 1, 3),
(48, '2023-06-15', '17:25:00', 'Evening rain slippery road pedestrian impact', 3, 3, 2, 2, 4),
(49, '2023-10-10', '22:00:00', 'Night speeding motorcyclist clipped curb barrier', 3, 3, 1, 2, 1),
(50, '2024-02-14', '13:45:00', 'Afternoon delivery scooter sideswiped by urban transit bus', 3, 3, 1, 1, 3),
(51, '2024-05-30', '23:20:00', 'Late night intoxicated driver collision at metro intersection', 3, 3, 1, 2, 2),
(52, '2024-08-22', '08:45:00', 'Morning peak rear bumper damage in crawl traffic', 3, 3, 1, 1, 3),
(53, '2024-12-19', '19:15:00', 'Evening rain caused skidding into bridge support', 3, 3, 2, 2, 1),
(54, '2025-02-10', '18:10:00', 'Evening rush multi-vehicle minor squeeze', 3, 3, 1, 1, 3),
(55, '2023-04-11', '08:50:00', 'Morning scooter skid on wet pedestrian crosswalk', 3, 3, 2, 1, 4),
(56, '2023-08-27', '14:15:00', 'Rear collision at traffic signal due to mobile phone distraction', 3, 3, 1, 1, 3),
(57, '2023-11-14', '20:30:00', 'Cyclist brushed by city bus making tight turn', 3, 3, 1, 2, 3),
(58, '2024-03-29', '11:20:00', 'U-turn violation collided with oncoming sedan', 3, 3, 1, 1, 1),
(59, '2024-07-04', '17:40:00', 'Torrential rain caused low visibility crash at metro signal', 3, 3, 2, 2, 6),
(60, '2024-10-12', '22:15:00', 'Night drunk driver struck metro station safety pillar', 3, 3, 1, 2, 2),
(61, '2025-01-20', '09:00:00', 'School bus clipped taxi in congested lane merge', 3, 3, 1, 1, 3),
(62, '2025-02-28', '19:45:00', 'Evening rear-end impact during sudden braking for jaywalker', 3, 3, 1, 2, 3),

-- Location 9: Electronic City Elevated Expressway (10 accidents)
(63, '2023-03-05', '01:20:00', 'Night speeding car crashed into electronic toll lane barrier', 9, 7, 3, 3, 1),
(64, '2023-07-14', '22:10:00', 'Rain hydroplaning rollover on elevated highway section', 9, 7, 2, 3, 1),
(65, '2023-11-20', '07:45:00', 'Morning commuter vehicle stalled and was struck from behind', 9, 7, 1, 2, 3),
(66, '2024-02-22', '23:30:00', 'Late night high speed race ended in guardrail impact', 9, 7, 1, 3, 1),
(67, '2024-05-18', '15:15:00', 'Tire puncture caused truck to swerve across two lanes', 9, 7, 1, 2, 5),
(68, '2024-08-09', '21:50:00', 'Intoxicated motorcycle rider struck median divider', 9, 7, 2, 3, 2),
(69, '2024-11-05', '06:10:00', 'Morning dense smog caused four-car chain collision', 9, 7, 3, 2, 6),
(70, '2025-01-08', '23:15:00', 'High speed sedan rear-ended maintenance truck', 9, 7, 3, 3, 1),
(71, '2025-02-18', '12:40:00', 'Midday delivery van sideswiped EV on elevated curve', 9, 7, 1, 1, 3),
(72, '2025-03-01', '21:40:00', 'Speeding SUV overturned on wet elevated road', 9, 7, 2, 3, 1),

-- Location 10: Nelamangala Highway Flyover Split (8 accidents)
(73, '2023-02-18', '02:45:00', 'Night intercity bus hit flyover divider nose', 10, 2, 3, 3, 1),
(74, '2023-06-08', '21:30:00', 'Rain slick surface caused semi-truck jackknife', 10, 2, 2, 3, 1),
(75, '2023-09-24', '14:20:00', 'Daytime missed exit sudden swerve impact', 10, 2, 1, 2, 3),
(76, '2024-01-15', '03:10:00', 'Dense fog caused freight hauler collision into split barrier', 10, 2, 3, 3, 1),
(77, '2024-04-22', '18:15:00', 'Evening brake failure in queue for toll gate', 10, 2, 1, 2, 5),
(78, '2024-08-14', '22:40:00', 'Drunk driver entered wrong ramp of flyover split', 10, 2, 2, 3, 2),
(79, '2024-12-02', '08:30:00', 'Morning commercial pickup crashed into crash cushion', 10, 2, 1, 1, 3),
(80, '2025-01-25', '23:50:00', 'High speed night collision between two freight trailers', 10, 2, 3, 3, 1),

-- Location 4: Airport Toll Plaza North Approach (6 accidents)
(81, '2023-04-03', '03:40:00', 'High speed toll queue rear-end impact in early morning fog', 4, 2, 3, 3, 1),
(82, '2023-11-17', '12:15:00', 'Daytime lane divider grazing at high-speed ETC lane', 4, 2, 1, 1, 3),
(83, '2024-07-25', '22:30:00', 'Night speeding sedan spun on wet expressway asphalt', 4, 2, 2, 2, 1),
(84, '2025-01-22', '05:10:00', 'Predawn fog caused truck to strike toll barrier crash attenuator', 4, 2, 3, 2, 6),
(85, '2023-08-19', '19:25:00', 'Evening airport taxi brake failure in express lane', 4, 2, 2, 2, 5),
(86, '2024-10-30', '15:10:00', 'Afternoon sudden lane change grazed passenger van', 4, 2, 1, 1, 3),

-- Location 5: Greenwood Village Crossing (5 accidents)
(87, '2023-05-09', '14:50:00', 'Tractor cross-traffic collision with rural commuter bus', 5, 5, 1, 2, 4),
(88, '2024-03-24', '10:30:00', 'Morning pothole avoidance maneuver overturned small car', 5, 5, 1, 1, 4),
(89, '2024-10-18', '20:15:00', 'Night motorcycle collision with unlit bullock cart', 5, 5, 1, 2, 2),
(90, '2023-12-11', '06:45:00', 'Morning school bus skidded on unpaved gravel patch', 5, 5, 1, 1, 4),
(91, '2024-06-28', '18:30:00', 'Evening heavy tractor collided with rural post van', 5, 5, 2, 2, 4),

-- Location 6: West End Industrial Gate 4 (4 accidents)
(92, '2023-06-30', '07:15:00', 'Morning shift change forklift and pickup truck impact', 6, 8, 1, 1, 3),
(93, '2024-02-02', '21:50:00', 'Heavy freight hauler brake failure on factory ring road', 6, 8, 2, 2, 5),
(94, '2024-11-12', '16:00:00', 'Afternoon cargo van reversed into pedestrian worker', 6, 8, 1, 1, 3),
(95, '2025-02-12', '08:20:00', 'Morning tanker truck sideswiped factory employee bus', 6, 8, 1, 2, 1),

-- Location 7: Sunrise Valley Forest Road (3 accidents)
(96, '2023-08-28', '23:15:00', 'Midnight rural road overturn during severe thunderstorm wind', 7, 6, 5, 2, 6),
(97, '2024-09-05', '06:30:00', 'Morning animal darted across rural road causing tree impact', 7, 6, 1, 1, 4),
(98, '2025-01-30', '21:10:00', 'Night pickup truck slid into ditch during torrential rain', 7, 6, 2, 2, 4),

-- Location 8: Lakeview Promenade South Bend (2 accidents)
(99,  '2024-04-09', '11:45:00', 'Midday bicycle and hatchback minor mirror strike on curve', 8, 3, 1, 1, 3),
(100, '2024-09-20', '16:20:00', 'Afternoon scooter collided with pedestrian near lake park gate', 8, 3, 1, 1, 3);

-- ----------------------------------------------------------------------------
-- 8. Insert Accident-Vehicles (Junction Table: 1-3 vehicles per accident)
-- Total rows: 172 records
-- ----------------------------------------------------------------------------
INSERT INTO accident_vehicle (accident_id, vehicle_type_id) VALUES
-- 1-10
(1, 1), (1, 2), (1, 4),
(2, 2),
(3, 1), (3, 2), (3, 5),
(4, 1), (4, 3),
(5, 4), (5, 1),
(6, 1),
(7, 4), (7, 5),
(8, 2), (8, 3),
(9, 1), (9, 2),
(10, 4), (10, 2),
-- 11-20
(11, 5), (11, 1),
(12, 1), (12, 4),
(13, 1), (13, 2), (13, 5),
(14, 3),
(15, 4),
(16, 2),
(17, 1), (17, 2),
(18, 1), (18, 4),
(19, 4), (19, 1),
(20, 3), (20, 1),
-- 21-30
(21, 2), (21, 1),
(22, 1), (22, 3),
(23, 4),
(24, 2),
(25, 4), (25, 5),
(26, 4),
(27, 2), (27, 1),
(28, 1),
(29, 2),
(30, 3), (30, 2),
-- 31-40
(31, 1),
(32, 2), (32, 4), (32, 1),
(33, 4),
(34, 1), (34, 2),
(35, 1),
(36, 5), (36, 2),
(37, 3),
(38, 4), (38, 1),
(39, 1),
(40, 2),
-- 41-50
(41, 4),
(42, 1), (42, 2), (42, 3),
(43, 5), (43, 1),
(44, 3), (44, 4),
(45, 4),
(46, 1), (46, 2),
(47, 1), (47, 3),
(48, 1),
(49, 3),
(50, 3), (50, 5),
-- 51-60
(51, 1), (51, 2),
(52, 1), (52, 2),
(53, 1),
(54, 1), (54, 3),
(55, 3),
(56, 1), (56, 2),
(57, 5), (57, 3),
(58, 1), (58, 2),
(59, 1), (59, 3),
(60, 1),
-- 61-70
(61, 5), (61, 1),
(62, 1), (62, 2),
(63, 1), (63, 4),
(64, 2),
(65, 1), (65, 2),
(66, 1), (66, 2),
(67, 4),
(68, 3),
(69, 1), (69, 2), (69, 4),
(70, 1), (70, 4),
-- 71-80
(71, 1), (71, 4),
(72, 2),
(73, 5),
(74, 4),
(75, 1), (75, 2),
(76, 4),
(77, 4), (77, 1),
(78, 1), (78, 4),
(79, 4),
(80, 4), (80, 1),
-- 81-90
(81, 1), (81, 4),
(82, 2),
(83, 1),
(84, 4),
(85, 1), (85, 5),
(86, 2), (86, 1),
(87, 5), (87, 4),
(88, 1),
(89, 3), (89, 4),
(90, 5),
-- 91-100
(91, 4), (91, 1),
(92, 4), (92, 1),
(93, 4),
(94, 4),
(95, 4), (95, 5),
(96, 2),
(97, 1),
(98, 4),
(99, 1), (99, 3),
(100, 3);

-- Clean any duplicate composite keys in junction table
-- (mysql ignores duplicates if we use INSERT IGNORE, but with explicit list all pairs are unique)

-- ----------------------------------------------------------------------------
-- 9. Insert 145 Victims across the 100 Accidents
-- Realistic demographics, person types, hospitalization, and severity levels
-- ----------------------------------------------------------------------------
INSERT INTO victim (victim_id, accident_id, age, gender, person_type, hospitalized, injury_severity_id) VALUES
-- Accidents 1-10
(1,  1,  34, 'Male',   'Driver',     TRUE,  3),
(2,  1,  29, 'Female', 'Passenger',  TRUE,  3),
(3,  1,  45, 'Male',   'Passenger',  TRUE,  2),
(4,  2,  27, 'Male',   'Driver',     TRUE,  3),
(5,  2,  25, 'Female', 'Passenger',  TRUE,  2),
(6,  3,  42, 'Male',   'Driver',     TRUE,  2),
(7,  3,  38, 'Female', 'Passenger',  TRUE,  2),
(8,  4,  23, 'Male',   'Driver',     FALSE, 1),
(9,  5,  51, 'Male',   'Driver',     TRUE,  3),
(10, 5,  30, 'Male',   'Passenger',  TRUE,  2),
(11, 6,  28, 'Male',   'Driver',     TRUE,  3),
(12, 7,  49, 'Male',   'Driver',     TRUE,  2),
(13, 7,  32, 'Female', 'Passenger',  FALSE, 1),
(14, 8,  24, 'Male',   'Driver',     TRUE,  3),
(15, 9,  36, 'Female', 'Driver',     FALSE, 1),
(16, 10, 39, 'Male',   'Driver',     TRUE,  3),
(17, 10, 37, 'Female', 'Passenger',  TRUE,  3),
(18, 11, 56, 'Male',   'Passenger',  TRUE,  2),
-- Accidents 12-22
(19, 12, 33, 'Male',   'Driver',     TRUE,  2),
(20, 13, 44, 'Female', 'Driver',     TRUE,  2),
(21, 13, 19, 'Male',   'Passenger',  FALSE, 1),
(22, 14, 26, 'Male',   'Driver',     FALSE, 1),
(23, 15, 48, 'Male',   'Driver',     TRUE,  3),
(24, 16, 29, 'Male',   'Driver',     TRUE,  3),
(25, 16, 27, 'Female', 'Passenger',  TRUE,  3),
(26, 17, 35, 'Male',   'Driver',     FALSE, 1),
(27, 18, 38, 'Male',   'Driver',     TRUE,  3),
(28, 19, 41, 'Male',   'Driver',     TRUE,  2),
(29, 20, 24, 'Male',   'Driver',     TRUE,  2),
(30, 20, 22, 'Female', 'Passenger',  TRUE,  2),
(31, 21, 31, 'Male',   'Driver',     TRUE,  3),
(32, 22, 40, 'Female', 'Driver',     FALSE, 1),
-- Accidents 23-35 (Kaggalipura Ghat Severe Crashes)
(33, 23, 43, 'Male',   'Driver',     TRUE,  3),
(34, 23, 38, 'Male',   'Passenger',  TRUE,  2),
(35, 24, 31, 'Male',   'Driver',     TRUE,  3),
(36, 24, 28, 'Female', 'Passenger',  TRUE,  3),
(37, 25, 48, 'Male',   'Driver',     TRUE,  3),
(38, 25, 52, 'Male',   'Driver',     TRUE,  3),
(39, 25, 22, 'Female', 'Passenger',  TRUE,  2),
(40, 25, 35, 'Male',   'Passenger',  TRUE,  2),
(41, 26, 41, 'Male',   'Driver',     TRUE,  2),
(42, 27, 26, 'Male',   'Driver',     TRUE,  3),
(43, 27, 24, 'Male',   'Passenger',  TRUE,  2),
(44, 28, 33, 'Male',   'Driver',     TRUE,  3),
(45, 29, 40, 'Female', 'Driver',     TRUE,  3),
(46, 29, 19, 'Male',   'Passenger',  TRUE,  2),
(47, 30, 29, 'Male',   'Driver',     TRUE,  2),
(48, 31, 35, 'Male',   'Driver',     TRUE,  3),
(49, 32, 46, 'Male',   'Driver',     TRUE,  3),
(50, 32, 44, 'Female', 'Passenger',  TRUE,  3),
(51, 32, 12, 'Male',   'Passenger',  TRUE,  2),
(52, 33, 50, 'Male',   'Driver',     TRUE,  3),
(53, 34, 32, 'Male',   'Driver',     TRUE,  3),
(54, 34, 30, 'Female', 'Passenger',  TRUE,  3),
(55, 35, 28, 'Male',   'Driver',     TRUE,  3),
-- Accidents 36-46
(56, 36, 47, 'Male',   'Driver',     TRUE,  3),
(57, 36, 21, 'Male',   'Passenger',  TRUE,  2),
(58, 37, 23, 'Male',   'Driver',     TRUE,  2),
(59, 38, 45, 'Male',   'Driver',     TRUE,  3),
(60, 39, 36, 'Male',   'Driver',     TRUE,  3),
(61, 40, 30, 'Female', 'Driver',     TRUE,  3),
(62, 40, 32, 'Male',   'Passenger',  TRUE,  3),
(63, 41, 54, 'Male',   'Driver',     TRUE,  3),
(64, 42, 39, 'Male',   'Driver',     TRUE,  2),
(65, 42, 36, 'Female', 'Passenger',  TRUE,  2),
(66, 43, 51, 'Male',   'Driver',     TRUE,  3),
(67, 43, 48, 'Male',   'Passenger',  TRUE,  3),
(68, 44, 25, 'Male',   'Driver',     TRUE,  3),
(69, 45, 42, 'Male',   'Driver',     TRUE,  2),
(70, 46, 34, 'Male',   'Driver',     TRUE,  3),
(71, 46, 31, 'Female', 'Passenger',  TRUE,  3),
-- Accidents 47-62 (Trinity Metro Urban)
(72, 47, 27, 'Male',   'Driver',     FALSE, 1),
(73, 48, 62, 'Female', 'Pedestrian', TRUE,  2),
(74, 49, 21, 'Male',   'Driver',     TRUE,  2),
(75, 50, 25, 'Male',   'Driver',     FALSE, 1),
(76, 51, 33, 'Male',   'Driver',     TRUE,  2),
(77, 52, 44, 'Male',   'Driver',     FALSE, 1),
(78, 53, 38, 'Female', 'Driver',     TRUE,  2),
(79, 53, 15, 'Female', 'Passenger',  FALSE, 1),
(80, 54, 31, 'Male',   'Driver',     FALSE, 1),
(81, 55, 29, 'Female', 'Driver',     FALSE, 1),
(82, 56, 45, 'Male',   'Driver',     FALSE, 1),
(83, 57, 58, 'Male',   'Driver',     TRUE,  2),
(84, 58, 36, 'Male',   'Driver',     FALSE, 1),
(85, 59, 28, 'Female', 'Driver',     TRUE,  2),
(86, 60, 39, 'Male',   'Driver',     TRUE,  2),
(87, 61, 50, 'Male',   'Driver',     FALSE, 1),
(88, 62, 34, 'Male',   'Driver',     TRUE,  2),
(89, 62, 65, 'Male',   'Pedestrian', TRUE,  2),
-- Accidents 63-72 (Electronic City Elevated)
(90, 63, 31, 'Male',   'Driver',     TRUE,  3),
(91, 64, 28, 'Male',   'Driver',     TRUE,  3),
(92, 64, 26, 'Female', 'Passenger',  TRUE,  3),
(93, 65, 42, 'Male',   'Driver',     TRUE,  2),
(94, 66, 23, 'Male',   'Driver',     TRUE,  3),
(95, 66, 21, 'Male',   'Passenger',  TRUE,  3),
(96, 67, 49, 'Male',   'Driver',     TRUE,  2),
(97, 68, 27, 'Male',   'Driver',     TRUE,  3),
(98, 69, 36, 'Male',   'Driver',     TRUE,  2),
(99, 69, 33, 'Female', 'Passenger',  TRUE,  2),
(100, 70, 35, 'Male',  'Driver',     TRUE,  3),
(101, 71, 29, 'Male',  'Driver',     FALSE, 1),
(102, 72, 32, 'Female','Driver',     TRUE,  3),
-- Accidents 73-80 (Nelamangala Split)
(103, 73, 53, 'Male',  'Driver',     TRUE,  3),
(104, 73, 49, 'Male',  'Passenger',  TRUE,  3),
(105, 74, 46, 'Male',  'Driver',     TRUE,  3),
(106, 75, 38, 'Female','Driver',     TRUE,  2),
(107, 76, 44, 'Male',  'Driver',     TRUE,  3),
(108, 77, 50, 'Male',  'Driver',     TRUE,  2),
(109, 78, 37, 'Male',  'Driver',     TRUE,  3),
(110, 79, 29, 'Male',  'Driver',     FALSE, 1),
(111, 80, 48, 'Male',  'Driver',     TRUE,  3),
(112, 80, 42, 'Male',  'Driver',     TRUE,  3),
-- Accidents 81-86 (Airport Toll Plaza)
(113, 81, 29, 'Male',  'Driver',     TRUE,  3),
(114, 81, 27, 'Female','Passenger',  TRUE,  2),
(115, 82, 50, 'Male',  'Driver',     FALSE, 1),
(116, 83, 34, 'Male',  'Driver',     TRUE,  2),
(117, 84, 47, 'Male',  'Driver',     TRUE,  2),
(118, 85, 41, 'Male',  'Driver',     TRUE,  2),
(119, 86, 33, 'Female','Driver',     FALSE, 1),
-- Accidents 87-91 (Greenwood Crossing)
(120, 87, 55, 'Male',  'Driver',     TRUE,  2),
(121, 87, 40, 'Female','Passenger',  TRUE,  2),
(122, 88, 36, 'Female','Driver',     FALSE, 1),
(123, 89, 23, 'Male',  'Driver',     TRUE,  2),
(124, 90, 48, 'Male',  'Driver',     FALSE, 1),
(125, 91, 52, 'Male',  'Driver',     TRUE,  2),
-- Accidents 92-95 (West End Industrial)
(126, 92, 42, 'Male',  'Driver',     FALSE, 1),
(127, 93, 53, 'Male',  'Driver',     TRUE,  2),
(128, 94, 30, 'Male',  'Pedestrian', FALSE, 1),
(129, 95, 46, 'Male',  'Driver',     TRUE,  2),
(130, 95, 39, 'Female','Passenger',  TRUE,  2),
-- Accidents 96-98 (Sunrise Valley Forest)
(131, 96, 37, 'Female','Driver',     TRUE,  2),
(132, 97, 48, 'Male',  'Driver',     FALSE, 1),
(133, 98, 35, 'Male',  'Driver',     TRUE,  2),
-- Accidents 99-100 (Lakeview Promenade)
(134, 99,  26, 'Female','Driver',    FALSE, 1),
(135, 99,  19, 'Male',  'Pedestrian',FALSE, 1),
(136, 100, 22, 'Male',  'Driver',    FALSE, 1),
(137, 100, 58, 'Female','Pedestrian',FALSE, 1);
