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

    $vmdStore::topGui.frame1.right.f1.description delete 1.0 end
    $vmdStore::topGui.frame1.right.f1.description insert end $description
    
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