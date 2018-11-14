library(here)
library(rmarkdown)



# Render presentation -----------------------------------------------------

render(input = here("layered-map.Rmd"), 
       output_file = "index.html",
       clean = T)