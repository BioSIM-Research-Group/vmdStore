package provide vmdStoreTopGui 0.1

proc vmdStore::topGui {} {
    #### Check if the window exists
	if {[winfo exists $::vmdStore::topGui]} {wm deiconify $::vmdStore::topGui ;return $::vmdStore::topGui}
	toplevel $::vmdStore::topGui

	#### Title of the windows
	wm title $vmdStore::topGui "vmdStore v$vmdStore::version " ;

    #### Screen Size
    set sWidth [expr [winfo vrootwidth  $::vmdStore::topGui] -0]
	set sHeight [expr [winfo vrootheight $::vmdStore::topGui] -100]

    #### Window Size and Position
	wm geometry $::vmdStore::topGui 1000x700+[expr $sWidth / 2 - 1000 / 2]+[expr $sHeight / 2 - 700 / 2]
	$::vmdStore::topGui configure -background {white}

	## Procedure when the window is closed
	#wm protocol $::vmdStore::topGui WM_DELETE_WINDOW {vmdStore::quit}

    ## Apply Theme
    ttk::style theme use vmdStoreTheme


    ####################################################################################################################
	####################################################################################################################
	####################################################################################################################


    #### Pack background frame
    grid columnconfigure $vmdStore::topGui  0   -weight 1
    grid rowconfigure $vmdStore::topGui     1   -weight 1
    
    set f0 $vmdStore::topGui.frame0
    grid [ttk::frame $f0] -in $vmdStore::topGui -sticky news

    #### Header
    ## Left
    grid [ttk::label $f0.logo \
        -image [image create photo -file "$::vmdStorePath/lib/theme/images/vmdStore-Logo.gif"] \
        -style vmdStore.whiteFg.blueBg.TLabel \
        -font {Helvetica -25} \
        -anchor center \
        ] -in $f0 -row 0 -column 0 -sticky news -ipadx 25

    ## Right
    grid [ttk::frame $f0.h1 \
        -style vmdStore.gray.TFrame \
        -height 100 \
        ] -in $f0 -row 0 -column 1 -sticky news

    variable searchBar "Search..."
    grid [ttk::entry $f0.h1.searchBarEntry \
        -textvariable vmdStore::searchBar \
        -style vmdStore.searchBar.Entry \
       ] -in $f0.h1 -row 0 -column 0 -sticky news -pady 25 -padx [list 10 0]
    bind $f0.h1.searchBarEntry <Button-1> {if {$vmdStore::searchBar == "Search..."} {set vmdStore::searchBar ""}}

    grid [ttk::button $f0.h1.searchButton \
        -command {vmdStore::search $vmdStore::searchBar $vmdStore::topGui.frame1.left.f0.tree} \
        -text "Search" \
        -style vmdStore.blueBg.TButton \
        ] -in $f0.h1 -row 0 -column 1 -sticky e -pady 25 -padx [list 1 10]

    bind $f0.h1.searchBarEntry <Return> {puts $vmdStore::searchBar; vmdStore::search "$vmdStore::searchBar" $vmdStore::topGui.frame1.left.f0.tree}

    #grid [ttk::button $f0.h1.settings \
        -command {} \
        -text "Settings" \
        -style vmdStore.blueBg.TButton \
        ] -in $f0.h1 -row 0 -column 2 -sticky e -pady 25 -padx 10

    grid columnconfigure $f0        1   -weight 1
    grid columnconfigure $f0.h1     0   -weight 1


    #### Main
    set f1 $vmdStore::topGui.frame1
    grid [ttk::panedwindow $f1 \
        -orient horizontal \
        ] -sticky news -pady [list 10 0]
    grid columnconfigure $f1        1   -weight 1

    $f1 add [ttk::frame $f1.left] -weight 0 
    $f1 add [ttk::frame $f1.right] -weight 1


    grid [ttk::frame $f1.left.f0 \
        ] -in $f1.left -row 0 -column 0 -sticky news -rowspan 4

    ## TreeView
	grid [ttk::treeview $f1.left.f0.tree \
        -show tree \
        -yscroll "$f1.left.f0.vsb set" \
        ] -in $f1.left.f0 -row 0 -column 1 -sticky news 
	grid [ttk::scrollbar $f1.left.f0.vsb \
        -orient vertical \
        -command "$f1.left.f0.tree yview" \
        ] -in $f1.left.f0 -row 0 -column 0  -sticky ns 

    #### TreeView
    $vmdStore::topGui.frame1.left.f0.tree tag configure selected -background #0099ff -foreground white

    bind $f1.left.f0.tree <<TreeviewSelect>> {
        set selection [$vmdStore::topGui.frame1.left.f0.tree selection]

        set category [$vmdStore::topGui.frame1.left.f0.tree parent $selection]
        set plugin [$vmdStore::topGui.frame1.left.f0.tree item $selection -text]
        
        if {$category != ""} {
            set category [$vmdStore::topGui.frame1.left.f0.tree item $category -text]
            vmdStore::fillData $category $plugin
        }
    }

    ## Content
    # Title
    grid [ttk::frame $f1.right.f0 \
        -style vmdStore.blue.TFrame  \
        -height 30 \
        ] -in $f1.right -row 0 -column 0 -sticky new -padx [list 0 5]

    grid [ttk::label $f1.right.f0.pluginTitle \
        -text "Welcome to VMD Store!" \
        -font {Helvetica -20} \
        -style vmdStore.whiteFg.blueBg.TLabel \
        ] -in $f1.right.f0 -row 0 -column 0 -sticky news -padx 5
    
    grid [ttk::label $f1.right.f0.version \
        -text $vmdStore::pluginVersion \
        -font {Helvetica -14} \
        -style vmdStore.whiteFg.blueBg.TLabel \
        ] -in $f1.right.f0 -row 0 -column 1 -sticky news -padx 5

    grid columnconfigure $f1.right.f0      0 -weight 1

    # Description
    grid [ttk::frame $f1.right.f1 \
        -style vmdStore.gray.TFrame  \
        ] -in $f1.right -row 1 -column 0 -sticky news -padx [list 0 5] -pady 5

    grid [text $f1.right.f1.description \
		-yscrollcommand "$f1.right.f1.yscb0 set" \
		-highlightcolor #0099ff \
		-highlightthickness 0 \
		-wrap word \
        -font {Helvetica} \
        -state normal \
		] -in $f1.right.f1 -row 0 -column 0 -sticky news

    $vmdStore::topGui.frame1.right.f1.description insert end "vmdStore is the easiest way to manage and install third-part VMD extensions. vmdStore compile several VMD extensions and allows you to install them and push VMD to the next level."
    $vmdStore::topGui.frame1.right.f1.description configure -state disabled

    grid [ttk::scrollbar $f1.right.f1.yscb0 \
		-orient vertical \
		-command [list $f1.right.f1.description yview]\
		] -in $f1.right.f1 -row 0 -column 1 -sticky ns
    
    grid columnconfigure $f1.right.f1       0 -weight 1

    grid rowconfigure $f1.right         0 -weight 0
    grid rowconfigure $f1.right         1 -weight 1
    grid rowconfigure $f1.right.f1      0 -weight 1
    grid rowconfigure $f1.right         2 -weight 0
    grid rowconfigure $f1.right         3 -weight 0

    # Image Gallery
    grid [ttk::frame $f1.right.f2 \
        -style vmdStore.blue.TFrame  \
        -height 200 \
        ] -in $f1.right -row 2 -column 0 -sticky news -padx [list 0 5]

    grid [canvas $f1.right.f2.canvas \
        -xscrollcommand "$f1.right.f2.xsb set" \
        -bg #0099ff \
        ] -in $f1.right.f2 -row 0 -column 0 -sticky news

    grid [ttk::scrollbar $f1.right.f2.xsb \
		-orient horizontal \
		-command [list $f1.right.f2.canvas xview]\
		] -in $f1.right.f2 -row 1 -column 0 -sticky ew
    
    grid columnconfigure $f1.right.f2     0 -weight 1

    # Citation 
    grid [ttk::frame $f1.right.f4 \
        -style vmdStore.gray.TFrame  \
        ] -in $f1.right -row 3 -column 0 -sticky news -pady [list 2 0] -padx [list 0 5]

     grid [text $f1.right.f4.citationText \
		-highlightcolor #0099ff \
		-highlightthickness 0 \
        -bg #f2f2f2 \
		-wrap word \
        -font {Helvetica 11} \
        -state disabled \
        -height 2 \
        -yscrollcommand "$f1.right.f4.yscb0 set" \
		] -in $f1.right.f4 -row 0 -column 0 -sticky news -padx [list 5 0]
    
    grid columnconfigure $f1.right.f4   0   -weight 1

    grid [ttk::scrollbar $f1.right.f4.yscb0 \
		-orient vertical \
		-command [list $f1.right.f4.citationText yview]\
		] -in $f1.right.f4 -row 0 -column 1 -sticky ns

    # Footer buttons
    grid [ttk::frame $f1.right.f3 \
        -style vmdStore.gray.TFrame  \
        ] -in $f1.right -row 4 -column 0 -sticky news -pady [list 2 0] -padx [list 0 5]
    
    grid [ttk::button $f1.right.f3.uninstall \
        -text "Uninstall" \
        -command {vmdStore::uninstallPlugin $vmdStore::installLink} \
        -state disabled \
        -style vmdStore.uninstall.TButton \
        ] -in $f1.right.f3 -row 0 -column 0 -sticky w -pady 5 -padx 10
    
    
    grid [ttk::button $f1.right.f3.citation \
        -text "Citation" \
        -command {vmdStore::browser $vmdStore::citationLink} \
        -state disabled \
        -style vmdStore.blueBg.TButton \
        ] -in $f1.right.f3 -row 0 -column 2 -sticky e -pady 5 -padx 10
    
    grid [ttk::button $f1.right.f3.webPage \
        -text "Web Page" \
        -command {vmdStore::browser $vmdStore::webPageLink} \
        -state disabled \
        -style vmdStore.blueBg.TButton \
        ] -in $f1.right.f3 -row 0 -column 4 -sticky e -pady 5 -padx 10
    
    grid [ttk::button $f1.right.f3.install \
        -text "Install" \
        -command {vmdStore::installPlugin $vmdStore::installLink} \
        -state disabled \
        -style vmdStore.greenBg.TButton \
        ] -in $f1.right.f3 -row 0 -column 5 -sticky e -pady 5 -padx 10


    grid columnconfigure $f1.right.f1        0   -weight 1

    grid columnconfigure $f1        1   -weight 1
    grid columnconfigure $f1.left        0   -weight 1
    grid columnconfigure $f1.left.f0        1   -weight 1
    grid columnconfigure $f1.right        0   -weight 1
    grid columnconfigure $f1.right.f3        0   -weight 1
    grid rowconfigure $f0           0   -weight 0
    #grid rowconfigure $f1.right.f3     0   -weight 1
    grid rowconfigure $f1.left        0   -weight 1
    grid rowconfigure $f1.left.f0     0   -weight 1



    #### Footer
    set f2 $vmdStore::topGui.frame2
    grid [ttk::frame $f2 \
        ] -sticky news -pady [list 10 0]
    grid columnconfigure $f2        1   -weight 1
   
    grid [ttk::label $f2.credits \
        -text "Developed by Henrique S. Fernandes and Nuno M. F. S. A. Cerqueira - PortoBioComp" \
        -font {Helvetica 10} \
        ] -in $f2 -row 0 -column 1 -sticky e -pady [list 15 0] -padx [list 0 15]
    
    grid columnconfigure $f2       0    -weight 1



    #### Read package information 
    vmdStore::readExternalPackage "$vmdStore::readmePath"

}
