library(tidyverse)

trends <- rtweet::get_trends()

# 1. postar

rtweet::post_tweet(
  "Estou tuitando para o curso de Web Scraping da @curso_r, usando o pacote {rtweet}! #rstats"
)

# 2. timeline
da_timeline <- rtweet::get_timeline("clente_")
head(da_timeline$text)

# 3. mencoes

da_mencoes <- rtweet::get_mentions()

# 4. Encontrar amigos

da_users <- rtweet::search_users("#rstats", n = 100)
