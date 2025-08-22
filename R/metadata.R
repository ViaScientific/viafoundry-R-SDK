# ----------------------------
# canvas Functions
# ----------------------------

#' Search canvas
#'
#' @param searchParams A named list of search filters.
#' @return A JSON object with canvas search results.
#' @examples
#'  \dontrun{
#' search_params <- list(
#'   filter = list(
#'     name="new_canvas"
#'   )
#' )
#' canvas <- searchCanvas(search_params)
#' print(canvas)
#' }
#' @export
searchCanvas <- function(searchParams = list(filter = list())) {
  tryCatch({
    endpoint <- "/api/v1/vmeta/canvas/search"
    response <- call_endpoint("POST", endpoint, data = searchParams)
    message("Canvas fetched successfully.")
    return(response)
  }, error = function(e) {
    stop("Error 2001: Failed to search canvas: ", e$message)
  })
}

#' Create Canvas
#'
#' @param canvasData A named list with canvas details.
#' @return A JSON object with the created canvas.
#' @examples
#' \dontrun{
#' canvasData <- list(
#'   name = "new_canvas",
#'   label = "New canvas"
#' )
#' createCanvas(canvasData)
#' }
#' @export
createCanvas <- function(canvasData) {
  tryCatch({
    endpoint <- "/api/v1/vmeta/canvas/create"
    response <- call_endpoint("POST", endpoint, data = canvasData)
    message("canvas created successfully.")
    return(response)
  }, error = function(e) {
    stop("Error 2002: Failed to create canvas: ", e$message)
  })
}

#' Get canvas
#'
#' @param canvasID A character string with canvas ID.
#' @return A JSON object with canvas details.
#' @examples
#' \dontrun{
#' canvasData <- list(
#'   name = "new_canvas",
#'   label = "New canvas"
#' )
#' createCanvas(canvasData)
#' search_params <- list(
#' filter = list(
#'  name="new_canvas"
#' )
#' )
#' canvas <- searchCanvas(search_params)
#' getCanvas(canvas$data$`_id`[1])
#' 
#' }
#' @export
getCanvas <- function(canvasID) {
  tryCatch({
    endpoint <- paste0("/api/v1/vmeta/canvas/", canvasID)
    response <- call_endpoint("GET", endpoint)
    message("canvas details fetched for ID: ", canvasID)
    return(response)
  }, error = function(e) {
    stop("Error 2003: Failed to get canvas ", canvasID, ": ", e$message)
  })
}

#' Update canvas
#'
#' @param canvasID A character string with canvas ID.
#' @param updateData A named list of canvas updates.
#' @return A JSON object with updated canvas.
#' @export
updateCanvas <- function(canvasID, updateData) {
  tryCatch({
    endpoint <- paste0("/api/v1/vmeta/canvas/", canvasID)
    response <- call_endpoint("PATCH", endpoint, data = updateData)
    message("canvas updated for ID: ", canvasID)
    return(response)
  }, error = function(e) {
    stop("Error 2004: Failed to update canvas ", canvasID, ": ", e$message)
  })
}

#' Delete canvas
#'
#' @param canvasID A character string with canvas ID.
#' @return A confirmation object or message.
#' 
#' @examples
#'  \dontrun{
#' canvasData <- list(
#'   name = "new_canvas",
#'   label = "New canvas"
#' )
#' createCanvas(canvasData)
#' search_params <- list(
#' filter = list(
#'  name="new_canvas"
#' )
#' )
#' canvas <- searchCanvas(search_params)
#' deleteCanvas(canvas$data$`_id`[1])
#' }
#' @export
deleteCanvas <- function(canvasID) {
  tryCatch({
    endpoint <- paste0("/api/v1/vmeta/canvas/", canvasID)
    response <- call_endpoint("DELETE", endpoint)
    message("canvas deleted for ID: ", canvasID)
    return(response)
  }, error = function(e) {
    stop("Error 2005: Failed to delete canvas ", canvasID, ": ", e$message)
  })
}

