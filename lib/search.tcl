package provide vmdStoreSearch  0.1

proc vmdStore::search {textSearch treeView} {

    if {$textSearch != "" && $textSearch != "Search..." } {
        set parents [$treeView children ""]
        foreach parent $parents {
            set category [$treeView item $parent -text]
            set plugins [$treeView children $parent]
            foreach plugin $plugins {
                #Open File
                set pluginA [$treeView item $plugin -text]
                set path "$vmdStore::externalPackage/$category/$pluginA/description.txt"
                set file [open $path r]
                set description [read $file]
                close $file

                #Search
                $treeView item $parent -tag ""
                set searchResult [regexp -nocase $textSearch $description]
                if {$searchResult == 1} {
                    $treeView item $parent -tag selected
                    $treeView item $plugin -tag selected
                } else {
                    $treeView item $plugin -tag ""
                }
            }
        }

        vmdStore::colorSearchPattern $vmdStore::topGui.frame1.right.f1.description $textSearch
    } else {
        set parents [$treeView children ""]
        foreach parent $parents {
            set category [$treeView item $parent -text]
            set plugins [$treeView children $parent]
            $treeView item $parent -tag ""
            foreach plugin $plugins {
                $treeView item $plugin -tag ""
            }
        }
    }

}

proc vmdStore::colorSearchPattern {pathName textSearch} {
    $pathName tag delete search
    $pathName tag configure search -foreground white -background #0099ff
    
    set tagLength [string length $textSearch]
    set tagPos [$pathName search -all -nocase -strictlimits "$textSearch" 0.0 end]

    if {[llength $tagPos] != 0} {
        foreach tag $tagPos {
            set end1 [split $tag "."]
            $pathName tag add search $tag "[lindex $end1 0].[expr [lindex $end1 1] + $tagLength]"
        }
    }
}