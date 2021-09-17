# Create_Synology_Recovery_Boot_Image
Simple script to create a Windows 10 bootable recovery OS for Synology Active Backup

## Requirements
The following is needed to build a bootable Windows recovery image for Synology.
* Windows 10
* Windows ADK 1803 installed <https://go.microsoft.com/fwlink/?linkid=873065>
* Synology Recovery Tool zip file <https://www.synology.com/support/download>
* Target PC's Network/LAN drivers (your PC vendor)

## Getting Started
Download the script and update the _variables_ section with your specific
settings. It's easiest to run the script from the same directory where
your required files are. 

Run the script from the command line as Administrator. 

After the script is run it will clean up after itself and leave the new 
Windows bootable ISO. Burn the ISO to a bootable CD or USB disk.

Enjoy.

## Contributing


Copyright (c) 2021 @ethanpeterson
