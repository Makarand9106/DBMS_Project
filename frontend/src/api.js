// ============================================================================
// File: src/api.js
// Description: Centralized API client calling the Express MySQL backend.
// ============================================================================

// Use 127.0.0.1 to directly target the IPv4 Express server on macOS
const API_BASE = 'http://127.0.0.1:5000';

// Helper to handle response and parse JSON or throw meaningful error
async function handleResponse(res) {
  const data = await res.json().catch(() => ({}));
  if (!res.ok) {
    throw new Error(data.error || `HTTP error ${res.status}: ${res.statusText}`);
  }
  return data;
}

// 1. Fetch ranked hotspots from v_hotspot_ranking
export async function getHotspots() {
  const res = await fetch(`${API_BASE}/api/hotspots`);
  return handleResponse(res);
}

// 2. Fetch aggregation statistics (cause, weather, month, hour band)
export async function getStats() {
  const res = await fetch(`${API_BASE}/api/stats`);
  return handleResponse(res);
}

// 3. Fetch master entity lookups for form dropdowns
export async function getLookups() {
  const res = await fetch(`${API_BASE}/api/lookups`);
  return handleResponse(res);
}

// 4. Run stored procedure sp_predict_severity
export async function predictSeverity(payload) {
  const res = await fetch(`${API_BASE}/api/predict`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify(payload)
  });
  return handleResponse(res);
}

// 5. Insert a new accident with vehicle types and victims inside a transaction
export async function createAccident(payload) {
  const res = await fetch(`${API_BASE}/api/accidents`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify(payload)
  });
  return handleResponse(res);
}
