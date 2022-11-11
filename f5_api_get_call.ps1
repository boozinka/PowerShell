# Makes an API call to an F5 LTM appliance and returns results


function Get-ApiUri {
    # Function to API call input parameters from user input

    [CmdletBinding()]
    Param()

    # Input valid IP address
    $ipValid = $false
    While ($ipValid -ne $true)
        {
            $ipAddress = Read-Host 'Please enter the IP address of the F5 LTM you' `
                                    'want to make the API call on'
            if (($ipAddress -as [IPAddress] -as [Bool]) -eq $true)
            {
                $ipValid = $true
            }
        }

    # Create complete F5 REST API URI
    Write-Host "The base URI is: https://$ipAddress/mgmt/tm/ltm/"
    $uri_ext = Read-Host "Please enter the URI extension"
    Write-Host "Your API URL is: https://$ipAddress/mgmt/tm/ltm/$uri_ext"
    $apiUri = "https://$ipAddress/mgmt/tm/ltm/$uri_ext"

    Return $apiUri
}


function Get-F5apiResponse {
    # Function that makes an F5 Rest API Get call

    [CmdletBinding()]
    Param(
        [Parameter(Mandatory)]
        [String]$aprUri,
        [System.Management.Automation.PSCredential]$myCreds
    )

    # Disable Certificate errors and warnings
    if (-not ([System.Management.Automation.PSTypeName]'ServerCertificateValidationCallback').Type)
    {
    $certCallback = @"
        using System;
        using System.Net;
        using System.Net.Security;
        using System.Security.Cryptography.X509Certificates;
        public class ServerCertificateValidationCallback
        {
            public static void Ignore()
            {
                if(ServicePointManager.ServerCertificateValidationCallback ==null)
                {
                    ServicePointManager.ServerCertificateValidationCallback += 
                        delegate
                        (
                            Object obj, 
                            X509Certificate certificate, 
                            X509Chain chain, 
                            SslPolicyErrors errors
                        )
                        {
                            return true;
                        };
                }
            }
        }
"@
        Add-Type $certCallback
    }

    [ServerCertificateValidationCallback]::Ignore()

    $ContentType = 'application/json'
    $api_Response = Invoke-RestMethod -Uri $apiUri -Method Get -Credential $myCreds -ContentType $ContentType

    Return $api_Response
}

$apiUri = Get-ApiUri
$myCreds = Get-Credential
$apiResponse = Get-F5apiResponse -aprUri $apiUri -myCreds $myCreds
