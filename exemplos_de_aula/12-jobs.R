library(httr)
library(xml2)
library(dplyr)
library(purrr)
library(magrittr)

# Encontrar os links para a descrição das posições

links <- "https://realpython.github.io/fake-jobs/" %>%
  read_html() %>%
  xml_find_all("//footer[@class='card-footer']/a") %>%
  xml_attr("href") %>%
  stringr::str_subset("github")

# Acessar um link e obter as informações

parse_job <- function(link) {

  info <- link %>%
    read_html() %>%
    xml_find_first("//div[@id='ResultsContainer']")

  xpaths <- c(
    ".//h1", ".//h2", ".//p", ".//p[@id='location']", ".//p[@id='date']"
  )

  xpaths %>%
    map(~xml_find_first(info, .x)) %>%
    map(xml_text) %>%
    set_names("posicao", "empresa", "descricao", "local", "data") %>%
    as_tibble()
}

# Iterar nos links

df <- links %>%
  map_dfr(possibly(parse_job, tibble())) %>%
  mutate(
    local = stringr::str_remove(local, ".+: "),
    data = stringr::str_remove(data, ".+: "),
    data = lubridate::as_date(data)
  )
