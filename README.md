# vmdStore
vmdStore provides a user-friendly interface to free install VMD plugins. vmdStore also helps you keeping the plugins always updated.

![Logo](https://i.imgur.com/fH1A93b.gif)

![vmdStore](https://i.imgur.com/pt2Yydd.jpg)

## Minimum Requirements
Operating System: macOS, Linux, or Windows

Visual Molecular Dynamics (VMD) 1.9.3 or later

## Installation 
1. You can install VMD Store through the Tk Console on VMD:

   This installation can be used on every machine running VMD 1.9.3 or later.
   
   a. Download and unpack the installer:
   
   [![Download vmdStore](https://a.fsdn.com/con/app/sf-download-button)](https://sourceforge.net/projects/vmdstore/files/VMD%20Store%20Installer%20through%20VMD%20Tk%20Console/download)
   
   b. Launch VMD (1.9.3 or later) and open the Tk Console (Extensions > Tk Console);
   
   c. Go to the installer directory on Tk Console. Example:
   
   ```
   cd /home/users/myname/Downloads/vmdStore-Installer
   ```
   
   d. Run the following command on Tk Console:
   
   ```
   play vmdStore-install.tcl
   ```
   
   e. Follow the instructions;
   
   f. Done!
   
      Re-launch VMD and open VMD Store at Extensions > VMD Store > VMD Store.
      
      

2. or the GUI installer:

Available for Windows, macOS, and Linux.

[![Download vmdStore](https://a.fsdn.com/con/app/sf-download-button)](https://sourceforge.net/projects/vmdstore/files/latest/download)

[![Download vmdStore](https://img.shields.io/sourceforge/dt/vmdstore.svg)](https://sourceforge.net/projects/vmdstore/files/latest/download)
[![Download vmdStore](https://img.shields.io/sourceforge/dd/vmdstore.svg)](https://sourceforge.net/projects/vmdstore/files/latest/download)
[![Download vmdStore](https://img.shields.io/sourceforge/dw/vmdstore.svg)](https://sourceforge.net/projects/vmdstore/files/latest/download)
[![Download vmdStore](https://img.shields.io/sourceforge/dm/vmdstore.svg)](https://sourceforge.net/projects/vmdstore/files/latest/download)


3. or the bash script:

[![Download vmdStore](https://a.fsdn.com/con/app/sf-download-button)](https://sourceforge.net/projects/vmdstore/files/vmdStore-Installer-Script.zip/download)

<!---
[Download vmdStore for Windows](http://bit.ly/vmdStore-Windows)
[Download vmdStore for Linux](http://bit.ly/vmdStore-Linux)
[Download vmdStore for macOS](http://bit.ly/vmdStore-macOS)
Total of Downloads: 45 (updated on March 20th 2018) (7)
-->


4. or manually according to the following tutorial.


### Manual Installation
1. Download or clone the repository.

2. Copy the "vmdStore" directory, which is located inside the download package, to a Read&Write allowed directory on your system.

3. Edit the "vmdStore/vmdStore.rc" file to replace the "none" word by the path where the vmdStore directory is located. Example: "/home/users/name/vmdStore". (Attention: Enclose the path in quotation marks)

4. Add the following lines to your .vmdrc or vmd.rc file:

Replace the "none" word by the path where the vmdStore.rc file is located. Example: "/home/users/name/vmdStore/vmdStore.rc"

```
##### VMD Store ## START #####
play none
##### VMD Store ## END #####
```

5. Start VMD. It could be necessary to restart VMD on first launch after vmdStore installation.

## Bug Report/Suggestions
If you want to report bugs or suggest features, please contact me: henrique.fernandes@fc.up.pt

If you want to include your own VMD plugin on VMD Store, send an email to henrique.fernandes@fc.up.pt

## Available Plugins
### Alanine Scanning Mutagenesis
 - compASM (https://github.com/BioSIM-Research-Group/compASM)

### Education
 - vmdMagazine (https://github.com/BioSIM-Research-Group/vmdMagazine

### Molecular Mechanics
 - DelPhiForceVMD (https://github.com/delphi001/DelPhiForceVMD)
 - Pathways (https://github.com/balabin/pathways)

### QM/MM
 - molUP (https://github.com/BioSIM-Research-Group/molUP)
 
### Tools
 - toolBar (https://github.com/BioSIM-Research-Group/toolBar)
 - selectionManager (https://github.com/BioSIM-Research-Group/selectionManager)
 - chemPathTracker (https://github.com/BioSIM-Research-Group/chemPathTracker)
 - volArea (https://github.com/BioSIM-Research-Group/volArea)

### Molecular Docking
 - vsLab (https://github.com/BioSIM-Research-Group/vsLab)
