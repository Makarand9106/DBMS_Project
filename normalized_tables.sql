/*
===============================================================================
ROAD ACCIDENT HOTSPOT ANALYSIS & SEVERITY PREDICTION
NORMALIZATION WALKTHROUGH: UNNORMALIZED -> 1NF -> 2NF -> 3NF
===============================================================================

PURPOSE
-------
This is a PRESENTATION / VIVA demonstration script. It documents examples of
normalization violations and how the implemented design avoids them.

IMPORTANT
---------
1. The "VIOLATION EXAMPLES" below are intentionally commented out. They are
   illustrative anti-patterns, not tables to create in the production database.
2. The final section documents the normalized design used by the project.
3. Do NOT run DROP DATABASE or recreate your live accident_db from this file.
4. If your live schema uses slightly different column names/types, use
   SHOW CREATE TABLE accident; (and the other tables) to display the exact DDL.
*/


/* ============================================================================
   PART A — BEFORE NORMALIZATION: UNNORMALIZED / REPEATING GROUPS
   ============================================================================
   Problem: storing several vehicle types in columns such as bike, car, truck
   creates repeating groups. Adding a fourth type requires a schema change,
   and queries such as "which accidents involved trucks?" become awkward.

   Example of the BAD design (intentionally commented out):

   CREATE TABLE accident_un_normalized (
       accident_id INT,
       accident_date DATE,
       location_name VARCHAR(150),
       bike VARCHAR(3),       -- 'Yes' or 'No'
       car VARCHAR(3),        -- 'Yes' or 'No'
       truck VARCHAR(3),     -- 'Yes' or 'No'
       severity_name VARCHAR(50)
   );

   Example rows:
   accident_id | bike | car | truck
   ------------+------+------+------
       101     | Yes  | No   | Yes
       102     | No   | Yes  | No

   Violations / limitations:
   - Vehicle involvement is encoded as multiple columns instead of rows.
   - Adding bus/auto/tractor means altering the table structure.
   - It is harder to aggregate or filter all vehicle types consistently.
*/


/* ============================================================================
   PART B — FIRST NORMAL FORM (1NF)
   ============================================================================
   1NF rule: each field contains one atomic value; no repeating groups.

   A 1NF-style intermediate table can store one vehicle type per row:

   CREATE TABLE accident_vehicle_1nf_demo (
       accident_id INT NOT NULL,
       accident_date DATE,
       location_name VARCHAR(150),
       vehicle_type VARCHAR(40) NOT NULL,
       severity_name VARCHAR(50),
       PRIMARY KEY (accident_id, vehicle_type)
   );

   Example rows:
   accident_id | vehicle_type
   ------------+-------------
       101     | Bike
       101     | Truck
       102     | Car

   This removes the bike/car/truck repeating columns. However, this
   intermediate design still repeats descriptive vehicle information if we
   store it here, and it mixes accident facts with vehicle-type descriptions.
*/


/* ============================================================================
   PART C — SECOND NORMAL FORM (2NF) VIOLATION
   ============================================================================
   2NF rule: the table is in 1NF and every non-key attribute depends on the
   WHOLE candidate key, not only part of a composite key.

   BAD example:
   CREATE TABLE accident_vehicle_2nf_bad (
       accident_id INT NOT NULL,
       vehicle_type_id INT NOT NULL,
       vehicle_type_name VARCHAR(40) NOT NULL,
       vehicle_description VARCHAR(200),
       quantity INT DEFAULT 1,
       PRIMARY KEY (accident_id, vehicle_type_id)
   );

   Here the composite key is (accident_id, vehicle_type_id).
   But vehicle_type_name and vehicle_description depend only on
   vehicle_type_id, not on the whole composite key. This is a partial
   dependency, so the table violates 2NF.

   Consequences:
   - The same vehicle type description is repeated for many accidents.
   - Renaming a vehicle type requires updating multiple rows.
   - Inserting a vehicle type before it is involved in an accident is awkward.

   FIX:
   - Keep only the relationship in accident_vehicle.
   - Put vehicle type descriptions in vehicle_type.
*/


/* ============================================================================
   PART D — THIRD NORMAL FORM (3NF) VIOLATION
   ============================================================================
   3NF rule (informal): the table is in 2NF and non-key attributes do not
   depend transitively on the primary key through another non-key attribute.

   BAD example:
   CREATE TABLE accident_3nf_bad (
       accident_id INT PRIMARY KEY,
       road_id INT NOT NULL,
       road_name VARCHAR(150),
       road_type_id INT,
       road_type_name VARCHAR(80),
       severity_id INT,
       severity_name VARCHAR(50)
   );

   Intended functional dependencies:
       accident_id -> road_id, severity_id, ...
       road_id -> road_name, road_type_id
       road_type_id -> road_type_name
       severity_id -> severity_name

   road_type_name is determined by road_type_id, not directly by accident_id.
   severity_name is determined by severity_id. Keeping these descriptions
   inside accident creates transitive dependencies and repeated data.

   Consequences:
   - A road-type label may be inconsistent across accident rows.
   - Changing a severity label may require multiple updates.
   - Lookup descriptions are duplicated in the transaction/fact table.

   FIX:
   - Store road attributes in road.
   - Store severity labels/rank/description in severity.
   - Store weather labels in weather_condition.
   - Store cause labels/categories in accident_cause.
   - Store vehicle descriptions in vehicle_type.
   - Keep foreign keys to these lookup/entity tables in accident.
*/



