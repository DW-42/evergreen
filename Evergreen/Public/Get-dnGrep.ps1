Function Get-dnGrep {
    <#
        .SYNOPSIS
            Returns the available dnGrep versions and downloads.

        .DESCRIPTION
            Returns the available dnGrep versions and downloads.

        .NOTES
            Author: Aaron Parker
            Twitter: @stealthpuppy
        
        .LINK
            https://github.com/aaronparker/Evergreen

        .EXAMPLE
            Get-dnGrep

            Description:
            Returns the released Base Image Script Framework version and download URI.
    #>
    [OutputType([System.Management.Automation.PSObject])]
    [CmdletBinding()]
    Param()

    # Get application resource strings from its manifest
    $res = Get-FunctionResource -AppName ("$($MyInvocation.MyCommand)".Split("-"))[1]
    Write-Verbose -Message $res.Name

    # Get latest version and download latest release via GitHub API
    $iwcParams = @{
        Uri         = $res.Get.Uri
        ContentType = $res.Get.ContentType
    }
    $Content = Invoke-WebContent @iwcParams

    # Convert the returned release data into a useable object with Version, URI etc.
    $object = ConvertFrom-GitHubReleasesJson -Content $Content -MatchVersion $res.Get.MatchVersion
    Write-Output -InputObject $object
}
