# Copyright (c) 2000, Red Hat, Inc.
# 
# This file is part of Source-Navigator.
# 
# Source-Navigator is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License as published
# by the Free Software Foundation; either version 2, or (at your option)
# any later version.
# 
# Source-Navigator is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# General Public License for more details.
# 
# You should have received a copy of the GNU General Public License along
# with Source-Navigator; see the file COPYING.  If not, write to
# the Free Software Foundation, 59 Temple Place - Suite 330, Boston,
# MA 02111-1307, USA.
# 
# help.tcl - Online documentation and balloon help. 
# Copyright (C) 1998 Cygnus Solutions.

proc sn_help {{file ""} {busy 1}} {
    global sn_options tcl_platform sn_path

    if {${file} == ""} {
        set file "index.html"
        set dir $sn_path(htmldir)
        set file [file join ${dir} ${file}]
    }
    set file "file:${file}"

    switch -exact -- [tk windowingsystem] {
        win32 {
            sn_invoke_browser_win $file
        }
        default {
            sn_invoke_browser_unix $file
        }
    }
    return
}

proc sn_invoke_browser_win {file} {
	package require registry
    # Look for the application under HKEY_CLASSES_ROOT
    set root HKEY_CLASSES_ROOT

    # Get the application key for HTML files
    set appKey [registry get $root\\.html ""]

    # Get the command for opening HTML files
    set appCmd [registry get  $root\\$appKey\\shell\\open\\command ""]

    # Substitute the HTML filename into the command for %1,
    # IE doesn't seem to use the %1, so we simply append it.
    if {![regsub {%1} $appCmd "$file" appCmd]} {
        set appCmd [concat $appCmd $file]
    }
    sn_log "$appCmd"
    # Double up the backslashes for eval.
    regsub -all {\\} $appCmd  {\\\\} appCmd

    # Invoke the command
    if {[catch {eval exec $appCmd &} errmsg]} {
        sn_error_dialog $errmsg
    }
    return
}

proc sn_invoke_browser_unix {file} {
    global sn_options

    foreach browser {"$sn_options(def,html-viewer)" firefox iceweasel} {
        sn_log "$browser [list $file]"
        # I have to be this convoluted because to open Konqueror we have to
        # use a command with parameters and paths might have spaces.
        if {![catch {eval "exec $browser [list $file] &"} errmsg]} {
            return
        }
    }
    sn_error_dialog "Browser not found."
    return
}

# display a small window on the button of a widget to
# view the binded help text
set balloon_bind_info(screen_width) [winfo screenwidth .]
set balloon_bind_info(screen_height) [winfo screenheight .]
set balloon_bind_info(shown) 0

#use class of bindings for balloon help
proc balloon_button_bind {} {
    global balloon_bind_info

    set w SN_Balloon

    bind ${w} <Enter> {+
		catch {
			set balloon_bind_info(id) [after $balloon_bind_info(%W,delay)\
      $balloon_bind_info(%W,proc) %W [list $balloon_bind_info(%W,text)] %X %Y]
		}
	}
    bind ${w} <Leave> {+balloon_destroy}
    bind ${w} <Any-ButtonPress> {+balloon_destroy}
    bind ${w} <KeyPress> {+balloon_destroy}
}

proc balloon_destroy {} {
    global balloon_bind_info

    if {[winfo exists .cb_balloon]} {
        destroy .cb_balloon
    }
    if {[info exists balloon_bind_info(id)]} {
        after cancel $balloon_bind_info(id)
    }
    if {[info exists balloon_bind_info(id,timeout)]} {
        after cancel $balloon_bind_info(id,timeout)
    }
    set balloon_bind_info(shown) 0
}

proc balloon_menu_bind {} {
    global balloon_bind_info

    set w Menu

    bind ${w} <<MenuSelect>> {+
		set tmpidx [%W index active]
		catch {
			if {$balloon_bind_info(%W,last_menu_index) == $tmpidx ||
				$tmpidx == "none"} {
				break
			}
		}
		balloon_destroy
		if {![info exists balloon_bind_info(%W,$tmpidx,text)]} {
			catch {unset balloon_bind_info(%W,last_menu_index)}
			break
		}
		set balloon_bind_info(%W,last_menu_index) $tmpidx
		set balloon_bind_info(id) [after $balloon_bind_info(%W,delay)\
      $balloon_bind_info(%W,proc) %W {""} %X %Y]
		unset tmpidx
	}

    bind Menu <Leave> {+
		balloon_destroy
		catch {unset balloon_bind_info(%W,last_menu_index)}
	}
}

