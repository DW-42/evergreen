function Get-MicrosoftWvdMultimediaRedirection {
    <#
        .SYNOPSIS
            Get the current version and download URL for the Microsoft Azure Virtual Desktop Multimedia Redirection Extensions.

        .NOTES
            Site: https://stealthpuppy.com
            Author: Aaron Parker
            Twitter: @stealthpuppy
    #>
    [OutputType([System.Management.Automation.PSObject])]
    [CmdletBinding(SupportsShouldProcess = $False)]
    param (
        [Parameter(Mandatory = $False, Position = 0)]
        [ValidateNotNull()]
        [System.Management.Automation.PSObject]
        $res = (Get-FunctionResource -AppName ("$($MyInvocation.MyCommand)".Split("-"))[1])
    )

    $params = @{
        Uri          = $res.Get.Download.Uri
        Method       = "Head"
        ReturnObject = "Headers"
    }
    $Content = Invoke-WebRequestWrapper @params

    if ($null -ne $Content) {
        try {
            # Match filename
            $Filename = [RegEx]::Match($Content.'Content-Disposition', $res.Get.Download.MatchFilename).Captures.Groups[1].Value
        }
        catch {
            Write-Warning -Message "$($MyInvocation.MyCommand): Failed to match filename from `"$($Content.'Content-Disposition')`"."
        }

        try {
            # Match version
            $Version = [RegEx]::Match($Content.'Content-Disposition', $res.Get.Download.MatchVersion).Captures.Groups[1].Value
        }
        catch {
            $Version = [RegEx]::Match($Content.'Content-Disposition', $res.Get.Download.MatchVersionFallback).Captures.Groups[1].Value
            Write-Warning -Message "$($MyInvocation.MyCommand): Unable to determine a version number from `"$($Content.'Content-Disposition')`"."
        }

        # Construct the output; Return the custom object to the pipeline
        $PSObject = [PSCustomObject] @{
            Version      = $Version
            Architecture = Get-Architecture -String $Filename
            Date         = $Content.'Last-Modified'[0]
            Size         = $Content.'Content-Length'[0]
            Filename     = $Filename
            URI          = $res.Get.Download.Uri
        }
        Write-Output -InputObject $PSObject
    }
    else {
        Write-Warning -Message "$($MyInvocation.MyCommand): Failed to return a header from $($res.Get.Download.Uri)."
    }
}
