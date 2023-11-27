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
  select(-Country, -Features) %>%
  group_by(Region) %>%
  summarise(across(everything(), mean, na.rm = TRUE))

# Display the result
print(generation_by_region)

df_long <- generation_by_region %>%
  pivot_longer(cols = starts_with("X"), names_to = "Year", values_to = "Value") %>%
  mutate(Year = as.numeric(gsub("X", "", Year)))

regions_to_exclude <- c("North America")
df_long <- df_long %>%
  filter(!Region %in% regions_to_exclude)

# Create a streamgraph with ggplot2 using scaled values
ggplot(df_long, aes(x = Year, y = Value, fill = Region)) +
  geom_area(position = "stack") +
  labs(title = "Streamgraph Example", x = "Year", y = "Scaled Value") +
  theme_minimal()

