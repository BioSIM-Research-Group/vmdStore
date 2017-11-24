package provide vmdStoreInstallPlugins 0.1

proc vmdStore::installPlugin {plugin} {
    vmdStore::installGui $plugin

    set path "$vmdStore::server/plugins/$plugin"
    set installPath "$::vmdStorePath/plugins"

    set fileName ""
    set fileName [append fileName $plugin "_V" $vmdStore::pluginVersion]

    ## Download Plugin
    vmdhttpcopy "$path/$fileName.tar" "$::vmdStorePath/temp/plugin.tar"

    ## Untar the plugin
    file delete -force "$::vmdStorePath/plugins/$plugin"
    ::tar::untar "$::vmdStorePath/temp/plugin.tar" -dir $installPath


    ## Download VMDRC information to install
    vmdhttpcopy "$path/vmdrc.txt" "$::vmdStorePath/temp/vmdrc.txt"


    set vmdrcFile [open "$::vmdStorePath/temp/vmdrc.txt" r]
    set vmdrcFileContent [read $vmdrcFile]
    close $vmdrcFile

    set initDelimiter ""
    set finalDelimiter ""

    foreach line [split $vmdrcFileContent "\n"] {
        if {[regexp "####vmdStore#### START" $line] == 1} {
            set initDelimiter $line
        } elseif {[regexp "####vmdStore#### END" $line] == 1} {
            set finalDelimiter $line
        }
    }
    
    if {[string first "Windows" $::tcl_platform(os)] != -1} {
		set vmdrcPath "./vmd.rc"
	} else {
		set vmdrcPath "~/.vmdrc"
	}

    set vmdrcLocal [open $vmdrcPath r]
    set vmdrcLocalContent [split [read $vmdrcLocal] "\n"]
    close $vmdrcLocal

    file delete -force $vmdrcPath
    set vmdrcLocal [open $vmdrcPath w]

    set printOrNot 1
    set printOrNotA 0
    set i 0
    foreach line $vmdrcLocalContent {
        if {[regexp $initDelimiter $line] == 1} {
            set printOrNot 0
        } elseif {[regexp $finalDelimiter $line] == 1} {
            set printOrNotA 1
        }

        if {$printOrNot == 1 && $line != ""} {
            puts $vmdrcLocal $line
        }

        if {$printOrNotA == 1} {
            set printOrNot 1
        }

        incr i
    }
    
    set i 0
    foreach line [split $vmdrcFileContent "\n"] {
        if {[regexp "none" $line] == 1} {
            tk_messageBox -title "VMD Store" -icon warning -message "$plugin require some configurations." -detail "[string range [lindex [split $vmdrcFileContent "\n"] [expr $i - 1]] 1 end]"
            set path [tk_chooseDirectory]
            regexp {(.*.) none} $line -> newLine
            puts $vmdrcLocal "$newLine \"$path\""
        } else {
            puts $vmdrcLocal $line
        }
        incr i
    }

    close $vmdrcLocal

    destroy $::vmdStore::installing
    tk_messageBox -title "VMD Store" -icon info -message "$plugin was installed sucessfully!" -detail "Please, restart VMD to apply the new settings."

}


proc vmdStore::uninstallPlugin {plugin} {
    $vmdStore::topGui.frame1.right.f3.install  configure -text "Install" -style vmdStore.greenBg.TButton
    $vmdStore::topGui.frame1.right.f3.uninstall  configure -state disabled
    
    if {[string first "Windows" $::tcl_platform(os)] != -1} {
		set vmdrcPath "./vmd.rc"
	} else {
		set vmdrcPath "~/.vmdrc"
	}

    set vmdrcLocal [open $vmdrcPath r]
    set vmdrcLocalContent [split [read $vmdrcLocal] "\n"]
    close $vmdrcLocal

    file delete -force "$vmdStore::server/plugins/$plugin"

    file delete -force $vmdrcPath
    set vmdrcLocal [open $vmdrcPath w]

    set initDelimiter "####vmdStore#### START $plugin"
    set finalDelimiter "####vmdStore#### END $plugin"

    set printOrNot 1
    set printOrNotA 0
    foreach line $vmdrcLocalContent {
        if {[regexp $initDelimiter $line] == 1} {
            set printOrNot 0
        } elseif {[regexp $finalDelimiter $line] == 1} {
            set printOrNotA 1
        }

        if {$printOrNot == 1} {
            puts $vmdrcLocal $line
        }

        if {$printOrNotA == 1} {
            set printOrNot 1
        }
    }
    
    close $vmdrcLocal

    ## Delete the folder
    file delete -force $::vmdStorePath/plugins/$plugin

    tk_messageBox -title "VMD Store" -icon info -message "$plugin was uninstalled sucessfully!" -detail "$plugin will be completely removed after you quit VMD."
    
}