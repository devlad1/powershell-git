function __git_ps1 {
    $HEAD_PATH=".git/HEAD"
    $MERGE_PATH=".git/MERGE_HEAD"
    $REBASE_PATH=".git/REBASE_HEAD"
    $FETCH_HAED_PATH=".git/FETCH_HEAD"
    $CHERRY_PICK_PATH=".git/CHERRY_PICK_HEAD"
    $AUTO_MERGE_PATH=".git/AUTO_MERGE"

    function is_in_root_directory {
        return $(Get-Location) -match "^[A-Z]:\\$"
    }
    
    function is_git_directory {
        return $(Test-Path $HEAD_PATH)
    }
    
    function is_merging {
        return $(Test-Path $MERGE_PATH) -and $(is_auto_merge)
    }

    function is_rebasing {
        return $(Test-Path $REBASE_PATH) -and $(is_auto_merge)
    }

    function is_cherry_picking {
        return $(Test-Path $CHERRY_PICK_PATH) -and $(is_auto_merge)
    }
    
    function is_auto_merge {
        return $(Test-Path $AUTO_MERGE_PATH)
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

    $current_location=$(Get-Location)
    try {
        while (!(is_git_directory) -and !(is_in_root_directory)) {
            Set-Location ..
        }
        
        $ps1=""
        if (is_git_directory) {
            $ps1=$(Get-Content $HEAD_PATH | cut -Delimiter "/" -Column 2)
            if (is_merging) {
                $ps1="$ps1|MERGING"
            } elseif (is_rebasing) {
                $ps1=$(Get-Content $FETCH_HAED_PATH | cut -Delimiter " " -Column 1).Replace("'","")
                $ps1="$ps1|REBASE"
            } elseif (is_cherry_picking) {
                $ps1="$ps1|CHERRY-PICK"
            } elseif (is_auto_merge) {
                $ps1="$ps1|CONFLICT"
            }
        }
    
        return $ps1
    } finally {
        Set-Location $current_location
    }
}
