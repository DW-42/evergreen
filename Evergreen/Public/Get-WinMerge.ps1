Function Get-WinMerge {
    <#
        .SYNOPSIS
            Get the current version and download URL for WinMerge.

        .NOTES
            Site: https://stealthpuppy.com
            Author: Aaron Parker
            Twitter: @stealthpuppy
        
        .LINK
            https://github.com/aaronparker/Evergreen

        .EXAMPLE
            Get-WinMerge

            Description:
            Returns the current version and download URLs for WinMerge.
    #>
    [OutputType([System.Management.Automation.PSObject])]
    [CmdletBinding()]
    Param()

    # Get application resource strings from its manifest
    $res = Get-FunctionResource -AppName ("$($MyInvocation.MyCommand)".Split("-"))[1]
    Write-Verbose -Message $res.Name

    # Get latest version and download latest release via SourceForge API
    $iwcParams = @{
        Uri         = $res.Get.Update.Uri
        ContentType = $res.Get.Update.ContentType
    }
    $Content = Invoke-WebRequestWrapper @iwcParams

    # Convert the returned release data into a useable object with Version, URI etc.
    $params = @{
        Content      = $Content
        Download     = $res.Get.Download
        MatchVersion = $res.Get.MatchVersion
        # DatePattern  = $res.Get.DatePattern
    }
    $object = ConvertFrom-SourceForgeReleasesJson @params
    Write-Output -InputObject $object
}
