# Load configuration
load_config <- function() {
  config<-c()
  if (!file.exists(config_path)) {
    config <- authenticate()
  }else{
    config <- fromJSON(config_path)
  }
  
  
  if (is.null(config$hostname) || is.null(config$token)) {
    stop("Invalid configuration. Please authenticate again.")
  }
  return(config)
}

# Discover endpoints from Swagger
#' List Available Endpoints
#'
#' Fetches and lists all available API endpoints from the Swagger documentation.
#'
#' @return A character vector of available endpoints.
#' @examples
#' \dontrun{
#' discover()
#' }
#' @export
discover <- function() {
  config <- load_config()
  url <- paste0(config$hostname, "/api-docs/swagger.json?group=App")
  response <- GET(url, add_headers(Cookie = paste0("viafoundry-cookie=", config$token)))
  
  if (status_code(response) != 200) {
    stop("Failed to retrieve endpoints: ", content(response, "text"))
  }
  
  swagger <- fromJSON(content(response, "text", encoding = "UTF-8"))
  if (!"paths" %in% names(swagger)) {
    stop("Invalid Swagger response.")
  }
  
  return(names(swagger$paths))
}

# Call a specific API endpoint
#' Call an API Endpoint
#'
#' Sends an HTTP request to a specified API endpoint using the stored token for authentication.
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
#' @export
call_endpoint <- function(method, endpoint, params = list(), data = NULL) {
  config <- load_config()
  url <- paste0(config$hostname, endpoint)
  headers <- add_headers(Cookie = paste0("viafoundry-cookie=", config$token))
  
  if (!method %in% c("GET", "POST", "PUT", "DELETE")) {
    stop("Invalid HTTP method: ", method)
  }
  
  response <- switch(
    method,
    GET = GET(url, headers, query = params),
    POST = POST(url, headers, body = data, encode = "json"),
    PUT = PUT(url, headers, body = data, encode = "json"),
    DELETE = DELETE(url, headers, query = params)
  )
  
  if (status_code(response) != 200) {
    stop("API request failed: ", content(response, "text"))
  }
  
  return(fromJSON(content(response, "text", encoding = "UTF-8")))
}
