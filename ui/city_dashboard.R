city_dashboard_ui <- function(id) {
  ns <- NS(id)
  tagList(
    tags$style(HTML("
        .scrollable-viz { padding-right: 15px; padding-bottom: 50vh; }
        .btn-back { background: #e2e8f0; color: #1e293b; border: none; padding: 10px 20px; border-radius: 5px; font-weight: bold; cursor: pointer; }
        .btn-back:hover { background: #cbd5e1; }
    ")),
    fluidRow(
      column(8, h2(uiOutput(ns("city_title")), style = "color: #0f172a; font-weight: 800;")),
      column(4, align = "right", actionButton(ns("back_to_country"), "⬅ Back to Country", class = "btn-back", style = "margin-top:20px;"))
    ),
    br(),
    fluidRow(
      # Left Map Side - Sticky Map
      column(
        4,
        div(
          style = "position: sticky; top: 20px; height: 95vh; padding-right: 20px;",
          div(
            style = "background: rgba(15, 23, 42, 0.8); border-radius: 12px; padding: 15px; margin-bottom: 15px; box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1);",
            h4("City Deep-Dive", style = "color: #38bdf8; margin: 0; font-weight: bold;"),
            p("Review zone-level telemetry across 40 analytical dashboards.", style = "color: #cbd5e1; margin-top: 5px; margin-bottom: 0;")
          ),
          uiOutput(ns("city_summary")),
          div(
            style = "border-radius: 12px; overflow: hidden; box-shadow: 0 10px 15px -3px rgba(0, 0, 0, 0.1); border: 1px solid #e2e8f0;",
            leaflet::leafletOutput(ns("city_map"), height = "calc(95vh - 110px)")
          )
        )
      ),
      # Right Visualizations Side (Interactive Tabs)
      column(
        8,
        div(
          class = "scrollable-viz",
          tabBox(
            width = 12,
            tabPanel(
              "Micro-Analytics Explorer",
              fluidRow(
                column(6, selectInput(ns("ind1"), "Primary Metric (Trend & X-Axis):", c("PM2.5" = "pm25", "Congestion" = "congestion_index", "Noise" = "noise_db", "Temperature" = "temperature"))),
                column(6, selectInput(ns("ind2"), "Correlation Metric (Y-Axis):", c("AQI" = "aqi", "NO2" = "no2", "CO2" = "co2", "Humidity" = "humidity")))
              ),
              plotlyOutput(ns("city_trend_plot"), height = "300px"),
              hr(),
              plotlyOutput(ns("city_cor_plot"), height = "300px")
            ),
            tabPanel(
              "AI Risk Intelligence (K-Means)",
              h4("Anomaly Detection & Hazardous Zone Clustering", style = "color:#0f172a; margin-bottom:15px;"),
              p("Our unsupervised ML model clusters city zones by risk category to help flag hazardous areas."),
              plotlyOutput(ns("cluster_plot"), height = "500px"),
              hr(),
              uiOutput(ns("llm_insights"))
            )
          )
        )
      )
    ),
    fluidRow(
      column(12,
        h3("Extended Telemetry Visualizations (40 Charts)", style = "color:#0f172a; margin-top:30px; margin-bottom:20px; font-weight:800;"),
        uiOutput(ns("extra_viz_grid"))
      )
    )
  )
}
