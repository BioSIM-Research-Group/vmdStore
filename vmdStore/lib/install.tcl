package provide vmdStoreInstallPlugins 0.1

proc vmdStore::installPlugin {plugin} {
	## Disable the install button
	$vmdStore::topGui.frame1.right.f3.install  configure -state disabled
	$vmdStore::topGui.frame1.right.f3.uninstall  configure -state disabled

    vmdStore::installGui $plugin

    #### Save a backup of vmdrc
	catch {file copy -force $::vmdStorePath/vmdStore.rc $::vmdStorePath/vmdStore.rc.bak}

    # Getting the local Version of the Plugin
	set localVersion [lindex [lindex $vmdStore::installedPlugins [lsearch -index 0 $vmdStore::installedPlugins "$plugin"]] 1]

    # Getting the online version of the Plugin
    set onlineVersion $vmdStore::pluginVersion


    ###### Installing the Plugin
	puts "The most recent version of $plugin is installing..."

    # Cleaning the temp directory
    catch {file delete -force "$::vmdStorePath/temp"}
	file mkdir "$::vmdStorePath/temp"

    set url "https://github.com/portobiocomp/$plugin/archive/$onlineVersion.zip"
	set token [::http::geturl $url -timeout 30000]
	set data [::http::data $token]
	regexp -all {href=\"(\S+)\"} $data --> url
	puts "Downloading the plugin from: $url"
	variable successfullDownload 0
	set outputFile  [open "$::vmdStorePath/temp/plugin.zip" wb]
	set token [::http::geturl $url -channel $outputFile -binary true -timeout 1800000 -progress vmdStoreDownlodProgress -method GET]
    close $outputFile

	while {$vmdStore::successfullDownload == 0} {
		file delete -force "$::vmdStorePath/temp/plugin.zip"
		set outputFile  [open "$::vmdStorePath/temp/plugin.zip" wb]
		set token [::http::geturl $url -channel $outputFile -binary true -timeout 1800000 -progress vmdStoreDownlodProgress -method GET]
    	close $outputFile
	}

    # Extracting the plugin
    if {[string first "Windows" $::tcl_platform(os)] != -1} {
		exec "$::vmdStorePath/lib/zip/unzip.exe" -q -o "$::vmdStorePath/temp/plugin.zip" -d "$::vmdStorePath/temp"
	} else {
		exec unzip -q -o "$::vmdStorePath/temp/plugin.zip" -d "$::vmdStorePath/temp"
	}

    # Copy Files
    file delete -force "$::vmdStorePath/plugins/$plugin"
    file mkdir "$::vmdStorePath/plugins/$plugin"
	vmdStoreCopyFiles "$::vmdStorePath/temp/$plugin-$onlineVersion/$plugin" "$::vmdStorePath/plugins/$plugin"


    ##### Update VMDRC file
		set vmdrcFile [open "$::vmdStorePath/temp/$plugin-$onlineVersion/install.txt" r]
    	set vmdrcFileContent [read $vmdrcFile]
    	close $vmdrcFile
		set vmdrcPath "$::vmdStorePath/vmdStore.rc"

		foreach line [split $vmdrcFileContent "\n"] {
    	    if {[regexp "####vmdStore#### START" $line] == 1} {
    	        set initDelimiter $line
    	    } elseif {[regexp "####vmdStore#### END" $line] == 1} {
    	        set finalDelimiter $line
    	    }
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
	        if {[regexp "askFile" $line] == 1} {
				set types {
					{{All Files}        *             }
				}
				tk_messageBox -title "VMD Store" -icon warning -message "$plugin require some configurations.\n\n[string range [lindex [split $vmdrcFileContent "\n"] [expr $i - 1]] 1 end]"
                set path [tk_getOpenFile -filetypes $types]
	            regexp {(.*.) askFile} $line -> newLine
	            puts $vmdrcLocal "$newLine \"$path\""
			} elseif {[regexp "none" $line] == 1} {
	            tk_messageBox -title "VMD Store" -icon warning -message "$plugin require some configurations.\n\n[string range [lindex [split $vmdrcFileContent "\n"] [expr $i - 1]] 1 end]"
                set path [tk_chooseDirectory]
	            regexp {(.*.) none} $line -> newLine
	            puts $vmdrcLocal "$newLine \"$path\""
	        } elseif {[regexp "XXversionXX" $line] == 1} {
				regexp {(.*.) XXversionXX} $line -> newLine
				puts $vmdrcLocal "$newLine $onlineVersion"
			} else {
	            puts $vmdrcLocal $line
	        }
			incr i
	    }

	    close $vmdrcLocal


	# Cleaning the temp directory
    catch {file delete -force "$::vmdStorePath/temp"}
	file mkdir "$::vmdStorePath/temp"


    destroy $::vmdStore::installing
    tk_messageBox -title "VMD Store" -icon info -message "$plugin was installed sucessfully!" -detail "Please, restart VMD to apply the new settings."

	## Enabling the install button 
	$vmdStore::topGui.frame1.right.f3.uninstall  configure -state normal
	$vmdStore::topGui.frame1.right.f3.install  configure -state normal

}


proc vmdStore::uninstallPlugin {plugin} {
    $vmdStore::topGui.frame1.right.f3.install  configure -text "Install" -style vmdStore.greenBg.TButton
    $vmdStore::topGui.frame1.right.f3.uninstall  configure -state disabled
    
    #### Save a backup of vmdrc
	catch {file copy -force $::vmdStorePath/vmdStore.rc $::vmdStorePath/vmdStore.rc.bak}

	set vmdrcPath "$::vmdStorePath/vmdStore.rc"

    set vmdrcLocal [open $vmdrcPath r]
    set vmdrcLocalContent [split [read $vmdrcLocal] "\n"]
    close $vmdrcLocal

    file delete -force "$::vmdStorePath/plugins/$plugin"

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