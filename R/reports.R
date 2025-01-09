# Load required libraries
library(jsonlite)
library(httr)
library(dplyr)


#' Fetch the `JSON` data for a report
#'
#' @param reportID The ID of the report to fetch data for.
#' @return The `JSON` object containing the report data.
#' @export
fetchReportData <- function(reportID) {
  # Fetch data from the API
  endpoint <- paste0("/api/run/v1/", reportID, "/reports/")
  response <- call_endpoint(method = "GET", endpoint = endpoint)
  
  message("Data fetched for report ID: ", reportID)
  return(response)
}

#' Get unique process names
#'
#' @param json_data The `JSON` object containing the report data.
#' @return A character vector of unique process names.
#' @export
getProcessNames <- function(json_data) {
  # Directly access the processName field
  process_names <- json_data$data$processName
  
  # Return unique process names
  return(unique(process_names))
}

#' Get file names for a specific process
#'
#' @param json_data The `JSON` object containing the report data.
#' @param processName The name of the process to filter by.
#' @return A data frame containing `id`, `name`, `extension`, and `processName`.
#' @importFrom dplyr %>% filter
#' @importFrom purrr map_dfr
#' @importFrom utils read.table
#' @export
getFileNames <- function( json_data, processName ) {
  # Filter the data to the specified `processName`
  process_data <- json_data$data[json_data$data$processName == processName, ]
  
  # Extract the children associated with the process
  children <- process_data$children[[1]]
  
  # Select only the required columns
  files <- children %>%
    dplyr::select(id, processName, name, extension, fileSize, routePath)
  
  return(files)
}

#Declare global variables
utils::globalVariables(c("id", "name", "extension", "fileSize", "routePath"))

#' Load or download a file from a process and file name
#'
#' @param json_data The `JSON` object containing the report data.
#' @param processName The name of the process.
#' @param fileName The name of the file to load or download.
#' @param sep The separator for tabular files. Default is tab-separated.
#' @param download_dir The directory where non-tabular files will be downloaded.
#' @return A data frame with the file contents if the file is tabular; otherwise, NULL after downloading the file.
#' @importFrom httr write_disk
#' @export
loadFile <- function(json_data, processName, fileName, sep = "\t", download_dir = getwd()) {
  config <- load_config()  # Load the existing configuration
  baseHost <- config$hostname
  
  # Extract the specific file details
  files <- getFileNames(json_data, processName)
  file_details <- files %>% filter(name == fileName)  # Match by name
  
  if (nrow(file_details) == 0) {
    stop("File not found for the given process and file name.")
  }
  
  # Construct the URL for the file
  file_url <- paste0(baseHost, file_details$routePath[1])
  file_extension <- tolower(file_details$extension[1])  # Extract file extension
  
  # Handle file based on extension
  if (file_extension %in% c("tsv", "csv", "txt")) {
    # Download and load the tabular file
    response <- GET(file_url, add_headers(Cookie = paste0("viafoundry-cookie=", config$token)))
    if (status_code(response) != 200) {
      stop("Failed to fetch the file from the server. Status: ", status_code(response))
    }
    
    # Parse the tabular data
    content <- content(response, "text", encoding = "UTF-8")
    df <- read.table(text = content, sep = sep, header = TRUE, stringsAsFactors = FALSE)
    return(df)
  } else {
    # Download the file to the specified directory
    output_path <- file.path(download_dir, fileName)
    response <- GET(file_url, add_headers(Cookie = paste0("viafoundry-cookie=", config$token)), write_disk(output_path, overwrite = TRUE))
    if (status_code(response) != 200) {
      stop("Failed to download the file from the server. Status: ", status_code(response))
    }
    
    message("File downloaded to: ", output_path)
    return("success")
  }
}

#' Extract children names across all processes
#'
#' @param json_data The `JSON` object containing the report data.
#' @return A data frame containing `id`, `processName`, `name`, `extension`, `fileSize`, and `routePath`.
#' @importFrom dplyr select
#' @importFrom purrr map_dfr
#' @export
getAllFileNames <- function(json_data) {
  # Extract all children from the data
  all_files <- purrr::map_dfr(json_data$data$children, function(children) {
    # Convert children to a data frame, preserving required fields
    data.frame(
      id = children$id,
      processName = children$processName,
      name = children$name,
      extension = children$extension,
      fileSize = children$fileSize,
      routePath = children$routePath,
      stringsAsFactors = FALSE
    )
  })
  
  return(all_files)
}