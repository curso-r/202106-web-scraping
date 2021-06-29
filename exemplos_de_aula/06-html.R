
library(xml2)

html <- read_html("exemplos_de_aula/html_exemplo.html")

x <- xml_find_all(html, "//p")
x
x[[1]]
# // faz a busca "profunda"
xml_find_first(html, "//p")

xml_find_all(html, "./body/p")

xml_find_all(html, "//p")

# outras formas de acessar
xml_find_first(html, "//head")
xml_find_first(html, "./head")

# texto
todos_p <- xml_find_all(html, "//p")
xml_text(html)
xml_text(todos_p)

# atributos
xml_attrs(todos_p)
xml_attr(todos_p, "style")

xml_attr(todos_p, "style") <- "color: green;"
