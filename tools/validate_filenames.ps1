# Define regex patterns
$upperDirPattern = '(^C\d{4}_c\d+)|([A-Z]{2}\d{3}_c\d+)$'
$secondTierDirPattern = '^[\w\s\p{P}]+$'
$filePattern = '^\d{8}\.(tif)$'

# Get all directories and files recursively
$items = Get-ChildItem -Recurse

# Make an array for invalid names
$invalidNames = @()

# Check each item
foreach ($item in $items) {
    if ($item.PSIsContainer) {
        # Check for uppermost directories
        if ($item.Parent.FullName -eq (Get-Location).Path -and -not ($item.Name -match $upperDirPattern)) {
            $invalidNames += "Invalid upper directory name: $($item.FullName)"
        }
        # Check for second-tier directories
        elseif ($item.Parent.FullName -ne (Get-Location).Path -and -not ($item.Name -match $secondTierDirPattern)) {
            $invalidNames += "Invalid second-tier directory name: $($item.FullName)"
        }
        if ($item.Parent.FullName -ne (Get-Location).Path) {
            $subItems = Get-ChildItem -Path $item.FullName -Directory
            foreach ($subitem in $subItems) {
            if ($subitem.PSIsContainer) {
                $invalidNames += "Nested subdirectory $($subitem) not allowed at this level"
            }
          }
        }
    } else {
        # Check for file names
        if (-not ($item.Name -match $filePattern)) {
            $invalidNames += "Invalid file name: $($item.FullName)"
        }
    }
}

# Check for sequential filenames in the lowest level directories
$lowestLevelDirs = Get-ChildItem -Recurse -Directory | Where-Object { $_.GetFiles().Count -gt 0 }

foreach ($dir in $lowestLevelDirs) {
    $files = Get-ChildItem -Path $dir.FullName -File | Where-Object { $_.Name -match $filePattern }
    $numbers = $files | ForEach-Object { [int]$_.BaseName } | Sort-Object

    # Check for sequential numbers
    if ($numbers.Count -gt 1) {
        for ($i = 0; $i -lt $numbers.Count - 1; $i++) {
            if ($numbers[$i + 1] -ne $numbers[$i] + 1) {
                $invalidNames += "Non-sequential file names in directory: $($dir.FullName) following file number $($numbers[$i].ToString().PadLeft(8, '0'))."
                break
            }
        }
    }
}

# Output invalid names
if ($invalidNames.Count -eq 0) {
    Write-Host "All directory and file names are valid."
} else {
    $invalidNames | ForEach-Object { Write-Host $_ }
}
