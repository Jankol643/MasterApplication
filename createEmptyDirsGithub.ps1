# createEmptyDirsGithub.ps1

Function Get-Folders {
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
        $target = get-item $fileCollection
        if ($target.PSIsContainer) {
            # it's a folder
            Try {
                New-Item -Path C:\Temp\* -Name temp.txt -ItemType File # create new file in every subfolder
                if (!($PSBoundParameters.ContainsKey('WhatIf'))) {
                    "Renamed: $($file.FullName) => $newName" | Out-Default
                }
            }
            Catch {
                "Failed: $($_.Exception.Message)" | Out-Default
            }
        }
    }
}

Function Get-EmptyDirectories($basedir) { 
    Get-ChildItem -Directory $basedir | Where-Object { $_.GetFileSystemInfos().Count -eq 0 }
}