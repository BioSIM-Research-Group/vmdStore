# vmdStore
vmdStore provides a user-friendly interface to free install VMD plugins. vmdStore also helps you keeping the plugins always updated.

![Logo](https://i.imgur.com/fH1A93b.gif)

![vmdStore](https://i.imgur.com/pt2Yydd.jpg)

## Minimum Requirements
Operating System: macOS, Linux, or Windows

Visual Molecular Dynamics (VMD) 1.9.3 or later

## Installation 
You can install vmdStore through the installer:

[Download vmdStore for Windows](http://www.mediafire.com/file/kdcqrikq0i4z4kd/VMD_Store_Installer.zip)

[Download vmdStore for Linux](http://www.mediafire.com/file/q8cduvamdaomdvv/vmdStore)

[Download vmdStore for macOS](http://www.mediafire.com/file/1u9zh7kj7344ucg/vmdStore.dmg)





or manually according to the following tutorial.


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
 - compASM (https://github.com/portobiocomp/compASM)

### Education
 - vmdMagazine (https://github.com/portobiocomp/vmdMagazine)
 
### QM/MM
 - molUP (https://github.com/portobiocomp/molUP)
 
### Tools
 - toolBar (https://github.com/portobiocomp/toolBar)
 - selectionManager (https://github.com/portobiocomp/selectionManager)
 - chemPathTracker (https://github.com/portobiocomp/chemPathTracker)
 - volArea (https://github.com/portobiocomp/volArea)

### Molecular Docking
 - vsLab (https://github.com/portobiocomp/vsLab)
