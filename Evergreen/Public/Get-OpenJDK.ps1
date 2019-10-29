Function Get-OpenJDK {
    <#
        .SYNOPSIS
            Returns the latest Open JDK version number and download.

        .DESCRIPTION
            Returns the latest Open JDK version number and download.

        .NOTES
            Author: Aaron Parker
            Twitter: @stealthpuppy
        
        .LINK
            https://github.com/aaronparker/Evergreen

        .EXAMPLE
            Get-OpenJDK

            Description:
            Returns the latest Open JDK version number and download for each platform.
    #>
    [OutputType([System.Management.Automation.PSObject])]
    [CmdletBinding()]
    Param()

    # Get latest version and download latest Open JDK release via GitHub API
    # Query the Open JDK repository for releases, keeping the latest stable release
    $iwcParams = @{
        Uri         = $script:resourceStrings.Applications.OpenJDK.Uri
        ContentType = $script:resourceStrings.Applications.OpenJDK.ContentType
        Raw         = $True
    }
    $Content = Invoke-WebContent @iwcParams
    $Json = $Content | ConvertFrom-Json
    $latestRelease = ($Json | Where-Object { $_.prerelease -eq $False }) | Select-Object -First 1

    # Build the output object with release details
    ForEach ($release in $latestRelease.assets) {

        # Match architecture and platform from the URL string
        If ($release.browser_download_url -match "\.zip$|\.msi$") {
            Switch -Regex ($release.browser_download_url) {
                "amd64" { $arch = "AMD64" }
                "arm64" { $arch = "ARM64" }
                "arm32" { $arch = "ARM32" }
                "x86_64" { $arch = "x86_64" }
                "x64" { $arch = "x64" }
                "-x86" { $arch = "x86" }
                "fxdependent" { $arch = "fxdependent" }
                Default { $arch = "Unknown" }
            }
            Switch -Regex ($release.browser_download_url) {
                "rhel" { $platform = "RHEL" }
                "linux" { $platform = "Linux" }
                "win" { $platform = "Windows" }
                "osx" { $platform = "macOS" }
                "debian" { $platform = "Debian" }
                "ubuntu" { $platform = "Ubuntu" }
                Default { $platform = "Unknown" }
            }

            # Match version number
            $latestRelease.tag_name -match $script:resourceStrings.Applications.OpenJDK.MatchVersion | Out-Null
            $Version = $Matches[1]

            # Construct the output; Return the custom object to the pipeline
            $PSObject = [PSCustomObject] @{
                Version      = $Version
                Platform     = $platform
                Architecture = $arch
                Date         = (ConvertTo-DateTime -DateTime $release.created_at)
                Size         = $release.size
                URI          = $release.browser_download_url
            }
            Write-Output -InputObject $PSObject
        }
    }
}
