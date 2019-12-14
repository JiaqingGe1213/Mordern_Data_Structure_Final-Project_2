library(htm2txt)
library(dplyr)
library(xml2)
library(httr)
library(stringr)
library(tidyverse)
library(tidytext)
library(rvest)
library(tokenizers)
## 1. scrap from web the friends transcripts
## link: https://fangj.github.io/friends/
# get the urls from the web
link <- "https://fangj.github.io/friends/"
main.page <- read_html(x = link)
url <- main.page %>% # feed `main.page` to the next step
  html_nodes("a") %>% # get the CSS nodes
  html_attr("href") # extract the URLs
urls <- paste(link,url,sep = '') # obtain the full urls to get the text from website
episodes_trans <- vector() #build an empty vector for adding the data later
# adding the text into the vector
for (u in urls){
  episodes_trans <- c(episodes_trans,gettxt(u))
}
## 2. cleaning the transcripts
# building a function to clean the data
cleanText <- function(x){
  # remove new lines CHANGED TO SPACE BECAUSE OF EP 1 FORMATTING
  x <- gsub("\n", " ", x)
  # remove back slashes
  x <- gsub('\"', "", x, fixed = TRUE)
  x <- str_trim(x)
  x <- str_to_lower(x)
  return(x)
}
# buiding dataset id
episodes_id <- str_extract(url, '\\d+-?\\d+')
# clean the data one by one
episodes_trans_clean <- episodes_trans %>%
  map(~ cleanText(.x))
# turn the list into vector
episodes_trans_clean <- unlist(episodes_trans_clean, use.names=FALSE)
# split the text into lines
episodes_trans_clean <- str_split(episodes_trans_clean, '  ')
# build a dataframe
df_friends <- tibble(episodes_id,episodes_trans_clean)%>%
  unnest(episodes_trans_clean) %>%
  # determining whether a line is a scene, title, action or person speaking
  mutate(type =  ifelse(str_detect(episodes_trans_clean, "^(\\[sc)|(\\(at)|(\\[at)"), "scene",      # scenes are on singular lines, enclosed in square brackets annd ending in round
                         ifelse(str_detect(episodes_trans_clean, "^(\\()|(\\<)"), "action",              # actions are on singular lines, enclosed in round and angularbrackets
                                ifelse(str_detect(episodes_trans_clean, "^written"), "written",     # indicates who the episode was written by
                                       ifelse(str_detect(episodes_trans_clean, "^[a-z](.*):"), "person",  # if doesn't match anything above, and has a semicolon, should be a person speaking
                                              NA)))))
# seperate lines into person who talk and the content of line
df_friends <- df_friends %>%
  separate(episodes_trans_clean, into = c("person", "line"), sep = ":") %>%
  mutate(line = str_trim(line)) %>%
  mutate(season = substr(episodes_id, 1, 2))

# this line mark the number of scence the dialogue appears, learn it on stackflow
friends_lines <- df_friends %>%
  filter(type %in% c("person", "scene")) %>%
  group_by(episodes_id) %>%
  mutate(scene = ifelse(type == "scene", 1, NA)) %>%
  mutate(scene2 = cumsum(0 + !is.na(scene))) %>%
  ungroup() %>%
  select(-scene)

usethis::use_data(friends_lines,overwrite = TRUE)
write_csv(friends_lines, "data-raw/friends_lines.csv")
