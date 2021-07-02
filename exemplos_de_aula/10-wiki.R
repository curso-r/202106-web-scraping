library(xml2)
library(httr)
library(magrittr)
library(purrr)

links <- "https://en.wikipedia.org/wiki/R_(programming_language)" %>%
  read_html() %>%
  xml_find_first("//table[@class='infobox vevent']") %>%
  xml_find_all(".//a") %>%
  xml_attr("href") %>%
  stringr::str_c("https://en.wikipedia.org", .)

fs::dir_create("~/Downloads/wiki/")

raspa_wiki <- function(link, dir) {

  file <- link %>%
    fs::path_file() %>%
    stringr::str_to_lower() %>%
    stringr::str_remove_all("[^0-9a-z_]") %>%
    fs::path(dir, ., ext = "html")

  GET(link, write_disk(file, overwrite = TRUE))

  return(file)
}

raspa_wiki(links[3], "~/Downloads/wiki/")

map(links, possibly(raspa_wiki, ""), dir = "~/Downloads/wiki/")

# get_insistently <- insistently(GET)

library(furrr)
library(tictoc)
plan(sequential)

tic()
future_map(links, possibly(raspa_wiki, ""), dir = "~/Downloads/wiki/")
toc()
# 8.45 sec elapsed

plan(multicore, workers = 4)

tic()
future_map(links, possibly(raspa_wiki, ""), dir = "~/Downloads/wiki/")
toc()
# 8.758 sec elapsed
# 3.7 sec elapsed

plan(multisession, workers = 4)

tic()
future_map(links, possibly(raspa_wiki, ""), dir = "~/Downloads/wiki/")
toc()
# 4.259 sec elapsed

maybe_raspa_wiki_prog <- function(link, dir, prog) {
  prog()
  f <- possibly(raspa_wiki, "")
  f(link, dir)
}

library(progressr)

with_progress({
  prog <- progressor(along = links)
  map(links, maybe_raspa_wiki_prog, dir = "~/Downloads/wiki/", prog = prog)
})

with_progress({
  prog <- progressor(along = links)
  future_map(links, maybe_raspa_wiki_prog, dir = "~/Downloads/wiki/", prog = prog)
})
