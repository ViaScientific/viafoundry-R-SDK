library(viafoundry)

# Step 1: Authenticate
#authenticate(config_path="/Users/alper/.viaprod")
authenticate()

endpoints <- discover()
print("Available endpoints:")
print(endpoints)

#get report id from Via Foundry
a <- call_endpoint("GET", "/api/v1/process")

a <- call_endpoint("GET", "/api/project/v1/2/runs")
#reportID <- 2523
reportID <- 1

# Fetch the report 
report <- fetchReportData(reportID)

# Get all processes belong to the report
getProcessNames(report)

# Select the file from a process or a module 
getFileNames(report, "RSEM_module")

# Load a specific file
rsem_data <- loadFile(report, "RSEM_module", "genes_expression_expected_count.tsv")
dat <- data.frame(rsem_data)
rownames(dat) <- dat$gene
head(dat)
dim(dat)

# List processes
processes <- listProcesses()
print(processes)

# Get report directories to upload
getReportDirs(reportID)
response <- uploadReportFile(1, "~/Downloads/plot.png", "summary")
#response <- uploadReportFile(2523, "~/Desktop/test.txt", "summary")

# Prepare history file
history_file <- prepareSessionHistory()
print(paste("Session history saved to:", history_file))

# Upload the history file to the report section of a run
uploadSessionHistory(1, "summary")


