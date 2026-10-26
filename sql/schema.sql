-- ============================================================================
-- Project: Road Accident Hotspot Analysis and Severity Prediction System
-- Component: Database Schema Definition (DDL)
-- Target RDBMS: MySQL 8.0+
-- Normal Form: Third Normal Form (3NF)
-- ============================================================================

DROP DATABASE IF EXISTS accident_db;
CREATE DATABASE accident_db
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;

USE accident_db;

-- ----------------------------------------------------------------------------
-- Table 1: location
-- Stores spatial and geographic reference points where accidents occur.
-- ----------------------------------------------------------------------------
CREATE TABLE location (
    location_id INT AUTO_INCREMENT PRIMARY KEY,
    location_name VARCHAR(150) NOT NULL,
    district VARCHAR(100) NOT NULL,
    latitude DECIMAL(9, 6) NOT NULL,
    longitude DECIMAL(9, 6) NOT NULL,
    CONSTRAINT chk_latitude CHECK (latitude BETWEEN -90.000000 AND 90.000000),
    CONSTRAINT chk_longitude CHECK (longitude BETWEEN -180.000000 AND 180.000000)
) ENGINE=InnoDB;

-- ----------------------------------------------------------------------------
-- Table 2: road
-- Stores roadway infrastructure characteristics and classifications.
-- ----------------------------------------------------------------------------
CREATE TABLE road (
    road_id INT AUTO_INCREMENT PRIMARY KEY,
    road_name VARCHAR(150) NOT NULL,
    road_type VARCHAR(20) NOT NULL,
    lanes INT NOT NULL,
    surface_type VARCHAR(50) NOT NULL,
    speed_limit INT NOT NULL,
    CONSTRAINT chk_road_type CHECK (road_type IN ('Highway', 'Urban', 'Rural')),
    CONSTRAINT chk_lanes CHECK (lanes > 0),
    CONSTRAINT chk_speed_limit CHECK (speed_limit > 0)
) ENGINE=InnoDB;

-- ----------------------------------------------------------------------------
-- Table 3: weather_condition
-- Lookup table for standardized atmospheric and meteorological states.
-- ----------------------------------------------------------------------------
CREATE TABLE weather_condition (
    weather_id INT AUTO_INCREMENT PRIMARY KEY,
    condition_name VARCHAR(50) NOT NULL UNIQUE
) ENGINE=InnoDB;

-- ----------------------------------------------------------------------------
-- Table 4: severity
-- Lookup table for standardized crash severity rankings (Minor=1, Serious=2, Fatal=3).
-- ----------------------------------------------------------------------------
CREATE TABLE severity (
    severity_id INT AUTO_INCREMENT PRIMARY KEY,
    level_name VARCHAR(30) NOT NULL UNIQUE,
    level_rank INT NOT NULL UNIQUE,
    description VARCHAR(255) NOT NULL,
    CONSTRAINT chk_level_rank CHECK (level_rank IN (1, 2, 3))
) ENGINE=InnoDB;

-- ----------------------------------------------------------------------------
-- Table 5: accident_cause
-- Standardized catalog of primary incident causes and causal categories.
-- ----------------------------------------------------------------------------
CREATE TABLE accident_cause (
    cause_id INT AUTO_INCREMENT PRIMARY KEY,
    cause_name VARCHAR(100) NOT NULL UNIQUE,
    category VARCHAR(50) NOT NULL
) ENGINE=InnoDB;

-- ----------------------------------------------------------------------------
-- Table 6: accident
-- Core fact entity capturing individual accident incidents and environment FKs.
-- ----------------------------------------------------------------------------
CREATE TABLE accident (
    accident_id INT AUTO_INCREMENT PRIMARY KEY,
    accident_date DATE NOT NULL,
    accident_time TIME NOT NULL,
    description TEXT,
    location_id INT NOT NULL,
    road_id INT NOT NULL,
    weather_id INT NOT NULL,
    severity_id INT NOT NULL,
    cause_id INT NOT NULL,
    CONSTRAINT fk_accident_location FOREIGN KEY (location_id)
        REFERENCES location (location_id)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_accident_road FOREIGN KEY (road_id)
        REFERENCES road (road_id)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_accident_weather FOREIGN KEY (weather_id)
        REFERENCES weather_condition (weather_id)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_accident_severity FOREIGN KEY (severity_id)
        REFERENCES severity (severity_id)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_accident_cause FOREIGN KEY (cause_id)
        REFERENCES accident_cause (cause_id)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    INDEX idx_accident_location (location_id),
    INDEX idx_accident_date (accident_date),
    INDEX idx_accident_severity (severity_id)
) ENGINE=InnoDB;

-- ----------------------------------------------------------------------------
-- Table 7: vehicle_type
-- Lookup catalog of motorized and non-motorized vehicle categories.
-- ----------------------------------------------------------------------------
CREATE TABLE vehicle_type (
    vehicle_type_id INT AUTO_INCREMENT PRIMARY KEY,
    type_name VARCHAR(50) NOT NULL UNIQUE
) ENGINE=InnoDB;

-- ----------------------------------------------------------------------------
-- Table 8: accident_vehicle
-- Associative entity resolving Many-to-Many between accidents and vehicles.
-- ----------------------------------------------------------------------------
CREATE TABLE accident_vehicle (
    accident_id INT NOT NULL,
    vehicle_type_id INT NOT NULL,
    PRIMARY KEY (accident_id, vehicle_type_id),
    CONSTRAINT fk_av_accident FOREIGN KEY (accident_id)
        REFERENCES accident (accident_id)
        ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT fk_av_vehicle FOREIGN KEY (vehicle_type_id)
        REFERENCES vehicle_type (vehicle_type_id)
        ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB;

-- ----------------------------------------------------------------------------
-- Table 9: victim
-- Captures individuals involved in collisions and their injury severities.
-- ----------------------------------------------------------------------------
CREATE TABLE victim (
    victim_id INT AUTO_INCREMENT PRIMARY KEY,
    accident_id INT NOT NULL,
    age INT NOT NULL,
    gender VARCHAR(10) NOT NULL,
    person_type VARCHAR(20) NOT NULL,
    hospitalized BOOLEAN NOT NULL DEFAULT FALSE,
    injury_severity_id INT NOT NULL,
    CONSTRAINT chk_victim_age CHECK (age >= 0 AND age <= 125),
    CONSTRAINT chk_victim_gender CHECK (gender IN ('Male', 'Female', 'Other')),
    CONSTRAINT chk_victim_person_type CHECK (person_type IN ('Driver', 'Passenger', 'Pedestrian')),
    CONSTRAINT fk_victim_accident FOREIGN KEY (accident_id)
        REFERENCES accident (accident_id)
        ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT fk_victim_injury_severity FOREIGN KEY (injury_severity_id)
        REFERENCES severity (severity_id)
        ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB;
