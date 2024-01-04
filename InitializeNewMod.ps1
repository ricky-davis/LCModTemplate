# Get the name of the current directory
$currentDirectory = Split-Path -Path $PWD -Leaf

# Suggest the current directory name as the default mod name and ask for user input
$newModName = Read-Host "Please enter the new mod name (default: $currentDirectory)"
if (-not $newModName) {
    $newModName = $currentDirectory
}

# Define the directory where the files are located
$directoryPath = $PWD

# Update .csproj file
$csprojFile = Get-ChildItem -Path $directoryPath -Filter "ModTemplate.csproj" -Recurse
$content = Get-Content $csprojFile.FullName

# Format the new mod name for the <Product> tag (PascalCase to spaced words)

$formattedModName = ""
$newModName.ToCharArray() | ForEach-Object {
    if ($_ -cmatch "[A-Z]" -and $formattedModName.Length -gt 0) {
        $formattedModName += " " + $_
    } else {
        $formattedModName += $_
    }
}

# Replace "ModTemplate" and format "Mod Template" with the new mod name in the .csproj file
$content = $content -replace "<Product>Mod Template</Product>", "<Product>$formattedModName</Product>"


Set-Content -Path $csprojFile.FullName -Value $content

# Get the path of the currently running script
$currentScriptPath = $MyInvocation.MyCommand.Definition

# Get all files in the directory, excluding the current script
$files = Get-ChildItem -Path $directoryPath -Recurse -File | Where-Object { $_.FullName -ne $currentScriptPath -and $_.FullName -notmatch "\\.git\\" }
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