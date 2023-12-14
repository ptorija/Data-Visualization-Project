# Install and load required packages
if (!requireNamespace("shiny", quietly = TRUE)) {
  install.packages("shiny")
}
if (!requireNamespace("leaflet", quietly = TRUE)) {
  install.packages("leaflet")
}
if (!requireNamespace("dplyr", quietly = TRUE)) {
  install.packages("dplyr")
}
if (!requireNamespace("ggplot2", quietly = TRUE)) {
  install.packages("ggplot2")
}
if (!requireNamespace("scales", quietly = TRUE)) {
  install.packages("scales")
}
if (!requireNamespace("rnaturalearth", quietly = TRUE)) {
  install.packages("rnaturalearth")
}
if (!requireNamespace("rnaturalearthdata", quietly = TRUE)) {
  install.packages("rnaturalearthdata")
}
if (!requireNamespace("ggrepel", quietly = TRUE)) {
  install.packages("ggrepel")
}
if (!requireNamespace("tidyr", quietly = TRUE)) {
  install.packages("tidyr")
}

library(shiny)
library(leaflet)
library(dplyr)
library(ggplot2)
library(scales)
library(rnaturalearth)
library(rnaturalearthdata)
library(ggrepel)
library(tidyr)

source("scripts/charts_functions.R")

# Load Data
data <- read.csv("data/Global Electricity Statistics.csv", header = TRUE)

ui <- fluidPage(
  tags$head(
    tags$style(HTML("
      .main-title {
        text-align: center;
        font-size: 34px;
        font-weight: bold;
        margin-bottom: 50px;
      }
      .panels-group {
        display: flex;
        justify-content: center;
      }
      "))
  ),
  div(class = "main-title", "Global Electricity Statistics"),
  div(class = "panels-group",
      sidebarPanel(
        checkboxGroupInput("steamRegionsSelector", "Select regions to display:",
                           choices = c("Africa", "Asia & Oceania", "Europe", "Central & South America","North America", "Middle East"),
                           selected = c("Africa", "Asia & Oceania", "Europe", "Central & South America","North America", "Middle East")),
        width = 3
      ),
      mainPanel(
        plotOutput("steam", width = "100%"),
      )
  ),
  div(class = "panels-group",
      sidebarPanel(
        selectInput("mapYearSelector", "Select a Year:", seq(1980, 2021), selected = 2021),
        width = 2,
        
      ),
      mainPanel(
        plotOutput("map", width = "100%"),
      )
  ),
  div(class = "panels-group",
      sidebarPanel(
        selectInput("bubbleYearSelector", "Select a Year:", seq(1980, 2021), selected = 2021),
        checkboxGroupInput("bubbleRegionsSelector", "Select regions to display:",
                           choices = c("Africa", "Asia & Oceania", "Europe", "Central & South America","North America", "Middle East"),
                           selected = c("Africa", "Asia & Oceania", "Europe", "Central & South America","North America", "Middle East")),
        width = 3,
      ),
      mainPanel(
        plotOutput("bubble", width = "100%"),
      )
  )
)

# Define server
server <- function(input, output) {
  
  # Call the function to render the steam graph
  output$steam <- renderPlot({
    create_steam_graph(input$steamRegionsSelector, data)
  })
  
  # Call the function to render the map
  output$map <- renderPlot({
    create_map(input$mapYearSelector, data)
  })
  
  # Call the function to render the bubble graph
  output$bubble <- renderPlot({
  create_bubble_chart(input$bubbleRegionsSelector, data, input$bubbleYearSelector)
  })
}

# Run the Shiny app
shinyApp(ui = ui, server = server)
