#!/bin/bash

# Specify source and destination directories
isoSourceDir="$PWD/iso-source"
isoOutputDir="$PWD/iso-output"

# Copy custom files to ISO source directory
cp -r custom-files/* "$isoSourceDir"

# Modify a configuration file (example: config.txt)
configPath="$isoSourceDir/config.txt"

# Modify settings in the configuration file
sed -i 's/ReplaceMeWithSetting1/NewValue1/' "$configPath"
sed -i 's/ReplaceMeWithSetting2/NewValue2/' "$configPath"

# Create the customized ISO
isoName="custom-linux.iso"
isoPath="$isoOutputDir/$isoName"

# Run a tool to create the ISO (replace with your ISO creation command)
# Example: mkisofs -o "$isoPath" -R "$isoSourceDir"
# Replace this example command with the actual tool/command you use.

echo "Custom Linux ISO has been created: $isoPath"
