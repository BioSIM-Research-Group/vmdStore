package provide vmdStoreTheme 0.1

proc vmdStore::loadImages {imgdir {patterns {*.gif}}} {
    foreach pattern $patterns {
        foreach file [glob -directory $imgdir $pattern] {
            set img [file tail [file rootname $file]]
            if {![info exists images($img)]} {
                set images($img) [image create photo -file $file]
            }
        }
    }
    return [array get images]
}

variable images

array set vmdStore::images [vmdStore::loadImages [file join [file dirname [info script]] images] *.gif]

ttk::style theme create vmdStoreTheme -parent clam -settings {

    #### Color
    set blue #0099ff
    set gray #f2f2f2

    ttk::style configure . \
        -background white


    #### Frame
    ttk::style configure vmdStore.blue.TFrame \
        -background $blue

    #
    ttk::style configure vmdStore.gray.TFrame \
        -background $gray


    #### Label
    ttk::style configure vmdStore.whiteFg.blueBg.TLabel \
        -background $blue \
        -foreground white 


    #### Entry
    ttk::style element create vmdStore.searchBar.Entry.field \
        image [list $vmdStore::images(entry-n) \
                 pressed $vmdStore::images(entry-n) \
                 {selected active} $vmdStore::images(entry-n) \
                 selected $vmdStore::images(entry-n) \
                 active $vmdStore::images(entry-n) \
                 disabled $vmdStore::images(entry-n) \
                ] \
                -border [list 5 0 5 0] -sticky ew
    
    ttk::style configure vmdStore.searchBar.Entry \
        -selectbackground $blue \
        -selectforeground white \

    ttk::style layout vmdStore.searchBar.Entry {
        Entry.vmdStore.searchBar.Entry.field -children {
            Entry.vmdStore.searchBar.Entry.textarea
        }
    }


    


    #### Button
    ttk::style element create vmdStore.blueBg.TButton.button \
        image [list $vmdStore::images(button-n) \
                 pressed $vmdStore::images(button-a) \
                 {selected active} $vmdStore::images(button-a) \
                 selected $vmdStore::images(button-a) \
                 active $vmdStore::images(button-a) \
                 disabled $vmdStore::images(button-d) \
                ] \
                -border 4 -sticky ew -padding [list 10 0 10 0]

    ttk::style configure vmdStore.blueBg.TButton \
        -anchor center \
        -foreground white

    ttk::style layout vmdStore.blueBg.TButton {
        Button.vmdStore.blueBg.TButton.button -children {
            Button.vmdStore.blueBg.TButton.label
        }
    }

    #
     ttk::style element create vmdStore.greenBg.TButton.button \
        image [list $vmdStore::images(button-n-green) \
                 pressed $vmdStore::images(button-a-green) \
                 {selected active} $vmdStore::images(button-a-green) \
                 selected $vmdStore::images(button-a-green) \
                 active $vmdStore::images(button-a-green) \
                 disabled $vmdStore::images(button-d-green) \
                ] \
                -border [list 24 4 4 4] -sticky ew -padding [list 26 0 10 0]

    ttk::style configure vmdStore.greenBg.TButton \
        -anchor center \
        -foreground white

    ttk::style layout vmdStore.greenBg.TButton {
        Button.vmdStore.greenBg.TButton.button -children {
            Button.vmdStore.greenBg.TButton.label
        }
    }

    #
     ttk::style element create vmdStore.uninstall.TButton.button \
        image [list $vmdStore::images(button-uninstall-n) \
                 pressed $vmdStore::images(button-uninstall-a) \
                 {selected active} $vmdStore::images(button-uninstall-a) \
                 selected $vmdStore::images(button-uninstall-a) \
                 active $vmdStore::images(button-uninstall-a) \
                 disabled $vmdStore::images(button-uninstall-d) \
                ] \
                -border [list 24 4 4 4] -sticky ew -padding [list 24 0 10 0]

    ttk::style configure vmdStore.uninstall.TButton \
        -anchor center \
        -foreground white

    ttk::style layout vmdStore.uninstall.TButton {
        Button.vmdStore.uninstall.TButton.button -children {
            Button.vmdStore.uninstall.TButton.label
        }
    }

    #
     ttk::style element create vmdStore.update.TButton.button \
        image [list $vmdStore::images(button-update-n) \
                 pressed $vmdStore::images(button-update-a) \
                 {selected active} $vmdStore::images(button-update-a) \
                 selected $vmdStore::images(button-update-a) \
                 active $vmdStore::images(button-update-a) \
                 disabled $vmdStore::images(button-update-d) \
                ] \
                -border [list 24 4 4 4] -sticky ew -padding [list 26 0 10 0]

    ttk::style configure vmdStore.update.TButton \
        -anchor center \
        -foreground white

    ttk::style layout vmdStore.update.TButton {
        Button.vmdStore.update.TButton.button -children {
            Button.vmdStore.update.TButton.label
        }
    }

}