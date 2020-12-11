function Get-ReportsDownloadV3 {   
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

        # Request Parameter
        [Parameter(Mandatory=$true)]
        [ValidateSet("report_instance","report_instance_pdf","report_instance_csv","logo")]
        [string]
        $Type,

        # Request Parameter
        [Parameter(Mandatory=$true)]
        [string]
        $Uuid,

        [Parameter(Mandatory=$false)]
        [switch]
        $SkipCertificateCheck,

        # File is uses a ZIP extension
        [Parameter(Mandatory=$True)]
        [string]
        $OutFile,

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
        #$body.add("kind","kind")
        #$body.add("BodyParam1",$BodyParam1)

        $iwrArgs = @{
            Uri = "https://$($ComputerName):$($Port)/api/nutanix/v3/reports/download/$Type/$Uuid"
            Method = "GET"
            #ContentType = "application/json","text/plain","*/*"
            ErrorVariable = "iwrError"
            OutFile = $OutFile
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
            Invoke-WebRequest @iwrArgs

        <#
            if($response.StatusCode -in 200..204){
                #$content = $response.Content | ConvertFrom-Json
                Write-Verbose -Message "Web Request Status Code: $($response.StatusCode)"
            }
            elseif($response.StatusCode -eq 401){
                Write-Verbose -Message "Credential used not authorized, exiting..."
                Write-Error -Message "$($response.StatusCode): $($response.StatusDescription)"
                exit
            }
            else{
                Write-Error -Message "$($response.StatusCode): $($response.StatusDescription)"
            }   
        #>
        }
        catch{
            if($null -eq $iwrError){
                Write-Error -Message "API Call Failed"
            }
            else{
                #Write-Error -Message $iwrError
                $iwrError
            }
        }
    }
                
}
