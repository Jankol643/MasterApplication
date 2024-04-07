# IsTheSharedFileOpen.ps1
[CmdletBinding(SupportsShouldProcess)]
param (
    # The filename to search
    [Parameter(Mandatory)]
    [String]
    $Filename,

    # The file server containing the shared file
    [Parameter(Mandatory)]
    [String]
    $Server
)

$session = New-CimSession -ComputerName $Server

$remoteFiles = @(Get-SmbOpenFile -CimSession $session | Where-Object { $_.ShareRelativePath -eq $Filename })

foreach ($file in $remoteFiles) {
    $file |
    Select-Object @{n = "File"; e = { $_.Path } },
    @{n = "User"; e = { $_.ClientUserName } },
    @{n = "Source"; e = { $_.ClientComputerName } }
}