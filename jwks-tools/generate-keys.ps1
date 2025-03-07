<#
 generate-keys is responsible for creating a public and private key,
 the goal of which is to generate a "well-known" jwks file that can
 be used by 3rd parties to varify the signing of a payload by the
 private key. generate-keys will always append new keys to the collection. 
#>

# Define paths
$jwksPath = "./well-known/jwks.json"
$privateKeyPath = "./keys/private_key.pem"
$publicKeyPath = "./keys/public_key.pem"

# Generate RSA key pair (2048-bit key size)
$rsa = [System.Security.Cryptography.RSA]::Create(2048)

# Export private key to PEM format
$privateKeyBytes = $rsa.ExportPkcs8PrivateKey()
$privatePem = "-----BEGIN PRIVATE KEY-----`n" + 
              [System.Convert]::ToBase64String($privateKeyBytes, [Base64FormattingOptions]::InsertLineBreaks) + 
              "`n-----END PRIVATE KEY-----"

# Export public key to PEM format
$publicKeyBytes = $rsa.ExportSubjectPublicKeyInfo()
$publicPem = "-----BEGIN PUBLIC KEY-----`n" + 
             [System.Convert]::ToBase64String($publicKeyBytes, [Base64FormattingOptions]::InsertLineBreaks) + 
             "`n-----END PUBLIC KEY-----"

# Save the key files
$privatePem | Out-File $privateKeyPath -Encoding UTF8
$publicPem | Out-File $publicKeyPath -Encoding UTF8

# Generate JWKS from public key
# Get RSA parameters for JWKS
$rsaParams = $rsa.ExportParameters($false) # false = public key only

# Convert modulus (n) and exponent (e) to Base64Url encoding
function ConvertTo-Base64Url {
    param ([byte[]]$bytes)
    $base64 = [System.Convert]::ToBase64String($bytes)
    $base64Url = $base64.TrimEnd('=') -replace '\+', '-' -replace '/', '_'
    return $base64Url
}

$modulus = ConvertTo-Base64Url $rsaParams.Modulus
$exponent = ConvertTo-Base64Url $rsaParams.Exponent

 # Unix timestamp
 $unixEpoch = [datetime]::UnixEpoch
 $currentUnixTime = [int64](([datetime]::UtcNow - $unixEpoch).TotalSeconds)

 # Create a new key object
$newKey = @{
    kty = "RSA"
    use = "sig"
    alg = "RS256"
    kid = [Guid]::NewGuid().ToString() # Generate unique key ID
    n = $modulus
    e = $exponent
    ed = $currentUnixTime
}

# If jwksPath exists, then append new key, otherwise create
if (Test-Path $jwksPath) {
    $jwks = Get-Content $jwksPath -Raw | ConvertFrom-Json
    $jwks.keys += $newKey
} else {
    $jwks = @{
        keys = @($newKey)
    }
}

# Convert to JSON and save
$jwksJson = $jwks | ConvertTo-Json -Depth 3
$jwksJson | Out-File $jwksPath -Encoding UTF8

# Clean up
$rsa.Dispose()

Write-Host "Keys generated:" -ForegroundColor Green
Write-Output "Private key saved to: $privateKeyPath"
Write-Output "Public key saved to: $publicKeyPath"
Write-Output "JWKS file saved to: $jwksPath"