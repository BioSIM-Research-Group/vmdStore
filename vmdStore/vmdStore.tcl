package provide vmdStore 0.1

#### INIT ############################################################
namespace eval vmdStore:: {
	namespace export vmdStore
	
		#### Load Packages				
		package require Tk
		package require http
		package forget tls
		package require -exact tls 1.6.7.1

        ## GUI
        package require vmdStoreTopGui                      0.1
		package require vmdStoreLoadingGui 					0.1
		package require vmdStoreInstalling					1.0

        ## Theme
        package require vmdStoreTheme                       0.1

        ## Lib
        package require vmdStoreReadExternalPackage         0.1
		package require vmdStoreBrowser						1.0
		package require vmdStoreSearch  					0.1
		package require vmdStoreInstallPlugins				0.1
		package require tar									0.7.1


		
		#### Program Variables
		## General
		variable version	    	"1.1.9"

		#GUI
        variable topGui             ".vmdStore"
		variable loadingGui			".vmdStoreLoading"
		variable installing 		".vmdStoreInstalling"
		variable askDir				".vmdStoreAskDir"
        
        #Read External Package
        variable readmePath			"https://raw.githubusercontent.com/BioSIM-Research-Group/vmdStore/master/README.md"
		variable server				"https://biosim.pt/software/"
		variable externalPackage    "$::vmdStorePath/temp/repository"
		variable installLink		""
		variable webPageLink		""
		variable citationLink		""
		variable citationText		""
		variable pluginVersion		""
		variable installedPlugins	{}
		variable installingProgress	5

		#Markdown
		variable markdown			[list \
									[list "####" "\n" "Helvetica 10 bold" "h4"] \
									[list "###" "\n" "Helvetica 14 bold" "h3"] \
									[list "##" "\n" "Helvetica 18 bold" "h2"] \
									[list "#" "\n" "Helvetica 22 bold" "h1"] \
									[list "**_" "_**" "-weight bold -slant italic" "bolditalic"] \
									[list "**" "**" "-weight bold" "bold"] \
									[list "_" "_" "-slant italic" "italic"] \
									]
		
}


