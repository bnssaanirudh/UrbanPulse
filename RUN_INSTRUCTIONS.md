# UrbanPulse: Execution Instructions

Follow these steps to launch the **UrbanPulse Global Nexus** application on your local machine using the R Console.

## Step 1: Set the Working Directory
Open your R Console or RStudio and run the following command to point R to your project folder:

```r
setwd("c:/Users/aniru/Downloads/rproj")
```

## Step 2: Install Dependencies (If not already installed)
If this is your first time running the project, ensure all required libraries are installed by running:

```r
install.packages(c("shiny", "shinydashboard", "plotly", "leaflet", "jsonlite", "stats"))
```

## Step 3: Run the Application
You can now launch the dashboard by running:

```r
library(shiny)
runApp()
```

---

### Alternative: One-Click Launch
If you prefer to run the app in a single command without changing your working directory, use:

```r
shiny::runApp("c:/Users/aniru/Downloads/rproj")
```

### What to Expect:
1.  The console will display `Listening on http://127.0.0.1:XXXX`.
2.  Your default web browser will open a new tab.
3.  The **3D Global Landing Page** will initialize and begin auto-rotating.
4.  You can then click on any country to drill down into the National and City-level visualizations.

---
**Version:** 2.0  
**Backend:** R Shiny  
**Visuals:** Plotly & Leaflet
