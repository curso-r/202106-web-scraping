library(magrittr)

# acesso ------------------------------------------------------------------

# baixar a pagina
u_cdg <- "http://www.chancedegol.com.br/br19.htm"
r_cdg <- httr::GET(u_cdg)

# imprimiu NA!! Provavelmente problema de encoding

# vou salvar em um arquivo para testar
r_cdg <- httr::GET(u_cdg, httr::write_disk("output/cdg.html"))

# testando o arquivo
readr::read_file("output/cdg.html") %>%
  stringi::stri_enc_detect()

# testando o arquivo (alternativa)
readr::guess_encoding("output/cdg.html")

## Dá para checar direto do site!!
readr::guess_encoding(u_cdg)



# parse -------------------------------------------------------------------

# acessando a tabela ------------------------------------------------------

# jeito loooongo
httr::content(r_cdg, encoding = "latin1") %>%
  xml2::xml_find_first("/html/body/div/font/table")

# jeito mais sintético
httr::content(r_cdg, encoding = "ISO-8859-1") %>%
  xml2::xml_find_first("//table")

# transformando a tabela em data.frame
httr::content(r_cdg, encoding = "latin1") %>%
  xml2::xml_find_first("//table") %>%
  rvest::html_table(header = TRUE) %>%
  janitor::clean_names()

httr::content(r_cdg, encoding = "latin1") %>%
  xml2::xml_find_first("//table")

lista <- httr::content(r_cdg, encoding = "latin1") %>%
  xml2::xml_find_all("//table")

lista[[1]]

# vamos deixar a tabela bonitinha
tabela_final <- httr::content(r_cdg, encoding = "latin1") %>%
  xml2::xml_find_first("//table") %>%
  rvest::html_table(header = TRUE) %>%
  janitor::clean_names() %>%
  dplyr::mutate(
    data = lubridate::dmy(data),
    dplyr::across(
      vitoria_do_mandante:vitoria_do_visitante,
      readr::parse_number
    )
  ) %>%
  tidyr::separate(x, c("gols_mandante", "gols_visitante"), sep = "x")


# iteração (spoiler) ------------------------------------------------------

paginas <- 10:19
links <- stringr::str_glue("http://www.chancedegol.com.br/br{paginas}.htm")

caminho <- "output/cdg"

download_cdg <- function(ano, caminho) {
  u_cdg <- stringr::str_glue("http://www.chancedegol.com.br/br{ano}.htm")
  arquivo <- paste0(caminho, "/", ano, ".html")
  r_cdg <- httr::GET(u_cdg, httr::write_disk(arquivo))
}

purrr::walk(paginas, download_cdg, caminho = caminho)

arquivos_baixados <- fs::dir_ls(caminho)

parse_cdg <- function(arquivo) {

  html <- xml2::read_html(arquivo, encoding = "latin1")

  txt <- html %>%
    xml2::xml_find_all("//font[@color='#FF0000']") %>%
    xml2::xml_text()

  html %>%
    xml2::xml_find_first("//table") %>%
    rvest::html_table(header = TRUE) %>%
    janitor::clean_names() %>%
    dplyr::mutate(
      data = lubridate::dmy(data),
      vermelho = txt,
      dplyr::across(
        vitoria_do_mandante:vermelho,
        readr::parse_number
      )
    ) %>%
    tidyr::separate(x, c("gols_mandante", "gols_visitante"), sep = "x") %>%
    tibble::view()
}

dados_cdg <- purrr::map_dfr(arquivos_baixados, parse_cdg, .id = "arquivo")

purrr::map(arquivos_baixados, parse_cdg) %>%
  dplyr::bind_rows(.id = "arquivo")
