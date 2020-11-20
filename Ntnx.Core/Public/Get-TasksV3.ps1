function Get-TasksV3 {   
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
        # VIP or FQDN of target AOS cluster
        [Parameter(Mandatory=$true)]
        [string]
        $ComputerName,

        # Prism UI Credential to invoke call
        [Parameter(Mandatory=$true)]
        [PSCredential]
        $Credential,

        [Parameter(Mandatory=$false)]
        [int]
        $Count,

        [Parameter(Mandatory=$false)]
        [switch]
        $SkipCertificateCheck,

        [Parameter(Mandatory=$false)]
        [switch]
        $ShowMetadata,

        # Port (Default is 9440)
        [Parameter(Mandatory=$false)]
        [int16]
        $Port = 9440
    )

    begin {
        Set-StrictMode -Version Latest
    }

    process {
        $body = [Hashtable]::new()
        $body.add("kind","task")
        if($null -ne $Count){
            $body.add("length",$Count)
        }

        $iwrArgs = @{
            Uri = "https://$($ComputerName):$($Port)/api/nutanix/v3/tasks/list"
            Method = "POST"
            ContentType = "application/json"
        }

        if($body.count -ge 1){
            $iwrArgs.add("Body",($body | ConvertTo-Json))
        }

        if($PSVersionTable.PSVersion.Major -lt 6){
            $basicAuth = Initialize-BasicAuthHeader -credential $Credential
            $iwrArgs.Add("headers",$basicAuth)
        }
        else{
            $iwrArgs.add("Authentication","Basic")
            $iwrArgs.add("Credential",$Credential)
            $iwrArgs.add("SslProtocol","Tls12")

            if($SkipCertificateCheck){
                $iwrArgs.add("SkipCertificateCheck",$true)
            }
        }
        
        try {
            $response = Invoke-WebRequest @iwrArgs

            if($response.StatusCode -eq 200){
                $totalMatches = ($response.content | ConvertFrom-Json).metadata.total_matches
                Write-Verbose -Message "Total records: $totalMatches"
                if($Count -lt $totalMatches){
                    ($response.content | ConvertFrom-Json).entities
                }
                else{
                    do { 
                        $response = Invoke-WebRequest @iwrArgs
                        if($response.StatusCode -eq 200){
                            ($response.content | ConvertFrom-Json).entities
                        }
                        $iwrArgs.body.offset += $Count
                        Write-Verbose -Message "$Count"
                    }
                    Until (
                        $iwrArgs.body.offset -ge $totalMatches
                    )
                }
            }
        }
        catch {
            Write-Error -Message "ERROR $($response.StatusCode)"
        }
    }
                
}