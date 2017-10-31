## VMD Store ##
## Developed by Henrique S. Fernandes (henrique.fernandes@fc.up.pt) and Nuno M. F. S. A. Cerqueira (nscerque@fc.up.pt)

## Global Variable
variable vmdStorePath   "/Users/Henrique/Documents/Software-development/vmdStore"


package ifneeded vmdStore        	                            0.1 [list source [file join $dir/vmdStore.tcl]]

# Theme
package ifneeded vmdStoreTheme    	                            0.1 [list source [file join $dir/lib/theme/theme.tcl]]

# GUI
package ifneeded vmdStoreTopGui         	                    0.1 [list source [file join $dir/gui/topGui.tcl]]
package ifneeded vmdStoreLoadingGui        	                    0.1 [list source [file join $dir/gui/loading.tcl]]

# Lib
package ifneeded vmdStoreReadExternalPackage                    0.1 [list source [file join $dir/lib/readExternalPackage.tcl]]
package ifneeded vmdStoreBrowser                                1.0 [list source [file join $dir/lib/browser.tcl]]
package ifneeded tar                                            0.7.1 [list source [file join $dir/lib/tar.tcl]]