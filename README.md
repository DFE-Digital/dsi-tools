# dsi-tools

## jwks-tools

Used for managing JWKS for localhost development, and comprises of four powershell scripts.

1. `generate-keys` for generating a new private key to ./keys/private_key.pem, and adding a JWK entry to ./well-known/jwks.json
2. `remove-old-keys` for removing any keys within ./well-known/jwks.json that are older than 30 days
3. `sign-payload` is used for signing of a payload to ./signing/signed_output.txt
4. `verify-payload` is used to validate the integrity of a signed payload from ./signing/signed_output.txt


## Use proxy to connect to Node components on Mac

There is a limitation on Mac where TLS 1.3 is not supported which means that any HTTP request to mid-tier services will fail.

To workaround this the `node-proxy` can be used:

1. Run the proxy with `node ./node-proxy/proxy.js`.

2. Configure application to use the proxy.


## Use proxy to connect to Public API

Since the public API is spread across two technologies (Node.js and .NET) it is often useful to setup a local development environment to send some requests to one instance of the Public API whilst sending all other requests to another.

1. Configure path maapings as needed in `./node-proxy/public-api-proxy.js`.

2. Run the proxy with `node ./node-proxy/public-api-proxy.js`.

3. Configure application to use the proxy to Public API.


## Script: Connecting to a development environment

Ensure that the following secrets are set manually so that `RetrieveUserSecrets.ps` can connect to KeyVault to retrieve application specific configurations:

```pwsh
dotnet user-secrets set d01:TenantId "<secret>" --id login.dfe.dsi-config
dotnet user-secrets set d01:ApplicationId "<secret>" --id login.dfe.dsi-config
dotnet user-secrets set d01:SecurePassword "<secret>" --id login.dfe.dsi-config
```

Retrieve secrets to connect into the hosted development environments:

```pwsh
./user-secrets/RetrieveUserSecrets.ps1 -EnvId d01
```

## Script: Generate fresh Public API keys for use locally

This is useful when running components locally without connecting into a hosted development environment.

```pwsh
./user-secrets/GeneratePublicApiKeys.ps1
```

## Script: Generate authorization bearer token for Public API

This script generates a bearer token for use with the DfE Sign-in Public API which takes the `clientId` and `apiSecret` of a service.

Usage example:

```pwsh
./public-api/GenerateAuthorizationToken.ps1 -clientId "ExampleClient" -apiSecret "example-api-secret"
```
