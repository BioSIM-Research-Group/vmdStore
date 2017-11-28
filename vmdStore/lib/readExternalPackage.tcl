package provide vmdStoreReadExternalPackage 0.1

proc vmdStore::readExternalPackage {path} {
    set token [::http::geturl "$path" -timeout 30000]
    set data [split [::http::data $token] "\n"]
    
    set ignore "yes"
    set fillList {}
    set categoryList {}
    set category ""
    foreach line $data {
        if {ignore == "no"} {
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
    foreach category [lsort -dictionary -increasing -nocase $categoryList] {
        $vmdStore::topGui.frame1.left.f0.tree insert "" end -id $i -text $category
        set plugins [lsearch -all -index 0 $fillList $category]
        foreach plugin $plugins {
            $vmdStore::topGui.frame1.left.f0.tree insert $i end -text $plugin
        }
        incr i
    }

}


proc vmdStore::fillData {category plugin dir} {
    set path "$dir/$category/$plugin/description.txt"
    set file [open $path r]
    set description [read $file]
    close $file
    
    ## Title
    $vmdStore::topGui.frame1.right.f0.pluginTitle configure -text $plugin

    ## Description
    $vmdStore::topGui.frame1.right.f1.description configure -state normal
    $vmdStore::topGui.frame1.right.f1.description delete 1.0 end
    $vmdStore::topGui.frame1.right.f1.description insert end $description
    vmdStore::markDown $vmdStore::topGui.frame1.right.f1.description
    vmdStore::colorSearchPattern $vmdStore::topGui.frame1.right.f1.description $vmdStore::searchBar
    $vmdStore::topGui.frame1.right.f1.description configure -state disabled

    ## Get Images
    variable pluginImages

    set number [array size vmdStore::pluginImages]
    for {set index 0} { $index < $number } { incr index } {
        destroy $vmdStore::topGui.frame1.right.f2.image$index
    }
    array unset vmdStore::pluginImages
    array set vmdStore::pluginImages [vmdStore::loadImages "$dir/$category/$plugin/images" *.gif]

    set i 0
    set xPos 0
    
    ## Clean Image Gallery
    $vmdStore::topGui.frame1.right.f2.canvas delete all

    foreach {index image} [array get vmdStore::pluginImages] {
        set imageHeight [image height $image]
        set scale [format %.0f [expr ($imageHeight / 190) + 1]]
        set newImage [image create photo]
        set imageWidth [image width $image]
        $newImage copy $image -subsample $scale $scale
        #grid [ttk::label $vmdStore::topGui.frame1.right.f2.canvas.image$i \
            -image $newImage \
            ] -in $vmdStore::topGui.frame1.right.f2.canvas -row 0 -column $i -padx 5 -pady 5

        set xPos [expr $xPos + 10 + ($imageWidth / $scale / 2)]

        $vmdStore::topGui.frame1.right.f2.canvas create image $xPos 100 -image $newImage -tags [list image$i]
        $vmdStore::topGui.frame1.right.f2.canvas bind image$i <Button-1> "vmdStore::zoomImage $image $i"
        
        set xPos [expr $xPos + ($imageWidth / $scale / 2)]
        
        incr i

        #bind $vmdStore::topGui.frame1.right.f2.image[subst $i] <Button-1> {
        #}
    }

    $vmdStore::topGui.frame1.right.f2.canvas configure -scrollregion [list 0 0 [expr $xPos + 10] 100]


    ## Footer Buttons
    set path "$dir/$category/$plugin/link.txt"
    set file [open $path r]
    set link [split [read $file] "\n"]
    close $file

    set vmdStore::installLink   [lindex $link 0]
    set vmdStore::webPageLink	[lindex $link 1]
    set vmdStore::citationLink  [lindex $link 2]
    set vmdStore::citationText  [lindex $link 3]
    set vmdStore::pluginVersion [lindex $link 4]

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

    set imageList {}
    foreach {index image} [array get vmdStore::pluginImages] {
        lappend imageList $image
    }

    set number [array size vmdStore::pluginImages]
    
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
        set tag [lindex $tagList 0]
        set tagLength [string length $tag]

        set tagPos [$pathName search -all -strictlimits "$tag" 0.0 end]
        if {[llength $tagPos] != 0} {
            set numberTags [expr [llength $tagPos] / 2]
            for {set index 0} { $index < $numberTags } { incr index } {
                set tagPos [$pathName search -all -strictlimits "$tag" 0.0 end]
                $pathName tag add $tag [lindex $tagPos 0] [lindex $tagPos 1]
                $pathName tag configure $tag -font [lindex $tagList 1]
                set end1 [split [lindex $tagPos 0] "."]
                set end2 [split [lindex $tagPos 1] "."]
                $pathName delete "[lindex $tagPos 0]" "[lindex $end1 0].[expr [lindex $end1 1] + $tagLength]"  "[lindex $tagPos 1]" "[lindex $end2 0].[expr [lindex $end2 1] + $tagLength]"
            }
        }
        
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