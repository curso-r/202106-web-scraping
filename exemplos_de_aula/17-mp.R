library(magrittr)

u0 <- "https://portaldedireitoscoletivos.cnmp.mp.br/consulta.seam"

r0 <- httr::GET(u0)

state <- r0 %>%
  xml2::read_html() %>%
  xml2::xml_find_all("//input[contains(@name, 'ViewState')]") %>%
  xml2::xml_attr("value") %>%
  unique()

body <- list(
  "javax.faces.partial.ajax" = "true",
  "javax.faces.source" = "formConteudo:tabView:btPesquisar",
  "javax.faces.partial.execute" = "formConteudo:tabView:tabConsulta",
  "javax.faces.partial.render" = "formConteudo:tabView",
  "formConteudo:tabView:btPesquisar" = "formConteudo:tabView:btPesquisar",
  "formConteudo:tabView:j_idt47" = "direito",
  "formConteudo:tabView:j_idt53" = "TAC",
  "formConteudo:tabView:j_idt53" = "ICP",
  "formConteudo:tabView:j_idt53" = "ACC",
  "formConteudo:tabView:j_idt53" = "ACP",
  "formConteudo:tabView:j_idt53" = "AIJ",
  "formConteudo:tabView:j_idt53" = "APO",
  "formConteudo:tabView:j_idt53" = "MSC",
  "javax.faces.ViewState" = state
)

httr::POST(u0, body = body, encode = "form",
           httr::write_disk("output/direito.html", TRUE))
