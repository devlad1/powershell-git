$ErrorActionPreference="Stop"
$curr_location=$(Get-Location)
. .\__git_ps1.ps1
$tmp_tests_dir="tmp_dir_for_tests"
mkdir $tmp_tests_dir | Out-Null
Set-Location $tmp_tests_dir | Out-Null

function cleanup {
    Set-Location $curr_location
    Remove-Item $tmp_tests_dir -Recurse -Force
}

trap {
    cleanup | Out-Null
}

function create_repo {
    param(
        $RepoName
    )

    mkdir $RepoName
    Push-Location $RepoName
    git init
    Pop-Location
}

function write_and_commit {
    param (
        $FileName,
        $Text
    )

    Write-Output $Text | Out-File -FilePath $FileName
    git add $FileName
    git commit -m "Wrote '$Text' to $FileName"
}

function create_merging_repo {
    param (
        $RepoName
    )
    
    $repo_name="merge-repo"
    create_repo -RepoName $repo_name
    Push-Location $repo_name

    $test_file_name="test-file"
    New-Item -ItemType File -Name $test_file_name
    git add $test_file_name
    git commit -m "created $test_file_name"

    git checkout -q -b "test-branch"
    write_and_commit -FileName $test_file_name -Text "test"

    git checkout -q master
    write_and_commit -FileName $test_file_name -Text "master"

    git checkout -q "test-branch"
    git merge master

    Pop-Location
}

function create_rebase_repo {
    param (
        $RepoName
    )

}

function assert_equals {
    param (
        $Expected, $Actual
    )

    if ($Expected -ne $Actual) {
        Write-Host "Expected '$Actual' to be equal to '$Expected'"
        return $false
    }

    return $true
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

test_master
test_merge

cleanup | Out-Null
