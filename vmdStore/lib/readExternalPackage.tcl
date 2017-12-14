package provide vmdStoreReadExternalPackage 0.1

proc vmdStore::readExternalPackage {path} {
    set token [::http::geturl "$path" -timeout 30000]
    set data [split [::http::data $token] "\n"]
    
    set ignore "yes"
    set fillList {}
    set categoryList {}
    set category ""
    foreach line $data {
        if {$ignore == "no"} {
            if {[string first "###" $line] != -1} {
                set category [lrange $line 1 end]
                lappend categoryList $category
            }
            if {[string first "-" $line] != -1} {
                set plugin [lindex $line 1]
                set a [list $category $plugin]
                lappend fillList $a
            }
        }
        if {$line == "## Available Plugins"} {
            set ignore "no"
        }
    }

    set i 0
    ## Fill the tree with the categories
    foreach category $categoryList {
        $vmdStore::topGui.frame1.left.f0.tree insert "" end -id $i -text $category
        set plugins [lsearch -all -index 0 -inline $fillList $category]
        foreach plugin $plugins {
            $vmdStore::topGui.frame1.left.f0.tree insert $i end -text [lindex $plugin end]
        }
        incr i
    }

    
    ##### Get descriptions
    variable pluginDescriptions {}
    foreach plugin $fillList {
        set plugin [lindex $plugin end]
        ## Get the README file
        set token [::http::geturl "https://raw.githubusercontent.com/portobiocomp/$plugin/master/README.md" -timeout 30000]
        set data [::http::data $token]
        set a [list "$plugin" "$data"]
        lappend vmdStore::pluginDescriptions $a
    }

}


