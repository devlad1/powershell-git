
$HEAD_PATH=".git/HEAD"
$MERGE_PATH=".git/MERGE_HEAD"

$current_location=$(Get-Location)
trap {
    Set-Location $current_location
}

function __git_ps1 {
    function is_in_root_directory {
        return $(Get-Location) -match "^[A-Z]:\\$"
    }
    
    function is_git_directory {
        return $(Test-Path $HEAD_PATH)
    }
    
    function is_merging {
        return $(Test-Path $MERGE_PATH)
    }
    
    function cut {
    
        [CmdletBinding()]
    
        param (
            [Parameter(ValueFromPipeline)] $Text,
            $Delimiter,
            $Column
        )
    
        process {
            $Text | ForEach-Object {
                $line=$($_.split($Delimiter)[$Column])
    
                if (![string]::IsNullOrWhiteSpace($line)) {
                    Write-Output($line)
                }
            }
        }
    }
    
    while (!(is_git_directory) -and !(is_in_root_directory)) {
        Set-Location ..
    }
    
    $ps1=""
    if (is_git_directory) {
        $ps1=$(Get-Content $HEAD_PATH | cut -Delimiter "/" -Column 2)
        if (is_merging) {
            $ps1="$ps1|MERGING"
        }
    }

    Set-Location $current_location
    return $ps1
}
