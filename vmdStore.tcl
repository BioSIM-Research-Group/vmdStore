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
		package require vmdStoreBrowser						1.0


		
		#### Program Variables
		## General
		variable version	    	"0.1"

		#GUI
        variable topGui             ".vmdStore"
        
        #Read External Package
        variable externalPackage    "/Users/Henrique/Desktop/repository"
		variable installLink		""
		variable webPageLink		""
		variable citationLink		""
		variable citationText		""

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
	if {[winfo exists $::vmdStore::topGui]} {wm deiconify $::vmdStore::topGui ;return $::vmdStore::topGui}


	

	### Open the GUI
	vmdStore::topGui
	update
	return $::vmdStore::topGui


    
}