# PurgeEmptyDirectory.ps1
[CmdletBinding(SupportsShouldProcess)]
param (
    # Top folder to search
    [Parameter(Mandatory)]
    [String]
    $Folder
)

(Get-ChildItem $Folder -Recurse -Directory).ForEach(
    {
        $currentDir = $_
        if ($currentDir.GetFileSystemInfos().Count -lt 1) {
            Try {
                Remove-Item $_.FullName -Force -ErrorAction Stop
                if (!($PSBoundParameters.ContainsKey('WhatIf'))) {
                    "Deleted: $($_.FullName)" | Out-Default
                }
            }
            Catch {
                "Failed: $($_.Exception.Message)" | Out-Default
            }
        }
    }
)