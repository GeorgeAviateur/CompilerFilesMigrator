# Created by Jorge Garcia, all rights reserved. Not for commercial use, it's not even that perfect for that purpose anyway :v .
# Source directories (add as many as needed)
# Keep in mind that these routes should be subfolders inside the destination server. Do not use paths such as:
#C:\Users\MyUser\source\repos\Compiled
#use C:\Users\MyUser\source\repos\Compiled\Subfolder1
#Don't you dare! ¡Ni loco mi llave!
#Necessary files like favicon.ico, web.config, packages.config, located in the main folder, may be moved manually.

##1. These are the folders compiled by the dev engine
$sourcePaths = @(
    "C:\Users\MyUser\source\repos\compiled(bin)\Controllers",
    "C:\Users\MyUser\source\repos\compiled\Utilities",
	"...",
)


##2. Add the destination folders
# Destination folders
#Sample: $destination1 = "AA:\VirtualPath\MyProject\myTargetForder"
$destination1 = "C:\Users\MyUser\source\repos\compilado\T1"
$destination2 = "C:\Users\MyUser\source\repos\compilado\T2"

$chromePath = "C:\Program Files\Google\Chrome\Application\chrome.exe"  # Update Chrome path if necessary

## When the process is finished, the program tries to open this in the browser.
$UrlDePruebas1="http://bills/VirtualPath/home.aspx"


################## LOGIC #####################

# Prompt user to choose the destination folder
Write-Host "Choose the target folder:"
Write-Host "1. $destination1"
Write-Host "2. $destination2"
$choice = Read-Host "Enter your choice (1 or 2)"

# Determine the target folder based on user input
if ($choice -eq 1) {
    $destinationPath = $destination1
} elseif ($choice -eq 2) {
    $destinationPath = $destination2
} else {
    Write-Host "Invalid choice. Exiting."
    exit
}

# Ensure destination exists
if (!(Test-Path -Path $destinationPath)) {
    New-Item -ItemType Directory -Path $destinationPath
}

# Function to display progress
function Show-Progress {
    param (
        [int]$current,
        [int]$total
    )
    $percent = [math]::Round(($current / $total) * 100, 2)
    Write-Host "`rCopying files: $percent% complete" -NoNewline -ForegroundColor Yellow
}

# File copying process with progress percentage
foreach ($sourcePath in $sourcePaths) {
    Write-Host "Moving files from $sourcePath to $destinationPath, excluding web.config..." -ForegroundColor Gray

    # Get the name of the source folder (e.g., SST or bin)
    $parentFolderName = Split-Path -Path $sourcePath -Leaf
    $destinationFolderPath = Join-Path -Path $destinationPath -ChildPath $parentFolderName

    # Ensure the destination subfolder exists
    if (!(Test-Path -Path $destinationFolderPath)) {
        New-Item -ItemType Directory -Path $destinationFolderPath
    }

    # Get all files except web.config
    $allFiles = Get-ChildItem -Path $sourcePath -Recurse | Where-Object { $_.Name -ne "web.config" }
    $totalFiles = $allFiles.Count
    $currentFile = 0

    foreach ($file in $allFiles) {
        # Calculate the relative path
        $relativePath = $file.FullName.Substring($sourcePath.Length).TrimStart("\")
        $targetPath = Join-Path -Path $destinationFolderPath -ChildPath $relativePath

        # Ensure the target directory exists
        $targetDir = Split-Path -Path $targetPath -Parent
        if (!(Test-Path -Path $targetDir)) {
            New-Item -ItemType Directory -Path $targetDir -Force
        }

        # Copy the file
        $maxRetries = 3
		$attempt = 0
		$copySucceeded = $false
		
		while (-not $copySucceeded) {
			try {
					# Check if destination is reachable before proceeding
				if (!(Test-Path $destinationPath)) {
					Write-Host "`n[Error] Destination path '$destinationPath' not available. Check network or drive mapping." -ForegroundColor Red
					Write-Host "Press any key to retry..." -ForegroundColor Yellow
					$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
					continue  # Skip to next iteration
				}
				
				$robocopyCmd = "robocopy `"$sourcePath`" `"$destinationFolderPath`" /MIR /R:3 /W:5 /XD web.config /MT:16 /LOG+:copylog.txt /NFL /NDL"
				$robocopyResult = Invoke-Expression $robocopyCmd
				$exitCode = $LASTEXITCODE
				
				# Robocopy exit codes reference: 0-7 = success
				if ($exitCode -gt 7) {
					Write-Host "`n[Error] Robocopy failed with exit code $exitCode for path: $sourcePath" -ForegroundColor Red
					Write-Host "Press any key to retry..." -ForegroundColor Yellow
					$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
					$attempt = 0
					continue
				} else {
					$copySucceeded = $true
				}
				
			$copySucceeded = $true
			}
			catch {
				$attempt++
				Write-Host "`n[Error] Failed to copy $($file.FullName) (Attempt $attempt of $maxRetries)" -ForegroundColor Red
		
				if ($attempt -lt $maxRetries) {
					Write-Host "Retrying in 5 seconds..." -ForegroundColor Yellow
					Start-Sleep -Seconds 5
				} else {
					Write-Host "Network might be down. Press any key to retry this file..." -ForegroundColor Cyan
					$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
					$attempt = 0  # Reset retry count after user prompt
				}
			}
		}
		
		$currentFile++
		Show-Progress -current $currentFile -total $totalFiles

        # Update progress
        Show-Progress -current $currentFile -total $totalFiles
    }
}

Write-Host "`rFiles moved successfully to $destinationPath, excluding web.config." -ForegroundColor Green

# Open Chrome at the end of the script
Write-Host "Launching Chrome..."
$startUrl = if ($choice -eq 1) { $UrlDePruebas1 } else { $UrlDePruebas2 }
Start-Process -FilePath $chromePath -ArgumentList $startUrl

###################### Enjoy the Imperial March #####################

function Play-Note {
    param(
        [int]$frequency,
        [int]$duration
    )
    [console]::Beep($frequency, $duration)
    Start-Sleep -Milliseconds 10
}

# Imperial March (Darth Vader's Theme)
Play-Note 440 500  # A4
Play-Note 440 500  # A4
Play-Note 440 500  # A4
Play-Note 349 250  # F4
Play-Note 523 350  # C5
Play-Note 440 500  # A4
Start-Sleep -Milliseconds 150
Play-Note 349 250  # F4
Play-Note 523 350  # C5
Play-Note 440 700  # A4

Write-Host "Process completed successfully!" -ForegroundColor Green


##Happy days, mate!
