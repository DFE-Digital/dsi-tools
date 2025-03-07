<#
 sign-payload will output to a file "hello world" followed by a pipe (|)
 and the signature of the payload; this will be written to ./signing/signed_output.txt
 The private_key.pem will be used for the signing.
#>

# Define paths
$privateKeyPath = "./keys/private_key.pem"
$signedOutput = "./signing/signed_output.txt"

# Read the private key from the PEM file
$privateKeyPem = Get-Content -Path $privateKeyPath -Raw

# Remove PEM header/footer and convert from Base64
$keyContent = $privateKeyPem -replace '-----BEGIN PRIVATE KEY-----', '' `
                            -replace '-----END PRIVATE KEY-----', '' `
                            -replace '\s+', ''
$keyBytes = [System.Convert]::FromBase64String($keyContent)

# Create RSA object and import the private key
$rsa = [System.Security.Cryptography.RSA]::Create()
$rsa.ImportPkcs8PrivateKey($keyBytes, [ref]$null)

# String to sign
$data = "hello world"
$bytesToSign = [System.Text.Encoding]::UTF8.GetBytes($data)

# Create the signature using RS256
$signature = $rsa.SignData($bytesToSign, [System.Security.Cryptography.HashAlgorithmName]::SHA256, [System.Security.Cryptography.RSAsignaturePadding]::Pkcs1)
$signatureBase64 = [System.Convert]::ToBase64String($signature)

# Combine original string and signature with pipe
$result = "$data|$signatureBase64"

# Output the result
# Write-Output "Signed result:"
# Write-Output $result

# Save to file
$result | Out-File $signedOutput -Encoding UTF8

# Clean up
$rsa.Dispose()

Write-Output "Signature saved to $signedOutput"