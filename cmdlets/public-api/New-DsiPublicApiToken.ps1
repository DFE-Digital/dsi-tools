function New-DsiPublicApiToken {
<#
    .SYNOPSIS
        Create an authorization token to use when using the DfE Sign-in Public API.

    .PARAMETER ClientId
        The client ID.

    .PARAMETER ApiSecret
        The API secret.

    .PARAMETER Audience
        The audience.

        Defaults to "signin.education.gov.uk"

    .OUTPUTS
        The authorization token.

    .EXAMPLE
        PS> New-DsiPublicApiToken -ClientId abc -ApiSecret xyz
#>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)]
        [string]$ClientId,
        [Parameter(Mandatory=$true)]
        [string]$ApiSecret,
        [string]$Audience = "signin.education.gov.uk"
    )

    function Normalize-HmacSha256Key {
        param (
            [byte[]]$KeyBytes
        )
        if ($KeyBytes.Length -lt 32) {
            $paddedKey = New-Object byte[] 32
            [Array]::Copy($KeyBytes, 0, $paddedKey, 0, $KeyBytes.Length)
            return $paddedKey
        }
        return $KeyBytes
    }

    function ConvertTo-Base64Url {
        param (
            [byte[]]$Bytes
        )
        $base64 = [System.Convert]::ToBase64String($Bytes)
        $base64Url = $base64.TrimEnd('=') -replace '\+', '-' -replace '/', '_'
        return $base64Url
    }

    $headerBytes = [System.Text.Encoding]::UTF8.GetBytes('{"alg":"HS256","typ":"JWT"}')
    $header = ConvertTo-Base64Url $headerBytes
    $bodyBytes = [System.Text.Encoding]::UTF8.GetBytes('{"iss":"' + $ClientId + '","aud":"' + $Audience + '"}')
    $body = ConvertTo-Base64Url $bodyBytes

    $hmac = New-Object System.Security.Cryptography.HMACSHA256
    $hmac.Key = Normalize-HmacSha256Key ([Text.Encoding]::UTF8.GetBytes($ApiSecret))
    $signatureBytes = $hmac.ComputeHash([System.Text.Encoding]::UTF8.GetBytes("$header.$body"))
    $sig = ConvertTo-Base64Url $signatureBytes

    Write-Output "$header.$body.$sig"
}