#execute balloon bindings only once!
balloon_button_bind

proc balloon_bind_info {w text {delay -1} {procedure "balloon_display_info"}} {
    global sn_options
    global balloon_bind_info

    if {${delay} < 0} {
        set delay $sn_options(def,balloon-disp-delay)
    }
    set balloon_bind_info(${w},text) ${text}
    set balloon_bind_info(${w},delay) ${delay}
    set balloon_bind_info(${w},proc) ${procedure}

    sn_add_tags ${w} SN_Balloon 0
}

proc menu_balloon_bind_info {w idx text {delay -1} {procedure\
  "balloon_display_info"}} {
    global sn_options balloon_bind_info

    if {${delay} < 0} {
        set delay $sn_options(def,balloon-disp-delay)
    }
    set balloon_bind_info(${w},${idx},text) ${text}
    set balloon_bind_info(${w},delay) ${delay}
    set balloon_bind_info(${w},proc) ${procedure}
}

proc balloon_display_info {w text rx ry} {
    global sn_options
    global balloon_bind_info

    if {$balloon_bind_info(shown)} {
        return
    }
    if {[winfo containing [winfo pointerx .] [winfo pointery .]] != ${w}} {
        return
    }
    if {[catch {set bg_color $sn_options(def,balloon-bg)}]} {
        set bg_color lightyellow
    }
    if {[catch {set fg_color $sn_options(def,balloon-fg)}]} {
        set fg_color black
    }

    if {[winfo class ${w}] == "Menu"} {
        if {[catch {set act $balloon_bind_info(${w},last_menu_index)}] ||\
          [catch {set text $balloon_bind_info(${w},${act},text)}]} {
            return
        }

        if {[${w} cget -type] == "menubar"} {
            set y [expr [winfo rooty ${w}] + [winfo height ${w}]]
            set x [winfo rootx ${w}]
        }\
        elseif {${act} == [${w} index end]} {
            set y [expr [winfo rooty ${w}] + [winfo height ${w}]]
            set x [expr [winfo rootx ${w}] + [winfo width ${w}]]
        } else {
            set y [expr [winfo rooty ${w}] + [${w} yposition [expr ${act} +1]]]
            set x [expr [winfo rootx ${w}] + [winfo width ${w}]]
        }
    } else {
        set x ${rx}
        set y [expr [winfo rooty ${w}] + [winfo height ${w}]]
    }

    balloon_destroy

    set balloon_bind_info(shown) 1
    set t .cb_balloon

    toplevel ${t} -bg ${bg_color}
    wm withdraw ${t}

    if {$sn_options(def,desktop-font-size) > 14} {
        set fsize 14
    } else {
        set fsize $sn_options(def,desktop-font-size)
    }
    pack [frame ${t}.f -bd 1 -background black]
    pack [label ${t}.f.l -text ${text} -wraplength 300 -justify left\
      -bg ${bg_color} -fg ${fg_color} -bd 0 -relief raised\
      -font $sn_options(def,balloon-font) -padx 4 -pady 4]
    wm overrideredirect ${t} 1

    if {${y} < 0} {
        set y 0
    }
    set w [expr [winfo reqwidth ${t}.f.l] + 2]
    set h [expr [winfo reqheight ${t}.f.l] + 2]

    # make help window be completely visible
    if {${x} + ${w} > $balloon_bind_info(screen_width)} {
        set x [expr $balloon_bind_info(screen_width) - ${w}]
    }
    if {${y} + ${h} > $balloon_bind_info(screen_height)} {
        set y [expr $balloon_bind_info(screen_height) - ${h}]
    }

    wm geometry ${t} +${x}+${y}
    wm deiconify ${t}

    # remove the balloon window after time-out:
    set balloon_bind_info(id,timeout) [after\
      [expr $sn_options(def,balloon-undisp-delay) + [string length ${text}] *\
      50] "catch \{destroy ${t}\}"]
}

