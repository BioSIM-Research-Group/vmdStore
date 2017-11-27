package provide vmdStore 0.1

#### INIT ############################################################
namespace eval vmdStore:: {
	namespace export vmdStore
	
		#### Load Packages				
		package require Tk
		package require http
		package forget tls
		package require tls	1.6.7.1

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
		variable version	    	"0.4"

		#GUI
        variable topGui             ".vmdStore"
		variable loadingGui			".vmdStoreLoading"
		variable installing 		".vmdStoreInstalling"
		variable askDir				".vmdStoreAskDir"
        
        #Read External Package
        variable server				"http://www.compbiochem.org/Software/vmdStore"
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
									[list "<h1>" "Helvetica 24 bold"] \
									[list "<h2>" "Helvetica 22 bold"] \
									[list "<h3>" "Helvetica 20 bold"] \
									[list "<h4>" "Helvetica 16 bold"] \
									[list "<b>" "-weight bold"] \
									[list "<i>" "-slant italic"] \
									[list "<bi>" "-weight bold -slant italic"] \
									]
		
}


proc vmdStore::start {} {
	## Open loading GUI
	vmdStore::loadingGui

	## Save a backup of vmdrc
	if {[string first "Windows" $::tcl_platform(os)] != -1} {
		set homePathWin $env(HOME)
		catch {file copy -force "$homePathWin/vmd.rc" "$homePathWin/vmd.rc.bak.vmdStore"}
	} else {
		catch {file copy -force ~/.vmdrc ~/.vmdrc.bak.vmdStore}
	}

	## Read VMDRC to check the version of all installed plugins
	if {[string first "Windows" $::tcl_platform(os)] != -1} {
		set vmdrcPath "$env(HOME)/vmd.rc"
	} else {
		set vmdrcPath "~/.vmdrc"
	}
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

	## Update vmdStore
	# Getting the local Version of vmdStore
	set localVersion [lindex [lindex $vmdStore::installedPlugins [lsearch -index 0 $vmdStore::installedPlugins "vmdStore"]] 1]
	
	# Getting the online Version of vmdStore
	set url "https://github.com/portobiocomp/vmdStore/releases/latest"
	::http::register https 443 ::tls::socket
	set token [::http::geturl $url -timeout 30000]
	set data [::http::data $token]
	regexp -all {tag\/(\S+)\"} $data --> onlineVersion

	# Check if an update is needed
	if {$localVersion != $onlineVersion} {
		#Update vmdStore
		puts "A new version of vmdStore is available. It will be installed automatically."
	
		catch {file delete -force "$::vmdStorePath/temp"}
		file mkdir "$::vmdStorePath/temp"

		set url "https://github.com/portobiocomp/vmdStore/archive/$onlineVersion.zip"
		set token [::http::geturl $url -timeout 30000]
		set data [::http::data $token]
		regexp -all {href=\"(\S+)\"} $data --> url
		vmdhttpcopy $url "$::vmdStorePath/temp/plugin.zip"
		

		if {[string first "Windows" $::tcl_platform(os)] != -1} {
			
		} else {
			catch {exec unzip "$::vmdStorePath/temp/plugin.zip" -d "$::vmdStorePath/temp"} a
		}

		#file delete -force "$::vmdStorePath/temp/plugin.zip"
		file copy -force "$::vmdStorePath/temp/vmdStore-$onlineVersion/vmdStore" "[file dirname "$::vmdStorePath"]"


		#Update VMDRC file
		set vmdrcFile [open "$::vmdStorePath/temp/plugin/vmdStore-$onlineVersion/install.txt" r]
    	set vmdrcFileContent [read $vmdrcFile]
    	close $vmdrcFile
		if {[string first "Windows" $::tcl_platform(os)] != -1} {
			set vmdrcPath "$env(HOME)/vmd.rc"
		} else {
			set vmdrcPath "~/.vmdrc"
		}

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
	            puts $vmdrcLocal "$newLine $path"
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

	} else {
		#Running the latest version
		puts "You are running the latest version of vmdStore."
	}


	## Chech vmdStore update
	destroy $::vmdStore::loadingGui
	
	if {[winfo exists $::vmdStore::topGui]} {wm deiconify $::vmdStore::topGui ;return $::vmdStore::topGui}
	### Open the GUI
	vmdStore::topGui
	update
	return $::vmdStore::topGui

}