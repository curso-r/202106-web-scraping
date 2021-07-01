# 1. A partir do exemplo mostrado em aula, encontre uma forma de separar os
# links para as vagas ("apply") dos links para a home do site ("learn") sem usar
# o {stringr}. Só vale usar o XPath!

library(httr)
library(xml2)
library(dplyr)
library(purrr)
library(magrittr)

links <- "https://realpython.github.io/fake-jobs/" %>%
  read_html() %>%
  xml_find_all("//footer[@class='card-footer']/a[2]") %>%
  xml_attr("href")

# 2. A partir do exemplo mostrado em aula, transforme todo o conteúdo da função
# parse_job() em uma única pipeline (exceto pelo objeto `xpaths`).

parse_job <- function(link) {

  xpaths <- c(
    ".//h1", ".//h2", ".//p", ".//p[@id='location']", ".//p[@id='date']"
  )

  info <- link %>%
    read_html() %>%
    xml_find_first("//div[@id='ResultsContainer']") %>%
    map(xpaths, function(xpath, x) xml_find_first(x, xpath), x = .) %>%
    map(xml_text) %>%
    set_names("posicao", "empresa", "descricao", "local", "data") %>%
    as_tibble()
}

# 3. A partir do exemplo mostrado em aula, com a própria função map_dfr(),
# encontre uma maneira simples de criar uma coluna com o link para vaga no
# data frame final.

links %>%
  set_names() %>%
  map_dfr(parse_job, .id = "link") %>%
  mutate(
    local = stringr::str_remove(local, ".+: "),
    data = stringr::str_remove(data, ".+: "),
    data = lubridate::as_date(data)
  )