proc vmdStore::fillData {category plugin} {
    ## Disable Lateral Pannel while the information is collected from the server
    $vmdStore::topGui.frame1.left.f0.tree configure -selectmode none
    $vmdStore::topGui.frame1.right.f3.progressBar start 10
    $vmdStore::topGui.frame1.right.f3.progressLabel configure -text "Loading..."
    $vmdStore::topGui.frame0.h1.searchBarEntry configure -state disabled
    $vmdStore::topGui.frame0.h1.searchButton configure -state disabled


    set token [::http::geturl "https://raw.githubusercontent.com/portobiocomp/$plugin/master/README.md" -timeout 30000]
    set description [::http::data $token]
    
    ## Title
    $vmdStore::topGui.frame1.right.f0.pluginTitle configure -text $plugin

    $vmdStore::topGui.frame1.right.f3.progressLabel configure -text "Loading text..."

    ## Description
    $vmdStore::topGui.frame1.right.f1.description configure -state normal
    $vmdStore::topGui.frame1.right.f1.description delete 1.0 end
    $vmdStore::topGui.frame1.right.f1.description insert end $description
    vmdStore::markDown $vmdStore::topGui.frame1.right.f1.description
    vmdStore::colorSearchPattern $vmdStore::topGui.frame1.right.f1.description $vmdStore::searchBar
    $vmdStore::topGui.frame1.right.f1.description configure -state disabled


    ## Footer Buttons
    set vmdStore::installLink   "https://github.com/portobiocomp/$plugin/releases/latest"
    set vmdStore::webPageLink	"https://github.com/portobiocomp/$plugin"

    set vmdStore::citationText ""
    set vmdStore::citationLink ""
    set i 0
    set text [split $description "\n"]
    foreach line $text {
        if {[string first "Citation" $line] != -1} {
            set vmdStore::citationText  "[lindex $text [expr $i + 1]]"
        } elseif {[string first "DOI" $line] != -1} {
            set vmdStore::citationLink  "[lindex $text [expr $i + 1]]"
        }
        incr i
    }

    set url "https://github.com/portobiocomp/$plugin/releases/latest"
	set token [::http::geturl $url -timeout 30000]
	set data [::http::data $token]
	regexp -all {tag\/(\S+)\"} $data --> vmdStore::pluginVersion

    $vmdStore::topGui.frame1.right.f4.citationText configure -state normal
    $vmdStore::topGui.frame1.right.f4.citationText delete 1.0 end
    $vmdStore::topGui.frame1.right.f4.citationText insert end $vmdStore::citationText
    $vmdStore::topGui.frame1.right.f4.citationText configure -state disabled

    $vmdStore::topGui.frame1.right.f0.version configure -text "Version: $vmdStore::pluginVersion"

    if {$vmdStore::citationLink != ""} {
        $vmdStore::topGui.frame1.right.f3.citation  configure -state normal
    } else {
        $vmdStore::topGui.frame1.right.f3.citation  configure -state disabled
    }
    if {$vmdStore::webPageLink != ""} {
        $vmdStore::topGui.frame1.right.f3.webPage   configure -state normal
    } else {
        $vmdStore::topGui.frame1.right.f3.webPage   configure -state disabled
    }
   
    $vmdStore::topGui.frame1.right.f3.install  configure -state normal -style vmdStore.greenBg.TButton

    ### Check if the plugin is already installed
    set alreadyInstalled [lsearch -index 0 $::vmdStore::installedPlugins $vmdStore::installLink]
    if {$alreadyInstalled == -1} {
        $vmdStore::topGui.frame1.right.f3.install  configure -text "Install" -style vmdStore.greenBg.TButton
        $vmdStore::topGui.frame1.right.f3.uninstall  configure -state disabled
    } else {
        if {$vmdStore::pluginVersion == [lindex [lindex $::vmdStore::installedPlugins $alreadyInstalled] 1]} {
            $vmdStore::topGui.frame1.right.f3.install  configure -text "Re-Install"
            $vmdStore::topGui.frame1.right.f3.uninstall  configure -state normal
        } else {
            $vmdStore::topGui.frame1.right.f3.install  configure -text "Update" -style vmdStore.update.TButton
            $vmdStore::topGui.frame1.right.f3.uninstall  configure -state normal
        }
    }

    $vmdStore::topGui.frame1.right.f3.progressLabel configure -text "Loading images..."

    ## Get Images
    variable gallery {}
    puts "Loading image gallery..."
    foreach line [split $description "\n"] {
        if {[string first "!" $line] != -1} {
            regexp {\((\S+)\)} $line --> imagePath
            set token [::http::geturl "https://raw.githubusercontent.com/portobiocomp/$plugin/master/$imagePath" -timeout 30000]
            set image [::http::data $token]
            set image [image create photo -data $image]
            lappend vmdStore::gallery $image
        }
    }


    ## Clean Image Gallery
    $vmdStore::topGui.frame1.right.f2.canvas delete all

    set i 0
    set xPos 0
    foreach image $vmdStore::gallery {
        set imageHeight [image height $image]
        set scale [format %.0f [expr ($imageHeight / 190) + 1]]
        set newImage [image create photo]
        set imageWidth [image width $image]
        $newImage copy $image -subsample $scale $scale

        set xPos [expr $xPos + 10 + ($imageWidth / $scale / 2)]

        $vmdStore::topGui.frame1.right.f2.canvas create image $xPos 100 -image $newImage -tags [list image$i]
        $vmdStore::topGui.frame1.right.f2.canvas bind image$i <Button-1> "vmdStore::zoomImage $image $i"
        
        set xPos [expr $xPos + ($imageWidth / $scale / 2)]
        
        incr i
    }

    $vmdStore::topGui.frame1.right.f3.progressLabel configure -text "Done!"

    $vmdStore::topGui.frame1.right.f2.canvas configure -scrollregion [list 0 0 [expr $xPos + 10] 100]


    ## Re-Enabled Lateral Pannel
    $vmdStore::topGui.frame1.left.f0.tree configure -selectmode browse
    $vmdStore::topGui.frame1.right.f3.progressBar stop
    $vmdStore::topGui.frame1.right.f3.progressLabel configure -text ""
    $vmdStore::topGui.frame0.h1.searchBarEntry configure -state normal
    $vmdStore::topGui.frame0.h1.searchButton configure -state normal

}

proc vmdStore::zoomImage {image imageIndex} {
    #### Check if the window exists
	if {[winfo exists $::vmdStore::topGui.imagePopUp]} {wm deiconify $::vmdStore::topGui.imagePopUp ;return $::vmdStore::topGui.imagePopUp}
	toplevel $::vmdStore::topGui.imagePopUp

	#### Title of the windows
	wm title $::vmdStore::topGui.imagePopUp "vmdStore - Image Gallery" ;


    #### Set the size of the Window
    set sWidth [expr [winfo vrootwidth  $::vmdStore::topGui] - 200]
	set sHeight [expr [winfo vrootheight $::vmdStore::topGui] - 200]

    wm geometry $::vmdStore::topGui.imagePopUp ${sWidth}x${sHeight}+100+100
	$::vmdStore::topGui.imagePopUp configure -background {white}

    set newImage [vmdStore::resizeImage $image]

    grid [ttk::label $::vmdStore::topGui.imagePopUp.image \
        -image $newImage \
        -anchor center \
        ] -in $::vmdStore::topGui.imagePopUp -row 0 -column 0 -sticky news -columnspan 3

    set number [llength $vmdStore::gallery]
    
    set imageList $vmdStore::gallery
    
    if {$imageIndex == 0} {
        set previous [lindex $imageList 0]
        set prevI 0
    } else {
        set previous [lindex $imageList [expr $imageIndex - 1]]
        set prevI [expr $imageIndex - 1]
    }

    
    if {$imageIndex >= [expr $number - 1]} {
        set next [lindex $imageList end]
        set nextI [expr [llength $imageList] - 1]
    } else {
        set next [lindex $imageList [expr $imageIndex + 1]]
        set nextI [expr $imageIndex + 1]
    }


    grid [ttk::button $::vmdStore::topGui.imagePopUp.previous \
        -text "\< Previous" \
        -command "destroy $::vmdStore::topGui.imagePopUp; vmdStore::zoomImage $previous $prevI" \
        -style vmdStore.blueBg.TButton \
        ] -in $::vmdStore::topGui.imagePopUp -row 1 -column 0 -sticky w -padx 20 -pady 10

    grid [ttk::button $::vmdStore::topGui.imagePopUp.next \
        -text "Next \>" \
        -command "destroy $::vmdStore::topGui.imagePopUp; vmdStore::zoomImage $next $nextI" \
        -style vmdStore.blueBg.TButton \
        ] -in $::vmdStore::topGui.imagePopUp -row 1 -column 2 -sticky e -padx 20 -pady 10

    grid columnconfigure $::vmdStore::topGui.imagePopUp     0   -weight 1
    grid columnconfigure $::vmdStore::topGui.imagePopUp     1   -weight 1
    grid rowconfigure $::vmdStore::topGui.imagePopUp        0   -weight 1

    if {$imageIndex >= [expr $number - 1]} {
        $::vmdStore::topGui.imagePopUp.next configure -state disabled
    }

    if {$imageIndex == 0} {
        $::vmdStore::topGui.imagePopUp.previous configure -state disabled
    }

}

proc vmdStore::markDown {pathName} {
    foreach tagList $vmdStore::markdown {
        set tag0 [lindex $tagList 0]
        set tag1 [lindex $tagList 1]
        set tagName [lindex $tagList 3]
        set tagLength0 [string length $tag0]
        set tagLength1 [string length $tag1]

        set tagPos0 [$pathName search -all -strictlimits "$tag0" 0.0 end]
        if {[llength $tagPos0] != 0} {
            for {set index 0} { $index < [llength $tagPos0] } { incr index } {
                set pos0 [$pathName search -strictlimits "$tag0" 0.0 end]
                set pos1 [$pathName search -strictlimits "$tag1" $pos0 end]
                $pathName tag add $tagName $pos0 $pos1
                $pathName tag configure $tagName -font [lindex $tagList 2]
                set end1 [split $pos0 "."]
                set end2 [split $pos1 "."]
                $pathName delete "$pos0" "[lindex $end1 0].[expr [lindex $end1 1] + $tagLength0]"  "$pos1" "[lindex $end2 0].[expr [lindex $end2 1] + $tagLength1]"
            }
        }
        
    }

    ## Delete Images from the Description Text
    set tagPos [$pathName search -all -strictlimits "!" 0.0 end]
    for {set index 0} { $index < [llength $tagPos] } { incr index } {
        set pos0 [$pathName search -strictlimits "!" 0.0 end]
        set pos1 [$pathName search -strictlimits "\n" $pos0 end]
        set end1 [split $pos1 "."]
        $pathName delete "$pos0" "[lindex $end1 0].[expr [lindex $end1 1] + 3]"
    }

    ## Links
    set tagPos [$pathName search -all -strictlimits "\[" 0.0 end]
    for {set index 0} { $index < [llength $tagPos] } { incr index } {
        set pos0 [$pathName search -strictlimits "\[" 0.0 end]
        set pos1 [$pathName search -strictlimits "\)" $pos0 end]
        set pos3 [split [$pathName search -strictlimits "\(" $pos0 end] "."]
        set link [$pathName get "[lindex $pos3 0].[expr [lindex $pos3 1] + 1]" $pos1]
        set end0 [split $pos0 "."]
        set end1 [split $pos1 "."]
        $pathName tag add "$link" "[lindex $end0 0].[expr [lindex $end0 1] + 1]" "[lindex $pos3 0].[expr [lindex $pos3 1] - 1]"
        $pathName tag configure "$link" -foreground #0066ff -underline true
        $pathName tag bind "$link" <1> "vmdStore::browser $link"
        $pathName delete "$pos0" "[lindex $end0 0].[expr [lindex $end0 1] + 1]" "[lindex $pos3 0].[expr [lindex $pos3 1] - 1]" "[lindex $end1 0].[expr [lindex $end1 1] + 1]"
    }
}

proc vmdStore::resizeImage {image} {
    set sWidth [expr [winfo vrootwidth  $::vmdStore::topGui] - 200]
	set sHeight [expr [winfo vrootheight $::vmdStore::topGui] - 200]

     set imageHeight [image height $image]
    set imageWidth [image width $image]

    if {$imageHeight > $sHeight} {
        set scaleHeight [format %.0f [expr ($imageHeight / $sHeight) + 1]]
    } else {
        set scaleHeight 0
    }

    if {$imageWidth > $sWidth} {
        set scaleWidth [format %.0f [expr ($imageWidth / $sWidth) + 1]]
    } else {
        set scaleWidth 0
    }


    if {$scaleHeight == 0 && $scaleWidth == 0} {
        set newImage $image
    } elseif {$imageHeight >= $imageWidth} {
        set newImage [image create photo]
        $newImage copy $image -subsample $scaleHeight $scaleHeight
    } elseif {$imageHeight < $imageWidth} {
        set newImage [image create photo]
        $newImage copy $image -subsample $scaleWidth $scaleWidth
    }

    return $newImage

}