# Visualization Engine for Massive Dashboards
library(plotly)

# Light Theme Colors
theme_colors <- list(
  bg = "#ffffff",         # Light background
  container = "#f8fafc",  # Slightly off-white container
  grid = "#e2e8f0",       # Light grid lines
  text = "#334155",       # Dark slate text
  primary = "#0ea5e9",    # Blue
  secondary = "#8b5cf6",  # Purple
  accent1 = "#ef4444",    # Red
  accent2 = "#10b981",    # Green
  accent3 = "#f59e0b"     # Warning Yellow
)

base_layout <- function(p, title, xtitle = "", ytitle = "") {
  p %>% layout(
    title = list(text = title, font = list(color = theme_colors$text, size=16)),
    plot_bgcolor = theme_colors$bg,
    paper_bgcolor = theme_colors$bg,
    font = list(color = theme_colors$text),
    xaxis = list(title = xtitle, gridcolor = theme_colors$grid, zerolinecolor = theme_colors$grid),
    yaxis = list(title = ytitle, gridcolor = theme_colors$grid, zerolinecolor = theme_colors$grid),
    margin = list(l=40, r=20, t=40, b=40)
  )
}

# --- Plotly Globe ---
plot_interactive_globe <- function(summary_data) {
  plot_geo(summary_data, lat = ~lat, lon = ~lng) %>%
    add_markers(
      text = ~paste(country, "<br>Avg AQI:", round(aqi), "<br>Congestion:", round(congestion_index),"%"),
      customdata = ~country,
      size = ~aqi, 
      color = ~aqi, 
      colors = c("#10b981", "#f59e0b", "#ef4444"), # Green, Yellow, Red progression
      marker = list(sizeref = 0.5, opacity = 0.9, line = list(color = '#ffffff', width = 1.5))
    ) %>%
    layout(
      geo = list(
        projection = list(type = 'orthographic'),
        showland = TRUE,
        landcolor = '#1e293b',   # Dark slate land
        showocean = TRUE,
        oceancolor = '#020617',  # Very dark slate ocean
        showcountries = TRUE,
        countrycolor = '#334155', # Slate border color
        bgcolor = 'rgba(0,0,0,0)' # Transparent so custom css gradient shows through
      ),
      paper_bgcolor = 'rgba(0,0,0,0)',
      plot_bgcolor = 'rgba(0,0,0,0)',
      margin = list(l=0, r=0, t=0, b=0)
    ) %>%
    config(displayModeBar = FALSE) %>%
    hide_colorbar()
}

# Interactive Dashboard Chart Generators
plot_country_trend <- function(data, indicator) {
  agg <- aggregate(as.formula(paste(indicator, "~ timestamp")), data, mean)
  plot_ly(agg, x = ~timestamp, y = as.formula(paste0("~", indicator)), type = 'scatter', mode = 'lines+markers',
          line=list(color=theme_colors$primary), marker=list(color=theme_colors$secondary)) %>%
    base_layout(paste("National Trend:", toupper(indicator)), "Time", toupper(indicator))
}

plot_country_dist <- function(data, indicator) {
  plot_ly(data, y = as.formula(paste0("~", indicator)), color = ~city, type = "box") %>%
    base_layout(paste("City Distribution:", toupper(indicator)), "", toupper(indicator))
}

plot_city_trend <- function(data, indicator) {
  agg <- aggregate(as.formula(paste(indicator, "~ timestamp")), data, mean)
  plot_ly(agg, x = ~timestamp, y = as.formula(paste0("~", indicator)), type = 'scatter', mode = 'lines',
          fill = 'tozeroy', fillcolor = 'rgba(14, 165, 233, 0.2)', line=list(color=theme_colors$primary)) %>%
    base_layout(paste("City Avg Trend:", toupper(indicator)), "Time", toupper(indicator))
}

plot_city_cor <- function(data, ind1, ind2) {
  plot_ly(data, x = as.formula(paste0("~", ind1)), y = as.formula(paste0("~", ind2)), 
          color = ~zone, type = "scatter", mode = "markers", marker = list(size=8, opacity=0.7)) %>%
    base_layout(paste("Correlation:", toupper(ind1), "vs", toupper(ind2)), toupper(ind1), toupper(ind2))
}

