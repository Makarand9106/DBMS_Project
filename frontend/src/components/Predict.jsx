// ============================================================================
// File: src/components/Predict.jsx
// Description: Severity prediction form with dynamic dropdowns and visual badges.
// ============================================================================

import React, { useState, useEffect } from 'react';
import { getLookups, predictSeverity } from '../api';

export default function Predict() {
  const [lookups, setLookups] = useState(null);
  const [loadingLookups, setLoadingLookups] = useState(true);
  const [lookupError, setLookupError] = useState(null);

  // Form inputs
  const [roadType, setRoadType] = useState('Highway');
  const [weatherId, setWeatherId] = useState('');
  const [causeId, setCauseId] = useState('');
  const [hourBand, setHourBand] = useState('Night');

  // Prediction states
  const [predicting, setPredicting] = useState(false);
  const [result, setResult] = useState(null);
  const [predictError, setPredictError] = useState(null);

  // Fetch lookups once on component mount
  useEffect(() => {
    let isMounted = true;
    getLookups()
      .then((data) => {
        if (isMounted) {
          setLookups(data);
          if (data.weather_conditions?.length) {
            setWeatherId(data.weather_conditions[0].weather_id);
          }
          if (data.causes?.length) {
            setCauseId(data.causes[0].cause_id);
          }
          setLoadingLookups(false);
        }
      })
      .catch((err) => {
        if (isMounted) {
          setLookupError(err.message);
          setLoadingLookups(false);
        }
      });
    return () => {
      isMounted = false;
    };
  }, []);

  const handleSubmit = async (e) => {
    e.preventDefault();
    setPredictError(null);
    setPredicting(true);

    try {
      const res = await predictSeverity({
        road_type: roadType,
        weather_id: Number(weatherId),
        cause_id: Number(causeId),
        hour_band: hourBand
      });
      setResult(res);
    } catch (err) {
      setPredictError(err.message);
    } finally {
      setPredicting(false);
    }
  };

  if (loadingLookups) return <div className="loading-state">Loading lookup options...</div>;
  if (lookupError) return <div className="error-message">Error loading lookups: {lookupError}</div>;

  return (
    <div className="tab-container">
      <h2>Severity Prediction (MySQL Stored Procedure)</h2>
      <p className="subtitle">
        Uses history-based probability from <code>sp_predict_severity</code> to estimate crash severity.
      </p>

      {/* Input Parameters Form */}
      <form onSubmit={handleSubmit} className="form-card">
        <div className="form-grid">
          <div className="form-group">
            <label htmlFor="roadType">Road Type:</label>
            <select
              id="roadType"
              value={roadType}
              onChange={(e) => setRoadType(e.target.value)}
              required
            >
              {lookups.road_types.map((type) => (
                <option key={type} value={type}>
                  {type}
                </option>
              ))}
            </select>
          </div>

          <div className="form-group">
            <label htmlFor="weatherCondition">Weather Condition:</label>
            <select
              id="weatherCondition"
              value={weatherId}
              onChange={(e) => setWeatherId(e.target.value)}
              required
            >
              {lookups.weather_conditions.map((w) => (
                <option key={w.weather_id} value={w.weather_id}>
                  {w.condition_name}
                </option>
              ))}
            </select>
          </div>

          <div className="form-group">
            <label htmlFor="accidentCause">Primary Cause:</label>
            <select
              id="accidentCause"
              value={causeId}
              onChange={(e) => setCauseId(e.target.value)}
              required
            >
              {lookups.causes.map((c) => (
                <option key={c.cause_id} value={c.cause_id}>
                  {c.cause_name} ({c.category})
                </option>
              ))}
            </select>
          </div>

          <div className="form-group">
            <label htmlFor="hourBand">Time of Day (Hour Band):</label>
            <select
              id="hourBand"
              value={hourBand}
              onChange={(e) => setHourBand(e.target.value)}
              required
            >
              <option value="Morning">Morning (06:00 - 11:59)</option>
              <option value="Afternoon">Afternoon (12:00 - 16:59)</option>
              <option value="Evening">Evening (17:00 - 20:59)</option>
              <option value="Night">Night (21:00 - 05:59)</option>
            </select>
          </div>
        </div>

        <button type="submit" className="btn-primary" disabled={predicting}>
          {predicting ? 'Computing Prediction...' : 'Predict Crash Severity'}
        </button>
      </form>

      {predictError && <div className="error-message">Prediction failed: {predictError}</div>}

      {/* Prediction Output & Probability Breakdown */}
      {result && (
        <div className="prediction-result-card">
          <div className="result-header">
            <div>
              <h3>Predicted Severity</h3>
              <p className="data-source-tag">Source: {result.data_source} (Sample Size: {result.sample_size})</p>
            </div>
            {/* Coloured Badge: Green = Minor, Orange = Serious, Red = Fatal */}
            <span
              className={`severity-badge ${
                result.predicted_severity === 'Fatal'
                  ? 'badge-fatal'
                  : result.predicted_severity === 'Serious'
                  ? 'badge-serious'
                  : 'badge-minor'
              }`}
            >
              {result.predicted_severity}
            </span>
          </div>

          <h4>Severity Probability Distribution:</h4>
          <div className="probability-list">
            {result.breakdown.map((item) => {
              const barColor =
                item.severity_level === 'Fatal'
                  ? '#ef4444'
                  : item.severity_level === 'Serious'
                  ? '#f97316'
                  : '#10b981';

              return (
                <div key={item.severity_level} className="probability-item">
                  <div className="prob-label">
                    <span>
                      <strong>{item.severity_level}</strong> (Rank {item.level_rank})
                    </span>
                    <span>
                      {item.percentage}% ({item.accident_count} cases)
                      {item.is_predicted && <span className="predicted-chip">Modal Choice</span>}
                    </span>
                  </div>
                  {/* Small Horizontal Probability Bar */}
                  <div className="progress-track">
                    <div
                      className="progress-fill"
                      style={{
                        width: `${item.percentage}%`,
                        backgroundColor: barColor
                      }}
                    />
                  </div>
                </div>
              );
            })}
          </div>
        </div>
      )}
    </div>
  );
}
