#' Fetch the `JSON` data for a report
#'
#' @param reportID The ID of the report to fetch data for.
#' @return The `JSON` object containing the report data.
#' @importFrom httr GET
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
#' @return A data frame containing `id`, `name`, `extension`, `fileSize`, and `routePath`.
#' @importFrom dplyr select filter
#' @export
getFileNames <- function(json_data, processName) {
  # Filter the data to the specified `processName`
  process_data <- json_data$data[json_data$data$processName == processName, ]
  
  # Extract the children associated with the process
  children <- process_data$children[[1]]
  
  # Select only the required columns
  files <- children %>%
    dplyr::select(id, processName, name, extension, fileSize, routePath)
  
  return(files)
}

# Declare global variables
utils::globalVariables(c("id", "name", "extension", "fileSize", "routePath"))

#' Load or download a file from a process and file name
#'
#' @param json_data The `JSON` object containing the report data.
#' @param processName The name of the process.
#' @param fileName The name of the file to load or download.
#' @param sep The separator for tabular files. Default is tab-separated.
#' @param download_dir The directory where non-tabular files will be downloaded.
#' @return A data frame with the file contents if the file is tabular; otherwise, NULL after downloading the file.
#' @importFrom httr GET add_headers content status_code write_disk
#' @importFrom utils read.table
#' @importFrom dplyr  %>%
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
#' @importFrom purrr map_dfr
#' @importFrom dplyr  %>%
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

#' Upload a file to a specific report
#'
#' @param report_id The ID of the report for the API.
#' @param file_path The local path to the file being uploaded.
#' @param dir An optional directory name for organizing files.
#' @return A list containing the server response.
#' @importFrom httr POST add_headers upload_file
#' @export
uploadReportFile <- function(report_id, file_path, dir = NULL) {
  tryCatch({
    # Get all report paths
    report_paths <- getAllReportPaths(report_id)
    if (length(report_paths) == 0) {
      stop("No reports found.")
    }
    
    # Extract attempt ID from the first report path
    attempt_id <- sub(".*report-resources/(.+?)/pubweb.*", "\\1", report_paths[1])
    
    # Define the upload endpoint
    upload_endpoint <- paste0("/api/run/v1/", report_id, "/reports/upload/", attempt_id)
    
    # Debugging
    print(upload_endpoint)
    
    # Prepare the file and data
    files <- list(file = httr::upload_file(file_path))
    data <- if (!is.null(dir)) list(dir = dir) else list()
    
    # Debugging
    #print(files)
    if (!is.null(dir)) print(data)
    
    # Call the API to upload the file
    response <- call_endpoint(
      method = "POST",
      endpoint = upload_endpoint,
      data = data,
      files = files
    )

    return(response)
  }, error = function(e) {
    stop("Failed to upload file to report: ", conditionMessage(e))
  })
}

#' Get unique report directories and attempt IDs for a specific report
#'
#' @param report_id The ID of the report.
#' @return A character vector of unique report directories.
#' @importFrom httr GET add_headers content
#' @importFrom jsonlite fromJSON
#' @export
getAllReportPaths <- function(report_id) {
  tryCatch({
    # Define the API endpoint
    endpoint <- paste0("/api/run/v1/", report_id, "/reports")
    
    # Call the API to fetch report data
    response <- call_endpoint(method = "GET", endpoint = endpoint)
    reports <- response$data
    
    if (is.null(reports) || length(reports) == 0) {
      stop("No reports found.")
    }
    
    # Extract unique `routePath` entries
    unique_paths <- unique(reports$routePath)
    return(unique_paths)
  }, error = function(e) {
    stop("Failed to fetch report directories: ", conditionMessage(e))
  })
}

#' Get directories following "pubweb" in the routePath
#'
#' @param report_id The ID of the report.
#' @return A character vector of unique directories found after "pubweb".
#' @importFrom stringr str_extract
#' @export
getReportDirs <- function(report_id) {
  tryCatch({
    # Get all routePaths for the report
    all_paths <- getAllReportPaths(report_id)
    if (length(all_paths) == 0) {
      stop("No reports found.")
    }
    
    # Extract directories after "pubweb"
    report_dirs <- unique(sub(".*pubweb/(.+)", "\\1", all_paths[grepl("pubweb/", all_paths)]))
    if (length(report_dirs) == 0) {
      stop("No directories found after 'pubweb'.")
    }
    
    return(report_dirs)
  }, error = function(e) {
    stop("Failed to fetch possible directories: ", conditionMessage(e))
  })
}
