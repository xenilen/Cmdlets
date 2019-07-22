function Get-MacVendor {
    [CmdletBinding()]
    param(
        [Parameter (Mandatory = $true,
            ValueFromPipeline = $false)]
        [ValidatePattern("^([0-9A-Fa-f]{2}[:-]){5}([0-9A-Fa-f]{2})$")]
        [string[]]$MacAddress
    )

    foreach ($Mac in $MacAddress) {
        try {
            Write-Verbose 'Sending Request to https://api.macvendors.com/'
            Invoke-RestMethod -Method Get -Uri https://api.macvendors.com/$Mac -ErrorAction SilentlyContinue | Foreach-object {
                [pscustomobject]@{
                    Vendor     = $_
                    MacAddress = $Mac
                }
            }
            # Has to be 1+ seconds or API will deny request
            Start-Sleep -Seconds 1
        }
        catch {
            Write-Warning -Message "$Mac, $_"
        }
    }   
}