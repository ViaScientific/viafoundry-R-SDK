# Define the default configuration file path
DEFAULT_CONFIG_PATH <- "~/.viaenv"

# Create a global environment to store the configuration path
.viaenv <- new.env()
.viaenv$config_path <- DEFAULT_CONFIG_PATH

#' Authenticate with the `Via Foundry` API
#'
#' Authenticates the user with the `Via Foundry API` using either a personal access token
#' or username and password. Retrieves a bearer token and saves it along with the `API url` 
#' to a configuration file.
#'
#' @param hostname The API URL (optional in interactive mode; will prompt if not provided).
#' @param username The login username (optional; used with password authentication).
#' @param password The login password (optional; will prompt if not provided).
#' @param token Personal access token (optional; recommended for security).
#' @param identity_type The identity type (default is 1).
#' @param redirect_uri The redirect `URI`.
#' @param config_path Path to save the configuration file.
#' @param overwrite Logical flag to overwrite the existing configuration file (default is FALSE).
#' @return Invisibly returns the configuration list containing hostname and bearer_token.
#' @importFrom httr POST status_code content add_headers set_cookies
#' @importFrom jsonlite fromJSON toJSON
#' @importFrom askpass askpass
#' @export
#' @examples
#' \dontrun{
#' # Using token authentication (recommended)
#' authenticate(
#'     hostname = "https://your_foundry_server",
#'     token = "your-personal-access-token",
#'     config_path = "~/.viaenv",
#'     overwrite = TRUE
#' )
#' 
#' # Using username/password authentication
#' authenticate(
#'     hostname = "https://your_foundry_server",
#'     username = "username",
#'     password = "password",
#'     config_path = "~/.viaenv",
#'     overwrite = TRUE
#' )
#' }
authenticate <- function(hostname = NULL, username = NULL, password = NULL, token = NULL,
                         identity_type = 1, redirect_uri = "http://localhost", 
                         config_path = DEFAULT_CONFIG_PATH, overwrite = FALSE) {
  # Set the global config path in the environment
  # Default config path is `~/.viaenv`
  .viaenv$config_path <- normalizePath(config_path, mustWork = FALSE)
  
  # Determine if this is an interactive call (no arguments provided)
  is_interactive_call <- is.null(hostname) && is.null(username) && is.null(password) && is.null(token)
  
  # Check if the configuration file exists and handle overwrite
  # Only check existing config in interactive mode (no explicit credentials provided)
  if (file.exists(.viaenv$config_path) && is_interactive_call) {
    if (!overwrite) {
      # Try to read existing config, handle corrupted files gracefully
      config <- tryCatch({
        fromJSON(.viaenv$config_path)
      }, error = function(e) {
        message("Configuration file is corrupted or invalid. Re-authenticating...")
        return(NULL)
      })
      
      if (!is.null(config) && !is.null(config$hostname) && !is.null(config$bearer_token)) {
        # In interactive mode, ask user whether to use existing or create new
        cat("\nExisting configuration found for: ", config$hostname, "\n")
        cat("  1. Use existing configuration\n")
        cat("  2. Create new configuration\n")
        choice <- readline(prompt = "Enter choice (1 or 2): ")
        
        if (choice == "1") {
          message("Using existing configuration from ", .viaenv$config_path)
          return(invisible(config))
        }
        # If choice is "2", continue to prompt for new authentication
      } else if (!is.null(config)) {
        message("Configuration file is incomplete. Re-authenticating...")
      }
    } else {
      message("Overwriting existing configuration file at ", .viaenv$config_path)
    }
  }
  
  # If token is provided, delegate to authenticate_token()
  if (!is.null(token)) {
    return(authenticate_token(hostname = hostname, token = token, config_path = config_path, overwrite = TRUE))
  }
  
  # Prompt for hostname if not provided
  if (is.null(hostname)) {
    hostname <- readline(prompt = "Enter the API hostname (e.g., https://viafoundry.com): ")
  }
  
  # If username not provided, offer choice between token and username/password
  if (is.null(username)) {
    # Ask user to choose authentication method
    cat("\nChoose authentication method:\n")
    cat("  1. Token (recommended)\n")
    cat("  2. Username and Password\n")
    auth_choice <- readline(prompt = "Enter choice (1 or 2): ")
    
    if (auth_choice == "1") {
      token <- readline(prompt = "Enter your personal access token: ")
      return(authenticate_token(hostname = hostname, token = token, config_path = config_path, overwrite = TRUE))
    } else {
      username <- readline(prompt = "Enter your username: ")
    }
  }
  
  if (is.null(password)) {
    password <- askpass("Enter your password: ")
  }
  
  # Validate hostname
  if (is.null(hostname) || nchar(trimws(hostname)) == 0) {
    stop("Hostname cannot be empty")
  }
  # Validate username
  if (is.null(username) || nchar(trimws(username)) == 0) {
    stop("Username cannot be empty")
  }
  # Validate password
  if (is.null(password) || nchar(trimws(password)) == 0) {
    stop("Password cannot be empty")
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
  writeLines(toJSON(config, pretty = TRUE, auto_unbox = TRUE), con = .viaenv$config_path)
  message("Authentication successful. Bearer token saved to ", .viaenv$config_path)
  return(invisible(config))
}

#' Authenticate with Token
#'
#' Configure authentication using a pre-generated personal access token.
#' This is a convenience function for token-only authentication.
#'
#' @param hostname The API url.
#' @param token Personal access token.
#' @param config_path Path to save the configuration file.
#' @param overwrite Logical flag to overwrite the existing configuration file (default is TRUE).
#' @return Invisibly returns the configuration list containing hostname and bearer_token.
#' @importFrom jsonlite toJSON
#' @export
#' @examples
#' \dontrun{
#' authenticate_token(
#'     hostname = "https://your_foundry_server",
#'     token = "your-personal-access-token"
#' )
#' }
authenticate_token <- function(hostname, token, config_path = DEFAULT_CONFIG_PATH, overwrite = TRUE) {
  # Validate hostname
  if (is.null(hostname) || nchar(trimws(hostname)) == 0) {
    stop("Hostname cannot be empty")
  }
  # Validate token
  if (is.null(token) || nchar(trimws(token)) == 0) {
    stop("Token cannot be empty")
  }
  
  # Set the global config path in the environment
  .viaenv$config_path <- normalizePath(config_path, mustWork = FALSE)
  
  # Check if the configuration file exists and handle overwrite
  if (file.exists(.viaenv$config_path) && !overwrite) {
    config <- tryCatch({
      fromJSON(.viaenv$config_path)
    }, error = function(e) {
      NULL
    })
    if (!is.null(config) && !is.null(config$hostname) && !is.null(config$bearer_token)) {
      message("Using existing configuration from ", .viaenv$config_path)
      return(invisible(config))
    }
  }
  
  # Save the configuration with the provided token
  config <- list(
    hostname = hostname,
    bearer_token = token
  )
  writeLines(toJSON(config, pretty = TRUE, auto_unbox = TRUE), con = .viaenv$config_path)
  message("Authentication successful using token. Configuration saved to ", .viaenv$config_path)
  return(invisible(config))
}

#' Login and retrieve the cookie token
#'
#' @param hostname The API url
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
  h<-headers(response)
  # Extract the cookie token from Set-Cookie header
  cookies <- h[grep("set-cookie", names(h), ignore.case = TRUE)]
  
  # Find the cookie that starts with "viafoundry-cookie="
  viafoundry_cookie <- unlist(cookies)
  set_cookie <- viafoundry_cookie[grepl("^viafoundry-cookie=", viafoundry_cookie)]

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
#' @param hostname The API url
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
