# 1. Faça um script que seja capaz de baixar a base de dados utilizada pelo
# pesqEle. Ela pode ser acessada pelo botão "Download" na direita superior do
# app.

library(webdriver)
library(magrittr)

pjs <- run_phantomjs()
ses <- Session$new(port = pjs$port)

u_pesqele <- "https://rseis.shinyapps.io/pesqEle/"

ses$go(u_pesqele)
ses$takeScreenshot()

dld <- ses$findElement(xpath = '//a[@id="download"]')
link <- dld$getAttribute("href")

httr::GET(link, httr::write_disk("~/Downloads/dados.xlsx"))

# 2. [Dissertativa] Verifique quais informações podem ser extraídas **sem**
# webdriver. Use o resto do conhecimento obtido ao longo do curso para explorar
# o aplicativo.
