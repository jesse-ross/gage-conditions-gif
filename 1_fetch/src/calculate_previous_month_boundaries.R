#' @title Calculate the beginning and end of the previous month
#'
calculate_previous_month_boundaries <- function(){
  current_date <- Sys.Date()
  month_end <- current_date - days(day(current_date))
  previous_month <- list()
  previous_month[['start']] <- month_end - days(day(month_end)) + 1
  previous_month[['end']] <- month_end
  previous_month
}
