function Initialize-BasicAuthHeader {
    <#
    .SYNOPSIS
    Create Basic Auth headers for REST API calls
    
    NOT INTENDED FOR PRODUCTION USE -- FOR DEMONSTATION/EDUCTATION PURPOSES ONLY

    The code samples provided here are intended as standalone examples.  They can be downloaded, copied and/or modified in any way you see fit.

    Please be aware that all code samples provided here are unofficial in nature, are provided as examples only, are unsupported and will need to be heavily modified before they can be used in a production environment.

    #>
    [CmdletBinding()]

    PARAM(
        
        # PSCredential object to create auth headers from
        [Parameter(Mandatory=$true)]
        [pscredential]
        $credential
    )

    $credPair = "$($credential.username):$($credential.GetNetworkCredential().Password)"
    $encodedCredentials = [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes($credPair))
    $headers = @{ Authorization = "Basic $encodedCredentials" }

    Write-Output $headers
}