package provide vmdStoreInstalling 1.0

proc vmdStore::installGui {plugin} {
    #### Check if the window exists
	if {[winfo exists $::vmdStore::installing]} {wm deiconify $::vmdStore::installing ;return $::vmdStore::installing}
	toplevel $::vmdStore::installing

	#### Title of the windows
	wm title $vmdStore::installing "vmdStore v$vmdStore::version - Installing $plugin" ;

    #### Screen Size
    set sWidth [expr [winfo vrootwidth  $::vmdStore::installing] -0]
	set sHeight [expr [winfo vrootheight $::vmdStore::installing] -100]

    #### Window Size and Position
	wm geometry $::vmdStore::installing 400x190+[expr $sWidth / 2 - 400 / 2]+[expr $sHeight / 2 - 300 / 2]
	$::vmdStore::installing configure -background {white}

    wm resizable $::vmdStore::installing 0 0

	## Procedure when the window is closed
	#wm protocol $::vmdStore::installing WM_DELETE_WINDOW {vmdStore::quit}

    ## Apply Theme
    ttk::style theme use vmdStoreTheme

    ####################################################################################################################
	####################################################################################################################
	####################################################################################################################

    #### Pack background frame
    grid columnconfigure $vmdStore::installing  0   -weight 1
    grid rowconfigure $vmdStore::installing     0   -weight 1
    
    set f0 $vmdStore::installing.frame0
    grid [ttk::frame $f0] -in $vmdStore::installing -sticky news

    grid [ttk::label $f0.loading \
        -text "Installing $plugin..." \
        -style vmdStore.whiteFg.blueBg.TLabel \
        -font {Helvetica -25} \
        -anchor center \
        ] -in $f0 -row 0 -column 0 -sticky news -ipadx 20 -ipady 20

    grid [ttk::progressbar $f0.progressbar \
        -orient horizontal \
        -length 250 \
        -phase 1 \
        -variable vmdStore::installingProgress \
        -mode indeterminate \
        ] -in $f0 -row 1 -column 0 -sticky news

    $f0.progressbar start 10

    grid [ttk::label $f0.wait \
        -text "After the installation, you have to restart VMD to make the plugin available." \
        -style vmdStore.whiteFg.blueBg.TLabel \
        -font {Helvetica -10} \
        -anchor center \
        ] -in $f0 -row 2 -column 0 -sticky news -ipadx 20 -ipady 20

    grid columnconfigure $f0  0   -weight 1
    grid rowconfigure $f0     1   -weight 1
}