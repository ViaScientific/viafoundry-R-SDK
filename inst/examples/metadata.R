library(viafoundry)

# Step 1: Authenticate
authenticate(config_path="/Users/alper/.viaenv")
#authenticate(config_path="/Users/alper/.vialocal")

projectData <- list(
    name = "new_project",
    label = "New Project"
)

createProject(projectData)

search_params <- list(
  filter = list(
    name="vigor_production"
  )
)

project <- searchProjects(search_params)

print(project)
projectID <- project$data$`_id`

collectionName = "patient"
collectionFields <- getFieldsForCollection(projectID = project_id,collectionName = collectionName)
print(collectionFields)
patients <- searchData(projectID = projectID, collectionName = "patient")

searchParams <- list(filter = list(projectID = projectID))
collections <- searchCollections(searchParams)
print(collections)

collectionName = "surveys"
collectionFields <- getFieldsForCollection(projectID = project_id,collectionName = collectionName)

date_fields <- collectionFields %>%
  filter(type == "Date", active == TRUE) %>%
  pull(name)

print(date_fields)

start_date <- format(Sys.Date() - 1000, "%Y-%m-%dT00:00:00Z")

searchParams <- list(
  filter = list(
    inserteddate = start_date  # treated as "inserteddate >= start_date"
  )
)

response <- searchData(
  projectID = projectID,
  collectionName = collectionName,
  filterData = searchParams
)


search_params <- list(
  filter = list(
    participantid = "VIGOR_1566_8"
  )
)

data <- searchData(projectID, "surveys", filterData = search_params)
data <- searchData(projectID, "surveys")

participant_ids <- "bc30fd28-ecf0-4c1b-9f04-b06010e2cb7a"

survey_results <- map_dfr(participant_ids, function(pid) {
  tryCatch({
    res <- searchData(projectID, "surveys", filterData = list(filter = list(participantid = pid)))
    if (length(res) > 0) as_tibble(res) else NULL
  }, error = function(e) {
    message(paste("Failed for", pid, ":", e$message))
    NULL
  })
})

result <- purrr::map_dfr(participant_ids, function(pid) {
  tryCatch({
    searchData(projectID, "surveys", filterData = list(filter = list(participantid = pid))) %>%
      as_tibble()
  }, error = function(e) NULL)
})

search_params <- list(
  filter = list(
    patient_id = "VIGOR_1566_8"
  )
)


patients <- searchData(projectID = projectID, collectionName = "patient", filterData = search_params)

