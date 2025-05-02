param (
    [string]$clientId,
    [string]$apiSecret,
    [string]$audience = "signin.education.gov.uk"
)

function Normalize-HmacSha256Key {
    param (
        [byte[]]$keyBytes
    )

    if ($keyBytes.Length -lt 32) {
        $paddedKey = New-Object byte[] 32
        [Array]::Copy($keyBytes, 0, $paddedKey, 0, $keyBytes.Length)
        return $paddedKey
    }

    return $keyBytes
}

function ConvertTo-Base64Url {
    param ([byte[]]$bytes)
    $base64 = [System.Convert]::ToBase64String($bytes)
    $base64Url = $base64.TrimEnd('=') -replace '\+', '-' -replace '/', '_'
    return $base64Url
}

$headerBytes = [System.Text.Encoding]::UTF8.GetBytes('{"alg":"HS256","typ":"JWT"}')
$header = ConvertTo-Base64Url $headerBytes
$bodyBytes = [System.Text.Encoding]::UTF8.GetBytes('{"iss":"' + $clientId + '","aud":"' + $audience + '"}')
$body = ConvertTo-Base64Url $bodyBytes

$hmac = New-Object System.Security.Cryptography.HMACSHA256
$hmac.Key = Normalize-HmacSha256Key ([Text.Encoding]::UTF8.GetBytes($apiSecret))
$signatureBytes = $hmac.ComputeHash([System.Text.Encoding]::UTF8.GetBytes("$header.$body"))
$sig = ConvertTo-Base64Url $signatureBytes

Write-Output "$header.$body.$sig"