plot_ml_clusters <- function(data) {
  if(!"risk_category" %in% colnames(data)) return(plotly_empty())
  pal <- c("Low Risk"="#10b981", "Moderate Risk"="#f59e0b", "High/Hazardous Risk"="#ef4444", "Unknown"="#94a3b8")
  plot_ly(data, x = ~pm25, y = ~congestion_index, color=~risk_category, colors=pal,
          text = ~paste("Zone:", zone, "<br>AQI:", round(aqi)),
          type="scatter", mode="markers", marker=list(size=10, opacity=0.8, line=list(color="white", width=1))) %>%
    base_layout("K-Means Risk Clustering", "PM 2.5 Density", "Congestion Index")
}

# === MASSIVE COUNTRY CHART GENERATOR (10 Charts) ===
generate_country_charts <- function(data, num_charts = 10) {
  plots <- list()
  indicators <- c("aqi", "pm25", "no2", "co2", "congestion_index", "noise_db", "traffic_speed_kmh", "temperature", "humidity", "ozone")
  
  for(i in 1:num_charts) {
    ind <- indicators[((i - 1) %% length(indicators)) + 1]
    ind2 <- indicators[((i + 2) %% length(indicators)) + 1]
    chart_type <- i %% 10
    df <- data[sample(nrow(data), min(150, nrow(data))), ]
    
    p <- switch(as.character(chart_type),
      "1" = {
        # Time series scatter
        plot_ly(df, x = ~timestamp, y = as.formula(paste0("~", ind)), type = 'scatter', mode = 'lines+markers',
                line=list(color=theme_colors$primary), marker=list(color=theme_colors$secondary, size=4)) %>%
          base_layout(paste("National Trend:", toupper(ind)), "Time", toupper(ind))
      },
      "2" = {
        # Box plot by city
        plot_ly(data, y = as.formula(paste0("~", ind)), color = ~city, type = "box") %>%
          base_layout(paste("Distribution:", toupper(ind), "by City"), "", toupper(ind))
      },
      "3" = {
        # Bar chart average by city
        agg <- aggregate(as.formula(paste(ind, "~ city")), data, mean)
        plot_ly(agg, x = ~city, y = as.formula(paste0("~", ind)), type = "bar", marker=list(color=theme_colors$accent2)) %>%
          base_layout(paste("Avg", toupper(ind), "by City"), "City", toupper(ind))
      },
      "4" = {
        # Histogram
        plot_ly(df, x = as.formula(paste0("~", ind)), type = "histogram", nbinsx = 20, 
                marker=list(color=theme_colors$accent3, line=list(color="white", width=1))) %>%
          base_layout(paste("Frequency:", toupper(ind)), toupper(ind), "Count")
      },
      "5" = {
        # Scatter correlation
        plot_ly(df, x = as.formula(paste0("~", ind)), y = as.formula(paste0("~", ind2)),
                color = ~city, type = "scatter", mode = "markers", marker=list(size=7, opacity=0.7)) %>%
          base_layout(paste("Correlation:", toupper(ind), "vs", toupper(ind2)), toupper(ind), toupper(ind2))
      },
      "6" = {
        # Violin 
        plot_ly(data, y = as.formula(paste0("~", ind)), type = "violin", box = list(visible=T),
                meanline = list(visible=T), color = I(theme_colors$secondary)) %>%
          base_layout(paste("Violin:", toupper(ind)), "", toupper(ind))
      },
      "7" = {
        # Area fill time series
        agg <- aggregate(as.formula(paste(ind, "~ timestamp")), data, mean)
        plot_ly(agg, x = ~timestamp, y = as.formula(paste0("~", ind)), type='scatter', mode='lines',
                fill='tozeroy', fillcolor='rgba(139, 92, 246, 0.2)', line=list(color=theme_colors$secondary)) %>%
          base_layout(paste("Area Trend:", toupper(ind)), "Time", toupper(ind))
      },
      "8" = {
        # Heatmap-style: AQI vs Congestion binned 
        plot_ly(df, x = as.formula(paste0("~", ind)), y = as.formula(paste0("~", ind2)), type="histogram2d",
                colorscale="Viridis") %>%
          base_layout(paste("Heatmap:", toupper(ind), "vs", toupper(ind2)), toupper(ind), toupper(ind2))
      },
      "9" = {
        # Stacked bar by city
        agg1 <- aggregate(as.formula(paste(ind, "~ city")), data, mean)
        agg2 <- aggregate(as.formula(paste(ind2, "~ city")), data, mean)
        plot_ly(agg1, x = ~city, y = as.formula(paste0("~", ind)), type="bar", name=toupper(ind), marker=list(color=theme_colors$primary)) %>%
          add_trace(data=agg2, y = as.formula(paste0("~", ind2)), name=toupper(ind2), marker=list(color=theme_colors$accent1)) %>%
          layout(barmode="stack") %>%
          base_layout(paste("Stacked:", toupper(ind), "+", toupper(ind2)), "City", "Value")
      },
      "0" = {
        # Bubble chart
        plot_ly(df, x = as.formula(paste0("~", ind)), y = as.formula(paste0("~", ind2)),
                size = ~aqi, color = ~city, type="scatter", mode="markers",
                marker=list(opacity=0.6, sizeref=0.8, line=list(color="white", width=0.5))) %>%
          base_layout(paste("Bubble:", toupper(ind), "vs", toupper(ind2), "(size=AQI)"), toupper(ind), toupper(ind2))
      }
    )
    plots[[i]] <- p
  }
  return(plots)
}

