#' Dataset for TV series friends
#'
#' This dataset is built from TV series transcripts friends. It contains the lines each character speak, name of the speakers,
#' scene number when the dialogue take places.
#' @format A data frame with 64280 rows and 6 variables:
#' \describe{
#'   \item{episodes_id}{the id of episodes, integer with 4 digits, first two are for season, latter two are for episode number}
#'   \item{person}{the name of the speaker of the line, character}
#'   \item{line}{a single line of the speaker, character}
#'   \item{type}{type of the line, 'person' or 'scene'}
#'   \item{season}{the season that the line appears}
#'   \item{scene2}{the scene the line appears, integer}
#' }
#' @source \url{https://fangj.github.io/friends/}
"friends_lines"
