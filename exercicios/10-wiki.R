# 1. Crie uma função wiki_baixar_pag() que baixa uma página dado um URL e um
# diretório. Use o URL para criar um nome único para o arquivo a ser salvo e
# retorne esse caminho.

library(magrittr)

wiki_baixar_pag <- function(url, dir) {

  arq <- url %>%
    fs::path_file() %>%
    stringr::str_to_lower() %>%
    fs::path(dir, ., ext = "html")

  httr::GET(url, httr::write_disk(arq, TRUE))

  return(arq)
}

# 2. Crie uma função wiki_primeiro_link() que recebe um caminho de arquivo da
# Wikipédia e retorna o primeiro link que aparece no corpo do artigo.

# 3. [Desafio] Modificar a função do exercício 2 para que ela exclua os links
# que aparecem entre parênteses logo no início do artigo, pois normalmente eles
# dizem respeito à pronúncia do verbete.
## Dica: uma boa regex para remover parênteses é "\\([^()]*\\)|\\{[^{}]*\\}"

wiki_primeiro_link <- function(arq) {

  node <- arq %>%
    xml2::read_html() %>%
    xml2::xml_find_first("//div[@class='mw-parser-output']") %>%
    xml2::xml_find_first("./p[not(@class='mw-empty-elt')]")

   links <- node %>%
    xml2::xml_find_all("./a") %>%
    purrr::map(~ list(
      href = xml2::xml_attr(.x, "href"),
      text = xml2::xml_text(.x)
    ))

   text <- node %>%
     xml2::xml_text() %>%
     stringr::str_remove_all("\\([^()]*\\)|\\{[^{}]*\\}") %>%
     stringr::str_remove_all("\\(.+\\)")

   links %>%
     purrr::map_lgl(~stringr::str_detect(text, .x$text)) %>%
     which() %>%
     min() %>%
     magrittr::extract2(links, .) %>%
     purrr::pluck("href") %>%
     stringr::str_c("https://en.wikipedia.org", .)
}

# 4. Crie uma função wiki_ate_filo() que recebe o link para uma página da
# Wikipédia e repete o processo wiki_primeiro_link() -> wiki_baixar_pag() até
# encontrar a página https://en.wikipedia.org/wiki/Philosophy (ou até passar
# por 30 páginas, o que ocorrer antes). Ela deve retornar o número de passos
# até encontrar o artigo sobre filosofia.

wiki_ate_filo <- function(url, dir) {

  for (i in 1:30) {
    message(url)
    url <- wiki_primeiro_link(wiki_baixar_pag(url, dir))
    if (url == "https://en.wikipedia.org/wiki/Philosophy") {
      message(url)
      break()
    }
  }

  return(i)
}

# 5. Crie uma função wiki_jogo() que recebe um vetor de links da Wikipédia em
# inglês e executa wiki_ate_filo() para cada um. Ela deve retornar a média da
# distância entre cada artigo e filosofia.

wiki_jogo <- function(links, dir) {
  fs::dir_create(dir)
  mean(purrr::map_dbl(links, wiki_ate_filo, dir = dir))
}

links <- c(
  "https://en.wikipedia.org/wiki/R_(programming_language)",
  "https://en.wikipedia.org/wiki/Wikipedia",
  "https://en.wikipedia.org/wiki/Dungeons_%26_Dragons"
)

wiki_jogo(links, "~/Downloads/wiki/")
