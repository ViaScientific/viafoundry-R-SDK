# Define the default configuration file path
DEFAULT_CONFIG_PATH <- "~/.viaenv"

# Create a global environment to store the configuration path
.viaenv <- new.env()
.viaenv$config_path <- DEFAULT_CONFIG_PATH

#' Authenticate with the `Via Foundry` API
#'
#' Authenticates the user with the `Via Foundry` API using their username and password.
#' Retrieves a bearer token and saves it along with the hostname to a configuration file.
#'
#' @param hostname The API `hostname` (e.g., `https://your_viafoundry`).
#' @param username The login username.
#' @param password The login password (optional; will prompt if not provided).
#' @param identity_type The identity type (default is 1).
#' @param redirect_uri The redirect `URI` (default is `http://your_viafoundry/redirect`).
#' @param config_path Path to save the configuration file (default is `~/.viaenv`).
#' @param overwrite Logical flag to overwrite the existing configuration file (default is FALSE).
#' @return None. Saves the bearer token to the configuration file and sets the global config path.
#' @importFrom httr POST status_code content add_headers set_cookies
#' @importFrom jsonlite fromJSON toJSON
#' @importFrom askpass askpass
#' @export
authenticate <- function(hostname, username = NULL, password = NULL, identity_type = 1, 
                         redirect_uri = "http://localhost", config_path = DEFAULT_CONFIG_PATH, 
                         overwrite = FALSE) {
  # Set the global config path in the environment
  .viaenv$config_path <- normalizePath(config_path, mustWork = FALSE)
  
  # Check if the configuration file exists and handle overwrite
  if (file.exists(.viaenv$config_path)) {
    if (!overwrite) {
      config <- fromJSON(.viaenv$config_path)
      if (!is.null(config$hostname) && !is.null(config$bearer_token)) {
        message("Using existing configuration from ", .viaenv$config_path)
        return(config)
      } else {
        message("Configuration file is invalid or incomplete. Re-authenticating...")
      }
    } else {
      message("Overwriting existing configuration file at ", .viaenv$config_path)
    }
  }
  
  # Prompt for credentials if not provided
  if (is.null(username)) {
    hostname <- readline(prompt = "Enter the API hostname (e.g., http://host.docker.internal:8081): ")
    username <- readline(prompt = "Enter your username: ")
  }
  
  if (is.null(password)) {
    password <- askpass("Enter your password: ")
  }
  
  # Step 1: Retrieve the cookie token
  cookie_token <- login(hostname, username, password, identity_type, redirect_uri)
  
  # Step 2: Retrieve the bearer token using the cookie token
  bearer_token <- get_bearer_token(hostname, cookie_token)
  
  # Save the configuration to the file
  config <- list(
    hostname = hostname,
    bearer_token = bearer_token
  )
  write(toJSON(config, pretty = TRUE, auto_unbox = TRUE), file = .viaenv$config_path)
  message("Authentication successful. Bearer token saved to ", .viaenv$config_path)
}

#' Login and retrieve the cookie token
#'
#' @param hostname The API hostname.
#' @param username The login username.
#' @param password The login password.
#' @param identity_type The identity type.
#' @param redirect_uri The redirect URI.
#' @return The cookie token.
#' @importFrom httr POST content headers status_code
#' @export
login <- function(hostname, username, password, identity_type = 1, redirect_uri = "http://localhost") {
  url <- paste0(hostname, "/api/auth/v1/login")
  body <- list(
    username = username,
    password = password,
    identityType = identity_type,
    redirectUri = redirect_uri
  )
  
  response <- POST(url, body = body, encode = "json")
  
  if (status_code(response) != 200) {
    stop("Login failed: ", content(response, "text", encoding = "UTF-8"))
  }
  
  # Extract the cookie token from Set-Cookie header
  set_cookie <- headers(response)$`set-cookie`
  cookie_key <- "viafoundry-cookie="
  start <- regexpr(cookie_key, set_cookie)
  if (start == -1) {
    stop("Token not found in cookie.")
  }
  start <- start + nchar(cookie_key)
  end <- regexpr(";", substr(set_cookie, start, nchar(set_cookie)))
  token <- substr(set_cookie, start, start + end - 2)
  
  return(token)
}

#' Get bearer token using the cookie token
#'
#' @param hostname The API hostname.
#' @param cookie_token The cookie token.
#' @param name The name of the token (default is "token").
#' @return The bearer token.
#' @importFrom httr POST add_headers content set_cookies
#' @importFrom jsonlite fromJSON toJSON
#' @export
get_bearer_token <- function(hostname, cookie_token, name = "token") {
  url <- paste0(hostname, "/api/auth/v1/personal-access-token")
  headers <- add_headers(
    "Content-Type" = "application/json",
    "User-Agent" = "curl/8.7.1",
    "Accept" = "*/*"
  )
  # Define Cookie separately to avoid duplication
  cookie <- set_cookies(`viafoundry-cookie` = cookie_token)
  
  body <- list(
    name = name,
    expiresAt = calculate_expiration_date()
  )
  
  response <- POST(url, headers, cookie, body = body, encode = "json")
  
  if (status_code(response) != 200) {
    stop("Failed to get bearer token: ", content(response, "text", encoding = "UTF-8"))
  }
  
  data <- fromJSON(content(response, "text", encoding = "UTF-8"))
  bearer_token <- data$token
  if (is.null(bearer_token)) {
    stop("Bearer token not found in response.")
  }
  
  return(bearer_token)
}

#' Calculate expiration date (30 days from now)
#'
#' @return The expiration date as a string.
calculate_expiration_date <- function() {
  format(Sys.Date() + 30, "%Y-%m-%d")
}

#' Get headers for API requests
#'
#' @return A list of headers with the bearer token.
#' @importFrom httr add_headers
#' @importFrom jsonlite fromJSON
get_headers <- function() {
  config <- fromJSON(.viaenv$config_path)
  if (is.null(config$bearer_token)) {
    stop("Bearer token is missing. Please authenticate first.")
  }
  return(add_headers(Authorization = paste("Bearer", config$bearer_token)))
}
