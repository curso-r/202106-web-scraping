# da para acessar o arquivo direto, mas eu queria identificar o link
r <- httr::GET("https://mobileapps.saude.gov.br/esus-vepi/files/unAFkcaNDeXajurGB7LChj8SgQYS2ptm/494bbe4cc15886f3aafd024ec9502eae_HIST_PAINEL_COVIDBR_24jun2021.rar")

# baixando a página inicial do app, não aparece nada...
u_covid <- "https://covid.saude.gov.br"
r <- httr::GET(u_covid, httr::write_disk("output/covid.html"))

# mas fuçando nas requisições, encontrei que essa aqui tem o link que eu busco
u_api <- "https://xx9p7hp1p7.execute-api.us-east-1.amazonaws.com/prod/PortalGeral"
r_api <- httr::GET(u_api)

r_api$request$options


httr::content(r_api)

# vamos adicionar um header!

r_api <- httr::GET(
  u_api,
  httr::add_headers("x-parse-application-id" = "unAFkcaNDeXajurGB7LChj8SgQYS2ptm")
)

u_covid <- httr::content(r_api) %>%
  purrr::pluck("results", 1, "arquivo", "url")

httr::GET(u_covid, httr::write_disk("output/dados_covid.rar"))
