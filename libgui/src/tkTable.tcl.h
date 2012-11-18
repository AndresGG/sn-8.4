"namespace eval ::tk::table {\n"
"    # Ensure that a namespace is created for us\n"
"    variable Priv\n"
"    array set Priv [list x 0 y 0 afterId {} mouseMoved 0 \\n"
"	    borderInfo {} borderB1 1]\n"
"}\n"
"proc ::tk::table::ClipboardKeysyms {copy cut paste} {\n"
"    bind Table <$copy>	{tk_tableCopy %W}\n"
"    bind Table <$cut>	{tk_tableCut %W}\n"
"    bind Table <$paste>	{tk_tablePaste %W}\n"
"}\n"
"::tk::table::ClipboardKeysyms <Copy> <Cut> <Paste>\n"
"bind Table <3>		{\n"
"    ## You might want to check for cell returned if you want to\n"
"    ## restrict the resizing of certain cells\n"
"    %W border mark %x %y\n"
"}\n"
"bind Table <B3-Motion>	{ %W border dragto %x %y }\n"
"bind Table <1> { ::tk::table::Button1 %W %x %y }\n"
"bind Table <B1-Motion> { ::tk::table::B1Motion %W %x %y }\n"
"bind Table <ButtonRelease-1> {\n"
"    if {$::tk::table::Priv(borderInfo) == \"\" && [winfo exists %W]} {\n"
"	::tk::table::CancelRepeat\n"
"	%W activate @%x,%y\n"
"    }\n"
"}\n"
"bind Table <Double-1> {\n"
"    # empty\n"
"}\n"
"bind Table <Shift-1>	{::tk::table::BeginExtend %W [%W index @%x,%y]}\n"
"bind Table <Control-1>	{::tk::table::BeginToggle %W [%W index @%x,%y]}\n"
"bind Table <B1-Enter>	{::tk::table::CancelRepeat}\n"
"bind Table <B1-Leave>	{\n"
"    if {$::tk::table::Priv(borderInfo) == \"\"} {\n"
"	array set ::tk::table::Priv {x %x y %y}\n"
"	::tk::table::AutoScan %W\n"
"    }\n"
"}\n"
"bind Table <2> {\n"
"    %W scan mark %x %y\n"
"    array set ::tk::table::Priv {x %x y %y}\n"
"    set ::tk::table::Priv(mouseMoved) 0\n"
"}\n"
"bind Table <B2-Motion> {\n"
"    if {(%x != $::tk::table::Priv(x)) || (%y != $::tk::table::Priv(y))} {\n"
"	set ::tk::table::Priv(mouseMoved) 1\n"
"    }\n"
"    if {$::tk::table::Priv(mouseMoved)} { %W scan dragto %x %y }\n"
"}\n"
"bind Table <ButtonRelease-2> {\n"
"    if {!$::tk::table::Priv(mouseMoved)} { tk_tablePaste %W [%W index @%x,%y] }\n"
"}\n"
"bind Table <<Table_Commit>> {\n"
"    catch {%W activate active}\n"
"}\n"
"event add <<Table_Commit>> <Leave> <FocusOut>\n"
"bind Table <Shift-Up>		{::tk::table::ExtendSelect %W -1  0}\n"
"bind Table <Shift-Down>		{::tk::table::ExtendSelect %W  1  0}\n"
"bind Table <Shift-Left>		{::tk::table::ExtendSelect %W  0 -1}\n"
"bind Table <Shift-Right>	{::tk::table::ExtendSelect %W  0  1}\n"
"bind Table <Prior>		{%W yview scroll -1 pages; %W activate topleft}\n"
"bind Table <Next>		{%W yview scroll  1 pages; %W activate topleft}\n"
"bind Table <Control-Prior>	{%W xview scroll -1 pages}\n"
"bind Table <Control-Next>	{%W xview scroll  1 pages}\n"
"bind Table <Home>		{%W see origin}\n"
"bind Table <End>		{%W see end}\n"
"bind Table <Control-Home> {\n"
"    %W selection clear all\n"
"    %W activate origin\n"
"    %W selection set active\n"
"    %W see active\n"
"}\n"
"bind Table <Control-End> {\n"
"    %W selection clear all\n"
"    %W activate end\n"
"    %W selection set active\n"
"    %W see active\n"
"}\n"
"bind Table <Shift-Control-Home>	{::tk::table::DataExtend %W origin}\n"
"bind Table <Shift-Control-End>	{::tk::table::DataExtend %W end}\n"
"bind Table <Select>		{::tk::table::BeginSelect %W [%W index active]}\n"
"bind Table <Shift-Select>	{::tk::table::BeginExtend %W [%W index active]}\n"
"bind Table <Control-slash>	{::tk::table::SelectAll %W}\n"
"bind Table <Control-backslash> {\n"
"    if {[string match browse [%W cget -selectmode]]} {%W selection clear all}\n"
"}\n"
"bind Table <Up>			{::tk::table::MoveCell %W -1  0}\n"
"bind Table <Down>		{::tk::table::MoveCell %W  1  0}\n"
"bind Table <Left>		{::tk::table::MoveCell %W  0 -1}\n"
"bind Table <Right>		{::tk::table::MoveCell %W  0  1}\n"
"bind Table <KeyPress>		{::tk::table::Insert %W %A}\n"
"bind Table <BackSpace>		{::tk::table::BackSpace %W}\n"
"bind Table <Delete>		{%W delete active insert}\n"
"bind Table <Escape>		{%W reread}\n"
"bind Table <Return>		{::tk::table::Insert %W \"\n\"}\n"
"bind Table <Control-Left>	{%W icursor [expr {[%W icursor]-1}]}\n"
"bind Table <Control-Right>	{%W icursor [expr {[%W icursor]+1}]}\n"
"bind Table <Control-e>		{%W icursor end}\n"
"bind Table <Control-a>		{%W icursor 0}\n"
"bind Table <Control-k>		{%W delete active insert end}\n"
"bind Table <Control-equal>	{::tk::table::ChangeWidth %W active  1}\n"
"bind Table <Control-minus>	{::tk::table::ChangeWidth %W active -1}\n"
"bind Table <Alt-KeyPress>	{# nothing}\n"
"bind Table <Meta-KeyPress>	{# nothing}\n"
"bind Table <Control-KeyPress>	{# nothing}\n"
"bind Table <Any-Tab>		{# nothing}\n"
"if {[string match \"macintosh\" $::tcl_platform(platform)]} {\n"
"    bind Table <Command-KeyPress> {# nothing}\n"
"}\n"
"if {[string compare $::tcl_platform(platform) \"unix\"]} {\n"
"    proc ::tk::table::GetSelection {w {sel PRIMARY}} {\n"
"	if {[catch {selection get -displayof $w -selection $sel} txt]} {\n"
"	    return -code error \"could not find default selection\"\n"
"	} else {\n"
"	    return $txt\n"
"	}\n"
"    }\n"
"} else {\n"
"    proc ::tk::table::GetSelection {w {sel PRIMARY}} {\n"
"	if {[catch {selection get -displayof $w -selection $sel \\n"
"		-type UTF8_STRING} txt] \\n"
"		&& [catch {selection get -displayof $w -selection $sel} txt]} {\n"
"	    return -code error \"could not find default selection\"\n"
"	} else {\n"
"	    return $txt\n"
"	}\n"
"    }\n"
"}\n"
"proc ::tk::table::CancelRepeat {} {\n"
"    variable Priv\n"
"    after cancel $Priv(afterId)\n"
"    set Priv(afterId) {}\n"
"}\n"
"proc ::tk::table::Insert {w s} {\n"
"    if {[string compare $s {}]} {\n"
"	$w insert active insert $s\n"
"    }\n"
"}\n"
"proc ::tk::table::BackSpace {w} {\n"
"    set cur [$w icursor]\n"
"    if {[string compare {} $cur] && $cur} {\n"
"	$w delete active [expr {$cur-1}]\n"
"    }\n"
"}\n"
"proc ::tk::table::Button1 {w x y} {\n"
"    variable Priv\n"
"    #\n"
"    # $Priv(borderInfo) is null if the user did not click on a border\n"
"    #\n"
"    if {$Priv(borderB1) == 1} {\n"
"	set Priv(borderInfo) [$w border mark $x $y]\n"
"	# account for what resizeborders are set [Bug 876320] (ferenc)\n"
"	set rbd [$w cget -resizeborders]\n"
"	if {$rbd == \"none\" || ![llength $Priv(borderInfo)]\n"
"	    || ($rbd == \"col\" && [lindex $Priv(borderInfo) 1] == \"\")\n"
"	    || ($rbd == \"row\" && [lindex $Priv(borderInfo) 0] == \"\")} {\n"
"	    set Priv(borderInfo) \"\"\n"
"	}\n"
"    } else {\n"
"	set Priv(borderInfo) \"\"\n"
"    }\n"
"    if {$Priv(borderInfo) == \"\"} {\n"
"	#\n"
"	# Only do this when a border wasn't selected\n"
"	#\n"
"	if {[winfo exists $w]} {\n"
"	    ::tk::table::BeginSelect $w [$w index @$x,$y]\n"
"	    focus $w\n"
"	}\n"
"	array set Priv [list x $x y $y]\n"
"	set Priv(mouseMoved) 0\n"
"    }\n"
"}\n"
"proc ::tk::table::B1Motion {w x y} {\n"
"    variable Priv\n"
"    # If we already had motion, or we moved more than 1 pixel,\n"
"    # then we start the Motion routine\n"
"    if {$Priv(borderInfo) != \"\"} {\n"
"	#\n"
"	# If the motion is on a border, drag it and skip the rest\n"
"	# of this binding.\n"
"	#\n"
"	$w border dragto $x $y\n"
"    } else {\n"
"	#\n"
"	# If we already had motion, or we moved more than 1 pixel,\n"
"	# then we start the Motion routine\n"
"	#\n"
"	if {\n"
"	    $::tk::table::Priv(mouseMoved)\n"
"	    || abs($x-$::tk::table::Priv(x)) > 1\n"
"	    || abs($y-$::tk::table::Priv(y)) > 1\n"
"	} {\n"
"	    set ::tk::table::Priv(mouseMoved) 1\n"
"	}\n"
"	if {$::tk::table::Priv(mouseMoved)} {\n"
"	    ::tk::table::Motion $w [$w index @$x,$y]\n"
"	}\n"
"    }\n"
"}\n"
"proc ::tk::table::BeginSelect {w el} {\n"
"    variable Priv\n"
"    if {[scan $el %d,%d r c] != 2} return\n"
"    switch [$w cget -selectmode] {\n"
"	multiple {\n"
"	    if {[$w tag includes title $el]} {\n"
"		## in the title area\n"
"		if {$r < [$w cget -titlerows]+[$w cget -roworigin]} {\n"
"		    ## We're in a column header\n"
"		    if {$c < [$w cget -titlecols]+[$w cget -colorigin]} {\n"
"			## We're in the topleft title area\n"
"			set inc topleft\n"
"			set el2 end\n"
"		    } else {\n"
"			set inc [$w index topleft row],$c\n"
"			set el2 [$w index end row],$c\n"
"		    }\n"
"		} else {\n"
"		    ## We're in a row header\n"
"		    set inc $r,[$w index topleft col]\n"
"		    set el2 $r,[$w index end col]\n"
"		}\n"
"	    } else {\n"
"		set inc $el\n"
"		set el2 $el\n"
"	    }\n"
"	    if {[$w selection includes $inc]} {\n"
"		$w selection clear $el $el2\n"
"	    } else {\n"
"		$w selection set $el $el2\n"
"	    }\n"
"	}\n"
"	extended {\n"
"	    $w selection clear all\n"
"	    if {[$w tag includes title $el]} {\n"
"		if {$r < [$w cget -titlerows]+[$w cget -roworigin]} {\n"
"		    ## We're in a column header\n"
"		    if {$c < [$w cget -titlecols]+[$w cget -colorigin]} {\n"
"			## We're in the topleft title area\n"
"			$w selection set $el end\n"
"		    } else {\n"
"			$w selection set $el [$w index end row],$c\n"
"		    }\n"
"		} else {\n"
"		    ## We're in a row header\n"
"		    $w selection set $el $r,[$w index end col]\n"
"		}\n"
"	    } else {\n"
"		$w selection set $el\n"
"	    }\n"
"	    $w selection anchor $el\n"
"	    set Priv(tablePrev) $el\n"
"	}\n"
"	default {\n"
"	    if {![$w tag includes title $el]} {\n"
"		$w selection clear all\n"
"		$w selection set $el\n"
"		set Priv(tablePrev) $el\n"
"	    }\n"
"	    $w selection anchor $el\n"
"	}\n"
"    }\n"
"}\n"
"proc ::tk::table::Motion {w el} {\n"
"    variable Priv\n"
"    if {![info exists Priv(tablePrev)]} {\n"
"	set Priv(tablePrev) $el\n"
"	return\n"
"    }\n"
"    if {[string match $Priv(tablePrev) $el]} return\n"
"    switch [$w cget -selectmode] {\n"
"	browse {\n"
"	    $w selection clear all\n"
"	    $w selection set $el\n"
"	    set Priv(tablePrev) $el\n"
"	}\n"
"	extended {\n"
"	    # avoid tables that have no anchor index yet.\n"
"	    if {[catch {$w index anchor}]} { return }\n"
"	    scan $Priv(tablePrev) %d,%d r c\n"
"	    scan $el %d,%d elr elc\n"
"	    if {[$w tag includes title $el]} {\n"
"		if {$r < [$w cget -titlerows]+[$w cget -roworigin]} {\n"
"		    ## We're in a column header\n"
"		    if {$c < [$w cget -titlecols]+[$w cget -colorigin]} {\n"
"			## We're in the topleft title area\n"
"			$w selection clear anchor end\n"
"		    } else {\n"
"			$w selection clear anchor [$w index end row],$c\n"
"		    }\n"
"		    $w selection set anchor [$w index end row],$elc\n"
"		} else {\n"
"		    ## We're in a row header\n"
"		    $w selection clear anchor $r,[$w index end col]\n"
"		    $w selection set anchor $elr,[$w index end col]\n"
"		}\n"
"	    } else {\n"
"		$w selection clear anchor $Priv(tablePrev)\n"
"		$w selection set anchor $el\n"
"	    }\n"
"	    set Priv(tablePrev) $el\n"
"	}\n"
"    }\n"
"}\n"
"proc ::tk::table::BeginExtend {w el} {\n"
"    # avoid tables that have no anchor index yet.\n"
"    if {[catch {$w index anchor}]} { return }\n"
"    if {[string match extended [$w cget -selectmode]] &&\n"
"	[$w selection includes anchor]} {\n"
"	::tk::table::Motion $w $el\n"
"    }\n"
"}\n"
"proc ::tk::table::BeginToggle {w el} {\n"
"    if {[string match extended [$w cget -selectmode]]} {\n"
"	variable Priv\n"
"	set Priv(tablePrev) $el\n"
"	$w selection anchor $el\n"
"	if {[$w tag includes title $el]} {\n"
"	    scan $el %d,%d r c\n"
"	    if {$r < [$w cget -titlerows]+[$w cget -roworigin]} {\n"
"		## We're in a column header\n"
"		if {$c < [$w cget -titlecols]+[$w cget -colorigin]} {\n"
"		    ## We're in the topleft title area\n"
"		    set end end\n"
"		} else {\n"
"		    set end [$w index end row],$c\n"
"		}\n"
"	    } else {\n"
"		## We're in a row header\n"
"		set end $r,[$w index end col]\n"
"	    }\n"
"	} else {\n"
"	    ## We're in a non-title cell\n"
"	    set end $el\n"
"	}\n"
"	if {[$w selection includes  $end]} {\n"
"	    $w selection clear $el $end\n"
"	} else {\n"
"	    $w selection set   $el $end\n"
"        }\n"
"    }\n"
"}\n"
"proc ::tk::table::AutoScan {w} {\n"
"    if {![winfo exists $w]} return\n"
"    variable Priv\n"
"    set x $Priv(x)\n"
"    set y $Priv(y)\n"
"    if {$y >= [winfo height $w]} {\n"
"	$w yview scroll 1 units\n"
"    } elseif {$y < 0} {\n"
"	$w yview scroll -1 units\n"
"    } elseif {$x >= [winfo width $w]} {\n"
"	$w xview scroll 1 units\n"
"    } elseif {$x < 0} {\n"
"	$w xview scroll -1 units\n"
"    } else {\n"
"	return\n"
"    }\n"
"    ::tk::table::Motion $w [$w index @$x,$y]\n"
"    set Priv(afterId) [after 50 ::tk::table::AutoScan $w]\n"
"}\n"
"proc ::tk::table::MoveCell {w x y} {\n"
"    if {[catch {$w index active row} r]} return\n"
"    set c [$w index active col]\n"
"    set cell [$w index [incr r $x],[incr c $y]]\n"
"    while {[string compare [set true [$w hidden $cell]] {}]} {\n"
"	# The cell is in some way hidden\n"
"	if {[string compare $true [$w index active]]} {\n"
"	    # The span cell wasn't the previous cell, so go to that\n"
"	    set cell $true\n"
"	    break\n"
"	}\n"
"	if {$x > 0} {incr r} elseif {$x < 0} {incr r -1}\n"
"	if {$y > 0} {incr c} elseif {$y < 0} {incr c -1}\n"
"	if {[string compare $cell [$w index $r,$c]]} {\n"
"	    set cell [$w index $r,$c]\n"
"	} else {\n"
"	    # We couldn't find a non-hidden cell, just don't move\n"
"	    return\n"
"	}\n"
"    }\n"
"    $w activate $cell\n"
"    $w see active\n"
"    switch [$w cget -selectmode] {\n"
"	browse {\n"
"	    $w selection clear all\n"
"	    $w selection set active\n"
"	}\n"
"	extended {\n"
"	    variable Priv\n"
"	    $w selection clear all\n"
"	    $w selection set active\n"
"	    $w selection anchor active\n"
"	    set Priv(tablePrev) [$w index active]\n"
"	}\n"
"    }\n"
"}\n"
"proc ::tk::table::ExtendSelect {w x y} {\n"
"    if {[string compare extended [$w cget -selectmode]] ||\n"
"	[catch {$w index active row} r]} return\n"
"    set c [$w index active col]\n"
"    $w activate [incr r $x],[incr c $y]\n"
"    $w see active\n"
"    ::tk::table::Motion $w [$w index active]\n"
"}\n"
"proc ::tk::table::DataExtend {w el} {\n"
"    set mode [$w cget -selectmode]\n"
"    if {[string match extended $mode]} {\n"
"	$w activate $el\n"
"	$w see $el\n"
"	if {[$w selection includes anchor]} {::tk::table::Motion $w $el}\n"
"    } elseif {[string match multiple $mode]} {\n"
"	$w activate $el\n"
"	$w see $el\n"
"    }\n"
"}\n"
"proc ::tk::table::SelectAll {w} {\n"
"    if {[regexp {^(single|browse)$} [$w cget -selectmode]]} {\n"
"	$w selection clear all\n"
"	catch {$w selection set active}\n"
"    } elseif {[$w cget -selecttitles]} {\n"
"	$w selection set [$w cget -roworigin],[$w cget -colorigin] end\n"
"    } else {\n"
"	$w selection set origin end\n"
"    }\n"
"}\n"
"proc ::tk::table::ChangeWidth {w i a} {\n"
"    set tmp [$w index $i col]\n"
"    if {[set width [$w width $tmp]] >= 0} {\n"
"	$w width $tmp [incr width $a]\n"
"    } else {\n"
"	$w width $tmp [incr width [expr {-$a}]]\n"
"    }\n"
"}\n"
"proc tk_tableCopy w {\n"
"    if {[selection own -displayof $w] == \"$w\"} {\n"
"	clipboard clear -displayof $w\n"
"	catch {clipboard append -displayof $w [::tk::table::GetSelection $w]}\n"
"    }\n"
"}\n"
"proc tk_tableCut w {\n"
"    if {[selection own -displayof $w] == \"$w\"} {\n"
"	clipboard clear -displayof $w\n"
"	catch {\n"
"	    clipboard append -displayof $w [::tk::table::GetSelection $w]\n"
"	    $w cursel {}\n"
"	    $w selection clear all\n"
"	}\n"
"    }\n"
"}\n"
"proc tk_tablePaste {w {cell {}}} {\n"
"    if {[string compare {} $cell]} {\n"
"	if {[catch {::tk::table::GetSelection $w} data]} return\n"
"    } else {\n"
"	if {[catch {::tk::table::GetSelection $w CLIPBOARD} data]} {\n"
"	    return\n"
"	}\n"
"	set cell active\n"
"    }\n"
"    tk_tablePasteHandler $w [$w index $cell] $data\n"
"    if {[$w cget -state] == \"normal\"} {focus $w}\n"
"}\n"
"proc tk_tablePasteHandler {w cell data} {\n"
"    #\n"
"    # Don't allow pasting into the title cells\n"
"    #\n"
"    if {[$w tag includes title $cell]} {\n"
"        return\n"
"    }\n"
"    set rows	[expr {[$w cget -rows]-[$w cget -roworigin]}]\n"
"    set cols	[expr {[$w cget -cols]-[$w cget -colorigin]}]\n"
"    set r	[$w index $cell row]\n"
"    set c	[$w index $cell col]\n"
"    set rsep	[$w cget -rowseparator]\n"
"    set csep	[$w cget -colseparator]\n"
"    ## Assume separate rows are split by row separator if specified\n"
"    ## If you were to want multi-character row separators, you would need:\n"
"    # regsub -all $rsep $data <newline> data\n"
"    # set data [join $data <newline>]\n"
"    if {[string compare {} $rsep]} { set data [split $data $rsep] }\n"
"    set row	$r\n"
"    foreach line $data {\n"
"	if {$row > $rows} break\n"
"	set col	$c\n"
"	## Assume separate cols are split by col separator if specified\n"
"	## Unless a -separator was specified\n"
"	if {[string compare {} $csep]} { set line [split $line $csep] }\n"
"	## If you were to want multi-character col separators, you would need:\n"
"	# regsub -all $csep $line <newline> line\n"
"	# set line [join $line <newline>]\n"
"	foreach item $line {\n"
"	    if {$col > $cols} break\n"
"	    $w set $row,$col $item\n"
"	    incr col\n"
"	}\n"
"	incr row\n"
"    }\n"
"}\n"
"proc ::tk::table::Sort {w start end col args} {\n"
"    set start [$w index $start]\n"
"    set end   [$w index $end]\n"
"    scan $start %d,%d sr sc\n"
"    scan $end   %d,%d er ec\n"
"    if {($col < $sc) || ($col > $ec)} {\n"
"	return -code error \"$col is not within sort range $sc to $ec\"\n"
"    }\n"
"    set col [expr {$col - $sc}]\n"
"    set data {}\n"
"    for {set i $sr} {$i <= $er} {incr i} {\n"
"	lappend data [$w get $i,$sc $i,$ec]\n"
"    }\n"
"    set i $sr\n"
"    foreach row [eval [list lsort -index $col] $args [list $data]] {\n"
"	$w set row $i,$sc $row\n"
"	incr i\n"
"    }\n"
"}\n"
