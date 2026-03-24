# UrbanPulse Analytics, ML, DL & LLM Mocks
library(stats)
if (!requireNamespace("randomForest", quietly = TRUE)) install.packages("randomForest", repos = "http://cran.us.r-project.org")
library(randomForest)

# 1. Machine Learning: Congestion Impact Quantification (Random Forest)
run_impact_model <- function(data) {
  # We use Random Forest to predict AQI and extract feature importance
  features <- c("congestion_index", "pm25", "no2", "co2", "noise_db", "temperature", "humidity")
  valid_data <- data[complete.cases(data[, c("aqi", features)]), ]
  
  if (nrow(valid_data) < 10) return(NULL)
  
  # Cap ntree for dashboard performance
  rf_model <- randomForest(aqi ~ ., data = valid_data[, c("aqi", features)], 
                           ntree = 50, importance = TRUE)
  return(rf_model)
}

# 2. Risk Cluster / Anomaly Detection (K-Means)
run_kmeans_clustering <- function(data) {
  features <- c("pm25", "no2", "co2", "congestion_index")
  valid_data <- data[complete.cases(data[, features]), ]
  
  if(nrow(valid_data) < 3) return(data)
  
  scaled_f <- scale(valid_data[, features])
  set.seed(42)
  km <- kmeans(scaled_f, centers = 3)
  
  valid_data$cluster <- km$cluster
  cluster_aqi <- aggregate(aqi ~ cluster, valid_data, mean)
  ordered_clusters <- cluster_aqi[order(cluster_aqi$aqi), "cluster"]
  
  risk_map <- c("Low Risk", "Moderate Risk", "High/Hazardous Risk")
  names(risk_map) <- ordered_clusters
  
  valid_data$risk_category <- risk_map[as.character(valid_data$cluster)]
  
  # Merge back
  res <- merge(data, valid_data[, c("zone", "risk_category")], by="zone", all.x=TRUE)
  res$risk_category[is.na(res$risk_category)] <- "Unknown"
  return(res)
}

# 3. Deep Learning Mock: Spatio-Temporal Predictions
run_dl_forecast <- function(data) {
  current_congestion <- mean(data$congestion_index, na.rm=TRUE)
  forecast_hours <- 1:6
  predicted_aqi <- current_congestion * 1.5 - (forecast_hours * runif(6, 2, 5))
  predicted_aqi <- pmax(predicted_aqi, 20)
  
  df <- data.frame(
    Hour_From_Now = forecast_hours,
    Predicted_AQI = round(predicted_aqi)
  )
  return(df)
}

# 4. LLM Insights Generation
generate_llm_insights <- function(data) {
  max_zone <- data[which.max(data$aqi), "zone"]
  avg_congestion <- round(mean(data$congestion_index, na.rm=TRUE))
  
  prompt_output <- paste0(
    "UrbanPulse AI Insight 🧠: Currently, the urban area is experiencing an average congestion index of ", avg_congestion, "%. ",
    "The zone with the most critical air quality is '", max_zone, "'. ",
    "Actionable Recommendation: For cyclists and pedestrians, we advise avoiding '", max_zone, "' over the next 2 hours. ",
    "Traffic routing algorithms should divert heavy vehicles away from this core to reduce NO2 saturation."
  )
  return(prompt_output)
}