# ----------------------------
# Collection Functions
# ----------------------------

#' Search Collections
#'
#' @param searchParams A named list of search filters.
#' @return A JSON object with collection search results.
#' @export
searchCollections <- function(searchParams = list(filter = list())) {
  tryCatch({
    endpoint <- "/api/v1/vmeta/collection/search"
    response <- call_endpoint("POST", endpoint, data = searchParams)
    message("Collections fetched successfully.")
    return(response)
  }, error = function(e) {
    stop("Error 2011: Failed to search collections: ", e$message)
  })
}

#' Create Collection
#'
#' @param collectionData A named list with collection details.
#' @return A JSON object with the created collection.
#' @export
createCollection <- function(collectionData) {
  tryCatch({
    endpoint <- "/api/v1/vmeta/collection/create"
    response <- call_endpoint("POST", endpoint, data = collectionData)
    message("Collection created successfully.")
    return(response)
  }, error = function(e) {
    stop("Error 2012: Failed to create collection: ", e$message)
  })
}

#' Get Collection
#'
#' @param collectionID A character string with collection ID.
#' @return A JSON object with collection details.
#' @export
getCollection <- function(collectionID) {
  tryCatch({
    endpoint <- paste0("/api/v1/vmeta/collection/", collectionID)
    response <- call_endpoint("GET", endpoint)
    message("Collection details fetched for ID: ", collectionID)
    return(response)
  }, error = function(e) {
    stop("Error 2013: Failed to get collection ", collectionID, ": ", e$message)
  })
}

#' Update Collection
#'
#' @param collectionID A character string with collection ID.
#' @param updateData A named list of collection updates.
#' @return A JSON object with updated collection.
#' @export
updateCollection <- function(collectionID, updateData) {
  tryCatch({
    endpoint <- paste0("/api/v1/vmeta/collection/", collectionID)
    response <- call_endpoint("PATCH", endpoint, data = updateData)
    message("Collection updated for ID: ", collectionID)
    return(response)
  }, error = function(e) {
    stop("Error 2014: Failed to update collection ", collectionID, ": ", e$message)
  })
}

#' Delete Collection
#'
#' @param collectionID A character string with collection ID.
#' @return A confirmation object or message.
#' @export
deleteCollection <- function(collectionID) {
  tryCatch({
    endpoint <- paste0("/api/v1/vmeta/collection/", collectionID)
    response <- call_endpoint("DELETE", endpoint)
    message("Collection deleted for ID: ", collectionID)
    return(response)
  }, error = function(e) {
    stop("Error 2015: Failed to delete collection ", collectionID, ": ", e$message)
  })
}

# ----------------------------
# Field Functions
# ----------------------------

#' Search Fields
#'
#' @param searchParams A named list of search filters.
#' @return A JSON object with field search results.
#' @export
searchFields <- function(searchParams = list(filter = list())) {
  tryCatch({
    endpoint <- "/api/v1/vmeta/field/search"
    response <- call_endpoint("POST", endpoint, data = searchParams)
    message("Fields fetched successfully.")
    return(response)
  }, error = function(e) {
    stop("Error 2021: Failed to search fields: ", e$message)
  })
}

#' Create Field
#'
#' @param fieldData A named list with field details.
#' @return A JSON object with the created field.
#' @export
createField <- function(fieldData) {
  tryCatch({
    endpoint <- "/api/v1/vmeta/field/create"
    response <- call_endpoint("POST", endpoint, data = fieldData)
    message("Field created successfully.")
    return(response)
  }, error = function(e) {
    stop("Error 2022: Failed to create field: ", e$message)
  })
}

#' Get Field
#'
#' @param fieldID A character string with field ID.
#' @return A JSON object with field details.
#' @export
getField <- function(fieldID) {
  tryCatch({
    endpoint <- paste0("/api/v1/vmeta/field/", fieldID)
    response <- call_endpoint("GET", endpoint)
    message("Field details fetched for ID: ", fieldID)
    return(response)
  }, error = function(e) {
    stop("Error 2023: Failed to get field ", fieldID, ": ", e$message)
  })
}

