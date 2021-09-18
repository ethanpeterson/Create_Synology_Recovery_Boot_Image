@ECHO OFF

:: Description  : Script to create a Windows 10 bootable recovery OS for Synology Active Backup
:: Created      : 15-Sep-2021
:: Prerequisites: 
::     Windows ADK installed (https://go.microsoft.com/fwlink/?linkid=873065)
::     Synology Recovery Tool zip file (https://www.synology.com/support/download)
::     Target PC's Network/LAN drivers
:: Instructions:
::     Make sure all prerequisites are met
::     Change any of the variables below to your liking
::     Add LAN drivers and other drivers into your "Drivers" directory
::     Create a bootable ISO with the output of this script

:: variables
SET targetdirectory=E:\temp\
SET sourcedirectory=E:\temp\
SET winpefolder=winpe
SET adkdirectory=C:\Program Files (x86)\Windows Kits\10\Assessment and Deployment Kit\Deployment Tools
SET timezone=Central Standard Time
SET recoverytoolname=Synology Recovery Tool-x64-2.2.0-2074.zip
SET driverfoldername=Drivers
SET isoname=custom_pe_amd64.iso

:: paths
SET winpepath=%targetdirectory%%winpefolder%
SET recoverytoolpath=%sourcedirectory%%recoverytoolname%
SET driverpath=%sourcedirectory%%driverfoldername%
SET imagename=%targetdirectory%%isoname%

:: clean up left over directories
ECHO =============================
ECHO Preliminary cleanup
ECHO =============================
IF EXIST %winpepath%\ (
    rmdir %winpepath% /s /q
) ELSE (
    ECHO Nothing found to cleanup, continuing...
)

:: CD to ADK tools as Administrator
pushd %adkdirectory%

:: set environments
CALL DandISetEnv.bat

:: copy the base image to the working directory
CALL copype.cmd amd64 %winpepath%

:: create the image and mount it
ECHO =============================
ECHO Creating the image and mounting it
ECHO =============================
CALL Dism.exe /Mount-Wim /WimFile:"%winpepath%\media\sources\boot.wim" /index:1 /MountDir:"%winpepath%\mount"

:: create the Synology specific directory "ActiveBackup"
mkdir %winpepath%\mount\ActiveBackup

:: unzip the Synology files into the ISO directory
IF EXIST %recoverytoolpath% (
    ECHO =============================
    ECHO Extracting Zip contents from %recoverytoolpath%...
    ECHO =============================
    pushd %winpepath%\mount\ActiveBackup
    tar -xf "%recoverytoolpath%"
    ECHO =============================
    ECHO Unzip complete, moving on...
    ECHO =============================
    pushd %adkdirectory%
    GOTO :SETTIMEZONE
) ELSE (
    ECHO No Active Backup Recovery Zip file found, exiting...
    GOTO :CANCEL
)

:: set the local timezone
:SETTIMEZONE
CALL Dism.exe /Image:"%winpepath%\mount" /Set-TimeZone:"%timezone%"
ECHO =============================
ECHO Timezone has been set
ECHO =============================

:: if the driver directory exists then copy the drivers into our image
IF EXIST %driverpath%\ (
    ECHO =============================
    ECHO Copying LAN drivers
    ECHO =============================
    CALL Dism.exe /Image:"%winpepath%\mount" /Add-Driver /Driver:"%driverpath%" /Recurse
    ECHO =============================
    ECHO Drivers copy complete...
    ECHO =============================
) ELSE (
    ECHO No drivers found
)

:: unmount and commit image
ECHO =============================
ECHO Save and unmount image...
ECHO =============================
CALL Dism.exe /Unmount-Wim /MountDir:"%winpepath%\mount" /COMMIT

:: build an ISO of this image
ECHO =============================
ECHO Create ISO
ECHO =============================
CALL MakeWinPEMedia /ISO %winpepath% %imagename%
ECHO =============================
ECHO ISO creation complete
ECHO =============================

:: cleanup
rmdir %winpepath% /s /q
ECHO =============================
ECHO Directory cleaned up
ECHO =============================

:: create Bootable USB drive (as MBR) with Rufus from the ISO

:COMPLETE
ECHO Image successfully created!
ECHO Don't forget to create a bootable USB with this ISO ^(%imagename%^)
GOTO :END

:CANCEL
CALL Dism.exe /Unmount-Wim /MountDir:"%winpepath%\mount" /COMMIT
CALL DISM /cleanup-wim
ECHO Image unmounted

:END
ECHO The End.
