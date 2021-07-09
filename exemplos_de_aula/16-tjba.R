
tjba_cpopg_download <- function(id, path) {

  ts <- stringr::str_replace_all(lubridate::now("Brazil/East"), "[^0-9]", "")

  f_captcha <- fs::file_temp(ext = ".png")

  # primeiro: acessar a página inicial

  u_search <- "http://esaj.tjba.jus.br/cpopg/search.do"
  r0 <- httr::GET(u_search)

  # segundo: baixar o captcha e resolvê-lo
  httr::GET(
    "http://esaj.tjba.jus.br/cpopg/imagemCaptcha.do",
    query = list(timestamp = ts),
    httr::write_disk(f_captcha)
  )

  ## visualizar
  # img <- decryptr::read_captcha(f_captcha)
  # plot(img[[1]])

  # resolvendo o captcha
  modelo <- decryptr::load_model("esaj")
  label <- decryptr::decrypt(f_captcha, modelo)

  # terceiro: incluindo o captcha nos parâmetros da sua busca
  query <- list(
    "dadosConsulta.localPesquisa.cdLocal" = "-1",
    "cbPesquisa" = "NUMPROC",
    "dadosConsulta.tipoNuProcesso" = "UNIFICADO",
    "numeroDigitoAnoUnificado" = stringr::str_sub(id, 1, 13),
    "foroNumeroUnificado" = stringr::str_sub(id, -4, -1),
    "dadosConsulta.valorConsultaNuUnificado" = id,
    "dadosConsulta.valorConsulta" = "",
    "vlCaptcha" = label
  )

  resultado <- httr::GET(
    u_search,
    query = query,
    httr::write_disk(paste0(path, "/resultado_tjba.html"))
  )

}

id <- "05042786720178050004"
