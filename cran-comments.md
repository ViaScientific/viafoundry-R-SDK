## Test Environments
* Local machine, R version 4.3.0 (macOS Ventura)
* Windows 10, R version 4.3.0 (via win-builder)
* Ubuntu 22.04, R version 4.3.0
* R-devel (pre-release), R version 4.4.0 (via macOS Ventura)

## R CMD check results
There were no ERRORs, WARNINGs, or NOTEs.

## Downstream Dependencies
This is the initial submission of the `foundry` package to CRAN, so there are no reverse dependencies.

## Notes
* All examples in the package are wrapped with `\dontrun{}` as they require authentication and a working API server.

## Resubmission Notes (if applicable)
* This is a resubmission. In this version:
  - Description and Title changed
  - Addressed spelling errors in documentation.
  - Improved error handling for expired tokens in the `authenticate()` function.
