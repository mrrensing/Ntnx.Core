function Get-VmsV3 {   
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

        # Body Parameter1
        [Parameter(Mandatory=$false)]
        [ValidateRange(0,500)]
        [int]
        $Count = 20,

        [Parameter(Mandatory=$false)]
        [int]
        $Offset = 0,

        [Parameter(Mandatory=$false)]
        [switch]
        $SkipCertificateCheck,

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
        $body.add("kind","vm")
        $body.add("offset",$Offset)
        $body.add("length",$Count)
        
        $iwrArgs = @{
            Uri = "https://$($ComputerName):$($Port)/api/nutanix/v3/vms/list"
            Method = "POST"
            ContentType = "application/json"
            ErrorVariable = "iwrError"
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
        
        try{
            $iwr = Invoke-WebRequest @iwrArgs
            $metadata = ($iwr.Content | ConvertFrom-Json -Depth 99).metadata
            $entities = ($iwr.Content | ConvertFrom-Json -Depth 99).entities
            Write-Verbose -Message "Total number of $($metadata.kind) entities: $($metadata.total_matches); Number of entites retrieved in this iteration: $($metadata.length)"     
            
            do {               
                $body.offset += $metadata.length
                Write-Verbose -Message "IWR offset: $($body.offset); IWR length = $($body.length)"
        
                $iwrArgs.Body = ($body | ConvertTo-Json)
        
                $response = Invoke-WebRequest @iwrArgs
                if ($response.StatusCode -in 200..204) {
                    $entities += ($response.Content | ConvertFrom-Json -Depth 99).entities
                    $metadata = ($response.Content | ConvertFrom-Json -Depth 99).metadata
                    Write-Verbose -Message "Total number of $($metadata.kind) entities: $($metadata.total_matches); Number of entites retrieved in this iteration: $($metadata.length)"
                }
            } while ($metadata.total_matches -gt ([int]$metadata.length + [int]$metadata.offset))
         
            $entities

        } 
        catch{
            if($null -eq $iwrError){
                Write-Error -Message "API Call Failed"
                throw
            }
            else{
                Write-Error -Message $iwrError.Message
                throw
            }
        }
    }
                
}
