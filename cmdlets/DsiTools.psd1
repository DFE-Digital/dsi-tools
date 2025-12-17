@{
    RootModule      = "DsiTools.psm1"
    ModuleVersion   = "0.0.1"

    GUID            = "02bf8520-7d70-46d3-8f6a-b99fbbb10e63"

    CmdletsToExport = @(
        # azure/
        'Connect-DsiEnv'
        'Disconnect-DsiEnv'
        'Get-DsiConnectedEnv'
        'Get-DsiEnvMetadata'
        'Get-DsiKeyVaultSecret'
        'Set-DsiKeyVaultSecret'
        'Test-DsiConnectedEnv'

        # mac/
        'Start-DsiTlsProxy'

        # public-api/
        'New-DsiPublicApiToken'
        'Start-DsiPublicApiProxy'

        # user-secrets/
        'Clear-DsiSecrets'
        'Export-DsiTestDataToKeyVault'
        'Get-DsiTestDataPath'
        'Import-DsiSecrets'
        'Import-DsiTestData'
        'Use-DsiTestData'
    )
}
