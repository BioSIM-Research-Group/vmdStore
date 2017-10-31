package provide vmdStoreReadExternalPackage 0.1

proc vmdStore::readExternalPackage {path} {
    ## Delete all information loaded on the tree
    $vmdStore::topGui.frame1.left.f0.tree delete [ $vmdStore::topGui.frame1.left.f0.tree  children {}]


    ## Get list of categories
    set categories [glob -nocomplain -tails -directory $path *]

    set i 0
    ## Fill the tree with the categories
    foreach category [lsort -dictionary -increasing -nocase $categories] {
        $vmdStore::topGui.frame1.left.f0.tree insert "" end -id $i -text $category
        set plugins [glob -nocomplain -tails -directory "$path/$category" *]
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
        $vmdStore::topGui.frame1.right.f2.canvas bind image$i <Button-1> "vmdStore::zoomImage $image"
        
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

    $vmdStore::topGui.frame1.right.f3.citationText configure -state normal
    $vmdStore::topGui.frame1.right.f3.citationText delete 1.0 end
    $vmdStore::topGui.frame1.right.f3.citationText insert end $vmdStore::citationText
    $vmdStore::topGui.frame1.right.f3.citationText configure -state disabled

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
   
    $vmdStore::topGui.frame1.right.f3.install  configure -state normal


}

proc vmdStore::zoomImage {image} {
    #### Check if the window exists
	if {[winfo exists $::vmdStore::topGui.imagePopUp]} {wm deiconify $::vmdStore::topGui.imagePopUp ;return $::vmdStore::topGui.imagePopUp}
	toplevel $::vmdStore::topGui.imagePopUp

	#### Title of the windows
	wm title $::vmdStore::topGui.imagePopUp "vmdStore - Image Gallery" ;

    grid [ttk::label $::vmdStore::topGui.imagePopUp.image \
        -image $image \
        ] -in $::vmdStore::topGui.imagePopUp -row 0 -column 0 -sticky news

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