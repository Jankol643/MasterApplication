# SyncFolder.ps1
[CmdletBinding(SupportsShouldProcess)]
param (
    # The source folder
    [Parameter(Mandatory)]
    [String]
    $SourceFolder,

    # The destination
    [Parameter(Mandatory)]
    [String]
    $DestinationFolder,

    # Date since the last update
    [Parameter(Mandatory)]
    [datetime]
    $SinceLastUpdate,

    # Switch to do a recursive deletion
    [Parameter()]
    [switch]
    $Recurse
)

#Region Replicate Directory Structure
# Get a list of directories in the source folder (excluding files)
$directories = Get-ChildItem -Path $sourceFolder -Directory -Recurse
# Create corresponding directories in the destination folder
foreach ($directory in $directories) {
    try {
        $destinationPath = Join-Path -Path $destinationFolder -ChildPath $directory.FullName.Substring($sourceFolder.Length)
        if (!(Test-Path $destinationPath)) {
            $null = New-Item -Path $destinationPath -ItemType Directory -Force -ErrorAction Stop
        }
    }
    catch {
        "Failed: $($_.Exception.Message)" | Out-Default
        return $null
    }
}
#EndRegion

# Compose the Get-ChildItem parameters.
$fileSearchParams = @{
    Path    = $SourceFolder
    Recurse = $Recurse
    File    = $true
    Force   = $true
}

# Get files.
$fileCollection = Get-ChildItem @fileSearchParams | Where-Object { $_.LastWriteTime -gt $SinceLastUpdate }

# Copy the selected files to the destination folder
foreach ($file in $fileCollection) {
    Try {
        $destinationPath = Join-Path -Path $destinationFolder -ChildPath $file.FullName.Substring($sourceFolder.Length)
        Copy-Item -Path $file.FullName -Destination $destinationPath -Force -ErrorAction Stop
        if (!($PSBoundParameters.ContainsKey('WhatIf'))) {
            "Copied: $($file.FullName) => $($destinationPath)" | Out-Default
        }
    }
    Catch {
        "Failed: $($_.Exception.Message)" | Out-Default
    }
}