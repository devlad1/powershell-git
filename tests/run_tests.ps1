$ErrorActionPreference="Stop"
$curr_location=$(Get-Location)
. ..\__git_ps1.ps1
. .\test_utils.ps1
. .\git_utils.ps1
$tmp_tests_dir="tmp_dir_for_tests"
mkdir $tmp_tests_dir | Out-Null
Set-Location $tmp_tests_dir | Out-Null

function cleanup {
    Set-Location $curr_location
    Remove-Item $tmp_tests_dir -Recurse -Force
}

function test_master {
    $repo="master-repo"
    create_repo -RepoName "$repo" | Out-Null
    Push-Location $repo | Out-Null

    $output="$(__git_ps1)"

    assert_equals -Actual $output -Expected "master"
    Pop-Location
}

function test_merge {
    $repo="merge-repo"
    create_merging_repo -RepoName $repo | Out-Null
    Push-Location $repo | Out-Null

    $output="$(__git_ps1)"

    assert_equals -Actual $output -Expected "test-branch|MERGING"
    Pop-Location
}

function test_rebase {
    $repo="rebase-repo"
    create_rebase_repo -RepoName $repo | Out-Null
    Push-Location "./rebase-clone/$repo" | Out-Null

    $output="$(__git_ps1)"

    assert_equals -Actual $output -Expected "master|REBASE"
    Pop-Location | Out-Null
}

function test_cherry_pick {
    $repo="cherry-pick-repo"
    create_cherry_pick_repo -RepoName $repo | Out-Null
    Push-Location $repo

    $output="$(__git_ps1)"

    assert_equals -Actual $output -Expected "cherry-pick-branch|CHERRY-PICK"
    Pop-Location | Out-Null
}

function test_stash_conflict {
    $repo="stash-repo"
    create_stash_conflict_repo -RepoName $repo | Out-Null
    Push-Location $repo

    $output="$(__git_ps1)"

    assert_equals -Actual $output -Expected "master|CONFLICT"
    Pop-Location | Out-Null
}

try {
    test_master
    test_merge
    test_rebase
    test_cherry_pick
    test_stash_conflict
} finally {
    cleanup | Out-Null
}
