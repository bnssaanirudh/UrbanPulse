# UrbanPulse Global Nexus - Project Report

### 🌍 Project Overview: UrbanPulse Global
UrbanPulse is a planetary-scale telemetry and environment tracking dashboard built in R. It simulates a massive global sensor network that aggregates real-time data on air quality, traffic congestion, and noise pollution. The platform allows users to drill down from a macro global view to massive 40-visualization deep dives at the municipal zone level.

---

### 🛠️ Technology Stack & Libraries Used
- **Core Framework**: `shiny` and `shinydashboard` for the application structure and reactive UI.
- **Interactive Visualizations**: `plotly` (for the massive 10x and 40x interactive chart grids, 3D rotating globe, heatmaps, violin plots) and `leaflet` (for country and city-level interactive 2D street/terrain maps with marker clustering and rich popups).
- **Data Processing & Machine Learning**: Base R with `jsonlite` for API fetching, `stats` for K-Means anomaly risk clustering, and `randomForest` for feature importance and AQI predictive modeling.

---

### 🏗️ Application Architecture & UI Flow
The application is structured into three continuous drill-down layers, orchestrated by a dynamic UI router in `app.R`:

#### 1. Global Landing Page (`ui/landing_page.R`)
- Takes center stage with an **Auto-Rotating 3D Interactive Globe** built with Plotly. Modifying the globe allows users to rotate the earth (or pause on hover) and see real-time AQI and congestion pings across different nations.
- Redesigned into a sprawling, modern **Deep-Slate Dark Theme** featuring glassmorphism metric boxes, dynamic typography, and sleek CSS gradients.
- **Data Summaries & Capabilities**: Features a live updating "Top 15 Cities" table, global average statistic strips (Avg AQI, PM2.5, Congestion, Noise), and capability feature cards.
- Clicking any nation on the globe triggers a reactive event that drills down to that specific country.

#### 2. National Dashboard (`ui/country_dashboard.R`)
- Replaces the globe with an interactive **Leaflet Map** focused on the selected country, plotting cities as dynamically sized and colored circle markers. Uses **marker-clustering** to elegantly solve overlapping markers in dense environments like India.
- **Country Summary Panel**: Instantly calculates and displays the number of active zones, cities, and average regional telemetry values (AQI, temp, speed, noise).
- Features an interactive **National Analytics Explorer** sidebar where users can select specific environmental indicators to instantly drive trend and box plots.
- **10x Country Analytics Grid**: Automatically generates 10 massive visualizations capturing national environmental trends (Time-series scatters, correlation plots, bar charts, stacked areas, and 2D heatmaps) cycling through every metric.
- Clicking a city marker on the map drills down further into the exact city parameters.

#### 3. City Dashboard (`ui/city_dashboard.R`)
- Focuses on 10 specific intra-city **Zones**, mapping their boundaries and localized traffic/environmental stress directly on a macro **Leaflet Map**. 
- **Live Traffic & Pollution Feed**: Clicking any zone marker opening a rich HTML popup displaying real-time traffic congestion %, PM2.5, NO2, and AQI indices.
- **City Intelligence Panel**: Shows active zones, identifies the most congested zone, and summarizes urban parameters.
- Features an interactive **TabBox Dashboard** with three modes:
  - **Micro-Analytics Explorer**: Users define X and Y metrics to generate highly targeted dual-axis analytical layouts (Trend vs Correlation).
  - **AI Risk Intelligence (K-Means)**: Dedicated to machine learning outputs. This tab renders a **Cluster Plot** that segments zones into "Low, Moderate, and High/Hazardous" risk classes, alongside a generated LLM Insight summary.
  - **40x Deep Analytics**: An immense grid of **40 visualizations** dynamically spawned across 8 different chart typologies (Zone Area Trends, Scatter Correlations, Bar Breakdowns, Violin plots, Histograms, Box plots, 2D Heatmaps, and Bubble sizes).

---

### 📡 Data Pipeline & Simulation (`server/data_loader.R`)
The data generation is highly sophisticated, blending real-world API data with algorithmic simulations:
- **Base Geolocation**: Fetches and caches data from the `cities.json` API and the `RestCountries API` to anchor data to real geographic coordinates.
- **Authentic Environment Data**: Connects to the **Open-Meteo Air Quality API** to pull baseline atmospheric data (PM10, PM2.5, CO2, NO2, Ozone).
- **Algorithmic Simulation**: Simulates intra-city zones (10 per city) with an algorithm simulating rush hours (7-9 AM and 4-6 PM local time) to realistically augment **Congestion** and **Noise pollution (dB)**.

---

### 🧠 Analytics & AI Integration (`server/analytics.R`)
The backend features analytical ML frameworks that evaluate the simulated data streams:
1. **Machine Learning Feature Evaluation**: Uses a **Random Forest Algorithm (`randomForest`)** capped at 50 trees to dynamically forecast AQI and map the Gini importance values of varying factors (like humidity vs traffic congestion).
2. **Anomaly Detection & Risk Clustering**: An unsupervised **K-Means Clustering** model dynamically scales features and organizes city zones into 3 distinct Risk Categories ("Low", "Moderate", "High/Hazardous").
3. **LLM Insights Generator**: Analyzes the current dataset to generate plain-English actionable intelligence.

---

### 🎨 Design & Aesthetics (`server/visualizations.R`)
The project utilizes a dynamic dark mode aesthetic for the Global layer and a polished, professional light theme (`theme_colors`) prioritizing slate grays, bright blues, and contextual accent colors (Emerald for good, Amber for warning, Rose for critical) for the dashboard layers, ensuring optimal legibility across 50+ simultaneous interactive charts.
