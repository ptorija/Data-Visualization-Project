# Install and load required packages
install.packages(c("leaflet", "dplyr"))
install.packages("rnaturalearth")
library(leaflet)
library(ggplot2)
library(scales)
library(rnaturalearth)
install.packages("rnaturalearthdata")

electricity_data <- read.csv("C:/Users/34685/OneDrive/Documentos/DataVisualizationProject/data/Global Electricity Statistics.csv")

# Choose a specific year (e.g., 2021)
year <- 2021

# Select the relevant columns for the map
map_data <- electricity_data %>%
  filter(Features == "net generation") %>%
  select(-Features, -Region) %>%
  select(Country,X2021)


world <- rnaturalearth::ne_countries(scale = "medium", returnclass = "sf")
net_generation_world <- merge(world, map_data, by.x = "name", by.y = "Country", all.x = TRUE)

# Plot the map
ggplot(data = net_generation_world) +
  geom_sf(aes(fill = X2021)) +
  scale_fill_gradient(label = scales::comma) +
  theme_void()
