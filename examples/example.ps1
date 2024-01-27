# This is is an example usage.
# Put this code in a powershell profile
# The usual path is '$Home\Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1'

# Load or copy and paste the '__git_ps1' function here

function prompt {
    Write-Host -NoNewline -ForegroundColor Cyan "$(Get-Location) "
	Write-Host -NoNewline -ForegroundColor Green "($(__git_ps1)) "
	
	return "$ "
}
