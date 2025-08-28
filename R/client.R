#' Load Configuration
#'
#' Loads the configuration file or triggers authentication if the file is missing.
#' 
#' @return A list containing the host name and bearer token.
#' @importFrom jsonlite fromJSON
#' @export
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

#' Call an API Endpoint with Optional File Upload
#'
#' Sends an HTTP request to a specified API endpoint using the stored bearer token for authentication,
#' optionally supporting file uploads.
#'
#' @param method The HTTP method (e.g., "GET", "POST", "PUT", "DELETE").
#' @param endpoint The API endpoint.
#' @param params A named list of query parameters (optional).
#' @param data A named list or `JSON` object to include in the request body (optional).
#' @param files A list of files to upload, where each file is a named list with `name`, `path`, and optionally `type`.
#' @return A list containing the API response.
#' @examples
#' \dontrun{
#' response <- call_endpoint("POST", "/api/projects/upload", files = list(
#'   list(name = "file1", path = "path/to/file1.txt", type = "text/plain"),
#'   list(name = "file2", path = "path/to/file2.csv", type = "text/csv")
#' ))
#' print(response)
#' }
#' @importFrom httr GET POST PUT DELETE add_headers status_code content upload_file
#' @importFrom jsonlite toJSON fromJSON
#' @export
call_endpoint <- function(method, endpoint, params = list(), data = NULL, files = NULL) {
  config <- load_config()
  url <- paste0(config$hostname, endpoint)
  headers <- add_headers(Authorization = paste("Bearer", config$bearer_token))
  
  if (!method %in% c("GET", "POST", "PUT", "DELETE")) {
    stop("Invalid HTTP method: ", method)
  }
  
  # Handle file uploads
  if (!is.null(files) && length(files) > 0) {
    # Prepare files for upload
    upload_files <- lapply(files, function(file) {
      upload_file(file$path, type = file$type)
    })
    
    # Create a named list with data and files
    body <- c(data, upload_files)
    
    response <- POST(url, headers, query = params, body = body, encode = "multipart")
  } else {
    # Standard request
    #if (!is.null(data)) {
    #  data <- toJSON(data, auto_unbox = TRUE)
    #}
    
    response <- switch(
      method,
      GET = GET(url, headers, query = params),
      POST = POST(url, headers, body = data, encode = "json", query = params),
      PUT = PUT(url, headers, body = data, encode = "json", query = params),
      DELETE = DELETE(url, headers, query = params)
    )
  }
  
  # Handle the response
  if (status_code(response) >= 400) {
    stop("API request failed: ", content(response, "text", encoding = "UTF-8"))
  }
  
  content_type <- headers(response)$`content-type`
  if (!is.null(content_type) && grepl("application/json", content_type, fixed = TRUE)) {
    return(fromJSON(content(response, "text", encoding = "UTF-8")))
  } else {
    return(content(response, "text", encoding = "UTF-8"))
  }
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