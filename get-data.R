library(tigris)
library(tidyverse)
library(janitor)
library(rvest)
library(here)
library(ggmap)

register_google(key = "AIzaSyBonrLhrEfIT08lG62TA-KOYoaoghonw4Y")

options(tigris_class = "sf")

oregon_counties <- counties(state = "Oregon",
                            cb = T) %>% 
     clean_names() %>% 
     select(name)


# oregon_towns <- places(state = "Oregon",
#                        cb = T) %>% 
#      clean_names() %>% 
#      mutate(lon = as.numeric(intptlon)) %>% 
#      mutate(lat = as.numeric(intptlat)) %>% 
#      select(name, lon, lat)

oregon_towns <- read_csv(here::here("data", "oregon-towns.csv")) %>% 
     # separate_rows(county, sep = ",") %>% 
     filter(population < 25000) %>% 
     filter(!str_detect(county, ",")) %>% 
     sample_n(100) %>% 
     mutate(location = str_glue("{name}, Oregon")) %>% 
     mutate_geocode(location)


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


# tmap --------------------------------------------------------------------

tmap_mode("view")

tm_shape(oregon_counties) +
     tm_polygons(popup.vars = "namelsad") 
+
tm_shape(tfff_grants) +
     tm_dots(col = "department",
             filter = "department",
             size = "size",
             alpha = 0.5,
             popup.vars = "size")