proc canvas_rebind_info {w id text {delay -1} {procedure\
  "canvas_display_info"}} {
    global sn_options
    global balloon_bind_info

    if {${delay} < 0} {
        set delay $sn_options(def,balloon-disp-delay)
    }
    catch {
        ${w} bind ${id} <Enter> "
			set balloon_bind_info(id)  \[after ${delay} ${procedure} ${w} ${id} %X %Y\
          [list "{" ${text} "}"]\]
		"

        ${w} bind ${id} <Motion> "
			balloon_destroy
			set balloon_bind_info(id)  \[after ${delay} ${procedure} ${w} ${id} %X %Y\
          [list "{" ${text} "}"]\]
		"
    }
}

proc canvas_bind_info {w id text {delay -1} {procedure "canvas_display_info"}} {
    global sn_options
    global balloon_bind_info

    if {${delay} < 0} {
        set delay $sn_options(def,balloon-disp-delay)
    }
    #shown meens, that the info window is already displayed, don't
    #display it again
    set balloon_bind_info(shown) 0

    set balloon_bind_info(${w},${id},text) ${text}
    ${w} bind ${id} <Enter> "
		if \[info exists balloon_bind_info(${w},${id},text)\] {
		    set balloon_bind_info(id)  \[after ${delay} ${procedure}  ${w} ${id} %X\
      %Y [list "{" ${text} "}"]\]
		}
	"
    ${w} bind ${id} <Motion> "
		balloon_destroy
		if \[info exists balloon_bind_info(${w},${id},text)\] {
			set balloon_bind_info(id)  \[after ${delay} ${procedure}  ${w} ${id} %X %Y\
      [list "{" ${text} "}"]\]
		}
	"
    ${w} bind ${id} <Leave> {
		balloon_destroy
	}
    ${w} bind ${id} <Any-ButtonPress> [${w} bind ${id} <Leave>]
    ${w} bind ${id} <Any-Key> [${w} bind ${id} <Any-ButtonPress>]
}

proc canvas_display_info {w id rx ry args} {
    global sn_options
    global balloon_bind_info

    if {$balloon_bind_info(shown)} {
        return
    }
    if {[winfo containing [winfo pointerx .] [winfo pointery .]] != ${w}} {
        return
    }
    if {[catch {set bg_color $sn_options(def,balloon-bg)}]} {
        set bg_color lightyellow
    }
    if {[catch {set fg_color $sn_options(def,balloon-fg)}]} {
        set fg_color black
    }
    set balloon_bind_info(shown) 1

    catch {destroy [set t .cb_balloon]}
    toplevel ${t} -bg ${bg_color}
    wm withdraw ${t}

    if {$sn_options(def,desktop-font-size) > 14} {
        set fsize 14
    } else {
        set fsize $sn_options(def,desktop-font-size)
    }

    set text [join ${args}]
    label ${t}.l -text ${text} -wraplength 400 -justify left -bg ${bg_color}\
      -fg ${fg_color} -bd 1 -relief raised -font $sn_options(def,balloon-font)
    pack ${t}.l
    wm overrideredirect ${t} 1

    set x [winfo pointerx ${w}]
    set y [expr [winfo rooty ${w}] - [expr int([${w} canvasy 0])]]
    set bbox [${w} bbox ${id}]
    if {[catch {set y [expr ${y} + [expr [lindex ${bbox} 1] + [expr\
      [lindex ${bbox} 3] - [lindex ${bbox} 1]]]]}]} {
        set y 0
    }

    if {${y} < 0} {
        set y 0
    }
    set wdth [winfo reqwidth ${t}.l]
    set high [winfo reqheight ${t}.l]

    # make help window be completely visible
    if {${x} + ${wdth} > $balloon_bind_info(screen_width)} {
        set x [expr $balloon_bind_info(screen_width) - ${wdth}]
    }
    if {${y} + ${high} > $balloon_bind_info(screen_height)} {
        set y [expr $balloon_bind_info(screen_height) - ${high}]
    }

    wm geometry ${t} +${x}+${y}
    wm deiconify ${t}

    # remove the balloon window after 5 seconds:
    set balloon_bind_info(id,timeout) [after [expr 5000 + [string length\
      ${text}] * 50] "catch \{destroy ${t}\}"]
}

