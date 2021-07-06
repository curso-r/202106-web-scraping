library(webdriver)
pjs <- run_phantomjs()
ses <- Session$new(port = pjs$port)

url <- "https://rseis.shinyapps.io/pesqEle/"

ses$go(url)
ses$takeScreenshot()

elem <- ses$findElement(
  xpath = "//div[@id='contagens-num_pesquisas']//span[@class='info-box-number']"
)
elem$getText()

elems <- ses$findElements(xpath = "/@data-value/div[@class='info-box-content']")
purrr::map(elems, ~.x$getText())

aba <- ses$findElement(xpath = "//a[@data-value='empresas']")
aba$click()
ses$takeScreenshot()

dpdn <- ses$findElement(xpath = "//select[@name='DataTables_Table_0_length']/option[@value='100']")
dpdn$click()
ses$takeScreenshot()

html <- ses$getSource()
file <- fs::file_temp(ext = "html")
readr::write_file(html, file)

library(magrittr)

file %>%
  xml2::read_html() %>%
  xml2::xml_find_first("//table") %>%
  rvest::html_table() %>%
  janitor::clean_names()
