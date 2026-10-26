-- ============================================================================
-- Project: Road Accident Hotspot Analysis and Severity Prediction System
-- Component: Analytical Views, Queries, and Severity Prediction Procedure
-- Target RDBMS: MySQL 8.0+
-- ============================================================================

USE accident_db;

-- ----------------------------------------------------------------------------
-- 1. VIEW: v_hotspot_ranking
-- Calculates per-location metrics: total accident volume, fatal crashes,
-- and composite risk_score (SUM of severity level ranks: Minor=1, Serious=2, Fatal=3).
-- Ordered by risk_score DESC to immediately highlight top hazard zones.
-- ----------------------------------------------------------------------------
CREATE OR REPLACE VIEW v_hotspot_ranking AS
SELECT 
    l.location_id,
    l.location_name,
    l.district,
    l.latitude,
    l.longitude,
    COUNT(a.accident_id) AS total_accidents,
    SUM(CASE WHEN s.level_name = 'Fatal' THEN 1 ELSE 0 END) AS fatal_count,
    COALESCE(SUM(s.level_rank), 0) AS risk_score
FROM location l
LEFT JOIN accident a ON l.location_id = a.location_id
LEFT JOIN severity s ON a.severity_id = s.severity_id
GROUP BY 
    l.location_id, 
    l.location_name, 
    l.district, 
    l.latitude, 
    l.longitude
ORDER BY 
    risk_score DESC, 
    total_accidents DESC;

-- ----------------------------------------------------------------------------
-- 2. Query: Top 5 Hotspots
-- Retrieves the top 5 most dangerous geographical locations ranked by risk score.
-- ----------------------------------------------------------------------------
SELECT 
    location_id,
    location_name,
    district,
    latitude,
    longitude,
    total_accidents,
    fatal_count,
    risk_score
FROM v_hotspot_ranking
LIMIT 5;

-- ----------------------------------------------------------------------------
-- 3. Query: Accidents by Month
-- Chronological time-series analysis showing accident volume and severity
-- breakdown across months from 2023 to 2025.
-- ----------------------------------------------------------------------------
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

-- ----------------------------------------------------------------------------
-- 4. Query: Accidents by Cause
-- Causal breakdown showing frequencies, percentage of total collisions,
-- fatalities, and average severity rank.
-- ----------------------------------------------------------------------------
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
ORDER BY total_accidents DESC, avg_severity_rank DESC;

-- ----------------------------------------------------------------------------
-- 5. Query: Accidents by Weather Condition
-- Environmental analysis correlating weather with accident frequencies
-- and outcome severities.
-- ----------------------------------------------------------------------------
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

-- ----------------------------------------------------------------------------
-- 6. Query: Accidents by Hour Band
-- Diurnal temporal analysis categorizing incidents into 4 standard intervals:
-- Morning (06:00 - 11:59), Afternoon (12:00 - 16:59),
-- Evening (17:00 - 20:59), Night (21:00 - 05:59).
-- ----------------------------------------------------------------------------
SELECT 
    CASE
        WHEN HOUR(a.accident_time) BETWEEN 6 AND 11 THEN 'Morning (06:00 - 11:59)'
        WHEN HOUR(a.accident_time) BETWEEN 12 AND 16 THEN 'Afternoon (12:00 - 16:59)'
        WHEN HOUR(a.accident_time) BETWEEN 17 AND 20 THEN 'Evening (17:00 - 20:59)'
        ELSE 'Night (21:00 - 05:59)'
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

-- ----------------------------------------------------------------------------
-- 7. STORED PROCEDURE: sp_predict_severity
-- History-based Bayesian/Frequency severity predictor.
-- Matches past incidents against road type, weather, cause, and hour band.
-- Computes frequency and percentage per severity level (Minor, Serious, Fatal)
-- and selects the modal (most frequent) level as the predicted severity.
-- Gracefully falls back to overall dataset distribution if no exact match exists.
-- ----------------------------------------------------------------------------
DROP PROCEDURE IF EXISTS sp_predict_severity;

DELIMITER //

