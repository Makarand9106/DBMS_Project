// ============================================================================
// File: src/App.jsx
// Description: Main application component with header, tab bar navigation, and tab views.
// ============================================================================

import React, { useState } from 'react';
import Hotspots from './components/Hotspots';
import Predict from './components/Predict';
import Analytics from './components/Analytics';
import AddAccident from './components/AddAccident';
import './App.css';

export default function App() {
  const [activeTab, setActiveTab] = useState('hotspots');

  return (
    <div className="app-container">
      {/* Application Header */}
      <header className="app-header">
        <div className="header-brand">
          <h1>Road Accident Hotspot Analysis & Severity Prediction</h1>
          <p className="header-subtitle">
            MySQL 8 DBMS Project • 3NF Normalized Schema • Real-time Prediction Stored Procedure
          </p>
        </div>

        {/* Tab Navigation Bar */}
        <nav className="tab-nav">
          <button
            className={`tab-btn ${activeTab === 'hotspots' ? 'active' : ''}`}
            onClick={() => setActiveTab('hotspots')}
          >
            Hotspots
          </button>
          <button
            className={`tab-btn ${activeTab === 'predict' ? 'active' : ''}`}
            onClick={() => setActiveTab('predict')}
          >
            Predict
          </button>
          <button
            className={`tab-btn ${activeTab === 'analytics' ? 'active' : ''}`}
            onClick={() => setActiveTab('analytics')}
          >
            Analytics
          </button>
          <button
            className={`tab-btn ${activeTab === 'add' ? 'active' : ''}`}
            onClick={() => setActiveTab('add')}
          >
            Add Accident
          </button>
        </nav>
      </header>

      {/* Main Tab View (one active at a time) */}
      <main className="app-main">
        {activeTab === 'hotspots' && <Hotspots />}
        {activeTab === 'predict' && <Predict />}
        {activeTab === 'analytics' && <Analytics />}
        {activeTab === 'add' && <AddAccident />}
      </main>

      <footer className="app-footer">
        <p>Road Accident Database Management System • Backend: Express & MySQL 8 Pool (Port 5000)</p>
      </footer>
    </div>
  );
}