proc vmdStore::start {} {
	#### Open loading GUI
	vmdStore::loadingGui

	#### Enabling SSL protocol
	::http::register https 443 ::tls::socket


	#### Save a backup of vmdrc
	catch {file copy -force $::vmdStorePath/vmdStore.rc $::vmdStorePath/vmdStore.rc.bak}

	#### Read VMDRC to check the version of all installed plugins
	set vmdrcPath "$::vmdStorePath/vmdStore.rc"
	set vmdrcLocal [open $vmdrcPath r]
    set vmdrcLocalContent [split [read $vmdrcLocal] "\n"]
	close $vmdrcLocal
	set i 0
	foreach line $vmdrcLocalContent {
		if {[regexp "####vmdStore#### START" $line] == 1} {
			regexp {####vmdStore####\sSTART\s(\S+)} $line -> plugin
			regexp {##\sVersion\s(\S+)} [lindex $vmdrcLocalContent [expr $i + 1]] -> version
			set installedPlugin [list $plugin $version]
			lappend vmdStore::installedPlugins $installedPlugin
		}
		incr i
	}


	#### Update vmdStore
	# Getting the local Version of vmdStore
	set localVersion [lindex [lindex $vmdStore::installedPlugins [lsearch -index 0 $vmdStore::installedPlugins "vmdStore"]] 1]
	
	# Getting the online Version of vmdStore
	set onlineVersion ""
	while {$onlineVersion == ""} {
		set url "https://github.com/BioSIM-Research-Group/vmdStore/releases/latest"
		set token [::http::geturl $url -timeout 1000]
		set data [::http::data $token]
		regexp -all {tag\/(\S+)\"} $data --> onlineVersion
	}


	# Check if an update is needed
	if {$localVersion != $onlineVersion} {
		#Update vmdStore
		puts "A new version of vmdStore is available. It will be installed automatically."
	
		catch {file delete -force "$::vmdStorePath/temp"}
		file mkdir "$::vmdStorePath/temp"

		set url "https://github.com/BioSIM-Research-Group/vmdStore/archive/$onlineVersion.zip"
		set token [::http::geturl $url -timeout 30000]
		set data [::http::data $token]
		regexp -all {href=\"(\S+)\"} $data --> url
		puts "Downloading the update from: $url"
		variable successfullDownload 0
		set outputFile  [open "$::vmdStorePath/temp/plugin.zip" w]
		set token [::http::geturl $url -channel $outputFile -binary true -timeout 900000 -progress vmdStoreDownlodProgress -method GET]
		close $outputFile	

		while {$vmdStore::successfullDownload == 0} {
			file delete -force "$::vmdStorePath/temp/plugin.zip"
			set outputFile  [open "$::vmdStorePath/temp/plugin.zip" wb]
			set token [::http::geturl $url -channel $outputFile -binary true -timeout 900000 -progress vmdStoreDownlodProgress -method GET]
    		close $outputFile
		}

		if {[string first "Windows" $::tcl_platform(os)] != -1} {
			exec "$::vmdStorePath/lib/zip/unzip.exe" -q -o "$::vmdStorePath/temp/plugin.zip" -d "$::vmdStorePath/temp"
		} else {
			exec unzip -q -o "$::vmdStorePath/temp/plugin.zip" -d "$::vmdStorePath/temp"
		}

		# Copy Files
		vmdStoreCopyFiles "$::vmdStorePath/temp/vmdStore-$onlineVersion/vmdStore" "$::vmdStorePath"

		# Restore initial vmdStore.rc file
		catch {file copy -force $::vmdStorePath/vmdStore.rc.bak $::vmdStorePath/vmdStore.rc}

		#Update VMDRC file
		set vmdrcFile [open "$::vmdStorePath/temp/vmdStore-$onlineVersion/install.txt" r]
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
	    foreach line [split $vmdrcFileContent "\n"] {
	        if {[regexp "none" $line] == 1} {
	            set path [subst $::vmdStorePath]
	            regexp {(.*.) none} $line -> newLine
	            puts $vmdrcLocal "$newLine \"$path\""
	        } elseif {[regexp "XXversionXX" $line] == 1} {
				regexp {(.*.) XXversionXX} $line -> newLine
				puts $vmdrcLocal "$newLine $onlineVersion"
			} else {
	            puts $vmdrcLocal $line
	        }
	    }

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
	

	    close $vmdrcLocal

		destroy $::vmdStore::loadingGui
		tk_messageBox -title "VMD Store" -icon warning -message "The VMD Store was updated. Please, restart VMD to apply the new settings."

	} else {
		#Running the latest version
		#puts "You are running the latest version of vmdStore."
	
		destroy $::vmdStore::loadingGui
		
		if {[winfo exists $::vmdStore::topGui]} {wm deiconify $::vmdStore::topGui ;return $::vmdStore::topGui}
		#### Open the GUI
		vmdStore::topGui
		update
		return $::vmdStore::topGui
	}



}

proc vmdStoreDownlodProgress {token total current} {
	if {$total != 0} {
		set vmdStore::successfullDownload 1
	}
	set units "Bytes"
	if {$total > 1024} {
		set current [format %.2f [expr $current / 1024]]
		set total [format %.2f [expr $total / 1024]]
		set units "KB"
	}
	if {$total > 1024} {
		set current [format %.2f [expr $current / 1024]]
		set total [format %.2f [expr $total / 1024]]
		set units "MB"
	}
	if {$total > 1024} {
		set current [format %.2f [expr $current / 1024]]
		set total [format %.2f [expr $total / 1024]]
		set units "GB"
	}
	if {$total != 0} {
		puts "Downloading $current $units of $total $units"
	}
}

proc vmdStoreCopyFiles {origin destination} {
	set error none
	set list [glob -nocomplain -directory "$origin" *]
	foreach item $list {
		if {[file isdirectory $item] == 1} {
			set newDestination "$destination/[file tail $item]"
			if {[file exists "$newDestination"] != 1} {
				file mkdir "$newDestination"
			}
			vmdStoreCopyFiles "$item" "$newDestination"
		} else {
			catch {file copy -force "$item" "$destination"} debug
			#if {$debug != ""} {
		#		tk_messageBox -title "VMD Store" -icon error -message "The file \"$item\" was not installed/updated. Please, try again or install/update it manually."
		#	}
		}
	}
}
