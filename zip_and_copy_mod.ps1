$mod = "configurable-nukes"
$version = "0.1.0"

# $mod_directory = $mod + "_"
$mod_directory = $mod
# $full = $mod_directory + $version

# $full = $mod + "_" + $version
$full = $mod
$versioned_mod = $mod + "_" + $version

# Path to your mod
# $dev_path = "G:\Factorio\Mods\dev\" + $mod
$dev_path = "D:\mods\_dev\Factorio\" + $mod
# Default path to Factorio mods
$destination = $env:APPDATA + "\Factorio\mods\"

$source_directory = $dev_path + "\" + $mod
$output_directory = $mod_directory + "_" + $version

$zip = ".zip"
# $dev_full = $dev_path + "\" + $full
# $dev_full = $dev_path + "\" + $versioned_mod
$dev_full = $dev_path + "\" + $mod
$dev_full_versioned = $dev_full + "_" + $version

# Delete the old .zip file from the dev directory
Write-Output ("Deleteing " + ($dev_full_versioned + $zip))
del ($dev_full_versioned + $zip)

# Zip the contents of the mod folder
# Write-Output ("Zipping " + ($dev_full + "\") + " to " + ($dev_full + $zip))
# Compress-Archive ($dev_full + "\") ($dev_full + $zip)
Write-Output ("Zipping " + ($dev_full + "\") + " to " + ($dev_full_versioned + $zip))
Compress-Archive ($dev_full + "\") ($dev_full_versioned + $zip)

# Delete the old .zip file from the Factorio\mods folder
# Write-Output ("Deleteing " + ($destination + $full + $zip))
# del ($destination + $full + $zip)
Write-Output ("Deleteing " + ($destination + $versioned_mod + $zip))
del ($destination + $versioned_mod + $zip)

# Copy the .zip from the dev folder to the Factorio\mods folder
# Write-Output ("Copying " + ($dev_full + $zip) + " to " + $destination)
# Copy-Item ($dev_full + $zip) -Destination $destination
Write-Output ("Copying " + ($dev_full_versioned + $zip) + " to " + $destination)
Copy-Item ($dev_full_versioned + $zip) -Destination $destination