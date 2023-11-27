install.packages("dplyr")
install.packages("ggrepel")
install.packages("ggplot2")
install.packages("tidyr")

library(tidyr)
library(dplyr)
library(ggrepel)
library(ggplot2)
library(scales)

# Load Data
data <- read.csv("data/Global Electricity Statistics.csv", header = TRUE)

# Group by region and get mean generation
generation_by_region <- data %>%
  filter(Features == "net generation") %>%
  select(Country, Region, X2000)
  
print(generation_by_region)

max_production_by_region <- generation_by_region %>%
  group_by(Region) %>%
  filter(X2000 == max(X2000)) %>%
  ungroup()

# Display the result
print(max_production_by_region)

print(max_production_by_region$Country)

consumption_by_country <- data %>%
  filter(Features == "net consumption") %>%
  filter(Country %in% max_production_by_region$Country)%>%
  select(X2000)

capacity_by_country <- data %>%
  filter(Features == "installed capacity ") %>%
  filter(Country %in% max_production_by_region$Country)%>%
  select(X2000)

capacity_by_country

new_df = data.frame(
  Country = max_production_by_region$Country,
  Region = max_production_by_region$Region,
  Generation = max_production_by_region$X2000,
  Consumption = consumption_by_country$X2000,
  Capacity = capacity_by_country$X2000
)

new_df

# Create the bubble chart
ggplot(new_df, aes(x = Generation, y = Consumption, size = Capacity)) +
  geom_point(aes(color = Region), alpha = 0.7) +
  scale_size_continuous(range = c(3, 15)) +  # Adjust the range based on your preference
  labs(title = "Bubble Chart Example", x = "Generation", y = "Consumption", size = "Capacity") +
  theme_minimal()



