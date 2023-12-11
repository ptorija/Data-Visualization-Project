
create_map <- function(year, data) {
  
  # Select the relevant columns for the map
  map_data <- data %>%
    filter(Features == "net generation") %>%
    select(-Features, -Region) %>%
    select(Country,!!paste0("X", year))
  

  world <- rnaturalearth::ne_countries(scale = "medium", returnclass = "sf")
  net_generation_world <- merge(world, map_data, by.x = "name", by.y = "Country", all.x = TRUE)
  
  # Plot the map
  ggplot(data = net_generation_world) +
    geom_sf(aes(fill = !!sym(paste0("X", year)))) +
    scale_fill_gradient(label = scales::comma, name = 'Net generation') +
    theme(
      plot.margin = margin(t=0, r=0, b=0, l=0),
      panel.border = element_rect(color = "black", fill = NA, size = 1))
      
}



create_steam_graph <- function(year, data) {
  
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
  
  # Create a stream graph with ggplot2 using scaled values
  ggplot(df_long, aes(x = Year, y = Value, fill = Region)) +
    geom_area(position = "stack") +
    labs(title = "Streamgraph Example", x = "Year", y = "Scaled Value") +
    theme_minimal()
}


create_bubble_chart <- function(data) {
  
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
  
}