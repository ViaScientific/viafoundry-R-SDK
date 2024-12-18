# Load required packages
library(httr)
library(jsonlite)
#' @import httr
#' @import jsonlite
# Define the path for the config file
config_path <- "~/.viaenv"

# Authenticate and save the token
#' Authenticate with the Via Foundry API
#'
#' Authenticates the user with the Via Foundry API using their username and password.
#' Stores the hostname and authentication token in a local configuration file.
#'
#' @param hostname The API hostname (e.g., "https://your_viafoundry").
#' @param username The login username.
#' @param password The login password.
#' @param identity_type The identity type (default is 1).
#' @param redirect_uri The redirect URI (default is "http://your_viafoundry/redirect").
#' @return None. Saves the authentication token to the configuration file.
#' @examples
#' \dontrun{
#' authenticate("https://your_viafoundry", "username", "password")
#' }
#' @export
authenticate <- function(hostname, username, password, identity_type = 1, redirect_uri = "http://localhost") {
  
  # Check if the config file exists
  if (file.exists(config_path)) {
    # Load the existing configuration
    config <- fromJSON(config_path)
    if (!is.null(config$hostname) && !is.null(config$token)) {
      message("Using existing configuration from ", config_path)
      return(config)
    } else {
      message("Configuration file is invalid. Re-authenticating...")
    }
  }
  if (is.null(username)){
  # Prompt the user for input
  hostname <- readline(prompt = "Enter the API hostname (e.g., http://host.docker.internal:8081): ")
  username <- readline(prompt = "Enter your username: ")
  password <- readline(prompt = "Enter your password: ")
  }
  
  url <- paste0(hostname, "/api/auth/v1/login")
  body <- list(
    username = username,
    password = password,
    identityType = identity_type,
    redirectUri = redirect_uri
  )
  print( toJSON(body, auto_unbox = TRUE) )
  response <- POST(url, body = toJSON(body, auto_unbox = TRUE), encode = "json")
  
  if (status_code(response) != 200) {
    stop("Authentication failed: ", content(response, "text"))
  }
  
  # Extract token from Set-Cookie header
  set_cookie <- headers(response)$`set-cookie`
  cookie_key <- "viafoundry-cookie="
  start <- regexpr(cookie_key, set_cookie)
  if (start == -1) {
    stop("Authentication succeeded, but no token was found in the response headers.")
  }
  token <- substr(set_cookie, start + nchar(cookie_key), nchar(set_cookie))
  token <- strsplit(token, ";")[[1]][1]  # Remove any extra attributes
  
  # Save hostname and token to config file
  config <- list(
    hostname = hostname,
    token = token
  )
  write(toJSON(config, pretty = TRUE, auto_unbox = TRUE), file = config_path)
  message("Authentication successful. Token saved to ", config_path)
}
