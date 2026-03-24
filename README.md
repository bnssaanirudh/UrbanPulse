# UrbanPulse Global Nexus

UrbanPulse is a planetary-scale telemetry and environment tracking dashboard built in R. It simulates a massive global sensor network that aggregates real-time data on air quality, traffic congestion, and noise pollution, visualizing it across 3 drill-down layers: from an auto-rotating 3D Globe to an interactive 40-visualization City Deep-Dive.

## Features
- **Global Landing Page:** Auto-rotating 3D Plotly globe, Live Top 15 Cities Table, Global Averages stats strip.
- **National Dashboards:** Interactive Leaflet maps with marker clustering, Region Summary statistics, and a 10x dynamic visualization grid analyzing national trends.
- **City Deep-Dives:** Maps with rich Live Traffic & Pollution Feed popups, AI Risk Intelligence (K-Means Clustering for anomaly detection), and a massive **40-chart** analytical visualization grid breaking down 10 intra-city zones.
- **Predictive ML:** Integrates `randomForest` for feature importance and dynamic AQI projection.

## Requirements
Ensure you have **R** installed on your system.
The following R packages are required to run the application:
```R
install.packages(c("shiny", "shinydashboard", "plotly", "leaflet", "jsonlite", "randomForest"))
```

*(Note: The `randomForest` package is crucial for the ML analytical computations on the city dashboard level.)*

## How to Run
1. Open your terminal or `cmd`/`powershell`.
2. Navigate to the project directory:
   ```bash
   cd path/to/rproj
   ```
3. Execute the Shiny app using the R command line:
   ```bash
   R -e "shiny::runApp()"
   ```
4. The application will launch in your default web browser (typically on port `127.0.0.1:----`).

## Application Structure
- `app.R`: Main application file containing the UI router and server logic.
- `ui/`: Contains the UI definitions for the Landing Page, Country Dashboard, and City Dashboard.
- `server/`: Contains the backend logic (`data_loader.R` for API fetching/simulation, `analytics.R` for ML models, `visualizations.R` for Plotly chart generators).
- `data/`: Caches geographic and atmospheric JSON records to prevent excessive API calls.
- `www/`: Contains static web assets like the custom cursor or generated PDFs.

## Tech Stack
- **R / Shiny**: Core application framework
- **Plotly**: 3D Globe and 2D analytical charts
- **Leaflet**: Interactive map rendering
- **RandomForest & K-Means**: Backend AI / Machine Learning risk generation