CREATE PROCEDURE sp_predict_severity(
    IN p_road_type VARCHAR(20),
    IN p_weather_id INT,
    IN p_cause_id INT,
    IN p_hour_band VARCHAR(20)
)
BEGIN
    DECLARE v_match_count INT DEFAULT 0;
    DECLARE v_total_count INT DEFAULT 0;
    DECLARE v_top_severity_id INT DEFAULT NULL;

    -- Total system-wide accident count
    SELECT COUNT(*) INTO v_total_count FROM accident;

    -- Count past accidents matching the exact multi-dimensional scenario
    SELECT COUNT(*) INTO v_match_count
    FROM accident a
    JOIN road r ON a.road_id = r.road_id
    WHERE (p_road_type IS NULL OR r.road_type = p_road_type)
      AND (p_weather_id IS NULL OR a.weather_id = p_weather_id)
      AND (p_cause_id IS NULL OR a.cause_id = p_cause_id)
      AND (p_hour_band IS NULL OR (
            CASE
                WHEN HOUR(a.accident_time) BETWEEN 6 AND 11 THEN 'Morning'
                WHEN HOUR(a.accident_time) BETWEEN 12 AND 16 THEN 'Afternoon'
                WHEN HOUR(a.accident_time) BETWEEN 17 AND 20 THEN 'Evening'
                ELSE 'Night'
            END = p_hour_band
      ));

    IF v_match_count > 0 THEN
        -- Find most frequent severity among matches (ties broken by higher severity rank)
        SELECT s.severity_id INTO v_top_severity_id
        FROM severity s
        LEFT JOIN (
            SELECT a.severity_id, COUNT(*) AS cnt
            FROM accident a
            JOIN road r ON a.road_id = r.road_id
            WHERE (p_road_type IS NULL OR r.road_type = p_road_type)
              AND (p_weather_id IS NULL OR a.weather_id = p_weather_id)
              AND (p_cause_id IS NULL OR a.cause_id = p_cause_id)
              AND (p_hour_band IS NULL OR (
                    CASE
                        WHEN HOUR(a.accident_time) BETWEEN 6 AND 11 THEN 'Morning'
                        WHEN HOUR(a.accident_time) BETWEEN 12 AND 16 THEN 'Afternoon'
                        WHEN HOUR(a.accident_time) BETWEEN 17 AND 20 THEN 'Evening'
                        ELSE 'Night'
                    END = p_hour_band
              ))
            GROUP BY a.severity_id
        ) m ON s.severity_id = m.severity_id
        ORDER BY COALESCE(m.cnt, 0) DESC, s.level_rank DESC
        LIMIT 1;

        -- Return full percentage breakdown and prediction flag
        SELECT 
            'Exact Historical Match' AS data_source,
            s.level_name AS severity_level,
            s.level_rank,
            COALESCE(m.cnt, 0) AS accident_count,
            v_match_count AS sample_size,
            ROUND((COALESCE(m.cnt, 0) * 100.0) / v_match_count, 2) AS percentage,
            CASE 
                WHEN s.severity_id = v_top_severity_id THEN 'PREDICTED SEVERITY'
                ELSE '-'
            END AS prediction_flag
        FROM severity s
        LEFT JOIN (
            SELECT a.severity_id, COUNT(*) AS cnt
            FROM accident a
            JOIN road r ON a.road_id = r.road_id
            WHERE (p_road_type IS NULL OR r.road_type = p_road_type)
              AND (p_weather_id IS NULL OR a.weather_id = p_weather_id)
              AND (p_cause_id IS NULL OR a.cause_id = p_cause_id)
              AND (p_hour_band IS NULL OR (
                    CASE
                        WHEN HOUR(a.accident_time) BETWEEN 6 AND 11 THEN 'Morning'
                        WHEN HOUR(a.accident_time) BETWEEN 12 AND 16 THEN 'Afternoon'
                        WHEN HOUR(a.accident_time) BETWEEN 17 AND 20 THEN 'Evening'
                        ELSE 'Night'
                    END = p_hour_band
              ))
            GROUP BY a.severity_id
        ) m ON s.severity_id = m.severity_id
        ORDER BY s.level_rank ASC;

    ELSE
        -- Fallback: No direct history found, use overall dataset baseline distribution
        SELECT s.severity_id INTO v_top_severity_id
        FROM severity s
        LEFT JOIN (
            SELECT a.severity_id, COUNT(*) AS cnt
            FROM accident a
            GROUP BY a.severity_id
        ) o ON s.severity_id = o.severity_id
        ORDER BY COALESCE(o.cnt, 0) DESC, s.level_rank DESC
        LIMIT 1;

        SELECT 
            'Fallback: Overall System Distribution' AS data_source,
            s.level_name AS severity_level,
            s.level_rank,
            COALESCE(o.cnt, 0) AS accident_count,
            v_total_count AS sample_size,
            ROUND((COALESCE(o.cnt, 0) * 100.0) / v_total_count, 2) AS percentage,
            CASE 
                WHEN s.severity_id = v_top_severity_id THEN 'PREDICTED SEVERITY (FALLBACK)'
                ELSE '-'
            END AS prediction_flag
        FROM severity s
        LEFT JOIN (
            SELECT a.severity_id, COUNT(*) AS cnt
            FROM accident a
            GROUP BY a.severity_id
        ) o ON s.severity_id = o.severity_id
        ORDER BY s.level_rank ASC;

    END IF;
END //

DELIMITER ;

-- ----------------------------------------------------------------------------
-- 8. Procedure Execution Examples
-- ----------------------------------------------------------------------------
-- Example 1: High-risk scenario (Highway, Rain, Over-speeding, Night)
-- Expectation: Matches historical records and predicts 'Fatal'.
CALL sp_predict_severity('Highway', 2, 1, 'Night');

-- Example 2: Fallback scenario with unseen condition combination
-- Expectation: No exact matches; gracefully falls back to system-wide distribution.
CALL sp_predict_severity('Rural', 4, 5, 'Morning');