proc sn_show_abbrav {} {
    global sn_options
    global sn_scopes

    set win .sn_abbr
    set t ${win}

    if {[winfo exists ${t}]} {
        ${t} raise
        return
    }
    sourcenav::Window ${t}
    ${t} configure -title [list [get_indep String Abrav]]

    sn_ttk_buttons ${t} bottom 0 [get_indep String ok]

    ${t}.button_0 config -command "itcl::delete object ${t}"

    text ${t}.a -width 50 -wrap none -spacing1 2 -yscrollcommand "${t}.scr set"
    ttk::scrollbar ${t}.scr -command [list ${t}.a yview]
    set bw 0
    set max 0
    set sc_str ""

    foreach sc "${sn_scopes} lv ud" {
        set desc [convert_scope_to_plain_str ${sc}]

        set f ${t}.a.${sc}
        ttk::frame ${f}
        ttk::button ${f}.${sc} -image type_${sc}_image
        pack ${f}.${sc}
        pack ${f}

        ${t}.a window create end -window ${f}
        ${t}.a insert end " ${sc}:\t${desc}\n"
    }

    ${t}.a insert end ${sc_str}

    ${t}.a insert end "\n\t[get_indep String CrossReference]\n\n"
    ${t}.a insert end "r\t[get_indep String Read]\t\t"
    ${t}.a insert end "w\t[get_indep String Written]\n"
    ${t}.a insert end "p\t[get_indep String Passed]\t\t"
    ${t}.a insert end "u\t[get_indep String Unused]\n"

    ${t}.a insert end "\n\t[get_indep String ClassNoKey]\n\n"

    ${t}.a tag configure protected -font $sn_options(def,protected-font)
    ${t}.a tag configure public -font $sn_options(def,public-font)

    ${t}.a insert end "\t[get_indep String Private]\n"

    set idx [${t}.a index "insert linestart"]
    ttk::frame ${t}.a.p
    ttk::button ${t}.a.p.b -image cls_br_p_image
    pack ${t}.a.p.b
    pack ${t}.a.p

    ${t}.a window create end -window ${t}.a.p
    ${t}.a insert end "\t[get_indep String Protected]\n"

    ${t}.a tag add protected ${idx} insert

    set idx [${t}.a index "insert linestart"]
    ttk::frame ${t}.a.pub
    ttk::button ${t}.a.pub.b -image cls_br__image
    pack ${t}.a.pub.b
    pack ${t}.a.pub

    ${t}.a window create end -window ${t}.a.pub
    ${t}.a insert end "\t[get_indep String Public]\n"

    ${t}.a tag add public ${idx} insert

    ttk::frame ${t}.a.v
    ttk::button ${t}.a.v.v -image cls_br_v_image
    pack ${t}.a.v.v
    pack ${t}.a.v

    ${t}.a window create end -window ${t}.a.v
    ${t}.a insert end " v\t[get_indep String Virtual]\n"

    ttk::frame ${t}.a.s
    ttk::button ${t}.a.s.s -image cls_br_s_image
    pack ${t}.a.s.s
    pack ${t}.a.s

    ${t}.a window create end -window ${t}.a.s
    ${t}.a insert end " s\t[get_indep String Static]\n"

    ttk::frame ${t}.a.pl
    ttk::button ${t}.a.pl.pl -image cls_br_+_image
    pack ${t}.a.pl.pl
    pack ${t}.a.pl

    ${t}.a window create end -window ${t}.a.pl
    ${t}.a insert end " +\t[get_indep String PafAbrOverride]\n"

    ttk::frame ${t}.a.min
    ttk::button ${t}.a.min.mi -image cls_br_-_image
    pack ${t}.a.min.mi
    pack ${t}.a.min

    ${t}.a window create end -window ${t}.a.min
    ${t}.a insert end " -\t[get_indep String PafAbrOverridden]\n"

    set height [expr int([${t}.a index "end -1c"]) + 1]

    ${t}.a config -state disabled -height ${height}

    pack ${t}.a   -side left -fill x -expand yes
    pack ${t}.scr -side left -fill y

    ${t} move_to_mouse
#    catch {${t} resizable no yes}

    tkwait visibility ${win}

    set idx [lindex [split [${t}.a index end] "."] 0]
    update idletasks

    return
}
