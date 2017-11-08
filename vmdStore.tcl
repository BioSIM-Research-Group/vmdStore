package provide vmdStore 0.1

#### INIT ############################################################
namespace eval vmdStore:: {
	namespace export vmdStore
	
		#### Load Packages				
		package require Tk

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
		variable version	    	"0.1"

		#GUI
        variable topGui             ".vmdStore"
		variable loadingGui			".vmdStoreLoading"
		variable installing 		".vmdStoreInstalling"
		variable askDir				".vmdStoreAskDir"
        
        #Read External Package
        variable server				"http://henriquefernandes.pt/vmdStore"
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
	file copy -force ~/.vmdrc ~/.vmdrc.bak.vmdStore

	## Check for updates on repository content
	set openVersionFile [open $::vmdStorePath/temp/version.txt r]
	set localVersion [read $openVersionFile]
	close $openVersionFile
	vmdhttpcopy "$vmdStore::server/version.txt" "$::vmdStorePath/temp/version.txt"
	set openVersionFile [open $::vmdStorePath/temp/version.txt r]
	set onlineVersion [read $openVersionFile]
	close $openVersionFile
	if {$localVersion != $onlineVersion} {
		## Update repository
		vmdhttpcopy "$vmdStore::server/repository.tar" "$::vmdStorePath/temp/repository.tar"
		file delete -force "$::vmdStorePath/temp/repository"
		::tar::untar "$::vmdStorePath/temp/repository.tar" -dir "$::vmdStorePath/temp"
	} else {
		## Ignore
	}

	## Read VMDRC to check installed plugins
	set vmdrcPath "~/.vmdrc"
    set vmdrcLocal [open $vmdrcPath r]
    set vmdrcLocalContent [split [read $vmdrcLocal] "\n"]
	close $vmdrcLocal
	set i 0
	foreach line $vmdrcLocalContent {
		if {[regexp "####vmdStore#### START" $line] == 1} {
			regexp {####vmdStore####\sSTART\s(\S+)} $line -> plugin
			if {$plugin == "vmdStore"} {

			} else {
			regexp {##\sVersion\s(\S+)} [lindex $vmdrcLocalContent [expr $i + 1]] -> version
			set installedPlugin [list $plugin $version]
			lappend vmdStore::installedPlugins $installedPlugin
			}
		}
		incr i
	}

	destroy $::vmdStore::loadingGui
	
	if {[winfo exists $::vmdStore::topGui]} {wm deiconify $::vmdStore::topGui ;return $::vmdStore::topGui}
	### Open the GUI
	vmdStore::topGui
	update
	return $::vmdStore::topGui

}