# 1. Crie um scraper completo para o DEJT. Sua função deve receber um vetor de
# datas (strings na forma DD/MM/AAAA) e o caminho para um diretório (que pode
# ou não existir). Ela deve baixar os PDFs dos dias indicados em paralelo e
# retornar um vetor com os caminhos para todos os PDFs efetivamente baixados.
# Por fim, ela deve garantir uma execução segura e robusta: erro legível caso
# receba uma data inválida e warnings para todos os PDFs que não forem
# encontrados (p.e. se a data for final de semana), tudo isso sem quebrar caso
# haja alguma instabilidade no serviço do DEJT.

library(magrittr)
library(httr)
library(xml2)

scrape_dejt <- function(datas, dir) {
  fs::dir_create(dir)

  # Testar datas
  purrr::walk(datas, ~{
    data <- purrr::quietly(lubridate::dmy)(.x)[[1]]
    if (is.na(data)) stop("Data inválida")
  })

  purrr::map_chr(datas, scrape_dejt_, dir = dir)
}

scrape_dejt_ <- function(data, dir) {

  url <- "https://dejt.jt.jus.br/dejt/f/n/diariocon"

  viewstate <- url %>%
    GET(config(ssl_verifypeer = FALSE)) %>%
    content() %>%
    xml_find_first('//input[@name="javax.faces.ViewState"]') %>%
    xml_attr("value")

  body <- list(
    "corpo:formulario:dataIni" = data,
    "corpo:formulario:dataFim" = data,
    "corpo:formulario:tipoCaderno" = "",
    "corpo:formulario:tribunal" = "",
    "corpo:formulario:ordenacaoPlc" = "",
    "navDe" = "",
    "detCorrPlc" = "",
    "tabCorrPlc" = "",
    "detCorrPlcPaginado" = "",
    "exibeEdDocPlc" = "",
    "indExcDetPlc" = "",
    "org.apache.myfaces.trinidad.faces.FORM" = "corpo:formulario",
    "_noJavaScript" = "false",
    "javax.faces.ViewState" = viewstate,
    "source" = "corpo:formulario:botaoAcaoPesquisar"
  )

  resp <- POST(
    url, body = body, encode = "form",
    config(ssl_verifypeer = FALSE)
  )

  jid <- resp %>%
    read_html() %>%
    xml_find_all("//button") %>%
    xml_attr("onclick") %>%
    stringr::str_extract("(?<=plcLogicaItens:0:)j_id[0-9]+") %>%
    magrittr::extract(!is.na(.))

  # Caso o dia não tenha um diário, retornar vazio
  if (length(jid) == 0) {
    warning("Dia sem diário")
    return("")
  }

  body2 <- list(
    "corpo:formulario:dataIni" = data,
    "corpo:formulario:dataFim" = data,
    "corpo:formulario:tipoCaderno" = "",
    "corpo:formulario:tribunal" = "",
    "corpo:formulario:ordenacaoPlc" = "",
    "navDe" = "",
    "detCorrPlc" = "",
    "tabCorrPlc" = "",
    "detCorrPlcPaginado" = "",
    "exibeEdDocPlc" = "",
    "indExcDetPlc" = "",
    "org.apache.myfaces.trinidad.faces.FORM" = "corpo:formulario",
    "_noJavaScript" = "false",
    "javax.faces.ViewState" = viewstate,
    "source" = paste0("corpo:formulario:plcLogicaItens:", 0, ":", jid)
  )

  # Criar um nome inteligente para o arquivo
  file <- fs::path(dir, stringr::str_replace_all(data, "/", "-"), ext = "pdf")

  POST(
    url, body = body2,
    write_disk(file, TRUE),
    config(ssl_verifypeer = FALSE)
  )

  return(file)
}

datas <- c("17/04/2020", "19/04/2020", "-123")
scrape_dejt(datas, "~/Downloads/dejt/")

datas <- c("17/04/2020", "19/04/2020")
scrape_dejt(datas, "~/Downloads/dejt/")
