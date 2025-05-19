<#
    PowerShell script that creates dev_conflict.txt
    filled with dummy lines to force merge conflicts.
#>

param(
    [string]$OutFile = 'dev_conflict.txt'
)

$ErrorActionPreference = 'Stop'

$UID       = [guid]::NewGuid()
$Timestamp = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
$Hash      = (git rev-parse HEAD).Trim()

@'
############################################################
#   WARNING: DEVELOPMENT BRANCH WAS RECREATED
############################################################
'@ | Out-File -FilePath $OutFile -Encoding utf8

"Branch unique ID : $UID"        | Out-File -FilePath $OutFile -Append -Encoding utf8
"Creation date    : $Timestamp"  | Out-File -FilePath $OutFile -Append -Encoding utf8
"Commit hash      : $Hash"       | Out-File -FilePath $OutFile -Append -Encoding utf8
"############################################################" | Out-File -FilePath $OutFile -Append -Encoding utf8
"" | Out-File -FilePath $OutFile -Append -Encoding utf8

1..500 | ForEach-Object {
    "Instruction #$($_) - update local branch -> git fetch origin && git checkout dev && git pull" |
        Out-File -FilePath $OutFile -Append -Encoding utf8
}

1..500 | ForEach-Object {
    $Rand = -join ((48..57)+(65..90)+(97..122) | Get-Random -Count 32 | ForEach-Object {[char]$_})
    "Conflict line #$($_) - $Rand" |
        Out-File -FilePath $OutFile -Append -Encoding utf8
}

@'
############################################################
#   If you see this file your local branch is outdated!
#   Please update before pushing.
############################################################
'@ | Out-File -FilePath $OutFile -Append -Encoding utf8
