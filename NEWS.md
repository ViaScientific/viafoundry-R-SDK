# `Via Foundry R SDK Changelog`

## Version 1.0.1 (2025-01-26)
- Session Save and upload the session to a report section functionalities added 
- Upload/Download from Report section functionalities added
- Added new process management functionalities:
- Added parameter management functions:

## Version 1.0.0 (2024-12-18)
### Initial Release
- Added `authenticate()` function for logging into the Via Foundry API and saving authentication details to `~/.viaenv`.
- Implemented `discover()` function to fetch available API endpoints from Swagger documentation.
- Introduced `call_endpoint()` function for sending API requests with support for GET, POST, PUT, and DELETE methods.
- Automatic handling of the authentication token via cookies.
- Configurable `hostname` and token management with persistent storage in `~/.viaenv`.

## Version 0.1.1 (Unreleased)
### Improvements
- Improved error handling for expired tokens, including re-authentication prompts.
- Enhanced debugging support with detailed logs for API requests and responses.

### Bug Fixes
- Fixed a bug where invalid configuration files would cause the package to crash.
- Corrected handling of `non-JSON` responses from `/api-docs`.

## Version 0.2.0 (Planned)
### New Features
- Add support for uploading files to the API.
- Introduce a caching mechanism for Swagger documentation.
- Provide a `CLI` wrapper for the package via the `foundry` binary, which can be installed with `pip install viafoundry-SDK`.
