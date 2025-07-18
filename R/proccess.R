#' List All Processes
#'
#' Fetches all existing processes from the API.
#'
#' @return A JSON object containing the list of processes.
#' @importFrom httr GET
#' @export
listProcesses <- function() {
  tryCatch({
    endpoint <- "/api/v1/process/"
    response <- call_endpoint(method = "GET", endpoint = endpoint)
    message("Processes fetched successfully.")
    return(response)
  }, error = function(e) {
    stop("Error 1001: Failed to list processes: ", e$message)
  })
}

#' Get Process Information
#'
#' Fetches detailed information about a specific process.
#'
#' @param processID The ID of the process to retrieve.
#' @return A JSON object containing the process details.
#' @importFrom httr GET
#' @export
getProcess <- function(processID) {
  tryCatch({
    endpoint <- paste0("/api/v1/process/", processID)
    response <- call_endpoint(method = "GET", endpoint = endpoint)
    message("Process details fetched for ID: ", processID)
    return(response)
  }, error = function(e) {
    stop("Error 1002: Failed to retrieve process with ID ", processID, ": ", e$message)
  })
}

#' Get Process Revisions
#'
#' Fetches all revisions for a given process.
#'
#' @param processID The ID of the process.
#' @return A JSON object containing the revisions.
#' @importFrom httr GET
#' @export
getProcessRevisions <- function(processID) {
  tryCatch({
    endpoint <- paste0("/api/v1/process/", processID, "/revisions")
    response <- call_endpoint(method = "GET", endpoint = endpoint)
    message("Revisions fetched for process ID: ", processID)
    return(response)
  }, error = function(e) {
    stop("Error 1003: Failed to get revisions for process ID ", processID, ": ", e$message)
  })
}

#' Check Process Usage
#'
#' Checks if a process is used in pipelines or runs.
#'
#' @param processID The ID of the process.
#' @return A JSON object indicating usage information.
#' @importFrom httr GET
#' @export
checkProcessUsage <- function(processID) {
  tryCatch({
    endpoint <- paste0("/api/v1/process/", processID, "/is-used")
    response <- call_endpoint(method = "GET", endpoint = endpoint)
    message("Usage information fetched for process ID: ", processID)
    return(response)
  }, error = function(e) {
    stop("Error 1004: Failed to check usage for process ID ", processID, ": ", e$message)
  })
}

#' Duplicate Process
#'
#' Creates a duplicate of an existing process.
#'
#' @param processID The ID of the process to duplicate.
#' @return A JSON object containing the duplicated process details.
#' @importFrom httr POST
#' @export
duplicateProcess <- function(processID) {
  tryCatch({
    endpoint <- paste0("/api/v1/process/", processID, "/duplicate")
    response <- call_endpoint(method = "POST", endpoint = endpoint)
    message("Process duplicated for ID: ", processID)
    return(response)
  }, error = function(e) {
    stop("Error 1005: Failed to duplicate process with ID ", processID, ": ", e$message)
  })
}

#' Create Menu Group
#'
#' Creates a new menu group.
#'
#' @param name The name of the menu group to create.
#' @return A JSON object containing the created menu group details.
#' @importFrom httr POST
#' @export
createMenuGroup <- function(name) {
  tryCatch({
    endpoint <- "/api/v1/menu-group/process"
    payload <- list(name = name)
    response <- call_endpoint(method = "POST", endpoint = endpoint, data = payload)
    message("Menu group created with name: ", name)
    return(response)
  }, error = function(e) {
    stop("Error 1006: Failed to create menu group with name '", name, "': ", e$message)
  })
}

#' List Menu Groups
#'
#' Fetches all menu groups from the API.
#'
#' @return A JSON object containing the list of menu groups.
#' @importFrom httr GET
#' @export
listMenuGroups <- function() {
  tryCatch({
    endpoint <- "/api/v1/menu-group/process"
    response <- call_endpoint(method = "GET", endpoint = endpoint)
    message("Menu groups fetched successfully.")
    return(response)
  }, error = function(e) {
    stop("Error 1007: Failed to list menu groups: ", e$message)
  })
}

#' Update Menu Group
#'
#' Updates the name of an existing menu group.
#'
#' @param menuGroupID The ID of the menu group to update.
#' @param name The new name of the menu group.
#' @return A JSON object containing the updated menu group details.
#' @importFrom httr POST
#' @export
updateMenuGroup <- function(menuGroupID, name) {
  tryCatch({
    endpoint <- paste0("/api/v1/menu-group/process/", menuGroupID)
    payload <- list(name = name)
    response <- call_endpoint(method = "POST", endpoint = endpoint, data = payload)
    message("Menu group updated for ID: ", menuGroupID)
    return(response)
  }, error = function(e) {
    stop("Error 1008: Failed to update menu group with ID ", menuGroupID, ": ", e$message)
  })
}

