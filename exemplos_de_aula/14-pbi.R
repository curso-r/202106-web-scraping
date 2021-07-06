library(RSelenium)

rsd <- rsDriver(browser = "firefox")
ses <- rsd$client

url <- "https://app.powerbi.com/view?r=eyJrIjoiMjcxNDIyNjAtOGM0Yi00ZWJhLWJkNmEtNjFiOTI0MWVlYjNiIiwidCI6IjI1NmNiNTA1LTAzOWYtNGZiMi04NWE2LWEzZTgzMzI4NTU3OCIsImMiOjh9"
ses$navigate(url)

html <- ses$getPageSource()[[1]]
file <- fs::file_temp(ext = "html")
readr::write_file(html, file)

httr::BROWSE(file)

elem <- ses$findElement("xpath", "//div[@class='slicer-dropdown-menu']")
elem$clickElement()

scroll <- ses$findElement("xpath", "//*[contains(@class, 'scroll-scrolly_visible')]")
scroll$executeScript("arguments[0].scrollBy(0,400);", args = list(scroll))

checkbox <- ses$findElement("xpath", "//*[@title='Brazil']")
checkbox$clickElement()

html <- ses$getPageSource()[[1]]
file <- fs::file_temp(ext = "html")
readr::write_file(html, file)

httr::BROWSE(file)

file %>%
  xml2::read_html() %>%
  xml2::xml_find_all("//svg[@class='card']") %>%
  xml2::xml_text()

rsd$server$stop()

