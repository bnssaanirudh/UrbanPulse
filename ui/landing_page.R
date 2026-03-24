landing_page_ui <- function(id) {
  ns <- NS(id)
  tagList(
    tags$style(HTML("
      .landing-bg {
        background: linear-gradient(135deg, #0f172a 0%, #1e1b4b 100%);
        color: #f8fafc;
        padding-top: 50px;
        padding-bottom: 80px;
      }
      .metric-box {
        background: rgba(30, 41, 59, 0.7);
        border: 1px solid rgba(148, 163, 184, 0.2);
        border-radius: 12px;
        padding: 20px;
        margin-bottom: 20px;
        backdrop-filter: blur(10px);
        box-shadow: 0 4px 6px rgba(0,0,0,0.1);
      }
      .globe-container {
        border-radius: 50%;
        overflow: hidden;
        box-shadow: 0 0 40px rgba(56, 189, 248, 0.15), inset 0 0 60px rgba(0,0,0,0.8);
        display: inline-block;
        background: transparent;
      }
      .section-divider { border-top: 1px solid #1e293b; margin: 60px auto; width: 80%; }
      .feature-card {
        background: rgba(30, 41, 59, 0.5);
        border: 1px solid #334155;
        border-radius: 14px;
        padding: 30px;
        text-align: center;
        transition: transform 0.3s ease, box-shadow 0.3s ease;
        height: 220px;
      }
      .feature-card:hover { transform: translateY(-5px); box-shadow: 0 12px 30px rgba(56,189,248,0.12); }
      .stat-card {
        background: linear-gradient(135deg, rgba(14,165,233,0.15), rgba(139,92,246,0.15));
        border: 1px solid rgba(56,189,248,0.2);
        border-radius: 12px;
        padding: 25px;
        text-align: center;
      }
      .city-table { width: 100%; border-collapse: collapse; }
      .city-table th { background: #1e293b; color: #38bdf8; padding: 12px; text-align: left; font-size: 0.85rem; text-transform: uppercase; letter-spacing: 1px; }
      .city-table td { padding: 10px 12px; border-bottom: 1px solid #1e293b; color: #cbd5e1; font-size: 0.95rem; }
      .city-table tr:hover { background: rgba(56,189,248,0.05); }
    ")),

    # Auto-rotate globe JS
    tags$script(HTML(sprintf("
      $(document).ready(function() {
        var rotating = true;
        var angle = 0;
        var globeId = '%s';
        
        var interval = setInterval(function() {
          var gd = document.getElementById(globeId);
          if (gd && gd.data && rotating) {
            angle = (angle + 0.5) %% 360;
            Plotly.relayout(gd, {'geo.projection.rotation': {lon: angle, lat: 10}});
          }
        }, 100);
        
        $(document).on('mouseenter', '#' + globeId, function() { rotating = false; });
        $(document).on('mouseleave', '#' + globeId, function() { rotating = true; });
      });
    ", ns("globe")))),

    div(class = "landing-bg",
      # HERO SECTION
      fluidRow(
        column(12, align = "center",
               h1("UrbanPulse Global Nexus", style = "color: #38bdf8; font-weight: 900; font-size: 4.5rem; letter-spacing: -1px; text-shadow: 0 0 20px rgba(56,189,248,0.3); margin-top: 20px;"),
               p("Planetary-Scale Telemetry & Environment Tracking", style = "color: #94a3b8; font-size: 1.2rem; letter-spacing: 2px; text-transform: uppercase; margin-bottom: 40px;")
        )
      ),
      fluidRow(
        column(3,
               div(style = "padding: 0 40px;",
                 h3("Project Overview", style="color:#e2e8f0; font-weight: 800; border-bottom: 1px solid #334155; padding-bottom: 15px;"),
                 p("UrbanPulse is an advanced, real-time planetary monitoring system. We aggregate massive telemetric streams spanning traffic congestion, atmospheric air quality (AQI, PM2.5, NO2), and urban noise pollution to give a holistic view of the earth's health.", style="color:#94a3b8; line-height:1.7; font-size: 1.05rem; margin-top: 20px; margin-bottom: 30px;"),
                 div(class="metric-box",
                     h4("Active Sensors", style="color:#38bdf8; margin-top:0; font-weight: 600; text-transform: uppercase; font-size: 0.85rem; letter-spacing: 1px;"),
                     uiOutput(ns("total_sensors"))
                 ),
                 div(class="metric-box",
                     h4("Smart Cities", style="color:#a78bfa; margin-top:0; font-weight: 600; text-transform: uppercase; font-size: 0.85rem; letter-spacing: 1px;"),
                     uiOutput(ns("total_cities"))
                 ),
                 div(class="metric-box",
                     h4("Countries Monitored", style="color:#10b981; margin-top:0; font-weight: 600; text-transform: uppercase; font-size: 0.85rem; letter-spacing: 1px;"),
                     uiOutput(ns("total_countries"))
                 )
               )
        ),
        column(6, align = "center",
               div(class = "globe-container",
                   plotlyOutput(ns("globe"), width = "800px", height = "800px")
               )
        ),
        column(3,
               div(style = "padding: 0 40px;",
                 h3("Live Interactivity", style="color:#e2e8f0; font-weight: 800; border-bottom: 1px solid #334155; padding-bottom: 15px;"),
                 p("Our nodes transmit data continuously, simulating a real-time data ingestion pipeline. The globe centralizes these pings.", style="color:#94a3b8; line-height:1.7; font-size: 1.05rem; margin-top: 20px; margin-bottom: 30px;"),
                 div(style="background: rgba(15, 23, 42, 0.6); border-radius: 12px; padding: 25px; border: 1px solid #1e293b;",
                   h4("Exploration Guide:", style="color:#f8fafc; margin-bottom: 20px; font-weight: 700;"),
                   tags$ul(style="color: #cbd5e1; font-size: 1.05rem; line-height: 2; padding-left: 20px;",
                     tags$li("Globe auto-rotates. Hover to pause."),
                     tags$li(strong("Click any nation", style="color:#38bdf8;"), " to drill down into the national dashboard"),
                     tags$li("Each country has 10+ analytical visualizations"),
                     tags$li("Each city features 40+ deep-dive charts"),
                     tags$li("AI-powered risk clustering per zone")
                   )
                 )
               )
        )
      ),

      # SECTION 2: FEATURES
      div(class="section-divider"),
      fluidRow(
        column(12, align="center",
          h2("Platform Capabilities", style="color:#e2e8f0; font-weight:900; font-size:2.5rem; margin-bottom:15px;"),
          p("Powered by R, Plotly, Leaflet, Random Forest, and K-Means Clustering", style="color:#64748b; font-size:1.1rem; margin-bottom:40px;")
        )
      ),
      fluidRow(
        column(3, offset=0,
          div(class="feature-card",
            h3("\U0001f30d", style="font-size:3rem; margin-bottom:10px;"),
            h4("3D Interactive Globe", style="color:#38bdf8; font-weight:700;"),
            p("Orthographic projection with live AQI markers across 100+ cities worldwide.", style="color:#94a3b8;")
          )
        ),
        column(3,
          div(class="feature-card",
            h3("\U0001f9e0", style="font-size:3rem; margin-bottom:10px;"),
            h4("ML Risk Engine", style="color:#a78bfa; font-weight:700;"),
            p("K-Means clustering classifies zones into Low, Moderate, and High/Hazardous risk categories.", style="color:#94a3b8;")
          )
        ),
        column(3,
          div(class="feature-card",
            h3("\U0001f4ca", style="font-size:3rem; margin-bottom:10px;"),
            h4("40+ City-Level Charts", style="color:#10b981; font-weight:700;"),
            p("Violin plots, heatmaps, scatter correlations, bar charts, histograms, and bubble charts.", style="color:#94a3b8;")
          )
        ),
        column(3,
          div(class="feature-card",
            h3("\U0001f6a6", style="font-size:3rem; margin-bottom:10px;"),
            h4("Live Traffic Feed", style="color:#f59e0b; font-weight:700;"),
            p("Click any city zone to see real-time congestion, AQI, PM2.5, and NO2 readings.", style="color:#94a3b8;")
          )
        )
      ),

      # SECTION 3: HOT CITIES TABLE
      div(class="section-divider"),
      fluidRow(
        column(12, align="center",
          h2("Top Monitored Cities - Live Feed", style="color:#e2e8f0; font-weight:900; font-size:2.5rem; margin-bottom:15px;"),
          p("Snapshot of the highest-activity nodes in the network", style="color:#64748b; font-size:1.1rem; margin-bottom:30px;")
        )
      ),
      fluidRow(
        column(10, offset=1,
          uiOutput(ns("city_data_table"))
        )
      ),

      # SECTION 4: STATS STRIP
      div(class="section-divider"),
      fluidRow(
        column(12, align="center",
          h2("Global Averages", style="color:#e2e8f0; font-weight:900; font-size:2.5rem; margin-bottom:40px;")
        )
      ),
      fluidRow(
        column(2, offset=1, div(class="stat-card", h3(uiOutput(ns("avg_aqi")), style="color:#ef4444; font-size:2.5rem; margin:0;"), p("Avg AQI", style="color:#94a3b8;")) ),
        column(2, div(class="stat-card", h3(uiOutput(ns("avg_pm25")), style="color:#f59e0b; font-size:2.5rem; margin:0;"), p("Avg PM2.5", style="color:#94a3b8;")) ),
        column(2, div(class="stat-card", h3(uiOutput(ns("avg_congestion")), style="color:#38bdf8; font-size:2.5rem; margin:0;"), p("Avg Congestion", style="color:#94a3b8;")) ),
        column(2, div(class="stat-card", h3(uiOutput(ns("avg_noise")), style="color:#a78bfa; font-size:2.5rem; margin:0;"), p("Avg Noise (dB)", style="color:#94a3b8;")) ),
        column(2, div(class="stat-card", h3(uiOutput(ns("avg_speed")), style="color:#10b981; font-size:2.5rem; margin:0;"), p("Avg Speed km/h", style="color:#94a3b8;")) )
      ),

      # FOOTER
      div(class="section-divider"),
      fluidRow(
        column(12, align="center",
          p("UrbanPulse Global Nexus v2.0 | Built with R Shiny, Plotly, Leaflet, & Random Forest", style="color:#475569; font-size:0.9rem; margin-top:20px;"),
          p("Click any nation on the globe above to begin your exploration.", style="color:#64748b; font-size:1rem;")
        )
      )
    )
  )
}
