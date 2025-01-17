# `Via Foundry R SDK`

`viafoundry` is an R package for interacting with the Via Foundry API. It provides functions for user authentication, dynamic endpoint discovery, and executing API calls.

## Features
- **Authentication**: Log in to the Via Foundry API using your credentials.
- **Dynamic API Discovery**: List all available API endpoints.
- **Custom API Calls**: Send HTTP requests to any endpoint with parameters or payloads.

---

## Installation

### Development Version
You can install the package directly from the source using `devtools`:

```R

# Install the viafoundry package
install.packages("viafoundry")

# Or

# Install devtools if not already installed
install.packages("devtools")

# Install the viafoundry package
devtools::install_github("viascientific/viafoundry-R-SDK")
```

## Getting Started

### Authentication

Before interacting with the API, you need to authenticate and store your credentials. 
Once authentication is done it will put token into `~/.viaenv` file, you don't need to re-authenticate.

Use the authenticate() function:

```R
library(viafoundry)

# Authenticate and save the token
authenticate(
    hostname = "https://your_foundry_server",
    username = "username",
    password = "password",
    config_path = "~/.viaenv",
    overwrite = TRUE
)
```
or use authenticate() function it will ask the information needed for authentication

```R
library(viafoundry)
authenticate()
```

### Configuration File
The viafoundry package uses a configuration file `(~/.viaenv)` to store the `hostname` and token. Example:

```R

{
    "hostname": "http://localhost",
    "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
}

```

### Listing Available Endpoints

You can list all available API endpoints using the list_endpoints() function:

```R
library(viafoundry)
# Fetch and display available endpoints
endpoints <- discover()
print(endpoints)

```

### Calling an API Endpoint

To interact with a specific API endpoint, use the call_endpoint() function:


```R
library(viafoundry)
# Call an API endpoint
response <- call_endpoint(
    method = "GET",
    endpoint = "/api/v1/process",     # Replace with your desired endpoint
    params = list(key = "value"),   # Optional query parameters
    data = NULL                     # Optional payload for POST/PUT
)

# Print the API response
print(response)
```


### Example workflow

```R

library(viafoundry)

# Step 1: Authenticate
authenticate()

# Step 2: List all available endpoints
endpoints <- discover()
print("Available endpoints:")
print(endpoints)

# Step 3: Call a specific endpoint
response <- call_endpoint(
    method = "GET",
    endpoint = "/api/v1/process"
)
print("API response:")
print(response)


```

### Accessing the reports and load files

You can access any files in the report section using `SDK`
```R

library(viafoundry)
#get report id from Via Foundry

reportID <- 1 

# Fetch the report 
report <- fetchReportData(reportID)

# Get all processes belong to the report
getProcessNames(report)

# Select the file from a process or a module 
getFileNames(report, "RSEM_module")

# Load a specific file
rsem_data <- loadFile(report, "RSEM_module", "genes_expression_expected_count.tsv")
head(rsem_data)

```
You can access any files in the report section using `SDK`
```R

library(viafoundry)
#get report id from Via Foundry

reportID <- 1 

# Fetch the report 
report <- fetchReportData(reportID)

getAllFileNames(report)

# Choose a file from the list, if the extension is not tsv, csv, or txt, the file will be downloaded. you can define download directory

loadFile(report, "DE_module_RSEM", "control_vs_exper_des.Rmd")

```

### Uploading files to the reports section in Foundry

You can first get the available directories in report and upload the files to those directories. After 
creating new plots(e.g png, pdf) or would like to upload some analysis code to organize the data within the 
report section you can use this method.

```R

library(viafoundry)
#get report id from Via Foundry
reportID <- 1 

getReportDirs(1) # [1] "summary"       "multiqc"     "multiqc"  etc.

response <- uploadReportFile(1, "FILE_LOCATION", dir="summary") # Change the file location

print(response)
```


## Troubleshooting

### Common Issues

	1.	Authentication Fails:
   	-	Verify your `username`, `password`, and `hostname`.
	  -	Check if the token in the `~/.viaenv` file is expired.
	2.	API Call Fails:
  	-	Ensure the endpoint exists and you have the necessary permissions.
  	-	Check the API documentation for the correct method and parameters.
	3.	Server Returns HTML Instead of JSON:
  	-	Ensure the Accept: application/json header is sent with requests. This is handled automatically by the package.
  4. If you want to re-authenticate remove the `viaenv` file (e.g `~/.viaenv`) 
