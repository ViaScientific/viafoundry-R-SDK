# ViaFoundry R SDK

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
devtools::install_github("viafoundry")

# Or

# Install devtools if not already installed
install.packages("devtools")

# Install the viafoundry package
devtools::install_github("viascientific/viafoundry-R-SDK")
```

## Getting Started

### Authentication

Before interacting with the API, you need to authenticate and store your credentials. 
Once authentication is done it will put token into ~/.viaenv file, you don't need to re-authenticate.

Use the authenticate() function:

```R
library(viafoundry)

# Authenticate and save the token
authenticate(
    hostname = "https://your_foundry_server",
    username = "username",
    password = "password",
    identity_type = 1,          # Default is 1
    redirect_uri = "http://your_foundry_server/redirect"
)
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
authenticate(
    hostname = "http://your_viafoundry",
    username = "username",
    password = "password"
)

# Step 2: List all available endpoints
endpoints <- list_endpoints()
print("Available endpoints:")
print(endpoints)

# Step 3: Call a specific endpoint
response <- call_endpoint(
    method = "GET",
    endpoint = "/api/projects"
)
print("API response:")
print(response)
```


### Configuration File
The viafoundry package uses a configuration file (~/.viaenv) to store the hostname and token. Example:

```R

{
    "hostname": "http://localhost",
    "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
}
```

This file is automatically created during authentication.

## Troubleshooting

### Common Issues

	1.	Authentication Fails:
	•	Verify your username, password, and hostname.
	•	Check if the token in the ~/.viaenv file is expired.
	2.	API Call Fails:
	•	Ensure the endpoint exists and you have the necessary permissions.
	•	Check the API documentation for the correct method and parameters.
	3.	Server Returns HTML Instead of JSON:
	•	Ensure the Accept: application/json header is sent with requests. This is handled automatically by the package.
