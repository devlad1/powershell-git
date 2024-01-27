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
