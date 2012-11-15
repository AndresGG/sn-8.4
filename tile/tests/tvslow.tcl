#
# ttk::treeview population timing tests.
#
# Ref: <ON-dnWgQoZl6LzPanZ2dnUVZ_gqdnZ2d@comcast.com>

package require tile

proc tick {} { set ::d [clock clicks] }
proc tock {} { expr {([clock clicks] - $::d) / 1000.00} }

set n 8000

### Case 1:
#
ttk::treeview .tv
tick
puts [time {
    for {set i 0} {$i <= $n} {incr i} {
	.tv insert {} end -text "Item $i"
	if {!($i % 1000)} { puts [format "%8d - %f" $i [tock]]; tick }
    }
}]
destroy .tv

### Case 2:
#
set m 10
pack [ttk::treeview .tv] -expand true -fill both
tick
puts [time {
    for {set i 0} {$i <= $n} {incr i} {
	set parent [.tv insert {} end -text "Item $i"]
	for {set j 0} {$j <= $m} {incr j} {
	    .tv insert $parent end -text "Item $i/$j"
	}
	if {!($i % 1000)} { puts [format "%8d - %f" $i [tock]] ; tick }
    }
}]
destroy .tv

destroy .