#' Update Field
#'
#' @param fieldID A character string with field ID.
#' @param updateData A named list of field updates.
#' @return A JSON object with updated field.
#' @export
updateField <- function(fieldID, updateData) {
  tryCatch({
    endpoint <- paste0("/api/v1/vmeta/field/", fieldID)
    response <- call_endpoint("PATCH", endpoint, data = updateData)
    message("Field updated for ID: ", fieldID)
    return(response)
  }, error = function(e) {
    stop("Error 2024: Failed to update field ", fieldID, ": ", e$message)
  })
}

#' Delete Field
#'
#' @param fieldID A character string with field ID.
#' @return A confirmation object or message.
#' @export
deleteField <- function(fieldID) {
  tryCatch({
    endpoint <- paste0("/api/v1/vmeta/field/", fieldID)
    response <- call_endpoint("DELETE", endpoint)
    message("Field deleted for ID: ", fieldID)
    return(response)
  }, error = function(e) {
    stop("Error 2025: Failed to delete field ", fieldID, ": ", e$message)
  })
}

# ----------------------------
# Dataset Functions
# ----------------------------

#' Search Dataset Files
#'
#' Lists files associated with a dataset.
#'
#' @param datasetID The ID of the dataset.
#' @param filterData A named list of filter parameters.
#' @return A JSON object of matching files.
#' @export
searchDatasetFiles <- function(datasetID, filterData = list(filter = list())) {
  tryCatch({
    endpoint <- paste0("/api/v1/vmeta/dataset/", datasetID, "/files/search")
    response <- call_endpoint("POST", endpoint, data = filterData)
    message("Files searched for dataset ID: ", datasetID)
    return(response)
  }, error = function(e) {
    stop("Error 2036: Failed to search dataset files for ", datasetID, ": ", e$message)
  })
}

#' Add Files to Dataset
#'
#' Adds file metadata to a dataset.
#'
#' @param datasetID The dataset ID.
#' @param fileData A named list of file metadata.
#' @return A JSON object confirming file addition.
#' @export
addFilesToDataset <- function(datasetID, fileData) {
  tryCatch({
    endpoint <- paste0("/api/v1/vmeta/dataset/", datasetID, "/addFiles")
    response <- call_endpoint("POST", endpoint, data = fileData)
    message("Files added to dataset ID: ", datasetID)
    return(response)
  }, error = function(e) {
    stop("Error 2037: Failed to add files to dataset ", datasetID, ": ", e$message)
  })
}

# ----------------------------
# Data Functions
# ----------------------------

#' Search Collection Data
#'
#' Searches entries in a metadata collection.
#'
#' @param canvasID The canvas ID.
#' @param collectionName The name of the collection.
#' @param filterData Optional filters.
#' @return A JSON object of matching data entries.
#' @export
searchData <- function(canvasID, collectionName, filterData = list(filter = list())) {
  tryCatch({
    endpoint <- paste0("/api/v1/vmeta/canvas/", canvasID, "/data/", collectionName, "/search/")
    print(endpoint)
    response <- call_endpoint("POST", endpoint, data = filterData)
    #response <- call_endpoint("POST", endpoint)
    message("Data searched in collection: ", collectionName)
    return(response)
  }, error = function(e) {
    stop("Error 2041: Failed to search data for ", collectionName, ": ", e$message)
  })
}

#' Get Data Entry
#'
#' Retrieves a single data record by ID.
#'
#' @param canvasID The canvas ID.
#'
#' @param collectionName The collection name.
#' @param dataID The ID of the data record.
#' @return A JSON object with data entry.
#' @export
getData <- function(canvasID, collectionName, dataID) {
  tryCatch({
    endpoint <- paste0("/api/v1/vmeta/canvas/", canvasID, "/data/", collectionName, "/", dataID)
    response <- call_endpoint("GET", endpoint)
    message("Data entry fetched: ", dataID)
    return(response)
  }, error = function(e) {
    stop("Error 2042: Failed to get data ", dataID, ": ", e$message)
  })
}

