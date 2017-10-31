package provide vmdStoreLoadingGui 0.1

proc vmdStore::loadingGui {} {
    #### Check if the window exists
	if {[winfo exists $::vmdStore::loadingGui]} {wm deiconify $::vmdStore::loadingGui ;return $::vmdStore::loadingGui}
	toplevel $::vmdStore::loadingGui

	#### Title of the windows
	wm title $vmdStore::loadingGui "vmdStore v$vmdStore::version - Loading..." ;

    #### Screen Size
    set sWidth [expr [winfo vrootwidth  $::vmdStore::loadingGui] -0]
	set sHeight [expr [winfo vrootheight $::vmdStore::loadingGui] -100]

    #### Window Size and Position
	wm geometry $::vmdStore::loadingGui 400x300+[expr $sWidth / 2 - 400 / 2]+[expr $sHeight / 2 - 300 / 2]
	$::vmdStore::loadingGui configure -background {white}

    wm resizable $::vmdStore::loadingGui 0 0

	## Procedure when the window is closed
	#wm protocol $::vmdStore::loadingGui WM_DELETE_WINDOW {vmdStore::quit}

    ## Apply Theme
    ttk::style theme use vmdStoreTheme

    ####################################################################################################################
	####################################################################################################################
	####################################################################################################################

    #### Pack background frame
    grid columnconfigure $vmdStore::loadingGui  0   -weight 1
    grid rowconfigure $vmdStore::loadingGui     0   -weight 1
    
    set f0 $vmdStore::loadingGui.frame0
    grid [ttk::frame $f0] -in $vmdStore::loadingGui -sticky news

    grid [ttk::label $f0.loading \
        -text "Loading..." \
        -style vmdStore.whiteFg.blueBg.TLabel \
        -font {Helvetica -25} \
        -anchor center \
        ] -in $f0 -row 0 -column 0 -sticky news -ipadx 20 -ipady 20

    set image [image create photo -file "$::vmdStorePath/lib/theme/images/spinner.gif"]

    grid [ttk::label $f0.loadingImage \
        -image $image \
        -style vmdStore.whiteFg.blueBg.TLabel \
        -anchor center \
        ] -in $f0 -row 1 -column 0 -sticky news

    grid [ttk::label $f0.wait \
        -text "We are collecting new data from internet.\nPlease wait..." \
        -style vmdStore.whiteFg.blueBg.TLabel \
        -font {Helvetica -20} \
        -anchor center \
        ] -in $f0 -row 2 -column 0 -sticky news -ipadx 20 -ipady 20

    grid columnconfigure $f0  0   -weight 1
    grid rowconfigure $f0     1   -weight 1

}
