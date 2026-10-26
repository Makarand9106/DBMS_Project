// ============================================================================
// File: src/components/AddAccident.jsx
// Description: Form for recording new accident records within an ACID transaction.
// ============================================================================

import React, { useState, useEffect } from 'react';
import { getLookups, createAccident } from '../api';

export default function AddAccident() {
  const [lookups, setLookups] = useState(null);
  const [loadingLookups, setLoadingLookups] = useState(true);
  const [lookupError, setLookupError] = useState(null);

  // Form Fields
  const [accidentDate, setAccidentDate] = useState(new Date().toISOString().split('T')[0]);
  const [accidentTime, setAccidentTime] = useState('18:30:00');
  const [description, setDescription] = useState('');
  const [locationId, setLocationId] = useState('');
  const [roadId, setRoadId] = useState('');
  const [weatherId, setWeatherId] = useState('');
  const [severityId, setSeverityId] = useState('');
  const [causeId, setCauseId] = useState('');
  const [selectedVehicles, setSelectedVehicles] = useState([]);

  // Submission state
  const [submitting, setSubmitting] = useState(false);
  const [successMessage, setSuccessMessage] = useState(null);
  const [errorMessage, setErrorMessage] = useState(null);

  useEffect(() => {
    let isMounted = true;
    getLookups()
      .then((data) => {
        if (isMounted) {
          setLookups(data);
          if (data.locations?.length) setLocationId(data.locations[0].location_id);
          if (data.roads?.length) setRoadId(data.roads[0].road_id);
          if (data.weather_conditions?.length) setWeatherId(data.weather_conditions[0].weather_id);
          if (data.severities?.length) setSeverityId(data.severities[0].severity_id);
          if (data.causes?.length) setCauseId(data.causes[0].cause_id);
          if (data.vehicle_types?.length) setSelectedVehicles([data.vehicle_types[0].vehicle_type_id]);
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

  const handleVehicleToggle = (vehicleId) => {
    setSelectedVehicles((prev) => {
      if (prev.includes(vehicleId)) {
        if (prev.length === 1) return prev; // Keep at least one
        return prev.filter((id) => id !== vehicleId);
      } else {
        return [...prev, vehicleId];
      }
    });
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    setSuccessMessage(null);
    setErrorMessage(null);
    setSubmitting(true);

    const payload = {
      accident_date: accidentDate,
      accident_time: accidentTime.length === 5 ? `${accidentTime}:00` : accidentTime,
      description: description.trim() || 'Incident logged via frontend application',
      location_id: Number(locationId),
      road_id: Number(roadId),
      weather_id: Number(weatherId),
      severity_id: Number(severityId),
      cause_id: Number(causeId),
      vehicle_type_ids: selectedVehicles.map(Number)
    };

    try {
      const res = await createAccident(payload);
      setSuccessMessage(`Accident successfully registered with ID #${res.accident_id} (Vehicles recorded: ${res.vehicles_recorded}).`);
      setDescription('');
    } catch (err) {
      setErrorMessage(err.message);
    } finally {
      setSubmitting(false);
    }
  };

  if (loadingLookups) return <div className="loading-state">Loading form catalogs...</div>;
  if (lookupError) return <div className="error-message">Error loading lookups: {lookupError}</div>;

  return (
    <div className="tab-container">
      <h2>Record New Accident</h2>
      <p className="subtitle">
        Submits incident data with foreign key lookups and inserts into <code>accident</code> and{' '}
        <code>accident_vehicle</code> inside a database transaction.
      </p>

      {successMessage && <div className="success-banner">{successMessage}</div>}
      {errorMessage && <div className="error-message">{errorMessage}</div>}

      <form onSubmit={handleSubmit} className="form-card">
        <div className="form-grid">
          <div className="form-group">
            <label htmlFor="accidentDate">Date:</label>
            <input
              id="accidentDate"
              type="date"
              value={accidentDate}
              onChange={(e) => setAccidentDate(e.target.value)}
              required
            />
          </div>

          <div className="form-group">
            <label htmlFor="accidentTime">Time:</label>
            <input
              id="accidentTime"
              type="time"
              step="1"
              value={accidentTime}
              onChange={(e) => setAccidentTime(e.target.value)}
              required
            />
          </div>

          <div className="form-group">
            <label htmlFor="accidentLocation">Location:</label>
            <select
              id="accidentLocation"
              value={locationId}
              onChange={(e) => setLocationId(e.target.value)}
              required
            >
              {lookups.locations.map((loc) => (
                <option key={loc.location_id} value={loc.location_id}>
                  {loc.location_name} ({loc.district})
                </option>
              ))}
            </select>
          </div>

          <div className="form-group">
            <label htmlFor="accidentRoad">Roadway:</label>
            <select
              id="accidentRoad"
              value={roadId}
              onChange={(e) => setRoadId(e.target.value)}
              required
            >
              {lookups.roads.map((r) => (
                <option key={r.road_id} value={r.road_id}>
                  {r.road_name} [{r.road_type}, {r.speed_limit} km/h]
                </option>
              ))}
            </select>
          </div>

          <div className="form-group">
            <label htmlFor="formWeather">Weather:</label>
            <select
              id="formWeather"
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
            <label htmlFor="formSeverity">Severity Level:</label>
            <select
              id="formSeverity"
              value={severityId}
              onChange={(e) => setSeverityId(e.target.value)}
              required
            >
              {lookups.severities.map((s) => (
                <option key={s.severity_id} value={s.severity_id}>
                  {s.level_name} (Rank {s.level_rank})
                </option>
              ))}
            </select>
          </div>

          <div className="form-group">
            <label htmlFor="formCause">Primary Cause:</label>
            <select
              id="formCause"
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
        </div>

        {/* Vehicles Involved Selection */}
        <div className="form-group" style={{ marginTop: '1rem' }}>
          <label>Vehicles Involved (select 1 to 3):</label>
          <div className="checkbox-row">
            {lookups.vehicle_types.map((v) => {
              const checked = selectedVehicles.includes(v.vehicle_type_id);
              return (
                <label key={v.vehicle_type_id} className="checkbox-pill">
                  <input
                    type="checkbox"
                    checked={checked}
                    onChange={() => handleVehicleToggle(v.vehicle_type_id)}
                  />
                  <span>{v.type_name}</span>
                </label>
              );
            })}
          </div>
        </div>

        <div className="form-group" style={{ marginTop: '1rem' }}>
          <label htmlFor="formDescription">Incident Description:</label>
          <input
            id="formDescription"
            type="text"
            placeholder="e.g. Wet road skidding near highway curve"
            value={description}
            onChange={(e) => setDescription(e.target.value)}
          />
        </div>

        <button type="submit" className="btn-primary" disabled={submitting}>
          {submitting ? 'Recording Accident...' : 'Submit Accident Record'}
        </button>
      </form>
    </div>
  );
}
