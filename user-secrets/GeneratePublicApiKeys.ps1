$ErrorActionPreference = "Stop"

$userSecretsId = ""

function SetUserSecret {
    param(
        [string]$localKey,
        [string]$secret
    )
    Write-Output "Setting user secret '$localKey'..."
    dotnet user-secrets set $localKey $secret --id $userSecretsId > $null
}

Write-Output "Generating public keys for Public API..."
./jwks-tools/GenerateKeys.ps1
$privateKeyPem = Get-Content -Path "./jwks-tools/keys/private_key.pem"
$publicKeysJson = Get-Content -Path "./jwks-tools/well-known/jwks.json"
$publicKeyId = New-Guid

Write-Output "Setup: Public API..."
$userSecretsId = "9cf57240-a4e9-44b7-8c09-922da90f69eb"
SetUserSecret "Application:PublicKeysJson" $publicKeysJson

Write-Output "Setup: Select Organisation..."
$userSecretsId = "9bc1d9ef-36ce-492e-876f-6d80fe79896c"
SetUserSecret "PublicApiSigning:PrivateKeyPem" $privateKeyPem
SetUserSecret "PublicApiSigning:PublicKeyId" $publicKeyId
SetUserSecret "PublicApiSigning:Algorithm" "SHA256"
SetUserSecret "PublicApiSigning:Padding" "pkcs1"
