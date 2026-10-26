// ============================================================================
// File: src/components/Analytics.jsx
// Description: Multi-dimensional analytics charts (Cause, Weather, Month) using Recharts.
// ============================================================================

import React, { useState, useEffect } from 'react';
import {
  BarChart,
  Bar,
  LineChart,
  Line,
  XAxis,
  YAxis,
  Tooltip,
  Legend,
  ResponsiveContainer,
  CartesianGrid
} from 'recharts';
import { getStats } from '../api';

export default function Analytics() {
  const [stats, setStats] = useState(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

  useEffect(() => {
    let isMounted = true;
    getStats()
      .then((data) => {
        if (isMounted) {
          setStats(data);
          setLoading(false);
        }
      })
      .catch((err) => {
        if (isMounted) {
          setError(err.message);
          setLoading(false);
        }
      });
    return () => {
      isMounted = false;
    };
  }, []);

  if (loading) return <div className="loading-state">Loading statistical aggregations...</div>;
  if (error) return <div className="error-message">Error loading analytics: {error}</div>;

  return (
    <div className="tab-container">
      <h2>Accident Analytics & Aggregations</h2>
      <p className="subtitle">
        Visual breakdown of incidents grouped by primary cause, environmental weather, and timeline.
      </p>

      {/* Chart 1: Accidents by Primary Cause */}
      <div className="chart-card">
        <h3>1. Accidents & Fatalities by Cause</h3>
        <div style={{ width: '100%', height: 320 }}>
          <ResponsiveContainer>
            <BarChart
              data={stats.by_cause}
              margin={{ top: 20, right: 30, left: 10, bottom: 40 }}
            >
              <CartesianGrid strokeDasharray="3 3" stroke="#eee" />
              <XAxis
                dataKey="cause_name"
                angle={-15}
                textAnchor="end"
                interval={0}
                tick={{ fontSize: 12 }}
              />
              <YAxis />
              <Tooltip />
              <Legend verticalAlign="top" height={36} />
              <Bar dataKey="total_accidents" name="Total Incidents" fill="#6366f1" />
              <Bar dataKey="fatal_count" name="Fatal Incidents" fill="#ef4444" />
            </BarChart>
          </ResponsiveContainer>
        </div>
      </div>

      {/* Chart 2: Accidents by Weather Condition */}
      <div className="chart-card">
        <h3>2. Severity Breakdown by Weather Condition</h3>
        <div style={{ width: '100%', height: 500 }}>
          <ResponsiveContainer>
            <BarChart
              data={stats.by_weather}
              margin={{ top: 20, right: 30, left: 10, bottom: 20 }}
            >
              <CartesianGrid strokeDasharray="3 3" stroke="#eee" />
              <XAxis dataKey="condition_name" tick={{ fontSize: 13 }} />
              <YAxis />
              <Tooltip />
              <Legend verticalAlign="top" height={36} />
              <Bar dataKey="minor_count" name="Minor (Rank 1)" fill="#10b981" stackId="a" />
              <Bar dataKey="serious_count" name="Serious (Rank 2)" fill="#f97316" stackId="a" />
              <Bar dataKey="fatal_count" name="Fatal (Rank 3)" fill="#ef4444" stackId="a" />
            </BarChart>
          </ResponsiveContainer>
        </div>
      </div>

      {/* Chart 3: Accidents Chronologically by Month */}
      <div className="chart-card">
        <h3>3. Monthly Incident Trend (2023 - 2025)</h3>
        <div style={{ width: '100%', height: 320 }}>
          <ResponsiveContainer>
            <LineChart
              data={stats.by_month}
              margin={{ top: 20, right: 30, left: 10, bottom: 40 }}
            >
              <CartesianGrid strokeDasharray="3 3" stroke="#eee" />
              <XAxis
                dataKey="accident_month"
                angle={-45}
                textAnchor="end"
                interval={0}
                tick={{ fontSize: 11 }}
              />
              <YAxis />
              <Tooltip />
              <Legend verticalAlign="top" height={36} />
              <Line
                type="monotone"
                dataKey="total_accidents"
                name="Total Accidents"
                stroke="#2563eb"
                strokeWidth={3}
                dot={{ r: 4 }}
              />
              <Line
                type="monotone"
                dataKey="fatal_count"
                name="Fatal Crashes"
                stroke="#dc2626"
                strokeWidth={2}
                dot={{ r: 3 }}
              />
            </LineChart>
          </ResponsiveContainer>
        </div>
      </div>
    </div>
  );
}
