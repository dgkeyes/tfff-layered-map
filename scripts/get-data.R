library(tigris)
library(tidyverse)
library(janitor)
library(rvest)
library(here)
library(ggmap)


# TK ----------------------------------------------------------------------



# register_google(key = "")

options(tigris_class = "sf")

oregon_counties <- counties(state = "Oregon",
                            cb = T) %>% 
     clean_names() %>% 
     select(name)


# oregon_towns <- read_csv(here::here("data", "oregon-towns.csv")) %>% 
#      # separate_rows(county, sep = ",") %>% 
#      filter(population < 25000) %>% 
#      filter(!str_detect(county, ",")) %>% 
#      sample_n(100) %>% 
#      mutate(location = str_glue("{name}, Oregon")) %>% 
#      mutate_geocode(location)


write_csv(oregon_towns, here("data", "oregon-towns-geo.csv"))

tfff_departments <- c("Children, Youth and Families",
                      "Postsecondary Success",
                      "Visual Arts",
                      "Ford Institute for Community Building")

grant_size <- sample(10000:100000, 100)

# Make data frames ---------------------------------------------------------

tfff_grants <- oregon_towns %>% 
     mutate(name = "Grant Name") %>% 
     sample_n(100) %>% 
     mutate(department = rep(tfff_departments, 25)) %>% 
     mutate(size = grant_size) 


write_csv(tfff_grants, here("data", "tfff-grants.csv"))



# Make shapefile for individual grants -----------------------------------------

tfff_grants <- read_csv(here::here("data", "tfff-grants.csv")) %>%
     st_as_sf(coords = c("lon", "lat"),
              crs = 4326)

st_write(tfff_grants, here("data", "tfff_grants.shp"))

# Make shapefile for counties -----------------------------------------

options(tigris_class = "sf")

oregon_counties <- counties(state = "Oregon",
                            cb = T) %>% 
     clean_names() %>% 
     select(name) %>% 
     rename("county" = "name")

tfff_grants_by_county <- read_csv(here::here("data", "tfff-grants.csv")) %>%
     group_by(county) %>% 
     summarize(total = sum(size)) 

tfff_grants_by_county_sf <- merge(oregon_counties, tfff_grants_by_county) %>% 
     mutate(county = str_glue("{county} County"))

st_write(tfff_grants_by_county_sf, here("data", "tfff_grants_by_county.shp"))
