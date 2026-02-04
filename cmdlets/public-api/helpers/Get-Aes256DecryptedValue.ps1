function Get-Aes256DecryptedValue {
    <#
    .SYNOPSIS
        Decrypts a AES-256-GCM encrypted value.

    .DESCRIPTION
        Decrypts a Base64-encoded value encrypted using AES-256 in GCM mode.
        The encrypted value must contain a 6-character version prefix, followed by
        the IV (nonce), authentication tag, and ciphertext in that order.

    .PARAMETER Key
        The AES-256 encryption key as a string.
        Must be exactly 32 bytes when UTF-8 encoded.

    .PARAMETER Value
        The encrypted value to decrypt.

    .OUTPUTS
        The decrypted plaintext value.

    .EXAMPLE
        PS> Get-Aes256GcmDecryptedValue -Key "0123456789abcdef0123456789abcdef" -Value "ENC:0:Base64EncodedEncryptedValue"
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [String]$Key,

        [Parameter(Mandatory = $true)]
        [String]$Value
    )

    if ($Value.Length -lt 7) {
        throw "Encrypted value is too short to contain a version prefix."
    }

    $Value = $Value.Substring(6)

    $keyBytes = [Text.Encoding]::UTF8.GetBytes($Key)
    if ($keyBytes.Length -ne 32) {
        throw "Invalid encryption key length $($keyBytes.Length). Expected 32 bytes."
    }

    $encryptedBytes = [Convert]::FromBase64String($Value)

    $IvLength = 12
    $TagLength = 16

    if ($encryptedBytes.Length -lt ($IvLength + $TagLength)) {
        throw "Invalid encrypted data."
    }

    $iv = $encryptedBytes[0..($IvLength - 1)]
    $tag = $encryptedBytes[$IvLength..($IvLength + $TagLength - 1)]
    $cipherText = $encryptedBytes[($IvLength + $TagLength)..($encryptedBytes.Length - 1)]

    $plainBytes = New-Object byte[] $cipherText.Length

    $aesGcm = [System.Security.Cryptography.AesGcm]::new($keyBytes, $TagLength)
    try {
        $aesGcm.Decrypt($iv, $cipherText, $tag, $plainBytes)
    }
    finally {
        $aesGcm.Dispose()
    }

    [Text.Encoding]::UTF8.GetString($plainBytes)
}
