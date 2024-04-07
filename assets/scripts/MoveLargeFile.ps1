# MoveLargeFile.ps1
[CmdletBinding(SupportsShouldProcess)]
param (
    # The top folder path to search
    [Parameter(Mandatory)]
    [String]
    $SourceFolder,

    # The destination folder
    [Parameter(Mandatory)]
    [String]
    $DestinationFolder,

    # File size threshold
    [Parameter(Mandatory)]
    [int64]
    $Size,

    # Switch to do a recursive deletion
    [Parameter()]
    [switch]
    $Recurse
)

# Compose the Get-ChildItem parameters.
$fileSearchParams = @{
    Path    = $SourceFolder
    Recurse = $Recurse
    File    = $true
    Force   = $true
}

# Find the large files
$largeFiles = Get-ChildItem @fileSearchParams |
Where-Object {
    $_.Length -gt $Size
}

# Moved the filtered large files
$largeFiles | ForEach-Object {
    Try {
        Move-Item $_.FullName -Destination $DestinationFolder -Force -ErrorAction Stop
        if (!($PSBoundParameters.ContainsKey('WhatIf'))) {
            "Copied: $($_.FullName) => $($DestinationFolder)" | Out-Default
        }
    }
    Catch {
        "Failed: $($_.Exception.Message)" | Out-Default
    }
}