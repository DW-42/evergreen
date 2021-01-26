﻿Function Get-Cyberduck {
    <#
        .SYNOPSIS
            Get the current version and download URIs for Cyberduck for Windows.

        .NOTES
            Site: https://stealthpuppy.com
            Author: Aaron Parker
            Twitter: @stealthpuppy
        
        .LINK
            https://github.com/aaronparker/Evergreen

        .EXAMPLE
            Get-Cyberduck

            Description:
            Get the current version and download URIs for Cyberduck for Windows - Stable, Beta and Nightly.
    #>
    [OutputType([System.Management.Automation.PSObject])]
    [CmdletBinding()]
    Param()

    # Get application resource strings from its manifest
    $res = Get-FunctionResource -AppName ("$($MyInvocation.MyCommand)".Split("-"))[1]
    Write-Verbose -Message $res.Name

    # Walk through each update URI (Stable, Beta and Nightly)
    ForEach ($release in $res.Get.Uri.GetEnumerator()) {
        
        # Query the update feed
        $iwcParams = @{
            Uri         = $res.Get.Uri[$release.key]
            ContentType = $res.Get.ContentType
            Raw         = $True
        }
        $Content = Invoke-WebRequestWrapper @iwcParams

        # Convert the update feed to an XML object
        If ($Null -ne $Content) {
            Try {
                [System.XML.XMLDocument] $xmlDocument = $Content
            }
            Catch [System.Exception] {
                Throw "$($MyInvocation.MyCommand): failed to convert feed into an XML object."
            }
    
            # Build an output object by selecting entries from the feed
            If ($xmlDocument -is [System.XML.XMLDocument]) {
                $item = Select-Xml -Xml $xmlDocument -XPath $res.Get.ItemXmlNode | Select-Object –ExpandProperty "node"
                $nodes = Select-Xml -Xml $xmlDocument -XPath $res.Get.EnclosureXmlNode | Select-Object –ExpandProperty "node"

                # Output the update object
                ForEach ($node in $nodes) {

                    # Capture the URL without https:// & replace // with /
                    # Then put the URL back together
                    try {
                        $path = [RegEx]::Match($node.url, $res.Get.MatchUrlPath).Groups[0].Value
                        $url = "https://$($path -replace "//", "/")"
                    }
                    catch {
                        $url = $node.url
                    }

                    # Output the object
                    $PSObject = [PSCustomObject] @{
                        Version = "$($node.shortVersionString).$($node.version)"
                        Date    = ConvertTo-DateTime -DateTime $item.pubDate -Pattern $res.Get.DatePattern
                        Channel = $release.Name
                        URI     = $url
                    }
                    Write-Output -InputObject $PSObject
                }
            }
        }
    }
}
