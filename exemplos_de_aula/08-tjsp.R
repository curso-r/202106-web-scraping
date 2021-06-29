busca <- "vacina"

# body completa
body <- list(
  "conversationId" = "",
  "dados.buscaInteiroTeor" = busca,
  "dados.pesquisarComSinonimos" = "S",
  "dados.pesquisarComSinonimos" = "S",
  "dados.buscaEmenta" = "",
  "dados.nuProcOrigem" = "",
  "dados.nuRegistro" = "",
  "agenteSelectedEntitiesList" = "",
  "contadoragente" = "0",
  "contadorMaioragente" = "0",
  "codigoCr" = "",
  "codigoTr" = "",
  "nmAgente" = "",
  "juizProlatorSelectedEntitiesList" = "",
  "contadorjuizProlator" = "0",
  "contadorMaiorjuizProlator" = "0",
  "codigoJuizCr" = "",
  "codigoJuizTr" = "",
  "nmJuiz" = "",
  "classesTreeSelection.values" = "",
  "classesTreeSelection.text" = "",
  "assuntosTreeSelection.values" = "",
  "assuntosTreeSelection.text" = "",
  "comarcaSelectedEntitiesList" = "",
  "contadorcomarca" = "0",
  "contadorMaiorcomarca" = "0",
  "cdComarca" = "",
  "nmComarca" = "",
  "secoesTreeSelection.values" = "",
  "secoesTreeSelection.text" = "",
  "dados.dtJulgamentoInicio" = "",
  "dados.dtJulgamentoFim" = "",
  "dados.dtPublicacaoInicio" = "",
  "dados.dtPublicacaoFim" = "",
  "dados.origensSelecionadas" = "T",
  "tipoDecisaoSelecionados" = "A",
  "dados.ordenarPor" = "dtPublicacao"
)

# body minimal (apenas busca)
body <- list(
  "dados.buscaInteiroTeor" = busca,
  "dados.origensSelecionadas" = "T"
)

u_tjsp <- "https://esaj.tjsp.jus.br/cjsg/resultadoCompleta.do"

r_tjsp <- httr::POST(u_tjsp, body = body,
                     httr::write_disk("output/tjsp.html", TRUE))



# ideal: passo de parsear o r_tjsp para obter quantidade de paginas

# acessar paginas ---------------------------------------------------------

pag <- 2
pasta <- "output/tjsp"
arquivo <- sprintf("%s/%03d.html", pasta, pag)

## dica: preencha com zeros à esquerda
# sort(c("001", "010", "005", "003", "100"))

query <- list(
  "tipoDeDecisao" = "A",
  "pagina" = pag,
  "conversationId" = ""
)

u_pagina <- "https://esaj.tjsp.jus.br/cjsg/trocaDePagina.do"

r_pagina <- httr::GET(u_pagina, query = query, httr::write_disk(arquivo, TRUE))

# parsear -----------------------------------------------------------------

# primeiro passo: vamos listar os processos


# processo <- processos[[1]]
parse_processo <- function(processo) {
  tabela <- processo %>%
    xml2::xml_find_first(".//table")

  tabela_parseada <- tabela %>%
    rvest::html_table() %>%
    dplyr::select(-X2) %>%
    dplyr::mutate(X1 = stringr::str_squish(X1))

  n_processo <- tabela_parseada %>%
    dplyr::slice(1) %>%
    dplyr::pull(X1) %>%
    stringr::str_extract("[^ ]+")

  tabela_metadados <- tabela_parseada %>%
    dplyr::slice(-1) %>%
    tidyr::separate(
      X1,
      c("titulo", "valor"),
      sep = ": ",
      fill = "right",
      extra = "merge"
    )

  codigo_acordao <- tabela %>%
    xml2::xml_find_first(".//a[@class='downloadEmenta']") %>%
    xml2::xml_attr("cdacordao")

  tabela_metadados %>%
    tidyr::pivot_wider(names_from = titulo, values_from = valor) %>%
    janitor::clean_names() %>%
    dplyr::mutate(
      n_processo = n_processo,
      codigo_acordao = codigo_acordao
    ) %>%
    dplyr::relocate(n_processo, codigo_acordao)
}

parse_pagina <- function(arquivo) {
  processos <- arquivo %>%
    xml2::read_html(encoding = "UTF-8") %>%
    xml2::xml_find_all("//tr[@class='fundocinza1']")

  tabela_pagina <- purrr::map_dfr(processos, parse_processo, .id = "id_pag")
  tabela_pagina
}

# exercicio: baixar até a pagina 10!
purrr::map_dfr(arquivos, parse_pagina)


httr::BROWSE("output/tjsp.html")
browseURL()
