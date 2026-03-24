country_map_ui <- function(id) {
  ns <- NS(id)
  tagList(
    h3("Select an Urban Zone on the Map", style = "color: #00c3ff; font-weight: 700;"),
    p("Clicking a marker will filter the dashboard to that specific congestion zone.", style = "color: #94a3b8;"),
    div(
      style = "border: 2px solid #1e293b; border-radius: 12px; overflow: hidden; height: 600px;",
      leaflet::leafletOutput(ns("main_map"), height = "100%")
    )
  )
}
