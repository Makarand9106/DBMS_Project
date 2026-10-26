// ============================================================================
// File: src/components/Hotspots.jsx
// Description: Ranked hotspot table with top 3 highlighted and location bar chart.
// ============================================================================

import React, { useState, useEffect } from 'react';
import {
  BarChart,
  Bar,
  XAxis,
  YAxis,
  Tooltip,
  Legend,
  ResponsiveContainer,
  CartesianGrid
} from 'recharts';
import { getHotspots } from '../api';

export default function Hotspots() {
  const [hotspots, setHotspots] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

  useEffect(() => {
    let isMounted = true;
    getHotspots()
      .then((data) => {
        if (isMounted) {
          setHotspots(data);
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

  if (loading) return <div className="loading-state">Loading accident hotspots...</div>;
  if (error) return <div className="error-message">Error: {error}</div>;

  return (
    <div className="tab-container">
      <h2>Accident Hotspot Ranking</h2>
      <p className="subtitle">
        Locations ranked by composite Risk Score (Minor = 1, Serious = 2, Fatal = 3).
        Top 3 high-risk zones highlighted.
      </p>

      {/* Ranked Table */}
      <div className="table-responsive">
        <table className="data-table">
          <thead>
            <tr>
              <th>Rank</th>
              <th>Location</th>
              <th>District</th>
              <th>Total Accidents</th>
              <th>Fatal Count</th>
              <th>Risk Score</th>
            </tr>
          </thead>
          <tbody>
            {hotspots.map((item, index) => {
              const isTop3 = index < 3;
              return (
                <tr key={item.location_id} className={isTop3 ? 'row-hotspot-top3' : ''}>
                  <td>
                    <strong>#{index + 1}</strong>
                    {isTop3 && <span className="badge-danger">HIGH RISK</span>}
                  </td>
                  <td>{item.location_name}</td>
                  <td>{item.district}</td>
                  <td>{item.total_accidents}</td>
                  <td className={item.fatal_count > 0 ? 'text-fatal' : ''}>
                    {item.fatal_count}
                  </td>
                  <td>
                    <strong>{item.risk_score}</strong>
                  </td>
                </tr>
              );
            })}
          </tbody>
        </table>
      </div>

      {/* Recharts Bar Chart of Accidents per Location */}
      <div className="chart-card">
        <h3>Accidents & Fatalities by Location</h3>
        <div style={{ width: '100%', height: 360 }}>
          <ResponsiveContainer>
            <BarChart
              data={hotspots}
              margin={{ top: 20, right: 30, left: 10, bottom: 60 }}
            >
              <CartesianGrid strokeDasharray="3 3" stroke="#eee" />
              <XAxis
                dataKey="location_name"
                angle={-25}
                textAnchor="end"
                interval={0}
                height={70}
                tick={{ fontSize: 12 }}
              />
              <YAxis />
              <Tooltip />
              <Legend verticalAlign="top" height={36} />
              <Bar dataKey="total_accidents" name="Total Accidents" fill="#3b82f6" />
              <Bar dataKey="fatal_count" name="Fatalities" fill="#ef4444" />
            </BarChart>
          </ResponsiveContainer>
        </div>
      </div>
    </div>
  );
}
