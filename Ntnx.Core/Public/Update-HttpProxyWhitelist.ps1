function Update-HttpProxyWhitelist {

<#
.SYNOPSIS
Dynamically Generated API Function
.NOTES
NOT FOR PRODUCTION USE - FOR DEMONSTRATION/EDUCATION PURPOSES ONLY

The code samples provided here are intended as standalone examples.  They can be downloaded, copied and/or modified in any way you see fit.

Please be aware that all code samples provided here are unofficial in nature, are provided as examples only, are unsupported and will need to be heavily modified before they can be used in a production environment.
#>

    [CmdletBinding()]
    [OutputType()]

    param(
        [Parameter(Mandatory=$true)]
        [string]
        $ComputerName,

        [Parameter(Mandatory=$false)]
        [int16]
        $Port = 9440,

        # Work around until classes load when PS modules are loaded
        #[Parameter()]
        #$Body,

        [Parameter()]
        $Whitelist = @(@{targetType="IPV4_NETWORK_MASK";target="10.0.0.0/255.0.0.0"},@{targetType="DOMAIN_NAME_SUFFIX";target="*.tiaa-cref.org"}),

        [Parameter()]
        [string]
        $TargetType,

        [Parameter()]
        [string]
        $Target,

        [Parameter(Mandatory=$true)]
        [PSCredential]
        $Credential
    )

    PROCESS {

        $headers = Initialize-BasicAuthHeader -credential $Credential
        $headers.Add("content-type", "application/json")

        $body =  @{
                    whitelist = $whitelist
                }
        
        $body = $body | ConvertTo-Json

        $url = "https://$($ComputerName):$($port)/PrismGateway/services/rest/v1/http_proxies/whitelist"
        
        $Response = Invoke-RestMethod -Method PUT -Uri $url -Headers $headers -Body $body

        Write-Output $Response

    }
        
        
}
