library(magrittr)


dia <- "2021-07-17"
url_base <- "https://mananciais.sabesp.com.br/api/"

endpoint <- "Mananciais/ResumoSistemas/"

u <- paste0(url_base, endpoint, dia)

httr::GET(
  "https://mananciais.sabesp.com.br/api/Mananciais/ResumoSistemas/2021-07-17",
  httr::config(ssl_verifypeer = FALSE)
)

## não funciona :(
# r <- httr::GET(u)

## Agora funciona :sunglasses:

(r <- httr::GET(u, httr::config(ssl_verifypeer = FALSE)))

dados <- r %>%
  httr::content(simplifyDataFrame = TRUE) %>%
  purrr::pluck("ReturnObj", "sistemas") %>%
  tibble::as_tibble() %>%
  janitor::clean_names()


x <- r %>%
  httr::content(simplifyDataFrame = TRUE)

x$ReturnObj$sistemas
# equivale a
x %>% purrr::pluck("ReturnObj", "sistemas")

# como faço para montar uma base com isso?

dias <- Sys.Date() - 1:10

names(dias) <- dias

baixa_e_processa_sabesp <- function(dia) {
  url_base <- "https://mananciais.sabesp.com.br/api/"
  endpoint <- "Mananciais/ResumoSistemas/"
  u <- paste0(url_base, endpoint, dia)
  r <- httr::GET(u, httr::config(ssl_verifypeer = FALSE))

  dados <- r %>%
    httr::content(simplifyDataFrame = TRUE) %>%
    purrr::pluck("ReturnObj", "sistemas") %>%
    tibble::as_tibble() %>%
    janitor::clean_names()
  dados
}

da_sabesp <- purrr::map_dfr(
  dias,
  baixa_e_processa_sabesp,
  .id = "data"
)

# agora vamos fazer separadamente

baixar_sabesp <- function(dia, path) {
  url_base <- "https://mananciais.sabesp.com.br/api/"
  endpoint <- "Mananciais/ResumoSistemas/"
  u <- paste0(url_base, endpoint, dia)
  r <- httr::GET(
    u,
    httr::config(ssl_verifypeer = FALSE),
    httr::write_disk(paste0(path, dia, ".json"))
  )
}

processar_sabesp <- function(arquivo) {
  dados <- arquivo %>%
    jsonlite::read_json(simplifyDataFrame = TRUE) %>%
    purrr::pluck("ReturnObj", "sistemas") %>%
    tibble::as_tibble() %>%
    janitor::clean_names()
  dados
}

path <- "output/sabesp/"
fs::dir_create(path)

# passo 1: baixar

purrr::map(dias, baixar_sabesp, path)

# passo 2: processar

da_sabesp <- fs::dir_ls(path) %>%
  purrr::map_dfr(processar_sabesp, .id = "data")

