<#
 remove-old-keys reads ./well-known/jwks.json and removes
 any entries where the 'ed' value date is greater than
 the number of configured days in the script
#>

# Define variables
$maxKeyAgeInDays = 30
$JwksPath = "./well-known/jwks.json"
$currrentDate = Get-Date
$secondsToDays = 86400

# Load existing keys
$jwks = Get-Content $jwksPath -Raw | ConvertFrom-Json

# Calculate cutoff timestamp
$unixEpoch = [datetime]::UnixEpoch
$currentUnixTime = [int64](([datetime]::UtcNow - $unixEpoch).TotalSeconds)
$cutoffUnixTime = $currentUnixTime - ($maxKeyAgeInDays * $secondsToDays)

# Filter keys based on ed timestampt
$keysToKeep = @()
$removedKeys = 0

foreach($key in $jwks.keys) {
    $keyAgeSeconds = $currentUnixTime - $key.ed
    $keyAgeDays = $keyAgeSeconds / $secondsToDays

    if ($key.ed -gt $cutoffUnixTime) {
        $keysToKeep += $key
        Write-Host "Keeping key with kid: $($key.kid) (Age: $($keyAgeDays.ToString("F2"))) days"
    } else {
        $removedKeys ++
        Write-Host "Removing key with kid: $($key.kid) (Age: $($keyAgeDays.ToString("F2"))) days"  -ForegroundColor Red
    }
}

# Update JWKS structure
$jwks.keys = $keysToKeep

# Save the updated structure
$jwks | ConvertTo-Json -Depth 3 | Out-File $JwksPath -Encoding UTF8

Write-Host "JWKS cleanup complete:" -ForegroundColor Green
Write-Host "Keys removed: $removedKeys"
Write-Host "Keys remaining: $($keysToKeep.Count)"
