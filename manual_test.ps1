# MANUAL TEST RUNNER

$testCases = @(
    @{ start = "head"; end = "tail"; expected = @("head", "heal", "teal", "tell", "tall", "tail") },
    @{ start = "flip"; end = "flop"; expected = @("flip", "flop") },
    @{ start = "save"; end = "cost"; expected = @("save", "case", "cast", "cost") },
    @{ start = "cold"; end = "warm"; expected = @("cold", "cord", "card", "ward", "warm") },
    @{ start = "game"; end = "play"; expected = @("game", "gape", "pape", "pale", "poll", "poly", "play") },
    @{ start = "cold"; end = "heat"; expected = @("cold", "cord", "card", "hard", "hart", "heat") },
    @{ start = "node"; end = "mode"; expected = @("node", "mode") },
    @{ start = "barn"; end = "farm"; expected = @("barn", "bare", "fare", "farm") },
    @{ start = "book"; end = "cook"; expected = @("book", "cook") },
    @{ start = "calf"; end = "lamb"; expected = @("calf", "call", "ball", "balk", "bank", "lank", "lamp", "lamb") }
)

# Determine next report index
$existingReports = Get-ChildItem -Path . -Filter "run_manual_test_report_*.txt" | Sort-Object Name
$reportNumber = if ($existingReports.Count -eq 0) { 1 } else {
    $lastName = $existingReports[-1].Name
    if ($lastName -match 'run_manual_test_report_(\d+)\.txt') { [int]$Matches[1] + 1 } else { 1 }
}
$reportFile = "run_manual_test_report_$reportNumber.txt"
New-Item -Path $reportFile -ItemType File -Force | Out-Null
Add-Content $reportFile "=== MANUAL TEST REPORT #$reportNumber ==="
Add-Content $reportFile "Generated: $(Get-Date)`n"

$total = $testCases.Count
$passed = 0
$failed = 0

# Run tests
foreach ($i in 0..($testCases.Count - 1)) {
    $case = $testCases[$i]
    $start = $case.start
    $end = $case.end
    $expected = $case.expected

    Write-Host "Running Test $($i + 1)/${total}: [$start -> $end]" -ForegroundColor Cyan

    # Call script and capture output
    $output = powershell -ExecutionPolicy Bypass -File .\word-ladder.ps1 $start $end "testmode" | Out-String
    $lines = $output -split "`r?`n"
    $actual = @()

    # Extract actual path from output
    foreach ($line in $lines) {
        # If line is in format ['word1', 'word2', ...]
        if ($line -match "^\['.*'\]$") {
            $line -replace "[\[\]']", "" -split ",\s*" | ForEach-Object {
                $actual += $_.Trim().ToLower()
            }
        }
        elseif ($line -match "^[a-zA-Z]{3,}$") {
            $actual += $line.ToLower()
        }
    }

    $expectedStr = $expected -join " -> "
    $actualStr = $actual -join " -> "
    $gptOutput = $output.Trim()

    $result = if ($actual -join "," -eq $expected -join ",") {
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
    Write-Host "  Expected: $expectedStr"
    Write-Host "  Actual:   $actualStr"
    Write-Host "  Status:   $result`n" -ForegroundColor $color

    # File report
    Add-Content $reportFile @"
--- TEST CASE #$($i + 1) ---
Start Word:  $start
End Word:    $end

GPT output:
$gptOutput

Expected:    $expectedStr
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
