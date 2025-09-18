# Define regex patterns
$upperDirPattern = '(^C\d{4}_c\d+)|([A-Z]{2}\d{3}_c\d+)$'
$secondTierDirPattern = '^[\w\s\p{P}]+$'
$filePattern = '^\d{8}\.(tif)$'

# Get all directories and files 
$items = Get-ChildItem -Recurse

# Make an array for invalid names
$errors = @()

# Check each item
foreach ($item in $items) {
    if ($item.PSIsContainer) {
        # Check for uppermost directories
        if ($item.Parent.FullName -eq (Get-Location).Path -and -not ($item.Name -match $upperDirPattern)) {
            $errors += "Invalid top-directory name: $($item.FullName)"
        }
        # Check second-tier directories
        if ($item.Parent.FullName -ne (Get-Location).Path -and -not ($item.Name -match $secondTierDirPattern)) {
            $errors += "Invalid sub-directory name: $($item.FullName)"
        }
        #Check nesting
        if ($item.Parent.FullName -ne (Get-Location).Path) {
            $subItems = Get-ChildItem -Path $item.FullName -Directory
            foreach ($subitem in $subItems) {
            if ($subitem.PSIsContainer) {
                $errors += "Subdirectory nested too deep: $($subitem.FullName)"
            }
          }
        }
    } else {
        # Check for file names
        if (-not ($item.Name -match $filePattern)) {
            $errors += "Invalid file name or extension: $($item.FullName)"
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
                $errors += "Files out of sequence in this directory: $($dir.FullName) (check following file number $($numbers[$i].ToString().PadLeft(8, '0')))"
            }
        }
    }
}

# Output invalid names
if ($errors.Count -eq 0) {
    Write-Host "All directory and file names are valid."
} else {
    $errors | ForEach-Object { Write-Host $_ }
}
