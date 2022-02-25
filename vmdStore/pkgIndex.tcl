## VMD Store ##
## Developed by Henrique S. Fernandes (henrique.fernandes@fc.up.pt) and Nuno M. F. S. A. Cerqueira (nscerque@fc.up.pt)

package ifneeded vmdStore        	                            0.2 [list source [file join $dir/vmdStore.tcl]]

# Theme
package ifneeded vmdStoreTheme    	                            0.1 [list source [file join $dir/lib/theme/theme.tcl]]

# GUI
package ifneeded vmdStoreTopGui         	                    0.1 [list source [file join $dir/gui/topGui.tcl]]
package ifneeded vmdStoreLoadingGui        	                    0.1 [list source [file join $dir/gui/loading.tcl]]
package ifneeded vmdStoreInstalling        	                    1.0 [list source [file join $dir/gui/installing.tcl]]

# Lib
package ifneeded vmdStoreReadExternalPackage                    0.1 [list source [file join $dir/lib/readExternalPackage.tcl]]
package ifneeded vmdStoreBrowser                                1.0 [list source [file join $dir/lib/browser.tcl]]
package ifneeded vmdStoreSearch                                 0.1 [list source [file join $dir/lib/search.tcl]]
package ifneeded vmdStoreInstallPlugins                         0.1 [list source [file join $dir/lib/install.tcl]]
package ifneeded tar                                            0.7.1 [list source [file join $dir/lib/tar.tcl]]

if {[lindex "$::tcl_platform(os)" 0] == "Windows"} {
    if {$::tcl_platform(pointerSize) == 8} {
        package ifneeded tls 1.7.16 \
        "[list source [file join $dir/lib/tls/windows/1.7.16 tls.tcl]] ; \
        [list tls::initlib $dir/lib/tls/windows/1.7.16 tls1716t.dll]"
    } else {
        package ifneeded tls 1.6.7.1 \
        "[list source [file join $dir/lib/tls/windows tls.tcl]] ; \
        [list tls::initlib $dir/lib/tls/windows tls1671.dll]"
    }
} elseif {[lindex "$::tcl_platform(os)" 0] == "Darwin"} {
    package ifneeded tls 1.6.7.1     "[list source [file join $dir/lib/tls/macOS tls.tcl]] ;      [list tls::initlib $dir/lib/tls/macOS libtls1.6.7.1.dylib]"
} elseif {[lindex "$::tcl_platform(os)" 0] == "Linux"} {
    if {$::tcl_platform(machine) == "i686"} {
        package ifneeded tls 1.6.7.1  "[list source [file join $dir/lib/tls/linux/i868 tls.tcl]] ;  [list tls::initlib $dir/lib/tls/linux/i868 libtls1.6.7.1.so]"
    } elseif {$::tcl_platform(machine) == "x86_64"} {
        package ifneeded tls 1.6.7.1  "[list source [file join $dir/lib/tls/linux/x86_64 tls.tcl]] ;  [list tls::initlib $dir/lib/tls/linux/x86_64 libtls1.6.7.1.so]"

    }
}