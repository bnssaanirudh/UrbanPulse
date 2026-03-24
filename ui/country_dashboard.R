country_dashboard_ui <- function(id) {
  ns <- NS(id)
  tagList(
    tags$style(HTML("
        .light-card { background: #ffffff; border-radius: 12px; padding: 20px; margin-bottom: 20px; box-shadow: 0 4px 6px rgba(0,0,0,0.05); border: 1px solid #e2e8f0; }
        .light-panel { background: #f8fafc; border-left: 5px solid #0ea5e9; padding: 20px; margin-bottom: 20px; border-radius: 0 12px 12px 0; font-size: 1.1em; color: #334155; }
        .btn-back { background: #e2e8f0; color: #1e293b; border: none; padding: 10px 20px; border-radius: 5px; font-weight: bold; cursor: pointer; }
        .btn-back:hover { background: #cbd5e1; }
        .scrollable-viz { padding-right: 15px; padding-bottom: 50vh; }
      ")),
    fluidRow(
      column(8, h2(uiOutput(ns("country_title")), style = "color: #0f172a; font-weight: 800;")),
      column(4, align="right", actionButton(ns("back_to_globe"), "Back to Globe", class="btn-back", style="margin-top:20px;"))
    ),
    br(),
    fluidRow(
      column(5,
             div(style = "position: sticky; top: 20px; height: 95vh; padding-right: 20px;",
                 div(style = "background: rgba(15, 23, 42, 0.8); border-radius: 12px; padding: 15px; margin-bottom: 15px; box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1);",
                     h4("National Overview", style="color: #38bdf8; margin: 0; font-weight: bold;"),
                     p("Select any city on the map to access the deep-dive 40-visualization City Dashboard.", style="color: #cbd5e1; margin-top: 5px; margin-bottom: 0;")
                 ),
                 uiOutput(ns("country_summary")),
                 div(style = "border-radius: 12px; overflow: hidden; box-shadow: 0 10px 15px -3px rgba(0, 0, 0, 0.1); border: 1px solid #e2e8f0;",
                     leaflet::leafletOutput(ns("country_map"), height = "calc(95vh - 200px)")
                 )
             )
      ),
      column(7,
             div(class = "scrollable-viz",
                 box(width = 12, status = "primary", solidHeader = TRUE, title = "National Analytics Explorer",
                     selectInput(ns("metric_selector"), "Select Environmental Indicator:", 
                                 choices = c("AQI" = "aqi", "PM2.5" = "pm25", "NO2" = "no2", "Congestion" = "congestion_index", "Noise (dB)" = "noise_db")),
                     plotlyOutput(ns("metric_trend_plot"), height="350px"),
                     hr(),
                     plotlyOutput(ns("metric_dist_plot"), height="350px")
                 ),
                 h3("Full National Analytics (10 Charts)", style="color:#0f172a; margin-top:30px; font-weight:800;"),
                 uiOutput(ns("country_viz_grid"))
             )
      )
    )
  )
}
