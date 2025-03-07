# dsi-tools

## jwks-tools
Used for managing JWKS for localhost development, and comprises of four powershell scripts.

1. `generate-keys` for generating a new private key to ./keys/private_key.pem, and adding a JWK entry to ./well-known/jwks.json
2. `remove-old-keys` for removing any keys within ./well-known/jwks.json that are older than 30 days
3. `sign-payload` is used for signing of a payload to ./signing/signed_output.txt
4. `verify-payload` is used to validate the integrity of a signed payload from ./signing/signed_output.txt


## node-proxy (Mac)
dotnet/runtime on a Mac doesn't support TLS 1.3, and therefore, any http request to mid-tier services hosted in Azure will fail. node-proxy can be used which solves this, requiring that any dotnet httpclient based requests are configured accordingly.

```C#
HttpClientHandler httpClientHandler = new HttpClientHandler()
{
    UseProxy = true,
    Proxy = new WebProxy("proxy-url")
};

HttpClient client = new HttpClient(httpClientHandler);
```