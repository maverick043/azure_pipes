# CustomizeWindowsISO.ps1

# Specify source and destination directories
$isoSourceDir = "$PSScriptRoot\iso-source"
$isoOutputDir = "$PSScriptRoot\iso-output"

# Copy custom files to ISO source directory
Copy-Item -Path "$PSScriptRoot\custom-files\*" -Destination $isoSourceDir -Recurse

# Modify a configuration file (example: unattend.xml)
$unattendXmlPath = Join-Path $isoSourceDir "unattend.xml"
$unattendXmlContent = Get-Content -Path $unattendXmlPath -Raw

# Modify settings in the XML content
$modifiedXmlContent = $unattendXmlContent -replace "ReplaceMeWithSetting1", "NewValue1" `
                                          -replace "ReplaceMeWithSetting2", "NewValue2"

$modifiedXmlContent | Set-Content -Path $unattendXmlPath

# Create the customized ISO
$isoName = "custom-windows.iso"
$isoPath = Join-Path $isoOutputDir $isoName

# Run a tool to create the ISO (replace with your ISO creation command)
# Example: genisoimage -o $isoPath -r "$isoSourceDir"
# Replace this example command with the actual tool/command you use.

Write-Host "Custom Windows ISO has been created: $isoPath"
