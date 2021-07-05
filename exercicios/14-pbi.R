# 1. Aproveitando o código apresentado em aula, faça uma breve análise
# comparando os dados de Covid do Brasil com os do mundo todo. Crie um código
# que extraia os dados do PBI sem intervenção humana.

library(RSelenium)
library(magrittr)

driver <- rsDriver(browser = "firefox")
u <- "https://app.powerbi.com/view?r=eyJrIjoiMjcxNDIyNjAtOGM0Yi00ZWJhLWJkNmEtNjFiOTI0MWVlYjNiIiwidCI6IjI1NmNiNTA1LTAzOWYtNGZiMi04NWE2LWEzZTgzMzI4NTU3OCIsImMiOjh9"

driver$client$navigate(u)

readr::write_file(driver$client$getPageSource()[[1]], "~/Downloads/pbi.html")
html <- xml2::read_html("~/Downloads/pbi.html")

i <- html %>%
  xml2::xml_find_all("//text[@class='label']") %>%
  xml2::xml_text() %>%
  stringr::str_detect("Total Confirmed Cases") %>%
  which() %>%
  magrittr::extract(1)

total_world <- html %>%
  xml2::xml_find_all("//text[@class='value']/title") %>%
  magrittr::extract(i) %>%
  xml2::xml_text() %>%
  stringr::str_remove_all(",") %>%
  as.numeric()

el <- driver$client$findElement("xpath", "//*[@class='slicer-dropdown-menu']")
el$clickElement()

scroll <- driver$client$findElement("xpath", "//*[contains(@class, 'scroll-scrolly_visible')]")
scroll$executeScript("arguments[0].scrollBy(0,400);", args = list(scroll))

checkbox <- driver$client$findElement("xpath", "//*[@title='Brazil']")
checkbox$clickElement()

readr::write_file(driver$client$getPageSource()[[1]], "~/Downloads/pbi.html")
html <- xml2::read_html("~/Downloads/pbi.html")

i <- html %>%
  xml2::xml_find_all("//text[@class='label']") %>%
  xml2::xml_text() %>%
  stringr::str_detect("Total Confirmed Cases") %>%
  which() %>%
  magrittr::extract(1)

total_brasil <- html %>%
  xml2::xml_find_all("//text[@class='value']/title") %>%
  magrittr::extract(i) %>%
  xml2::xml_text() %>%
  stringr::str_remove_all(",") %>%
  as.numeric()

print(total_brasil/total_world)

# 2. [Dissertativa] Como você poderia utilizar a função scrollBy() para
# descobrir automaticamente a localização do elemento de interesse, ou seja,
# sem precisar encontrar de antemão o número de pixels a serem rolados.