#' Create a New Process
#'
#' Creates a new process using the provided data.
#'
#' @param processData A list containing the process data.
#' @return A JSON object containing the created process details.
#' @importFrom httr POST
#' @export
createProcess <- function(processData) {
  tryCatch({
    endpoint <- "/api/v1/process"
    response <- call_endpoint(method = "POST", endpoint = endpoint, data = processData)
    message("Process created successfully.")
    return(response)
  }, error = function(e) {
    stop("Error 1009: Failed to create a new process: ", e$message)
  })
}

#' Update a Process
#'
#' Updates an existing process with the given data.
#'
#' @param processID The ID of the process to update.
#' @param processData A list containing the updated process data.
#' @return A JSON object containing the updated process details.
#' @importFrom httr PUT
#' @export
updateProcess <- function(processID, processData) {
  tryCatch({
    endpoint <- paste0("/api/v1/process/", processID)
    response <- call_endpoint(method = "PUT", endpoint = endpoint, data = processData)
    message("Process updated for ID: ", processID)
    return(response)
  }, error = function(e) {
    stop("Error 1010: Failed to update process with ID ", processID, ": ", e$message)
  })
}

#' Delete a Process
#'
#' Deletes a specific process by its ID.
#'
#' @param processID The ID of the process to delete.
#' @return A confirmation message.
#' @importFrom httr DELETE
#' @export
deleteProcess <- function(processID) {
  tryCatch({
    endpoint <- paste0("/api/v1/process/", processID)
    response <- call_endpoint(method = "DELETE", endpoint = endpoint)
    message("Process deleted for ID: ", processID)
    return(response)
  }, error = function(e) {
    stop("Error 1011: Failed to delete process with ID ", processID, ": ", e$message)
  })
}

#' Create Process Config
#'
#' Assembles a complete process configuration object.
#'
#' @param name Name of the process.
#' @param menuGroupName Name of the menu group.
#' @param inputParams A list of input parameter specs.
#' @param outputParams A list of output parameter specs.
#' @param summary Optional. Summary string.
#' @param scriptBody Optional. Script body.
#' @param scriptLanguage Optional. Language (default "bash").
#' @param scriptHeader Optional. Script header.
#' @param scriptFooter Optional. Script footer.
#' @param permissionSettings Optional. A list of permission settings.
#' @param revisionComment Optional. Revision comment.
#' @return A list representing the full process config.
#' @export
createProcessConfig <- function(
    name,
    menuGroupName,
    inputParams,
    outputParams,
    summary = "",
    scriptBody = "",
    scriptLanguage = "bash",
    scriptHeader = "",
    scriptFooter = "",
    permissionSettings = list(viewPermissions = 3, writeGroupIds = list()),
    revisionComment = "Initial revision"
) {
  menuGroupID <- getMenuGroupByName(menuGroupName)
  
  if (is.null(menuGroupID)) {
    created <- createMenuGroup(menuGroupName)
    menuGroupID <- created$id
  }
  
  processParameter <- function(param) {
    matches <- filterParameters(
      name = param$name,
      qualifier = param$qualifier,
      fileType = param$fileType,
      id = param$id
    )
    if (length(matches) == 0) {
      createParameter(list(
        name = param$name,
        qualifier = param$qualifier,
        fileType = param$fileType
      ))
      matches <- filterParameters(
        name = param$name,
        qualifier = param$qualifier,
        fileType = param$fileType,
        id = param$id
      )
    }
    p <- matches[[1]]
    return(list(
      parameterId = p$id,
      displayName = param$displayName %||% p$name,
      operator = param$operator %||% "",
      operatorContent = param$operatorContent %||% "",
      optional = param$optional %||% FALSE,
      test = param$test %||% ""
    ))
  }
  
  config <- list(
    name = name,
    menuGroupId = menuGroupID,
    summary = summary,
    inputParameters = lapply(inputParams, processParameter),
    outputParameters = lapply(outputParams, processParameter),
    script = list(
      body = scriptBody,
      header = scriptHeader,
      footer = scriptFooter,
      language = scriptLanguage
    ),
    permissionSettings = permissionSettings,
    revisionComment = revisionComment
  )
  
  return(config)
}

#' Get Pipeline Parameters
#'
#' Retrieves the list of parameters for a specific pipeline.
#'
#' @param pipelineID The ID of the pipeline.
#' @return A JSON object containing the list of parameters.
#' @importFrom httr GET
#' @export
getPipelineParameters <- function(pipelineID) {
  tryCatch({
    endpoint <- paste0("/api/run/v1/pipeline/", pipelineID, "/parameter-list")
    response <- call_endpoint(method = "GET", endpoint = endpoint)
    message("Parameters fetched for pipeline ID: ", pipelineID)
    return(response)
  }, error = function(e) {
    stop("Error 1012: Failed to get parameters for pipeline ID ", pipelineID, ": ", e$message)
  })
}

