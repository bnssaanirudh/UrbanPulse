library(shiny)
library(shinydashboard)
library(plotly)
library(leaflet)

source("server/data_loader.R")
source("server/visualizations.R")
source("server/analytics.R")
source("ui/landing_page.R")
source("ui/country_dashboard.R")
source("ui/city_dashboard.R")

ui <- dashboardPage(
  dashboardHeader(title = "UrbanPulse Global"),
  dashboardSidebar(disable = TRUE),
  dashboardBody(
    uiOutput("main_content")
  )
)

server <- function(input, output, session) {
  
  # State
  current_view <- reactiveVal("globe") # "globe", "country", "city"
  selected_country <- reactiveVal(NULL)
  selected_city <- reactiveVal(NULL)
  
  # Data
  raw_data <- reactive({
    # invalidateLater(5000, session) # Disabled to stop constant refreshing
    # Get latest simulated sensor data
    load_urban_data()
  })
  
  globe_summary <- reactive({
    get_globe_summary(raw_data())
  })
  
  # Reactive Data Contexts
  country_data <- reactive({
    req(selected_country())
    df <- raw_data()
    df[df$country == selected_country(), ]
  })
  
  city_data <- reactive({
    req(selected_city())
    df <- raw_data()
    df[df$city == selected_city(), ]
  })
  
  # Dynamic UI Router
  output$main_content <- renderUI({
    view <- current_view()
    if (view == "globe") {
      landing_page_ui("landing")
    } else if (view == "country") {
      country_dashboard_ui("country_dash")
    } else if (view == "city") {
      city_dashboard_ui("city_dash")
    }
  })
  
  # ----------- GLOBE LAYER -----------
  output[["landing-total_sensors"]] <- renderUI({
    req(raw_data())
    h2(format(nrow(raw_data()), big.mark=","), style="font-weight:900; margin:0; font-size: 2.5rem;")
  })
  
  output[["landing-total_cities"]] <- renderUI({
    req(raw_data())
    h2(paste(length(unique(raw_data()$city)), "Nodes"), style="font-weight:900; margin:0; font-size: 2.5rem;")
  })
  
  output[["landing-total_countries"]] <- renderUI({
    req(raw_data())
    h2(length(unique(raw_data()$country)), style="font-weight:900; margin:0; font-size: 2.5rem;")
  })
  
  output[["landing-avg_aqi"]] <- renderUI({ req(raw_data()); tags$span(round(mean(raw_data()$aqi, na.rm=T))) })
  output[["landing-avg_pm25"]] <- renderUI({ req(raw_data()); tags$span(round(mean(raw_data()$pm25, na.rm=T), 1)) })
  output[["landing-avg_congestion"]] <- renderUI({ req(raw_data()); tags$span(paste0(round(mean(raw_data()$congestion_index, na.rm=T)), "%")) })
  output[["landing-avg_noise"]] <- renderUI({ req(raw_data()); tags$span(round(mean(raw_data()$noise_db, na.rm=T), 1)) })
  output[["landing-avg_speed"]] <- renderUI({ req(raw_data()); tags$span(round(mean(raw_data()$traffic_speed_kmh, na.rm=T), 1)) })
  
  output[["landing-city_data_table"]] <- renderUI({
    req(raw_data())
    gs <- get_globe_summary(raw_data())
    gs <- gs[order(-gs$aqi), ]
    top <- head(gs, 15)
    
    rows <- lapply(1:nrow(top), function(i) {
      r <- top[i,]
      aqi_val <- as.numeric(r$aqi)
      congestion_val <- as.numeric(r$congestion_index)
      pm25_val <- as.numeric(r$pm25)
      lat_val <- as.numeric(r$lat)
      lng_val <- as.numeric(r$lng)
      
      aqi_color <- if(is.na(aqi_val)) "#10b981" else if(aqi_val > 50) "#ef4444" else if(aqi_val > 25) "#f59e0b" else "#10b981"
      tags$tr(
        tags$td(r$country),
        tags$td(paste0(round(lat_val, 2), ", ", round(lng_val, 2))),
        tags$td(style=paste0("color:", aqi_color, "; font-weight:bold;"), ifelse(is.na(aqi_val), "N/A", round(aqi_val))),
        tags$td(paste0(ifelse(is.na(congestion_val), "N/A", round(congestion_val)), "%")),
        tags$td(ifelse(is.na(pm25_val), "N/A", round(pm25_val, 1)))
      )
    })
    
    tags$table(class="city-table",
      tags$thead(tags$tr(
        tags$th("Country"), tags$th("Coordinates"), tags$th("AQI"), tags$th("Congestion"), tags$th("PM2.5")
      )),
      tags$tbody(rows)
    )
  })

  output[["landing-globe"]] <- renderPlotly({
    plot_interactive_globe(globe_summary())
  })
  
  # Globe Click Event
  observeEvent(event_data("plotly_click"), {
    click <- event_data("plotly_click")
    if (!is.null(click) && !is.null(click$customdata)) {
      selected_country(click$customdata)
      current_view("country")
    }
  })
  
  # ----------- COUNTRY LAYER -----------
  output[["country_dash-country_title"]] <- renderUI({ paste("National Dashboard:", selected_country()) })
  
  output[["country_dash-country_summary"]] <- renderUI({
    req(country_data())
    df <- country_data()
    n_cities <- length(unique(df$city))
    n_zones <- length(unique(paste(df$city, df$zone)))
    div(style="background: linear-gradient(135deg, rgba(14,165,233,0.1), rgba(139,92,246,0.1)); border: 1px solid #e2e8f0; border-radius: 12px; padding: 20px; margin-bottom: 20px;",
      h4(paste("Region Summary:", selected_country()), style="color:#0f172a; font-weight:800; margin-top:0;"),
      p(paste0("Monitoring ", n_cities, " cities with ", n_zones, " active zones."), style="color:#334155;"),
      p(paste0("Avg AQI: ", round(mean(df$aqi, na.rm=T)), " | Avg PM2.5: ", round(mean(df$pm25, na.rm=T), 1),
               " \u00b5g/m\u00b3 | Avg Congestion: ", round(mean(df$congestion_index, na.rm=T)), "%",
               " | Avg Noise: ", round(mean(df$noise_db, na.rm=T), 1), " dB"), style="color:#475569; font-size:0.95rem;"),
      p(paste0("Traffic Avg Speed: ", round(mean(df$traffic_speed_kmh, na.rm=T), 1), " km/h | Temperature: ",
               round(mean(df$temperature, na.rm=T), 1), "\u00b0C | Humidity: ", round(mean(df$humidity, na.rm=T)), "%"), style="color:#475569; font-size:0.95rem;")
    )
  })
  
  observeEvent(input[["country_dash-back_to_globe"]], {
    current_view("globe")
  })
  
  output[["country_dash-country_map"]] <- renderLeaflet({
    req(selected_country())
    c_summary <- get_country_summary(raw_data(), selected_country())
    
    leaflet(c_summary) %>%
      addProviderTiles(providers$CartoDB.Positron) %>%
      addCircleMarkers(
        ~lng, ~lat, 
        layerId = ~city,
        label = ~paste(city, "- AQI:", round(aqi)),
        fillColor = ~ifelse(aqi > 50, "#ef4444", ifelse(aqi > 25, "#f59e0b", "#10b981")), 
        radius = ~10 + (congestion_index / 10),
        fillOpacity = 0.8,
        stroke = FALSE,
        clusterOptions = markerClusterOptions() # Fixes clumsy overloading in India
      )
  })
  
  # Country Map Click
  observeEvent(input[["country_dash-country_map_marker_click"]], {
    click <- input[["country_dash-country_map_marker_click"]]
    if (!is.null(click$id)) {
      selected_city(click$id)
      current_view("city")
    }
  })
  
  # Country Interactive Charts
  output[["country_dash-metric_trend_plot"]] <- renderPlotly({
    req(current_view() == "country", input[["country_dash-metric_selector"]])
    plot_country_trend(country_data(), input[["country_dash-metric_selector"]])
  })
  
  output[["country_dash-metric_dist_plot"]] <- renderPlotly({
    req(current_view() == "country", input[["country_dash-metric_selector"]])
    plot_country_dist(country_data(), input[["country_dash-metric_selector"]])
  })
  
  # 10 Country Charts Grid
  output[["country_dash-country_viz_grid"]] <- renderUI({
    plot_output_list <- lapply(1:10, function(i) {
      box(width = 6, status = "primary",
          plotlyOutput(paste0("country_plot_", i), height = "300px"))
    })
    do.call(tagList, plot_output_list)
  })
  
  observe({
    req(current_view() == "country")
    ctype_plots <- generate_country_charts(country_data(), 10)
    for (i in 1:10) {
      local({
        my_i <- i
        output[[paste0("country_plot_", my_i)]] <- renderPlotly({ ctype_plots[[my_i]] })
      })
    }
  })
  
  # ----------- CITY LAYER -----------
  output[["city_dash-city_title"]] <- renderUI({ paste("City Dashboard:", selected_city()) })
  
  output[["city_dash-city_summary"]] <- renderUI({
    req(city_data())
    df <- city_data()
    n_zones <- length(unique(df$zone))
    top_zone <- df$zone[which.max(df$congestion_index)]
    div(style="background: linear-gradient(135deg, rgba(239,68,68,0.08), rgba(245,158,11,0.08)); border: 1px solid #fde68a; border-radius: 12px; padding: 15px; margin-bottom: 15px;",
      h4(paste("City Intelligence:", selected_city()), style="color:#0f172a; font-weight:800; margin-top:0; font-size:1rem;"),
      p(paste0("Active Zones: ", n_zones, " | Most Congested: ", top_zone), style="color:#334155; margin:3px 0; font-size:0.9rem;"),
      p(paste0("Avg AQI: ", round(mean(df$aqi, na.rm=T)), " | PM2.5: ", round(mean(df$pm25, na.rm=T),1),
               " | Congestion: ", round(mean(df$congestion_index, na.rm=T)), "% | Speed: ",
               round(mean(df$traffic_speed_kmh, na.rm=T),1), " km/h"), style="color:#475569; margin:3px 0; font-size:0.85rem;"),
      p(paste0("Temp: ", round(mean(df$temperature, na.rm=T),1), "\u00b0C | Humidity: ",
               round(mean(df$humidity, na.rm=T)), "% | Noise: ", round(mean(df$noise_db, na.rm=T),1), " dB"), style="color:#475569; margin:3px 0; font-size:0.85rem;")
    )
  })
  
  observeEvent(input[["city_dash-back_to_country"]], {
    current_view("country")
  })
  
  output[["city_dash-city_map"]] <- renderLeaflet({
    req(selected_city())
    city_sum <- get_city_summary(raw_data(), selected_city())
    
    # Live Feed Data
    feed_label <- sprintf(
      "<strong>%s</strong><br/>🚦 Traffic Congestion: %d%%<br/>😷 AQI: %d<br/>🌫️ PM2.5: %.1f µg/m³<br/>🚗 NO2: %.1f",
      city_sum$zone, round(city_sum$congestion_index), round(city_sum$aqi), city_sum$pm25, city_sum$no2
    )

    leaflet(city_sum) %>%
      addProviderTiles(providers$CartoDB.Positron) %>%
      addCircleMarkers(
        ~lng, ~lat, 
        layerId = ~zone,
        popup = ~lapply(feed_label, htmltools::HTML),
        label = ~paste(zone, "- Click for Live Traffic & Pollution Feed"),
        fillColor = ~ifelse(congestion_index > 75, "#ef4444", ifelse(congestion_index > 50, "#f59e0b", "#10b981")), 
        radius = 12,
        fillOpacity = 0.8,
        stroke = TRUE, weight=2, color="white"
      )
  })
  
  # City Interactive Charts
  output[["city_dash-city_trend_plot"]] <- renderPlotly({
    req(current_view() == "city", input[["city_dash-ind1"]])
    plot_city_trend(city_data(), input[["city_dash-ind1"]])
  })
  
  output[["city_dash-city_cor_plot"]] <- renderPlotly({
    req(current_view() == "city", input[["city_dash-ind1"]], input[["city_dash-ind2"]])
    plot_city_cor(city_data(), input[["city_dash-ind1"]], input[["city_dash-ind2"]])
  })
  
  # ML Cluster Plot
  output[["city_dash-cluster_plot"]] <- renderPlotly({
    req(current_view() == "city")
    data_with_clusters <- run_kmeans_clustering(city_data())
    plot_ml_clusters(data_with_clusters)
  })
  
  output[["city_dash-llm_insights"]] <- renderUI({
    req(current_view() == "city")
    insight <- generate_llm_insights(city_data())
    div(style="background: #f8fafc; border-left: 4px solid #8b5cf6; padding: 15px; border-radius: 4px;",
        p(insight, style="margin:0; font-size: 1.1em; color: #334155;")
    )
  })
  
  # 40x City Charts Render
  output[["city_dash-extra_viz_grid"]] <- renderUI({
    plot_output_list <- lapply(1:40, function(i) {
      box(width = 6, status = "info",
          plotlyOutput(paste0("city_extra_plot_", i), height = "250px"))
    })
    do.call(tagList, plot_output_list)
  })
  
  observe({
    req(current_view() == "city")
    extra_plots <- generate_city_charts(city_data(), 40)
    for (i in 1:40) {
      local({
        my_i <- i
        output[[paste0("city_extra_plot_", my_i)]] <- renderPlotly({ extra_plots[[my_i]] })
      })
    }
  })

}

shinyApp(ui = ui, server = server)
