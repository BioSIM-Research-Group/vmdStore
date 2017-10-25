package provide vmdStore 0.1

#### INIT ############################################################
namespace eval vmdStore:: {
	namespace export vmdStore
	
		#### Load Packages				
		package require Tk

        ## GUI
        package require vmdStoreTopGui                      0.1

        ## Theme
        package require vmdStoreTheme                       0.1

        ## Lib
        package require vmdStoreReadExternalPackage         0.1


		
		#### Program Variables
		## General
		variable version	    	"0.1"

		#GUI
        variable topGui             ".vmdStore"
        
        #Read External Package
        variable externalPackage    "/Users/Henrique/Desktop/repository"
		
}

proc vmdStore::start {} {
	if {[winfo exists $::vmdStore::topGui]} {wm deiconify $::vmdStore::topGui ;return $::vmdStore::topGui}

	### Open the GUI
	vmdStore::topGui
	update
	return $::vmdStore::topGui


    
}