# CleanupFilename.ps1
[CmdletBinding(SupportsShouldProcess)]
param (
    # The top folder path
    [Parameter(Mandatory)]
    [String]
    $Folder,

    # Optional file extensions to include
    # eg. *.txt,*.pdf
    [Parameter()]
    [string[]]
    $FileExtension,

    # Switch to do a recursive deletion
    [Parameter()]
    [switch]
    $Recurse
)

# Compose the Get-ChildItem parameters.
$fileSearchParams = @{
    Path    = $Folder
    Recurse = $Recurse
    File    = $true
    Force   = $true
}
if ($FileExtension) { $fileSearchParams += @{Include = $FileExtension } }

# Get files and clean up the filenames.
$fileCollection = Get-ChildItem @fileSearchParams

foreach ($file in $fileCollection) {
    Try {
        $newName = $file.Name -replace "[0-9]", ""
        Rename-Item -Path $file.FullName -NewName $newName -ErrorAction Stop
        if (!($PSBoundParameters.ContainsKey('WhatIf'))) {
            "Renamed: $($file.FullName) => $newName" | Out-Default
        }
    }
    Catch {
        "Failed: $($_.Exception.Message)" | Out-Default
    }
}