#' Update Data Entry
#'
#' Updates an existing data record.
#'
#' @param canvasID The canvas ID.
#' @param collectionName The collection name.
#' @param dataID The ID of the data to update.
#' @param updateData A named list of updates.
#' @return A JSON object with updated entry.
#' @export
updateData <- function(canvasID, collectionName, dataID, updateData) {
  tryCatch({
    endpoint <- paste0("/api/v1/vmeta/canvas/", canvasID, "/data/", collectionName, "/", dataID)
    response <- call_endpoint("PATCH", endpoint, data = updateData)
    message("Data entry updated: ", dataID)
    return(response)
  }, error = function(e) {
    stop("Error 2043: Failed to update data ", dataID, ": ", e$message)
  })
}

#' Delete Data Entry
#'
#' Deletes a data entry by ID.
#'
#' @param canvasID The canvas ID.
#' @param collectionName The collection name.
#' @param dataID The ID of the data entry.
#' @return A JSON confirmation.
#' @export
deleteData <- function(canvasID, collectionName, dataID) {
  tryCatch({
    endpoint <- paste0("/api/v1/vmeta/canvas/", canvasID, "/data/", collectionName, "/", dataID)
    response <- call_endpoint("DELETE", endpoint)
    message("Data entry deleted: ", dataID)
    return(response)
  }, error = function(e) {
    stop("Error 2044: Failed to delete data ", dataID, ": ", e$message)
  })
}

# ----------------------------
# Helper Functions
# ----------------------------


#' Get canvas Fields
#'
#' Retrieves all metadata fields for a given canvas by collecting them from each collection.
#'
#' @param canvasID The ID of the canvas.
#' @return A JSON object with a list of all fields.
#' @export
getCanvasFields <- function(canvasID) {
  tryCatch({
    searchParams <- list(filter = list(canvasID = canvasID))
    collections <- searchCollections(searchParams)
    allFields <- list()
    
    for (collection in collections$data) {
      fields <- getCollectionFields(collection$`_id`)
      if (!is.null(fields$data)) {
        allFields <- append(allFields, fields$data)
      }
    }
    
    return(list(data = allFields))
  }, error = function(e) {
    stop("Error 2027: Failed to get fields for canvas ", canvasID, ": ", e$message)
  })
}

#' Get Collection Fields
#'
#' Retrieves metadata fields by collection ID.
#'
#' @param collectionID The ID of the collection.
#' @return A JSON object with a list of fields.
#' @export
getCollectionFields <- function(collectionID) {
  tryCatch({
    searchParams <- list(filter = list(collectionID = collectionID))
    response <- searchFields(searchParams)
    return(response)
  }, error = function(e) {
    stop("Error 2026: Failed to get fields for collection: ", collectionID, ": ", e$message)
  })
}

#' Get Fields for a Specific Collection in a canvas
#'
#' Given a canvas ID and collection name, returns the metadata fields defined for that collection.
#'
#' @param canvasID The ID of the canvas.
#' @param collectionName The name of the collection (e.g., "surveys").
#' @return A list of field definitions for the collection.
#' @export
getFieldsForCollection <- function(canvasID, collectionName) {
  tryCatch({
    # Step 1: Find all collections for the canvas
    searchParams <- list(filter = list(canvasID = canvasID))
    collections <- searchCollections(searchParams)
    
    # Step 2: Find the matching index in the name vector
    idx <- which(collections$data$name == collectionName)
    
    if (length(idx) == 0) {
      stop("No collection found with name: ", collectionName)
    }
    
    collectionID <- collections$data$`_id`[idx]
    
    # Step 3: Fetch the fields for the collection
    fields <- getCollectionFields(collectionID)
    
    return(fields$data)
    
  }, error = function(e) {
    stop("Error 2044: Failed to get fields for collection '", collectionName, "': ", e$message)
  })
}

