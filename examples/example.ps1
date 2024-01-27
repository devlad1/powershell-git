# This is is an example usage.
# Put this code in a powershell profile
# The usual path is '$Home\Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1'

# Load or copy the '__git_ps1' function here

function prompt {
    Write-Host -NoNewline -ForegroundColor Cyan "$(Get-Location) "

    $git_state=__git_ps1
    if ($git_state -ne "") {
        Write-Host -NoNewline -ForegroundColor Green "($git_state) "
    }
	
	return "$ "
}
