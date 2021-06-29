library(magrittr)

# nao rola, pois a pagina é dinamica --------------------------------------

u_discourse <- "https://discourse.curso-r.com/login"

username <- Sys.getenv("DISCOURSE_USER")
password <- Sys.getenv("DISCOURSE_PWD")
body <- list(
  username = username,
  password = password,
  redirect = "https://discourse.curso-r.com/u/account-created"
)

r <- httr::POST(u_discourse, body = body,
                httr::write_disk("output/discourse.html", TRUE))

httr::content(r, "text") %>%
  stringr::str_detect("trecenti")

httr::GET("https://discourse.curso-r.com/",
          httr::write_disk("output/discourse_login.html", TRUE))

# outro exemplo de login --------------------------------------------------

# brasil io
u_login <- "https://brasil.io/auth/login/"

# esse token não funciona
token <- "XeAgTeNk7OZlFB8pZ1DScIAxvCmIECycBpQabxcakeasJKWAzCrQfozRr3oRrOTB"

r_inicial <- httr::GET(u_login)

token <- r_inicial %>%
  xml2::read_html() %>%
  xml2::xml_find_first("//input[@name='csrfmiddlewaretoken']") %>%
  xml2::xml_attr("value")


body <- list(
  "csrfmiddlewaretoken" = token,
  "username" = Sys.getenv("BRASILIO_USER"),
  "password" = Sys.getenv("BRASILIO_PWD"),
  "next" = ""
)

r <- httr::POST(
  u_login,
  body = body,
  # encode = "form",
  httr::add_headers("referer" = "https://brasil.io/auth/login/"),
  httr::write_disk("output/brasilio.html", TRUE)
)

u_auth_tokens <- xml2::read_html("output/brasilio.html") %>%
  xml2::xml_find_first("//*[@title='Chaves da API']") %>%
  xml2::xml_attr("href")


u_tokens <- paste0("https://brasil.io", u_auth_tokens)


httr::GET(
  u_tokens,
  httr::write_disk("output/brasilio_tokens.html", TRUE))
