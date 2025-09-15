# Define regex patterns
$upperDirPattern = '^[A-Z]{1,2}\d{3,4}_c\d*$'
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
    } else {
        # Check for file names
        if (-not ($item.Name -match $filePattern)) {
            $invalidNames += "Invalid file name: $($item.FullName)"
        }
    }
}

# Output invalid names
if ($invalidNames.Count -eq 0) {
    Write-Host "All directory and file names are valid."
} else {
    $invalidNames | ForEach-Object { Write-Host $_ }
}
