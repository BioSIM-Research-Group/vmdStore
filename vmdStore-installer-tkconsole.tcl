#### VMD Store Installer
#### Installation via VMD Tk Console

#### Requirements
## VMD 1.9.3 later

#### How to install ?
## 1. Launch VMD;
## 2. Open the Tk Console (Extensions > Tk console);
## 3. Write the following command and press ENTER:
##      cd <COMPLETE PATH OF vmdStore-Installer DIRECTORY>
##      Example: cd /home/users/myname/Downloads/vmdStore-Installer
## 4. Write the following command and press ENTER:
##      play vmdStore-install.tcl
## 5. Follow the instruction;
## 6. Done!
##    Re-launch VMD and open VMD Store at Extensions > VMD Store > VMD Store.

#### How to uninstall?
## 1. Edit your .vmdrc or vmd.rc file and delete all the lines related to VMD Store (example below);
##      ####vmdStore#### START vmdStore
##      play "/some.path/vmdStore/vmdStore.rc"
##      ####vmdStore#### END vmdStore
## 2. Delete the vmdStore directory. 

############################################################################################################
############################################################################################################
############################################################################################################
############################################################################################################

#### Installation code
set vmdStoreVersion "1.1.13" ; #Current VMD Store version
set installerLocation "." ; #Get path of the installer location

if {[file exists "$installerLocation/vmdStore"] == 0} {
    puts "FAILED!\n\nYou are not running the installation script (vmdStore-install.tcl) on the installation directory (vmdStore-Installer).\n\nPlease, run \"cd <COMPLETE PATH OF vmdStore-Installer DIRECTORY>\"\nExample:\ncd /home/users/myname/Downloads/vmdStore-Installer"

} else {
    puts "VMD Store Installer\n\nWhere do you want to install the VMD Store?\nPlease provide a full path:\n"  ; #Initial message asking for the installation path
    gets stdin installPath ; #Ask for user input - Installation Path
    puts "The VMD Store ($vmdStoreVersion) is going to be installed in \"$installPath/vmdStore\"" ; #Message telling that the path was correctly collected

    # Copy the vmdStore directory to the path provided by the user.
    file copy -force "$installerLocation/vmdStore" "$installPath"

    # Edit the vmdStore.rc file
    set vmdStoreRCfile [open "$installPath/vmdStore/vmdStore.rc" w]
    puts $vmdStoreRCfile "####vmdStore#### START vmdStore"
    puts $vmdStoreRCfile "## Version $vmdStoreVersion"
    puts $vmdStoreRCfile "variable vmdStorePath \"$installPath/vmdStore\""
    puts $vmdStoreRCfile "lappend auto_path \$::vmdStorePath"
    puts $vmdStoreRCfile "vmd_install_extension vmdStore \"vmdStore::start\" \"VMD Store/VMD Store\""
    puts $vmdStoreRCfile "####vmdStore#### END vmdStore\n## VMD Store Plugin Manager ##\n## Please, do not change this file unless you know what are you doing! ##"

    close $vmdStoreRCfile

    # Add the installation line to .vmdrc or vmd.rc file
    set home $::env(HOME) ; # set home directory
    puts $home
    if {[string first "Windows" $::tcl_platform(os)] != -1} {
        set vmdrcPath "$home/vmd.rc"
    } else {
        set vmdrcPath "$home/.vmdrc"
    }

    set file [open "$vmdrcPath" a+]
    puts $file "##### VMD Store ## START #####\nplay \"$installPath/vmdStore/vmdStore.rc\"\n##### VMD Store ## END #####\nmenu main on"
    close $file

    # if {[string first "Windows" $::tcl_platform(os)] != -1} {
    #     set vmdrcPath "C:/Program Files (x86)/University of Illinois/VMD/vmd.rc"

    #     set file [open "$vmdrcPath" a+]
    #     puts $file "##### VMD Store ## START #####\nplay \"$installPath/vmdStore/vmdStore.rc\"\n##### VMD Store ## END #####\nmenu main on"
    #     close $file
    # }

    # Final messages
    puts "Installation Complete!"
    puts "==============================================================="
    puts "Enjoy the VMD Store under the \n\"Extensions\" > \"VMD Store\" > \"VMD Store\"\n menu of VMD."
    puts "==============================================================="
    puts "\n\nPlease, re-launch the VMD!"
}
