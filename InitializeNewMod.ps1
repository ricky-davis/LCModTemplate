# Ask for the new mod name
$newModName = Read-Host "Please enter the new mod name"

# Define the directory where the files are located
$directoryPath = Get-Location

# Update .csproj file
$csprojFile = Get-ChildItem -Path $directoryPath -Filter "ModTemplate.csproj" -Recurse
$content = Get-Content $csprojFile.FullName
$content = $content -replace "ModTemplate", $newModName
Set-Content -Path $csprojFile.FullName -Value $content

# Get all files and directories in the directory
$items = Get-ChildItem -Path $directoryPath -Recurse

# Get all files in the directory
$files = Get-ChildItem -Path $directoryPath -Recurse -File
foreach ($file in $files) {
    # Replace "ModTemplate" in the content of each file
    $fileContent = Get-Content $file.FullName -Raw
    $fileContent = $fileContent -replace "ModTemplate", $newModName
    Set-Content -Path $file.FullName -Value $fileContent

    # Rename the file if it contains "ModTemplate"
    $newName = $file.Name -replace "ModTemplate", $newModName
    if ($newName -ne $file.Name) {
        Rename-Item -Path $file.FullName -NewName $newName
    }
}


# Rename directories
$directories = Get-ChildItem -Path $directoryPath -Recurse -Directory | Sort-Object FullName -Descending
foreach ($directory in $directories) {
    $newDirectoryName = $directory.Name -replace "ModTemplate", $newModName
    if ($newDirectoryName -ne $directory.Name) {
        Rename-Item -Path $directory.FullName -NewName $newDirectoryName
    }
}

Write-Host "Mod setup complete."