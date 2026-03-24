# UrbanPulse Global Nexus - Project Report

### 🌍 Project Overview: UrbanPulse Global
UrbanPulse is a planetary-scale telemetry and environment tracking dashboard built in R. It simulates a massive global sensor network that aggregates real-time data on air quality, traffic congestion, and noise pollution, allowing users to drill down from a global view all the way to specific localized city zones.

---

### 🛠️ Technology Stack & Libraries Used
- **Core Framework**: `shiny` and `shinydashboard` for the application structure and reactive UI.
- **Interactive Visualizations**: `plotly` (for the 3D interactive globe and all scatter, box, and line charts) and `leaflet` (for country and city-level interactive 2D street/terrain maps).
- **Data Processing & Machine Learning**: Base R with `jsonlite` for API fetching, `stats` for analytical models (like K-Means), and `randomForest` for feature importance and predictive modeling.

---

### 🏗️ Application Architecture & UI Flow
The application is structured into three continuous drill-down layers, orchestrated by a dynamic UI router in `app.R`:

#### 1. Global Landing Page (`ui/landing_page.R`)
- Takes center stage with a **3D Interactive Globe** built with Plotly. Modifying the globe allows users to rotate the earth and see real-time AQI and congestion pings across different nations.
- Features a highly customized UI with sleek CSS gradients, glassmorphism metric boxes, and dynamic typography.
- The global metric readouts (Total Sensors and Active Nodes) are completely reactive and directly tied to the underlying live data engine.
- Clicking any nation on the globe triggers a reactive event that drills down to that specific country.

#### 2. National Dashboard (`ui/country_dashboard.R`)
- Replaces the globe with an interactive **Leaflet Map** focused on the selected country, plotting cities as dynamically sized and colored circle markers.
- Features an interactive **National Analytics Explorer** sidebar where users can select specific environmental indicators (AQI, PM2.5, NO2, Congestion, Noise) via dropdowns to instantly drive the following charts:
  - **National Trend Plot (`plotly`)**: A line chart showing the average temporal trend of the selected indicator across the country.
  - **City Distribution Plot (`plotly`)**: A box-plot visualizing the spread and median of the selected indicator across all cities in the country.
- Clicking a city marker on the map drills down further into the exact city parameters.

#### 3. City Dashboard (`ui/city_dashboard.R`)
- Focuses on specific intra-city **Zones**, mapping their boundaries and localized traffic/environmental stress directly on a macro **Leaflet Map**.
- Features an interactive **TabBox Dashboard** with two specific modes:
  - **Micro-Analytics Explorer**: Users can define X-Axis and Y-Axis metrics to dynamically generate a dual-axis analytical layout, rendering a **City Avg Trend (`plotly` line chart)** and a custom **Correlation scatter plot (`plotly`)** comparing variables like PM2.5 Density vs Traffic Congestion.
  - **AI Risk Intelligence (K-Means)**: Dedicated to machine learning outputs. This tab renders a highly specialized **Cluster Plot (`plotly`)** that segments all zones in the city into "Low, Moderate, and High/Hazardous" risk classes, alongside a dynamically generated LLM Insight summary text. 

---

### 📡 Data Pipeline & Simulation (`server/data_loader.R`)
The data generation is highly sophisticated, blending real-world API data with realistic algorithmic simulations:
- **Base Geolocation Data**: Fetches and caches data from the `cities.json` API and the `RestCountries API` to anchor data to real geographic coordinates.
- **Authentic Environmental Data**: Connects to the **Open-Meteo Air Quality API** to pull authentic, real-time metrics for PM10, PM2.5, Carbon Monoxide, Nitrogen Dioxide, Ozone, and European AQI for hundreds of cities.
- **Algorithmic Traffic Simulation**: Uses a time-zone aware algorithm to calculate local time based on longitude. It simulates rush hours (7-9 AM and 4-6 PM local time) to realistic drop traffic speeds and inversely spike the **Congestion Index** and **Noise pollution (dB)**.
- **Performance**: The fetched API data is cached into `data/cities_cache.rds` to ensure the dashboard remains incredibly fast and doesn't hit API rate limits on subsequent runs. 

---

### 🧠 Analytics & AI Integration (`server/analytics.R`)
The backend features advanced analytical frameworks that evaluate the simulated data streams:
1. **Machine Learning Feature Evaluation**: Uses a **Random Forest Algorithm (`randomForest`)** capped at 50 trees to dynamically forecast AQI and map the Gini importance values of varying factors (like humidity vs traffic congestion).
2. **Anomaly Detection & Risk Clustering**: An unsupervised **K-Means Clustering** model dynamically scales the features of the current city and organizes zones into 3 distinct Risk Categories ("Low", "Moderate", "High/Hazardous"). These clusters dictate the color-coding mapping on the AI Risk Interface.
3. **Deep Learning Forecasting (Mock)**: Simulates a neural network module that forecasts the AQI for the next 6 hours based on the current saturation of traffic congestion.
4. **LLM Insights Generator**: Analyzes the current dataset to generate plain-English, actionable intelligence summarizing the most critical zone and providing localized routing or pedestrian recommendations.

---

### 🎨 Design & Aesthetics (`server/visualizations.R`)
The project utilizes a centralized **Light Theme Color Palette** (`theme_colors`) prioritizing slate grays, bright blues, and contextual accent colors (Emerald for good, Amber for warning, Rose for critical) to ensure visual cohesion across all dynamic interactive charts and UI elements.
