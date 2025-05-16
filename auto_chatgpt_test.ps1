# AUTO TEST RUNNER (ChatGPT-based, NO expected)

# Step 0: Load API Key from .env
$envPath = ".\.env"
if (!(Test-Path $envPath)) {
    Write-Error "Missing .env file. Define OPENAI_API_KEY=<your_key>"
    exit 1
}
Get-Content $envPath | ForEach-Object {
    if ($_ -match "^\s*OPENAI_API_KEY\s*=\s*(.+)\s*$") {
        $env:OPENAI_API_KEY = $Matches[1].Trim()
    }
}

# Step 1: Generate word pairs with GPT
$prompt = "Generate 10 pairs of valid English words of the same length that can be transformed from one to another by changing one letter at a time. Format: word1 -> word2"

$headers = @{
    "Authorization" = "Bearer $env:OPENAI_API_KEY"
    "Content-Type"  = "application/json"
}
$body = @{
    model = "gpt-3.5-turbo"
    messages = @(@{ role = "user"; content = $prompt })
} | ConvertTo-Json -Depth 10

try {
    $response = Invoke-RestMethod -Uri "https://api.openai.com/v1/chat/completions" -Method Post -Headers $headers -Body $body
} catch {
    Write-Error "Failed to contact ChatGPT: $_"
    exit 1
}

# Step 2: Parse pairs
$lines = $response.choices[0].message.content -split "`r?`n"
$testCases = @()
foreach ($line in $lines) {
    if ($line -match "^\s*\d*\.?\s*(\w+)\s*->\s*(\w+)\s*$") {
        $testCases += @{
            start = $Matches[1]
            end = $Matches[2]
        }
    }
}

if ($testCases.Count -eq 0) {
    Write-Error "No valid test pairs found."
    exit 1
}

# Step 3: Prepare report
$existingReports = Get-ChildItem -Path . -Filter "run_auto_test_report_*.txt" | Sort-Object Name
$reportNumber = if ($existingReports.Count -eq 0) { 1 } else {
    $lastName = $existingReports[-1].Name
    if ($lastName -match 'run_auto_test_report_(\d+)\.txt') { [int]$Matches[1] + 1 } else { 1 }
}
$reportFile = "run_auto_test_report_$reportNumber.txt"
New-Item -Path $reportFile -ItemType File -Force | Out-Null
Add-Content $reportFile "=== AUTO TEST REPORT #$reportNumber ==="
Add-Content $reportFile "Generated: $(Get-Date)`n"

$total = $testCases.Count
$passed = 0
$failed = 0

# Step 4: Run tests
foreach ($i in 0..($testCases.Count - 1)) {
    $case = $testCases[$i]
    $start = $case.start
    $end = $case.end

    Write-Host "Running Test $($i + 1)/${total}: [$start -> $end]" -ForegroundColor Cyan

    # Call ladder script
    $output = powershell -ExecutionPolicy Bypass -File .\word-ladder.ps1 $start $end "testmode" | Out-String
    $linesOut = $output -split "`r?`n"
    $actual = @()

    foreach ($line in $linesOut) {
        if ($line -match "^\['.*'\]$") {
            $line -replace "[\[\]']", "" -split ",\s*" | ForEach-Object {
                $actual += $_.Trim().ToLower()
            }
        } elseif ($line -match "^[a-zA-Z]{3,}$") {
            $actual += $line.ToLower()
        }
    }

    $actualStr = $actual -join " -> "
    $gptOutput = $output.Trim()

    $result = if ($actual.Count -ge 2 -and $actual[0] -eq $start.ToLower() -and $actual[-1] -eq $end.ToLower()) {
        $passed++
        "PASSED"
    } else {
        $failed++
        "FAILED"
    }

    $color = if ($result -eq "PASSED") { "Green" } else { "Red" }

    # Console output
    Write-Host "  GPT output:" -ForegroundColor DarkYellow
    Write-Host "  $gptOutput`n"
    Write-Host "  Actual: $actualStr"
    Write-Host "  Status: $result`n" -ForegroundColor $color

    # File output
    Add-Content $reportFile @"
--- TEST CASE #$($i + 1) ---
Start Word:  $start
End Word:    $end

GPT output:
$gptOutput

Actual:      $actualStr
Status:      $result

"@
}

# Summary
$successRate = [math]::Round(100 * $passed / $total, 2)
$summary = @"
=== SUMMARY ===
Total Tests:   $total
Passed:        $passed
Failed:        $failed
Success Rate:  $successRate%

Report saved to: $reportFile
"@
Add-Content $reportFile "`n$summary"
Write-Host $summary -ForegroundColor Yellow
