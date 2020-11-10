function Add-TrustAllCertsPolicy {
<#
    .NOTES
    NOT FOR PRODUCTION USE - FOR DEMONSTRATION/EDUCATION PURPOSES ONLY
    
    The code samples provided here are intended as standalone examples.  They can be downloaded, copied and/or modified in any way you see fit.
    
    Please be aware that all code samples provided here are unofficial in nature, are provided as examples only, are unsupported and will need to be heavily modified before they can be used in a production environment.
#>

    [CmdletBinding()]

    param (

    )
   
    begin {

    }

    process {
        
        if ([System.Net.ServicePointManager]::CertificatePolicy.ToString() -eq "TrustAllCertsPolicy") {
            Write-Verbose -Message "Certifcate Policy already set to $([System.Net.ServicePointManager]::CertificatePolicy.ToString())"
        }
        else {
            add-type @"
            using System.Net;
            using System.Security.Cryptography.X509Certificates;
            public class TrustAllCertsPolicy : ICertificatePolicy {
                public bool CheckValidationResult(
                    ServicePoint srvPoint, X509Certificate certificate,
                    WebRequest request, int certificateProblem) {
                    return true;
                }
            }
"@    
            [System.Net.ServicePointManager]::CertificatePolicy = New-Object TrustAllCertsPolicy
            Write-Verbose -Message "Certifcate Policy set to $([System.Net.ServicePointManager]::CertificatePolicy.ToString())"
        }

        if ([System.Net.ServicePointManager]::SecurityProtocol.ToString() -eq 'Tls12') {
            Write-Verbose -Message "Certifcate Policy already set to $([System.Net.ServicePointManager]::SecurityProtocol.ToString())"
        }
        else {
            [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]'Tls12'
            Write-Verbose -Message "Certifcate Policy set to $([System.Net.ServicePointManager]::SecurityProtocol.ToString())"
        }
    }

    end {

    }
}