# === MASSIVE CITY CHART GENERATOR (40 Charts) ===
generate_city_charts <- function(data, num_charts = 40) {
  plots <- list()
  indicators <- c("aqi", "pm25", "no2", "co2", "congestion_index", "noise_db", "traffic_speed_kmh", "temperature", "humidity")
  
  for(i in 1:num_charts) {
    ind1 <- indicators[((i - 1) %% length(indicators)) + 1]
    ind2 <- indicators[((i + 3) %% length(indicators)) + 1]
    chart_type <- i %% 8
    df <- data[sample(nrow(data), min(200, nrow(data))), ]
    
    p <- switch(as.character(chart_type),
      "1" = {
        # Area fill time series
        agg <- aggregate(as.formula(paste(ind1, "~ timestamp")), data, mean)
        plot_ly(agg, x = ~timestamp, y = as.formula(paste0("~", ind1)), type = 'scatter', mode = 'lines',
                fill = 'tozeroy', fillcolor = 'rgba(14, 165, 233, 0.2)', line=list(color=theme_colors$primary)) %>%
          base_layout(paste("Zone Trend:", toupper(ind1)), "Time", toupper(ind1))
      },
      "2" = {
        # Scatter correlation colored by zone
        plot_ly(df, x = as.formula(paste0("~", ind1)), y = as.formula(paste0("~", ind2)), 
                color = ~zone, type = "scatter", mode = "markers", marker = list(size=8, opacity=0.7)) %>%
          base_layout(paste("Correlation:", toupper(ind1), "vs", toupper(ind2)), toupper(ind1), toupper(ind2))
      },
      "3" = {
        # Bar chart average by zone
        agg <- aggregate(as.formula(paste(ind1, "~ zone")), data, mean)
        plot_ly(agg, x = ~zone, y = as.formula(paste0("~", ind1)), type = "bar", marker=list(color=theme_colors$secondary)) %>%
          base_layout(paste("Zone Breakdown:", toupper(ind1)), "Zone", toupper(ind1))
      },
      "4" = {
        # Violin
        plot_ly(df, y = as.formula(paste0("~", ind1)), type = "violin", box = list(visible=T), 
                meanline = list(visible=T), color = I(theme_colors$accent1)) %>%
          base_layout(paste("Violin:", toupper(ind1)), "", toupper(ind1))
      },
      "5" = {
        # Histogram
        plot_ly(df, x = as.formula(paste0("~", ind1)), type = "histogram", nbinsx = 20, 
                marker=list(color=theme_colors$primary, line=list(color="white", width=1))) %>%
          base_layout(paste("Density:", toupper(ind1)), toupper(ind1), "Count")
      },
      "6" = {
        # Box plot by zone
        plot_ly(data, y = as.formula(paste0("~", ind1)), color = ~zone, type = "box") %>%
          base_layout(paste("Zone Distribution:", toupper(ind1)), "", toupper(ind1))
      },
      "7" = {
        # 2D Histogram Heatmap
        plot_ly(df, x = as.formula(paste0("~", ind1)), y = as.formula(paste0("~", ind2)), type="histogram2d",
                colorscale="YlOrRd") %>%
          base_layout(paste("Heatmap:", toupper(ind1), "vs", toupper(ind2)), toupper(ind1), toupper(ind2))
      },
      "0" = {
        # Bubble chart
        plot_ly(df, x = as.formula(paste0("~", ind1)), y = as.formula(paste0("~", ind2)),
                size = ~aqi, color = ~zone, type="scatter", mode="markers",
                marker=list(opacity=0.6, sizeref=0.8, line=list(color="white", width=0.5))) %>%
          base_layout(paste("Bubble:", toupper(ind1), "vs", toupper(ind2)), toupper(ind1), toupper(ind2))
      }
    )
    plots[[i]] <- p
  }
  return(plots)
}
