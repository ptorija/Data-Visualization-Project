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

ui <- navbarPage(
  "Global Electricity Statistics",
  tabPanel(
    "About",
    fluidPage(
      div(
        class = "main-title",
        "About Global Electricity Statistics",
        style = "text-align: center; font-size: 30px; font-weight: bold; margin-top: 50px; color: #2674D8;"
      ),
      div(
        class = "about-content",
        "This Shiny app presents visualizations of global electricity statistics from 1980 to 2021. Explore the evolution of electricity generation across regions, analyze the annual electricity consumption heatmap, and examine the relationships between generation, consumption, and capacity with the bubble chart.",
        style = "font-size: 18px; margin-top: 30px; margin-bottom: 30px;"
      ),
      div(
        class = "about-content",
        "Developed using the Shiny package for R, this app provides an interactive interface for users to gain insights into key aspects of global electricity trends. Navigate through the tabs to access different visualizations and discover patterns in the data.",
        style = "font-size: 18px; margin-bottom: 50px;"
      )
    )
  ),
  tabPanel(
    "Steam Graph",
    titlePanel(h3("Evolution of Electricity Generation Across Regions", style = "color: #2674D8; text-align: center; font-weight: bold;")),
    splitLayout(
      cellWidths = c("25%", "75%"),
      checkboxGroupInput("steamRegionsSelector", "Select regions to display:",
                         choices = c("Africa", "Asia & Oceania", "Europe", "Central & South America","North America", "Middle East"),
                         selected = c("Africa", "Asia & Oceania", "Europe", "Central & South America","North America", "Middle East")),
      plotOutput("steam", width = "75%"),
      style = "margin-left: 50px;"
    )
  ),
  tabPanel(
    "World Map",
    titlePanel(h3("Annual Electricity Consumption Heatmap", style = "color: #2674D8; text-align: center; font-weight: bold;")),
    splitLayout(
      cellWidths = c("25%", "75%"),
      selectInput("mapYearSelector", "Select a Year:", seq(1980, 2021), selected = 2021),
      plotOutput("map", width = "75%"),
      style = "margin-left: 50px;"
    )
  ),
  tabPanel(
    "Bubble Chart",
    titlePanel(h3("Generation, Consumption, and Capacity by Region", style = "color: #2674D8; text-align: center; font-weight: bold;")),
    splitLayout(
      cellWidths = c("25%", "75%"),
      div(
        selectInput("bubbleYearSelector", "Select a Year:", seq(1980, 2021), selected = 2021),
        checkboxGroupInput("bubbleRegionsSelector", "Select regions to display:",
                           choices = c("Africa", "Asia & Oceania", "Europe", "Central & South America","North America", "Middle East"),
                           selected = c("Africa", "Asia & Oceania", "Europe", "Central & South America","North America", "Middle East"))
      ),
      plotOutput("bubble", width = "75%"),
      style = "margin-left: 50px;"
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