#' List All Parameters
#'
#' Fetches all parameters from the API.
#'
#' @return A JSON object containing the list of parameters.
#' @importFrom httr GET
#' @export
listParameters <- function() {
  tryCatch({
    endpoint <- "/api/parameter/v1"
    response <- call_endpoint(method = "GET", endpoint = endpoint)
    message("Parameters fetched successfully.")
    return(response)
  }, error = function(e) {
    stop("Error 1013: Failed to list parameters: ", e$message)
  })
}

#' Create a Parameter
#'
#' Creates a new parameter with the given data.
#'
#' @param parameterData A list containing the parameter data.
#' @return A JSON object containing the created parameter details.
#' @importFrom httr POST
#' @export
createParameter <- function(parameterData) {
  tryCatch({
    endpoint <- "/api/parameter/v1"
    response <- call_endpoint(method = "POST", endpoint = endpoint, data = parameterData)
    message("Parameter created successfully.")
    return(response)
  }, error = function(e) {
    stop("Error 1014: Failed to create a new parameter: ", e$message)
  })
}

#' Update a Parameter
#'
#' Updates an existing parameter with the provided data.
#'
#' @param parameterID The ID of the parameter to update.
#' @param parameterData A list containing the updated parameter data.
#' @return A JSON object containing the updated parameter details.
#' @importFrom httr POST
#' @export
updateParameter <- function(parameterID, parameterData) {
  tryCatch({
    endpoint <- paste0("/api/parameter/v1/", parameterID)
    response <- call_endpoint(method = "POST", endpoint = endpoint, data = parameterData)
    message("Parameter updated for ID: ", parameterID)
    return(response)
  }, error = function(e) {
    stop("Error 1015: Failed to update parameter with ID ", parameterID, ": ", e$message)
  })
}

#' Delete a Parameter
#'
#' Deletes a specific parameter by its ID.
#'
#' @param parameterID The ID of the parameter to delete.
#' @return A confirmation message.
#' @importFrom httr DELETE
#' @export
deleteParameter <- function(parameterID) {
  tryCatch({
    endpoint <- paste0("/api/parameter/v1/", parameterID)
    response <- call_endpoint(method = "DELETE", endpoint = endpoint)
    message("Parameter deleted for ID: ", parameterID)
    return(response)
  }, error = function(e) {
    stop("Error 1016: Failed to delete parameter with ID ", parameterID, ": ", e$message)
  })
}

#' Filter Parameters
#'
#' Filters parameters by name, qualifier, file type, and/or ID.
#'
#' @param name Optional. Name to filter.
#' @param qualifier Optional. Qualifier to filter.
#' @param fileType Optional. File type to filter.
#' @param id Optional. ID to filter.
#' @return A list of filtered parameters.
#' @export
filterParameters <- function(name = NULL, qualifier = NULL, fileType = NULL, id = NULL) {
  tryCatch({
    response <- listParameters()
    parameters <- if (!is.null(response$data)) response$data else list()
    filtered <- Filter(function(param) {
      if (!is.null(name) && !grepl(tolower(name), tolower(param$name))) return(FALSE)
      if (!is.null(qualifier) && tolower(qualifier) != tolower(param$qualifier)) return(FALSE)
      if (!is.null(fileType) && tolower(fileType) != tolower(param$fileType)) return(FALSE)
      if (!is.null(id) && id != as.character(param$id)) return(FALSE)
      return(TRUE)
    }, parameters)
    
    for (param in filtered) {
      message(sprintf("ID: %s, Name: %s, Qualifier: %s, FileType: %s", 
                      param$id, param$name, param$qualifier %||% "", param$fileType %||% ""))
    }
    
    return(filtered)
  }, error = function(e) {
    message("Error filtering parameters: ", e$message)
    return(list())
  })
}

#' Get Menu Group by Name
#'
#' Searches for a menu group by name and returns its ID.
#'
#' @param groupName The name of the menu group.
#' @return The ID of the menu group if found, otherwise NULL.
#' @export
getMenuGroupByName <- function(groupName) {
  tryCatch({
    response <- listMenuGroups()
    groups <- response$data
    for (group in groups) {
      if (tolower(group$name) == tolower(groupName)) {
        return(group$id)
      }
    }
    return(NULL)
  }, error = function(e) {
    message("Error finding menu group: ", e$message)
    return(NULL)
  })
}