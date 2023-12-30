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
      panel.background = element_rect(fill = "white")  # Set the background color to white
    )
}


create_steam_graph <- function(selected_regions, data) {
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
  
  # Filter only the selected regions
  df_long <- df_long %>%
    filter(Region %in% selected_regions)
  
  # Create a stream graph with ggplot2 using scaled values
  ggplot(df_long, aes(x = Year, y = Value, fill = Region)) +
    geom_area(position = "stack") +
    labs(x = "Year", y = "Scaled Value") +
    scale_fill_manual(values = scales::brewer_pal(palette = "Set3")(length(unique(generation_by_region$Region)))) +
    theme_minimal() +
    theme(
      axis.text.x = element_text(margin = margin(b = 10)),
      axis.text.y = element_text(margin = margin(l = 10))
    )
}

create_bubble_chart <- function(selected_regions, data, column_name) {
  column_name <- paste0("X", column_name)

  generation_by_region <- data %>%
    filter(Features == "net generation") %>%
    select(Country, Region, column_name)
  
  max_production_by_region <- generation_by_region %>%
    group_by(Region) %>%
    filter(across({{ column_name }}, ~ . == max(.))) %>%
    ungroup()

  consumption_by_country <- data %>%
    filter(Features == "net consumption") %>%
    filter(Country %in% max_production_by_region$Country) %>%
    select(!!sym(column_name))

  capacity_by_country <- data %>%
    filter(Features == "installed capacity ") %>%
    filter(Country %in% max_production_by_region$Country) %>%
    select(!!sym(column_name))

  new_df <- data.frame(
    Country = max_production_by_region$Country,
    Region = max_production_by_region$Region,
    Generation = max_production_by_region[[column_name]],
    Consumption = consumption_by_country[[column_name]],
    Capacity = capacity_by_country[[column_name]]
  )

  new_df <- new_df %>%
    filter(Region %in% selected_regions)
  
  # Create the bubble chart
  ggplot(new_df, aes(x = Generation, y = Consumption, size = Capacity)) +
    geom_point(aes(color = Region), alpha = 0.7) +
    scale_size_continuous(range = c(3, 15)) +  
    labs(x = "Generation", y = "Consumption", size = "Capacity") +
    theme_minimal() +
    theme(
      axis.text.x = element_text(margin = margin(b = 10)),
      axis.text.y = element_text(margin = margin(l = 10))
    )
}