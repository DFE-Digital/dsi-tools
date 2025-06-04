function Get-DsiEnvMetadata {
<#
    .SYNOPSIS
        Gets metadata for a DfE Sign-in environment.

    .PARAMETER Name
        The name of the environment:
            - TRAN
            - DEV
            - TEST
            - PREPROD
            - PROD

    .OUTPUTS
        Metadata for the environment:
            - Name - The name of the environment (eg. "DEV").
            - Subscription - The name of the associated subscription.
            - Prefix - The resource prefix.
            - KeyVault - The name of the KeyVault resource.

    .EXAMPLE
        PS> Connect-DsiEnv -Name DEV
        PS> xyz...
        PS> Disconnect-DsiEnv
#>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)]
        [String]$Name
    )

    $mappings = @{
        "TRAN" = @{
            Name = "TRAN"
            Subscription = "s141-dfesignin-development"
            Prefix = "s141d03-signin-"
            KeyVault = "s141d03-signin-kv"
        }
        "DEV" = @{
            Name = "DEV"
            Subscription = "s141-dfesignin-development"
            Prefix = "s141d01-signin-"
            KeyVault = "s141d01-signin-kv"
        }
        "TEST" = @{
            Name = "TEST"
            Subscription = "s141-dfesignin-test"
            Prefix = "s141t01-signin-"
            KeyVault = "s141t01-signin-kv"
        }
        "PREPROD" = @{
            Name = "PREPROD"
            Subscription = "s141-dfesignin-test"
            Prefix = "s141t02-signin-"
            KeyVault = "s141t02-signin-kv"
        }
        "PROD" = @{
            Name = "PROD"
            Subscription = "s141-dfesignin-production"
            Prefix = "s141p01-signin-"
            KeyVault = "s141p01-signin-kv"
        }
    }

    return $mappings[$Name.ToUpper()]
}
