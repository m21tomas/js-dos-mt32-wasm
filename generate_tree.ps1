param(
    [string]$OutputPath = "project_structure.txt",
    [string[]]$ExcludeDirs = @("node_modules", ".git", "dist", "build", ".idea", ".vscode", "target", "bin", "obj")
)

function Get-DirectoryTree {
    param(
        [string]$Path,
        [string]$Indent = "",
        [string[]]$Exclude
    )

    $items = Get-ChildItem -Path $Path -ErrorAction SilentlyContinue | Where-Object { $Exclude -notcontains $_.Name }
    $count = $items.Count
    $index = 0

    foreach ($item in $items) {
        $index++
        $isLast = ($index -eq $count)

        $charCorner = [char]0x2514 + [char]0x2500 + [char]0x2500 + " "
        $charTee    = [char]0x251C + [char]0x2500 + [char]0x2500 + " "
        $charPipe   = [char]0x2502 + "   "

        if ($isLast) {
            $connector = $charCorner
            $padding   = "    "
        } else {
            $connector = $charTee
            $padding   = $charPipe
        }

        Write-Output "$Indent$connector$($item.Name)"

        if ($item.PSIsContainer) {
            $nextIndent = $Indent + $padding
            Get-DirectoryTree -Path $item.FullName -Indent $nextIndent -Exclude $Exclude
        }
    }
}

$rootDirectory = Get-Item .
$treeOutput = @($rootDirectory.Name + "/")
$treeOutput += Get-DirectoryTree -Path . -Exclude $ExcludeDirs

$utf8Encoding = New-Object System.Text.UTF8Encoding $true
[System.IO.File]::WriteAllLines((Join-Path (Get-Location) $OutputPath), $treeOutput, $utf8Encoding)

Write-Host "Project structure tree successfully saved: $OutputPath" -ForegroundColor Green