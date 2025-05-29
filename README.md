# dsi-tools

## Setup tooling

Run the following script to ensure that the required tooling is installed and is up-to-date:

```pwsh
./Install-Tooling.ps1
```

> **WARNING** - The above script makes changes to the user PowerShell profile located at the path `~/.config/powershell/Microsoft.PowerShell_profile.ps1`.

The cmdlets module is added to the user PowerShell profile which means that the various commands that are presented in this README.md file can be used when starting a new PowerShell session.


## Tip for developers working on the cmdlets

It is useful to re-import the cmdlets module when editing on the cmdlets.

Cmdlets can be re-imported into an existing PowerShell session with the following command:

```pwsh
Import-Module -Name ./cmdlets/Module -Force
```


## Connecting to the development environment

Connect to (or switch to a different) the development environment:

```pwsh
Connect-DsiEnv -Name DEV
```

Follow the on-screen instructions to connect with your Azure account.

Import secrets to connect to the hosted environment:

```pwsh
Import-DsiSecrets
```

Import test data for the development environment:

```pwsh
Import-DsiTestData
```

Disconnect when you are finished:

```pwsh
Disconnect-DsiEnv
```


## Clearing all local user secrets

Clear user secrets for all .NET projects:

```pwsh
Clear-DsiSecrets
```

You will be prompted to confirm; type 'yes' to confirm, or 'no' to abort.

> **WARNING** - User secrets will be deleted for all tracked DfE Sign-in .NET projects. This operation cannot be reversed.


## Getting help for the various commands

The cmdlets in this repository make use of the standard help comments feature of PowerShell.

For example, to get help for the `Connect-DsiEnv` command:

```pwsh
Help Connect-DsiEnv
```


## Generate authorization bearer token for Public API

This script generates a bearer token for use with the DfE Sign-in Public API which takes the `ClientId` and `ApiSecret` of a service.

Usage example:

```pwsh
New-DsiPublicApiToken -ClientId "ExampleClient" -ApiSecret "example-api-secret"
```


## MacOS - Use proxy to connect to hosted APIs

There is a limitation on Mac where TLS 1.3 is not supported which means that any HTTP request to mid-tier services will fail.

To workaround this the `node-proxy` can be used:

```pwsh
Start-DsiTlsProxy
```

> **NOTE** - The application needs to be configured to use the proxy.


## Use proxy to connect to Public API

Since the public API is spread across two technologies (Node.js and .NET) it is often useful to setup a local development environment to send some requests to one instance of the Public API whilst sending all other requests to another.

Configure path mappings as needed in `./cmdlets/public-api/PublicApiProxy.js`.

Run the proxy:

```pwsh
Start-DsiPublicApiProxy
```

> **NOTE** - The application needs to be configured to use the proxy.
