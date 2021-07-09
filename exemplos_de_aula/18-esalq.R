library(magrittr)

u0 <- "https://www.cepea.esalq.usp.br/br/indicador/listar_especificacao.aspx"

body <- list(produto = "3,4,35,36,37,38,43,44,45,46,47,48,49,50")

r0 <- httr::POST(u0, body = body)

# scrapr::html_view(r0)

query <- list(
  "tabela_id" = "53",
  "data_inicial" = "01/07/2021",
  "periodicidade" = "1",
  "data_final" = "08/07/2021"
)

r1 <- httr::GET(
  "https://www.cepea.esalq.usp.br/br/consultas-ao-banco-de-dados-do-site.aspx",
  query = query
)

link <- r1 %>%
  xml2::read_html() %>%
  xml2::xml_text() %>%
  jsonlite::fromJSON() %>%
  purrr::pluck("arquivo")

httr::GET(link, httr::write_disk(paste0("output/", basename(link)), TRUE))
