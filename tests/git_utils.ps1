function create_repo {
    param(
        $RepoName
    )

    mkdir $RepoName
    Push-Location $RepoName
    git init
    Pop-Location
}

function create_file_and_commit {
    param (
        $FileName
    )

    New-Item -ItemType File -Name $FileName
    git add $FileName
    git commit -m "created $FileName"
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
    
    $repo_name="$RepoName"
    create_repo -RepoName $repo_name
    Push-Location $repo_name

    $test_file_name="test-file"
    create_file_and_commit -FileName $test_file_name

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
    
    $repo_name="$RepoName"
    create_repo -RepoName $repo_name

    Push-Location $repo_name
    $test_file_name="test-file"
    create_file_and_commit -FileName $test_file_name
    Pop-Location

    $clone_dir="rebase-clone"
    mkdir "$clone_dir" | Out-Null
    Push-Location $clone_dir
    git clone --quiet "../$repo_name" *> $null
    Push-Location $repo_name
    write_and_commit -FileName $test_file_name -Text "clone"
    Pop-Location
    Pop-Location
    
    Push-Location "./$repo_name"
    write_and_commit -FileName $test_file_name -Text "original"
    Pop-Location

    Push-Location "./$clone_dir/$repo_name"
    try {
        git pull --quiet --rebase *> $null
    } catch {}
    Pop-Location
}

function create_cherry_pick_repo {
    param (
        $RepoName
    )
    
    $repo_name="$RepoName"
    create_repo -RepoName $repo_name

    Push-Location $repo_name
    $test_file_name="test-file"
    create_file_and_commit -FileName $test_file_name
    $other_branch="cherry-pick-branch"
    git checkout -q -b "$other_branch"

    write_and_commit -FileName $test_file_name -Text "other"

    git checkout -q "master"
    write_and_commit -FileName $test_file_name -Text "cherry-picked message"
    $cherry_picked_commit_id=$(git rev-parse HEAD)

    git checkout -q $other_branch
    try {
        git cherry-pick $cherry_picked_commit_id *> $null
    } catch {}
    
    Pop-Location
}

function create_stash_conflict_repo {
    param (
        $RepoName
    )
    
    $repo_name="$RepoName"
    create_repo -RepoName $repo_name

    Push-Location $repo_name
    $test_file_name="test-file"
    create_file_and_commit -FileName $test_file_name

    Write-Output "stashed text" | Out-File -FilePath $test_file_name
    git stash -q

    write_and_commit -FileName $test_file_name -Text "conflicting message"

    try {
        git stash pop -q *> $null
    } catch {}
    
    Pop-Location
}