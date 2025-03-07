<#
 verify-payload will verify the signature of the signed payload
 in the ./signing/signed_output.txt file.  It'll use the first
 key within the ./well-known/jwks.json file. Therefore, make
 sure its public key corresponds to the sign-payload private key
#>

# Define paths
$JwksPath = "./well-known/jwks.json"
$SignedDataPath = "./signing/signed_output.txt"


# Read the signed data
$signedData = Get-Content -Path $SignedDataPath -Raw -ErrorAction Stop
$data, $signatureBase64 = $signedData.Split('|')
$signature = [System.Convert]::FromBase64String($signatureBase64)

# Read and parse the JWKS file
$jwksJson = Get-Content -Path $JwksPath -Raw -ErrorAction Stop | ConvertFrom-Json
$key = $jwksJson.keys[0] # Assuming we're using the first key in the set

# Validate JWKS entry
if ($key.kty -ne "RSA") {
    throw "JWKS key type must be RSA"
}

# Convert Base64Url to Base64 and then to bytes
function ConvertFrom-Base64Url {
    param ([string]$base64Url)
    $base64 = $base64Url -replace '-', '+' -replace '_', '/'
    $padding = (4 - ($base64.Length % 4)) % 4
    $base64 += '=' * $padding
    return [System.Convert]::FromBase64String($base64)
}

$modulusBytes = ConvertFrom-Base64Url $key.n
$exponentBytes = ConvertFrom-Base64Url $key.e

# Create RSA object and import parameters
$rsa = [System.Security.Cryptography.RSA]::Create()
$rsaParams = [System.Security.Cryptography.RSAParameters]::new()
$rsaParams.Modulus = $modulusBytes
$rsaParams.Exponent = $exponentBytes
$rsa.ImportParameters($rsaParams)

# Convert data to bytes
$dataBytes = [System.Text.Encoding]::UTF8.GetBytes($data)

# Verify signature
$isValid = $rsa.VerifyData($dataBytes, 
                            $signature, 
                            [System.Security.Cryptography.HashAlgorithmName]::SHA256, 
                            [System.Security.Cryptography.RSAsignaturePadding]::Pkcs1)

# Output results
Write-Output "Verification Result:"
Write-Output "Original Data: $data"
Write-Output "Key ID (kid): $($key.kid)"
Write-Output "Signature Valid: $isValid"

if ($isValid) {
    Write-Host "The signature is valid and the data has not been tampered with." -ForegroundColor Green
} else {
    Write-Host "WARNING: The signature is invalid or the data has been modified!" -ForegroundColor Red
}


if ($rsa) { $rsa.Dispose() }
