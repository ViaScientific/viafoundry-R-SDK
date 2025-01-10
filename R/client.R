#' Load Configuration
#'
#' Loads the configuration file or triggers authentication if the file is missing.
#' 
#' @return A list containing the hostname and bearer token.
#' @importFrom jsonlite fromJSON
load_config <- function() {
  config_path <- .viaenv$config_path
  if (!file.exists(config_path)) {
    message("Configuration file not found. Initiating authentication...")
    authenticate(config_path = config_path)  # Trigger authentication if missing
  }
  
  config <- fromJSON(config_path)
  
  if (is.null(config$hostname) || is.null(config$bearer_token)) {
    stop("Invalid configuration. Please authenticate again.")
  }
  
  return(config)
}

#' Discover Available Endpoints
#'
#' Fetches and lists all available API endpoints from the Swagger documentation.
#'
#' @return A character vector of available endpoints.
#' @examples
#' \dontrun{
#' discover()
#' }
#' @importFrom httr GET add_headers status_code content
#' @importFrom jsonlite fromJSON
#' @export
discover <- function() {
  config <- load_config()
  url <- paste0(config$hostname, "/swagger.json")
  
  headers <- add_headers(Authorization = paste("Bearer", config$bearer_token))
  response <- GET(url, headers)
  
  if (status_code(response) != 200) {
    stop("Failed to retrieve endpoints: ", content(response, "text", encoding = "UTF-8"))
  }
  
  swagger <- fromJSON(content(response, "text", encoding = "UTF-8"))
  if (!"paths" %in% names(swagger)) {
    stop("Invalid Swagger response.")
  }
  
  return(names(swagger$paths))
}

#' Call an API Endpoint
#'
#' Sends an HTTP request to a specified API endpoint using the stored bearer token for authentication.
#'
#' @param method The HTTP method (e.g., "GET", "POST", "PUT", "DELETE").
#' @param endpoint The API endpoint (e.g., `/api/projects`).
#' @param params A named list of query parameters (optional).
#' @param data A named list or `JSON` object to include in the request body (optional).
#' @return A list containing the API response.
#' @examples
#' \dontrun{
#' response <- call_endpoint("GET", "/api/projects")
#' print(response)
#' }
#' @importFrom httr GET POST PUT DELETE add_headers status_code content
#' @importFrom jsonlite fromJSON
#' @export
call_endpoint <- function(method, endpoint, params = list(), data = NULL) {
  config <- load_config()
  url <- paste0(config$hostname, endpoint)
  headers <- add_headers(Authorization = paste("Bearer", config$bearer_token))
  
  if (!method %in% c("GET", "POST", "PUT", "DELETE")) {
    stop("Invalid HTTP method: ", method)
  }
  
  # Handle API requests based on method
  response <- switch(
    method,
    GET = GET(url, headers, query = params),
    POST = POST(url, headers, body = data, encode = "json"),
    PUT = PUT(url, headers, body = data, encode = "json"),
    DELETE = DELETE(url, headers, query = params)
  )
  
  if (status_code(response) != 200) {
    stop("API request failed: ", content(response, "text", encoding = "UTF-8"))
  }
  
  return(fromJSON(content(response, "text", encoding = "UTF-8")))
}

#' Get API Status
#'
#' Sends a simple GET request to check the status of the API.
#'
#' @return A character vector with the API status.
#' @examples
#' \dontrun{
#' status <- get_api_status()
#' print(status)
#' }
#' @importFrom httr GET add_headers status_code content
#' @importFrom jsonlite fromJSON
#' @export
get_api_status <- function() {
  config <- load_config()
  url <- paste0(config$hostname, "/api/status")
  
  headers <- add_headers(Authorization = paste("Bearer", config$bearer_token))
  response <- GET(url, headers)
  
  if (status_code(response) != 200) {
    stop("Failed to retrieve API status: ", content(response, "text", encoding = "UTF-8"))
  }
  
  status <- fromJSON(content(response, "text", encoding = "UTF-8"))
  return(status)
}