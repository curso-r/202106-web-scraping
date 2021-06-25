library(tidyverse)
library(httr)

u_sptrans <- "http://api.olhovivo.sptrans.com.br/v2.1"
endpoint <- "/Posicao"
u_sptrans_busca <- paste0(u_sptrans, endpoint)

r_sptrans <- httr::GET(u_sptrans_busca)
r_sptrans

httr::content(r_sptrans)

# caso voce nao queira/nao tenha conseguido fazer uma conta
api_key <- Sys.getenv("API_OLHO_VIVO")

# usethis::edit_r_environ("project")

u_sptrans_login <- paste0(u_sptrans, "/Login/Autenticar")
q_sptrans_login <- list(token = api_key)
r_sptrans_login <- httr::POST(u_sptrans_login, query = q_sptrans_login)

r_sptrans_login
httr::content(r_sptrans_login)

# agora sim, estamos autenticados :)
r_sptrans <- httr::GET(u_sptrans_busca)

lista <- httr::content(r_sptrans, simplifyDataFrame = TRUE)

tabela <- lista$l %>%
  tibble::as_tibble() %>%
  tidyr::unnest(vs) %>%
  filter(str_detect(c, "175P"))

library(leaflet)

tabela %>%
  leaflet() %>%
  addTiles() %>%
  addMarkers(
    lng = ~px,
    lat = ~py,
    clusterOptions = markerClusterOptions()
  )
