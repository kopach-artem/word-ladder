# WORD LADDER GENERATOR — ChatGPT API (supports manual and test mode)

# Step 0: Load API key from .env
$envPath = ".\.env"
if (Test-Path $envPath) {
    Get-Content $envPath | ForEach-Object {
        if ($_ -match "^\s*OPENAI_API_KEY\s*=\s*(.+)\s*$") {
            $env:OPENAI_API_KEY = $Matches[1].Trim()
        }
    }
} else {
    Write-Error "Missing .env file. Define OPENAI_API_KEY=<your_key>"
    exit 1
}

# Step 1: Read input words from args or prompt
if ($args.Count -ge 2) {
    $startWord = $args[0]
    $endWord = $args[1]
    $isTestMode = ($args.Count -ge 3 -and $args[2] -eq "testmode")
} else {
    $startWord = Read-Host "Enter the START word"
    $endWord = Read-Host "Enter the END word"
    $isTestMode = $false
}

# Step 2: Generate prompt
$prompt = "Find the shortest possible transformation sequence from '$startWord' to '$endWord' by changing exactly one letter at each step. Each word must be a valid English word of the same length. Return only the optimal (shortest) word ladder as a list of words, in order. If multiple optimal paths exist, return any one. Avoid repeated or unnecessary steps."

Write-Host "`nPrompt sent to ChatGPT:"
Write-Host $prompt

# Step 3: Call ChatGPT API
$apiKey = $env:OPENAI_API_KEY
$uri = "https://api.openai.com/v1/chat/completions"
$headers = @{
    "Authorization" = "Bearer $apiKey"
    "Content-Type"  = "application/json"
}
$body = @{
    model = "gpt-3.5-turbo"
    messages = @(
        @{ role = "user"; content = $prompt }
    )
} | ConvertTo-Json -Depth 10

Write-Host "`nSending request to ChatGPT..."

try {
    $response = Invoke-RestMethod -Uri $uri -Method Post -Headers $headers -Body $body
} catch {
    Write-Error "API call failed: $_"
    exit 1
}

# Step 4: Display result
$result = $response.choices[0].message.content

Write-Host "`n--- Word Ladder Result ---`n"
Write-Host $result

# Step 5: Save to file only if not in test mode
if (-not $isTestMode) {
    $existing = Get-ChildItem -Path . -Filter "run_*.txt" | Sort-Object Name
    if ($existing.Count -eq 0) {
        $runNumber = 1
    } else {
        $lastFile = $existing[-1].Name
        if ($lastFile -match 'run_(\d+)\.txt') {
            $runNumber = [int]$Matches[1] + 1
        } else {
            $runNumber = 1
        }
    }

    $filename = "run_$runNumber.txt"
    Set-Content -Path $filename -Value $result -Encoding UTF8
    Write-Host "`nSaved result to: $filename"

    notepad.exe $filename
}
