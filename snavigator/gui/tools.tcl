# Copyright (c) 2000, 2001, Red Hat, Inc.
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
# tools.tcl - Miscellaneous classes.
# Copyright (C) 1998, 1999 Cygnus Solutions.

##########################################
##
## Labeled entry
##
##########################################
option add *Entry&.width 5 widgetDefault
option add *Entry&.labelwidth -1 widgetDefault
option add *Entry&.state "normal" widgetDefault
option add *Entry&.exportselection y widgetDefault
option add *Entry&.underline -1 widgetDefault

itcl::class Entry& {
    inherit itk::Widget
    constructor {args} {

        itk_component add label {
            ttk::label $itk_interior.label
        } {
            rename -text -label label Label
            rename -width -labelwidth labelWidth Width
            keep -anchor -underline -state 
	}

	itk_component add entry {
	    ttk::entry $itk_interior.entry
	} {
	    keep -textvariable -exportselection -state -width
	}

        eval itk_initialize $args

	bind $itk_component(entry) <KeyPress> "
	    if {\[[itcl::code $this checkkeypress] %K\] == 1} {
	        continue
	    }
            bell
            break"

	pack $itk_component(label) -side $itk_option(-side)
        pack $itk_component(entry) -side $itk_option(-side)\
		-fill $itk_option(-fill) -expand $itk_option(-expand)

        if {$itk_option(-balloon) != ""} {
            balloon_bind_info $itk_component(entry) $itk_option(-balloon)
        }

        bind $itk_component(entry) <Tab> {focus [tk_focusNext %W]}
        bind $itk_component(entry) <Shift-Tab> {focus [tk_focusPrev %W]}
    }

    method checkkeypress {key {args ""}} {
	switch $itk_option(-filter) {
	    none { return 1 }
	    natural {
		if {$key == "BackSpace" \
			|| $key == "Delete" \
			|| $key == "Return"} {
		    return 1
		}
		if {[regexp {^[0-9]} $key] == 0} {
		    return 0
		}
	    }
	}
	return 1
    }    

    itk_option define -side side Side "left"

    itk_option define -anchor anchor Anchor "nw"

    itk_option define -fill fill Fill "both"

    itk_option define -expand expand Expand y

    itk_option define -balloon balloon Balloon ""

    itk_option define -filter filter Filter none {

	# Fixme: Currently only "none" and "natural" work.

	if {$itk_option(-filter) == "none"} {
	    # Unset all currently set filters.
	} elseif {$itk_option(-filter) == "posInt"} {
	    # Set filter for positive integers only (no zero).
	} elseif {$itk_option(-filter) == "natural"} {
	    # Set filter for positive integer and zero.
	} elseif {$itk_option(-filter) == "integer"} {
	    # Set filter for any integer value.
	} elseif {$itk_option(-filter) == "float"} {
	    # Any floating value.
	} else {
	    # Error condition
	    error "bad filter option \"$itk_option(-filter)\":\
		    should be none, posInt, natural, integer:\
		    or float."
	}
    }

}

##########################################
##
## Radio box
##
##########################################
itcl::class Radio& {
    inherit itk::Widget
    constructor {args} {

        eval itk_initialize $args

        if {$itk_option(-variable) == ""} {
            set itk_option(-variable) ${this}-value
        }

        if {$itk_option(-label) != ""} {
            ttk::label $itk_component(hull).label -text $itk_option(-label) -underline $itk_option(-labelunderline)
            pack $itk_component(hull).label -side $itk_option(-side) -fill x -expand n
            if {$itk_option(-labelwidth) != -1} {
                $itk_component(hull).label configure -width $itk_option(-labelwidth)
            }
        }

        set wdgs ""
        set i 0

        set fr $itk_component(hull)
        foreach n $itk_option(-labels) {
            set val [lindex $itk_option(-contents) ${i}]
            if {${val} == ""} {
                set val ${i}
            }
            set bal [lindex $itk_option(-balloons) ${i}]

            ttk::radiobutton ${fr}.radio-${i} -text ${n} -variable $itk_option(-variable)\
              -value ${val} -underline $itk_option(-underline)

            pack ${fr}.radio-${i} -side $itk_option(-side) -fill x -expand $itk_option(-expand)\
              -anchor nw

            if {$itk_option(-command) != ""} {
                ${fr}.radio-${i} configure -command "eval $itk_option(-command)"
            }
            #bind balloon text
            if {${bal} != ""} {
                balloon_bind_info ${fr}.radio-${i} ${bal}
            }

            lappend wdgs ${fr}.radio-${i}

            incr i
        }
    }

    itk_option define -labelwidth labelwidth LabelWidth 20
    itk_option define -width width Width 20
    itk_option define -label label Label ""
    itk_option define -side side Side left
    itk_option define -fill fill Fill both
    itk_option define -expand expand Expand n
    itk_option define -anchor anchor Anchor nw
    itk_option define -variable variable Variable ""
    itk_option define -labels labels Labels ""
    itk_option define -contents contents Contents ""
    itk_option define -command command Command ""
    itk_option define -balloons balloons Balloons ""
    itk_option define -underline underline Underline -1
    itk_option define -labelunderline labelunderline Labelunderline -1
}

##########################################
##
## Checkbutton
##
##########################################
# 
# This class is just to created groups of
# checkbuttons.
#
# Basic usage:
# 
# CheckButton& <path> -labels <list of checkbutton labels>\
#                     -values <list of checkbutton values>\
#                     -variables <list of checkbutton variables>
#
# Other Notes:
#  This is not the best way to create and manage groups of
#  checkbuttons.  This needs a complete rewrite.
#
#########################################

itcl::class CheckButton& {
    inherit itk::Widget

    constructor {args} {

        eval itk_initialize $args

        itk_component add label {
            ttk::label $itk_interior.label
	} {
	    keep -underline
            rename -text -label text Text
	    rename -width -labelwidth labelWidth Width
	}
        pack $itk_component(label) -side ${side} -fill x -expand n

        set fr $itk_component(hull)
        set i 0
        foreach n $itk_option(-labels) {
            set var [lindex $itk_option(-variables) ${i}]
            set bal [lindex $itk_option(-balloons) ${i}]
            if {${var} == ""} {
                set var ${this}-${i}
            }
            set vals [lindex $itk_option(-values) ${i}]
            if {${vals} != ""} {
                set onval [lindex ${vals} 0]
                set offval [lindex ${vals} 1]
            } else {
                set onval 1
                set offval 0
            }
            set underline [lindex ${underlines} ${i}]
            if {${underline} == ""} {
                set underline -1
            }
            ttk::checkbutton ${fr}.check-${i} -text ${n} -variable ${var}\
              -onvalue ${onval} -offvalue ${offval} 			 \
              -underline ${underline} -state ${state}

            pack ${fr}.check-${i} -side ${side} -fill x -expand ${expand}\
              -anchor nw

            if {${command} != ""} {
                ${fr}.check-${i} configure -command " eval ${command} "
            }
            #bind balloon text
            if {${bal} != ""} {
                balloon_bind_info ${fr}.check-${i} ${bal}
            }
            incr i
        }

        #when only a checkbutton is availiable and doesn't
        #have text, underline text widget.
        if {${labelunderline} == -1 && ${i} == 1 && ${n} == ""} {
            $itk_component(hull).label configure -underline ${underline}
        }
    }

    public variable labelwidth 20
    public variable width 20
    public variable label none
    public variable side left
    public variable fill both
    public variable expand n
    public variable anchor nw
    itk_option define -variables variables Variables ""
    public variable balloons ""
    itk_option define -labels labels Labels "on"
    itk_option define -values values Values ""
    public variable command ""
    public variable underlines -1
    public variable state "normal"
    public variable labelunderline -1
}


#############################################
# [Label Entry Button] widget
#############################################
itcl::class LabelEntryButton& {
    inherit itk::Widget
    constructor {args} {
        global sn_options

        itk_component add label {
            ttk::label $itk_component(hull).label
        } {
            rename -width -labelwidth labelWidth Width
            keep -underline -anchor -text
        }

        # entry for path
        itk_component add entry {
            ttk::entry $itk_interior.text
	} {
	    keep -state -width
	}

        itk_component add button {
	    ttk::button $itk_interior.button -text [get_indep String Choose] \
                -width [string len [get_indep String Choose]]
        } {
            rename -underline -buttonunderline buttonUnderline Underline
            keep -state -command
        }

        # this should be add as an itk_option
        if {${buttonballoon} != ""} {
            balloon_bind_info $itk_component(button) ${buttonballoon}
        }

        eval itk_initialize $args

        # If no -command is set then bind the button to a
        # file selection dialog.
        if {$itk_option(-command) == ""} {
            $this configure -command [itcl::code ${this} select_file]
        }

        pack $itk_component(label)  -side left -fill x
        pack $itk_component(entry)  -side left -fill both -expand y
        pack $itk_component(button) -side left -fill x    -padx {4 0}


        # Link up the widget and the -value option
        $itk_component(entry) configure -textvariable \
            [itcl::scope itk_option(-value)]
    }

    destructor {
        sourcenav::OptionTrace::deleteOptionTrace -variable -value \
            [itcl::scope itk_option]
    }

    private method select_file_cb {file} {
        global tcl_platform

        if {($tcl_platform(os)=="Windows 95") &({string length\
          $defaultextension} > 4)} {
            #Windows95 file select dialog has probably truncated the file\
              extension
            set file [file rootname ${file}]
            set file "${file}${defaultextension}"
        }
        
        if {${native}} {
            $this configure -value [file nativename $file]
        } else {
            $this configure -value ${file}
        }
    }

    private method select_file {} {

        if {$itk_option(-variable) != ""} {
	    global $itk_option(-variable)
	    upvar #0 $itk_option(-variable) var
            set inifile [file tail $var]
            if {$directory && [file isdirectory $var]} {
                set inidir $var
            } else {
                set inidir [file dirname $var]
            }
        } else {
	    # Fixme: if the user is not using -variable
	    # there are other ways to initialize these:-
            set inifile ""
            set inidir ""
        }

        if {$directory} {
            Editor&::DirDialog [winfo toplevel $itk_component(entry)] -title\
               [get_indep String Open] -script [itcl::code ${this} select_file_cb] \
               -dir $inidir
        } else {
            Editor&::FileDialog [winfo toplevel $itk_component(entry)] -title\
              [get_indep String Open] -save_open ${save_open} -script\
              [itcl::code ${this} select_file_cb] \
              -defaultextension ${defaultextension} -extensions ${extensions}\
              -initialdir ${inidir} -initialfile ${inifile}
        }
    }

    public variable native 1
    public variable defaultextension ""
    public variable extensions ""
    public variable save_open "open"
    public variable anchor nw
    public variable buttonballoon [get_indep String ChooseINFO]

    # Used to set the entry widget value.
    itk_option define -value value Value ""

    # Used to set a variable that will be the entry widget value.
    itk_option define -variable variable Variable "" {
        sourcenav::OptionTrace::configureOptionTrace -variable -value \
            [itcl::scope itk_option]
    }

    public variable directory 0
}

#Choose Font
itcl::class ChooseFont& {
    inherit sourcenav::Dialog

    global sn_options

    constructor {args} {
        global sn_options
        global tcl_platform

        eval itk_initialize $args

        $this configure -modality application

        ${this} withdraw

        $this configure -title [get_indep String ChooseFont]

        # External frame to cover all of the toplevel
        set extFrame [ttk::frame $itk_component(hull).extFrame]
        pack $extFrame -fill both -expand y 

        #ok/apply/cancel buttons
        sn_ttk_buttons $extFrame bottom 0 [get_indep String ok]\
          [get_indep String Apply] [get_indep String cancel]
        $extFrame.button_0 configure -command "${this} apply "
        $extFrame.button_1 configure -command "${this} apply 0"
        $extFrame.button_2 configure -command "${this} deactivate 0"

        set fntfr  $extFrame.font
        ttk::frame ${fntfr}
        pack ${fntfr} -side top -fill x -padx 10 -pady 5

        set fntfr $extFrame.font.name
        pack [ttk::frame ${fntfr}] -side top -fill x

        #font name
        ttk::label ${fntfr}.namlbl -text [get_indep String FontName] -anchor ne
        pack ${fntfr}.namlbl -side left
        set nam ${fntfr}.nam
        ttk::combobox ${nam} -width 22 
        bind ${nam} <<ComboboxSelected>> "${this} view_font"
        ${nam} configure -values [lsort -unique [font families]]
        pack ${nam} -side left

        #font size
        ttk::label ${fntfr}.sizlbl -text [get_indep String FontSize] -anchor ne
        pack ${fntfr}.sizlbl -side left
        set siz ${fntfr}.siz
        ttk::spinbox ${siz} -width 3 -command "${this} view_font" -from 8 -to 28
        pack ${siz} -side left

        set fntfr $extFrame.font.checks
        pack [ttk::frame ${fntfr}] -side top -fill x -anchor c

        #Normal/Bold
        set bld ${fntfr}.bld
        ttk::checkbutton ${bld} -text [get_indep String FontBold]\
          -variable ${this}-bold -onvalue "bold" -offvalue "medium"\
          -underline ${underline} -command " ${this} view_font "

        pack ${bld} -side left -anchor c

        #Normal/Cursive
        set cursive ${fntfr}.cursive
        ttk::checkbutton ${cursive} -text [get_indep String FontCursive]\
          -variable ${this}-cursive -onvalue "o" -offvalue "r"\
          -underline ${underline} -command " ${this} view_font "
        pack ${cursive} -side left -anchor c

        ttk::label $extFrame.sample -text  [get_indep String Sample] -anchor c
        pack  $extFrame.sample -side top -fill x -expand y -pady {3 10} -padx 20

        if {[catch {$extFrame.sample configure -font $itk_option(-current)}]} {
            set current $sn_options(def,default-font)
             $extFrame.sample configure -font $itk_option(-current)
        }

        disp_font $itk_option(-current)

        #view current color
        view_font $itk_option(-current)

        #center window
        ${this} centerOnScreen
        ${this} take_focus

        #vwait $variable
    }
    destructor {
        catch {itcl::delete object ${nam}}
        catch {itcl::delete object ${siz}}
        foreach v [::info globals "${this}-*"] {
            catch {uplevel #0 unset ${v}}
        }
    }

    method disp_font {fnt} {
        upvar #0 ${this}-bold bold
        upvar #0 ${this}-cursive cursive

        set fnt [split ${fnt} "-"]
        set len [llength ${fnt}]
        if {${len} > 8} {
            set family [lindex ${fnt} 1]
            set name [lindex ${fnt} 2]
            set sz [lindex ${fnt} 8]
            set bld [lindex ${fnt} 3]
            set crsv [lindex ${fnt} 4]
        } else {
            set name [lindex ${fnt} 0]
            set family ""
            set sz 120
            set bld ""
            set crsv ""
        }
        if {${name} == ""} {
            set name "Courier"
        }

        ${nam} set ${name}

        if {${sz} != "*" && [catch {set x [expr ${sz} + 0]}]} {
            set sz 120
        }
        if {${sz} != "*"} {
            set sz [expr ${sz} / 10]
        }
        ${siz} set ${sz}

        set bold [string tolower ${bld}]
        set cursive [string tolower ${crsv}]
    }

    method view_font {{value ""}} {
        global sn_options
        upvar #0 ${this}-bold bold
        upvar #0 ${this}-cursive cursive

        if {${bold} == ""} {
            set bold "medium"
        }
        if {${cursive} == ""} {
            set cursive "r"
        }

        set name   [${nam} get]
        set size   [${siz} get]

        #add '0' to the font size
        if {${size} != "*"} {
            set size "${size}0"
        }

        set itk_option(-current) \
          "-*-${name}-${bold}-${cursive}-Normal--*-${size}-*-*-*-*-iso8859-1"
        if {[catch {$itk_component(hull).extFrame.sample configure -font $itk_option(-current)}]} {
            set itk_option(-current) $sn_options(def,default-font)
            $itk_component(hull).extFrame.sample configure -font $itk_option(-current)
            bell
        }
    }

    method apply {{exit 1}} {
        if {$itk_option(-command) != ""} {
            eval $itk_option(-command) [list $itk_option(-current)]
        }
        if {${exit}} {
            $this deactivate 1
        }
    }

    protected variable nam
    protected variable siz

    public variable underline -1

    itk_option define -command command Command ""

    itk_option define -current current Current $sn_options(def,default-font) {
        if {[winfo exists ${this}]} {
            disp_font $itk_option(-current)
            view_font
        }
    }
}

###################################################
##
## Color managment
##
###################################################
itcl::class Color& {
    inherit itk::Widget

    constructor {args} {
        global sn_path

        set unknown_bitmap [file join $sn_path(bitmapdir) undef.xbm]
        set plus_bitmap [file join $sn_path(bitmapdir) plus.xbm]
        set minus_bitmap [file join $sn_path(bitmapdir) minus.xbm]

        set cmbfr $itk_component(hull).cmbfr
        ttk::frame ${cmbfr}
        pack ${cmbfr} -side left -fill y

        #Schemes
        set combo [ttk::combobox ${cmbfr}.schemes]
        bind $combo <<ComboboxSelected>> "${this} display_scheme"
        pack ${combo} -side top -fill x

        #Categories
        set tree ${cmbfr}.tree
        Tree ${tree} -indentwidth 20 -width 34 -plusimage plus_image\
          -minusimage minus_image -filter ""

        ${tree} treebind <ButtonRelease-1> "${this} display_value %x %y"
        ${tree} treebind <space> "%W selection clear 0 end
							%W selection set active
							${this} display_item
							break"
        ${tree} treebind <Return> [${tree} treebind <space>]
        pack ${tree} -side top -fill y -expand y
        set treew [${tree} tree]

        set fr $itk_component(hull).fr
        pack [ttk::frame ${fr}] -side right -fill both -expand y

        #sample for current setting
        set sample ${fr}.sample
        label ${sample} -text [get_indep String Sample] -anchor c -height 3
        pack ${sample} -fill x -side top -pady 30

        #choose font
        set fnt_btn ${fr}.fnt
        LabelEntryButton& ${fnt_btn} -text [get_indep String Font]\
          -labelwidth 14 -underline [get_indep Pos Font] -command " ${this}\
          choose_font ${fnt_btn} " -anchor e -state disabled

        # Since error handling is currently broken, disable typing.
        # ${fnt_btn}.txt configure -state disabled

        bind ${fnt_btn} <FocusOut> "${this} verify_font"
        pack ${fnt_btn} -side top -fill x

        #choose color
        set fg_btn ${fr}.fg
        #button $fg_btn -text [get_indep String FgColor]
        #pack $fg_btn -side top -padx 5 -pady 5 -fill x -expand y
        LabelEntryButton& ${fg_btn} -text [get_indep String FgColor]\
          -labelwidth 14 -underline [get_indep Pos FgColor] -command " ${this}\
          choose_fg ${fg_btn} " -anchor e -state disabled

        # Since error handling is currently broken, disable typing.
        # ${fg_btn}.txt configure -state disabled

        bind ${fg_btn} <FocusOut> "${this} verify_color fg"
        pack ${fg_btn} -side top -fill x

        #choose color
        set bg_btn ${fr}.bg
        #button $bg_btn -text [get_indep String BgColor]
        #pack $bg_btn -side top -padx 5 -pady 5 -fill x -expand y
        LabelEntryButton& ${bg_btn} -text [get_indep String BgColor]\
          -underline [get_indep Pos BgColor] -labelwidth 14 -command " ${this}\
          choose_bg ${bg_btn} " -anchor e -state disabled

        # Since error handling is currently broken, disable typing.
        # ${bg_btn}.txt configure -state disabled

        bind ${bg_btn} <FocusOut> "${this} verify_color bg"
        pack ${bg_btn} -side top -fill x

        #reset
        set rst ${fr}.rst
        ttk::button ${rst} -text [get_indep String Reset] -command " ${this} reset "
        pack ${rst} -side top -anchor ne -pady 5 -padx 1

        eval itk_initialize $args

        display_schemes

        after idle "pack propagate ${tree} 0"
    }

    #add availiable scheme names to the combo box
    method display_schemes {} {
        set default_scheme ""
        set contents [list]
        foreach sm ${schemes} {
            set sname [lindex ${sm} 0]
            lappend contents ${sname}

            if {${default_scheme} == ""} {
                set default_scheme ${sname}
            }
        }
        ${combo} configure -values $contents
        ${combo} set ${default_scheme}
        display_scheme ${default_scheme}
    }

    #draw the tree of variable settings for the actual scheme
    method display_scheme {scheme} {
        foreach sm ${schemes} {
            set sname [lindex ${sm} 0]
            if {${sname} != ${scheme}} {
                continue
            }
            set sents [lindex ${sm} 1]

            #delete old values
            ${treew} delete 0 end
            #categories (editor, class, ..)
            foreach cat [join [lrange ${sm} 1 end]] {
                set cname [lindex ${cat} 0]
                set cents [lindex ${cat} 1]
                set idx [${treew} insert end -text ${cname}\
                  -bitmap @${unknown_bitmap}]
                #options (text, ..)
                foreach ent ${cents} {
                    set ename [lindex ${ent} 0]
                    set eents [lindex ${ent} 1]
                    if {${ename} == ""} {
                        continue
                    }
                    ${treew} insert end -text ${ename} -parent ${idx}\
                      -data ${eents} -bitmap @${unknown_bitmap}
                }
            }
        }
    }

    method display_item {{idx ""}} {
        if {${idx} == ""} {
            set idx [${treew} curselection]
        }
        if {${idx} == ""} {
            bell
            return
        }
        set data [${treew} data ${idx}]
        control_buttons ${data}
    }

    method display_value {x y} {
        #toggle the sub tree, if availiable
        set ret [${treew} identify ${x} ${y}]
        if {${ret} == "view" || ${ret} == "hide"} {
            ${treew} toggle @${x},${y}
            return
        }
        display_item
    }

    method reset {} {
        global sn_options
        if {${fnt} != ""} {
            set sn_options(${opt_fnt}) $sn_options(${fnt})
        }
        if {${fg} != ""} {
            set sn_options(${opt_fg}) $sn_options(${fg})
        }
        if {${bg} != ""} {
            set sn_options(${opt_bg}) $sn_options(${bg})
        }
    }

    method control_buttons {data} {
        global sn_options

        if {${data} == ""} {
            set state disabled
        } else {
            set state normal
        }
        if {${data} == ""} {
            set fnt ""
            set opt_fnt ""
            set fg ""
            set opt_fg ""
            set bg ""
            set opt_bg ""
        } else {
            set fnt [lindex ${data} 0]
            set opt_fnt [lindex ${data} 1]
            set fg [lindex ${data} 2]
            set opt_fg [lindex ${data} 3]
            set bg [lindex ${data} 4]
            set opt_bg [lindex ${data} 5]
        }

        if {${fnt} == ""} {
            ${fnt_btn} configure  -state disabled -variable "" -value ""

# FIXME: disabled, do we even need this?
            # Since error handling is currently broken, disable typing.
#            ${fnt_btn}.txt configure -state disabled

            ${sample} configure -font $sn_options(def,default-font)
        } else {
            ${fnt_btn} configure -state normal

# FIXME: disabled, do we even need this?
            # Since error handling is currently broken, disable typing.
#            ${fnt_btn}.txt configure -state disabled

            if {![::info exists sn_options(${opt_fnt})]} {
                set sn_options(${opt_fnt}) $sn_options(${fnt})
            }
            ${sample} configure -font $sn_options(${opt_fnt})
            ${fnt_btn} configure -variable sn_options(${opt_fnt})\
              -value $sn_options(${opt_fnt})
        }
        if {${fg} == ""} {
            ${fg_btn} configure -state disabled -variable "" -value ""

            # Since error handling is currently broken, disable typing.
#            ${fg_btn}.txt configure -state disabled

            ${sample} configure -fg black
        } else {
            ${fg_btn} configure -state normal

            # Since error handling is currently broken, disable typing.
#            ${fg_btn}.txt configure -state disabled

            if {![::info exists sn_options(${opt_fg})]} {
                set sn_options(${opt_fg}) $sn_options(${fg})
            }
            ${sample} configure -fg $sn_options(${opt_fg})
            ${fg_btn} configure -variable sn_options(${opt_fg})\
              -value $sn_options(${opt_fg})
        }
        if {${bg} == ""} {
            ${bg_btn} configure -state disabled -variable "" -value ""

            # Since error handling is currently broken, disable typing.
#            ${bg_btn}.txt configure -state disabled

            ${sample} configure -bg white
        } else {
            ${bg_btn} configure -state normal

            # Since error handling is currently broken, disable typing.
#            ${bg_btn}.txt configure -state disabled

            if {![::info exists sn_options(${opt_bg})]} {
                set sn_options(${opt_bg}) $sn_options(${bg})
            }
            ${sample} configure -bg $sn_options(${opt_bg})
            ${bg_btn} configure -variable sn_options(${opt_bg})\
              -value $sn_options(${opt_bg})
        }
    }

    #if we can't set the font the sample, the
    #it is a wrong font
    method verify_font {} {
        global sn_options
        if {${fnt} == ""} {
            return
        }
        if {$sn_options(${opt_fnt}) == "" || [catch {${sample} configure \
          -font $sn_options(${opt_fnt})}]} {
            bell
            set sn_options(${opt_fnt}) $sn_options(${fnt})

            if {[catch {${sample} configure -font $sn_options(${fnt})}]} {
                set sn_options(${opt_fnt}) "Courier"
            }
        }
    }

    #verify if it is a correct color
    method verify_color {fg_bg} {
        global sn_options
        if {${fg_bg} == "fg" && ${fg} == "" || ${fg_bg} == "bg" && ${bg} ==\
          ""} {
            return
        }
        if {${fg_bg} == "fg"} {
            if {[catch {${sample} configure -fg $sn_options(${opt_fg})}] ||\
              $sn_options(${opt_fg}) == ""} {
                bell
                set sn_options(${opt_fg}) $sn_options(${fg})
            }
        }
        if {${fg_bg} == "bg"} {
            if {[catch {${sample} configure -bg $sn_options(${opt_bg})}] ||\
              $sn_options(${opt_bg}) == ""} {
                bell
                set sn_options(${opt_bg}) $sn_options(${bg})
            }
        }
    }

    #called from choosing font to set the selected font
    #to the optional variable
    method setfont {cls fontname choosed_font} {
        global sn_options
        if {${choosed_font} != ""} {
	    set ret [catch {${sample} configure -font ${choosed_font}}]
            
                set ${fontname} ${choosed_font}
           
        }
    }

    #choose different font
    method choose_font {cls} {
        global sn_options tcl_platform

        if {$tcl_platform(platform) == "windows"} {
            # use native Windows common Dialog font selector
            set tempFont [ide_win_choose_font\
              -default $sn_options(${opt_fnt}) -parent ${cls}]
            if {$tempFont ne ""} {
                set sn_options(${opt_fnt}) $tempFont
                sn_log "New font (for ${opt_fnt}) = $sn_options(${opt_fnt})"
            }
        } else {
            set win ${this}-font

            if {[itcl::find object ${win}] == $win} {
                itcl::delete object ${win}
            }

            ChooseFont& ${win} -current $sn_options(${opt_fnt}) -command\
              [itcl::code $this setfont $cls sn_options($opt_fnt)]

            $win activate

            itcl::delete object $win
        }
    }

    #accept choosed color
    method setcolor {fg_bg cls clrname choosed_clr} {
        global sn_options
        global ${clrname}
        if {${choosed_clr} != ""} {
            if {${fg_bg} == "fg"} {
                set ret [catch {${sample} configure -fg ${choosed_clr}}]
            } else {
                set ret [catch {${sample} configure -bg ${choosed_clr}}]
            }
            if {! ${ret}} {
                set ${clrname} ${choosed_clr}
            }
        }
    }

    #choose fgcolor
    method choose_fg {cls} {
        global sn_options
        set win ${this}-choose_color
        if {[itcl::find object ${win}] == $win} {
            itcl::delete object ${win}
        }
        set tempColor [tk_chooseColor -initialcolor $sn_options(${opt_fg}) \
                -parent ${cls} -title  [get_indep String ChooseColor]]
        if {$tempColor ne ""} {
                ${this} setcolor fg ${cls} sn_options(${opt_fg}) $tempColor
        }
    }

    #choose bg color
    method choose_bg {cls} {
        global sn_options
        set win ${this}-choose_color
        if {[itcl::find object ${win}] == $win} {
            itcl::delete object ${win}
        }
        set tempColor [tk_chooseColor -initialcolor $sn_options(${opt_bg}) \
                -parent ${cls} -title  [get_indep String ChooseColor]]
        if {$tempColor ne ""} {
                ${this} setcolor bg ${cls} sn_options(${opt_bg}) $tempColor
        }
    }

    protected variable fnt ""
    protected variable opt_fnt ""
    protected variable fg ""
    protected variable opt_fg ""
    protected variable bg ""
    protected variable opt_bg ""

    protected variable combo
    protected variable treew
    protected variable tree
    protected variable sample
    protected variable fnt_btn
    protected variable fg_btn
    protected variable bg_btn

    protected variable unknown_bitmap ""
    protected variable plus_bitmap ""
    protected variable minus_bitmap ""

    public variable width 20
    public variable text "class"
    public variable color "color"
    public variable variable ""
    public variable schemes ""
}

################################################################################
#
# Checklist a namespace to manage a list of related checkbuttons
#
################################################################################
namespace eval checklist {


proc checklist {w args} {
    variable ckArgs

    ttk::frame $w

    ParseArguments $w args

    set lb [ttk::label $w.label -underline $ckArgs(-underline) \
            -text $ckArgs(-text) -width $ckArgs(-labelwidth)   \
            -anchor $ckArgs(-anchor)]
    pack $lb -side $ckArgs(-side) -fill x -expand n

    set i 0
    foreach lab $ckArgs(-labels)   var $ckArgs(-variables) \
            bal $ckArgs(-balloons) val $ckArgs(-values)    \
            und $ckArgs(-underline) {
        if {${var} == ""} {
            set var ${w}-${i}
        }
        if {${val} != ""} {
            set onval  [lindex ${val} 0]
            set offval [lindex ${val} 1]
        } else {
            set onval 1
            set offval 0
        }
        if {${und} == ""} {
            set und -1
        }
        ttk::checkbutton ${w}.check-${i} -text ${lab} -variable ${var}   \
                -onvalue ${onval} -offvalue ${offval}                    \
                -underline ${und} -state $ckArgs(-state)
        pack ${w}.check-${i} -side $ckArgs(-side) -fill x                \
                -expand $ckArgs(-expand) -anchor $ckArgs(-anchor)        \
                -padx $ckArgs(-padx)

        if {$ckArgs(-command) != ""} {
            ${w}.check-${i} configure -command " eval $ckArgs(-command) "
        }
        if {${bal} != ""} {
            balloon_bind_info ${w}.check-${i} ${bal}
        }
        incr i
    }
    #when only a checkbutton is availiable and doesn't
    #have text, underline text widget.
    if {$ckArgs(-labelunderline) == -1 && ${i} == 1 && ${lab} == ""} {
        $w.label configure -underline $ckArgs(-underline)
    }
    return $w
}

################################################################################
# ParseArguements
#    Command to parse the options for the checklist.
#
# Parameters:
#    w: Path to the checklist.
#    parameters: The arguments to parse.
################################################################################
proc ParseArguments {w parameters} {
    variable ckArgs

    upvar $parameters args

    set ckArgs(-width)             20
    set ckArgs(-labelwidth)        20
    set ckArgs(-state)             normal
    set ckArgs(-labelunderline)   -1

    set ckArgs(-anchor)            w
    set ckArgs(-text)              ""
    set ckArgs(-textvariable)      radiolist::${w}.textvariable

    set ckArgs(-side)              left
    set ckArgs(-fill)              both
    set ckArgs(-expand)            0
    set ckArgs(-padx)              {0 15}

    set ckArgs(-balloons)          ""

    set ckArgs(-labels)            ""
    set ckArgs(-values)            ""
    set ckArgs(-underline)         -1

    set ckArgs(-variables)          ""
    set ckArgs(-command)           ""

    array set ckArgs $args

    return
}

}

###############################################################################
# labelentrybutton
#   A namespace to manage a megawidget made with, well, I'll let you guess
###############################################################################
namespace eval labelentrybutton {

proc labelentrybutton {w args} {
    global sn_options
    variable lebArgs

    ttk::frame $w
    ParseArguments $w args

    ttk::label $w.label -width $lebArgs($w,-labelwidth) -anchor $lebArgs($w,-anchor) \
            -text $lebArgs($w,-text)
    ttk::entry $w.entry -width $lebArgs($w,-width) -state $lebArgs($w,-state)        \
            -textvariable $lebArgs($w,-variable)
    ttk::button $w.button -text "..." -width 4  -state $lebArgs($w,-state)           \
            -command $lebArgs($w,-command)

    if {$lebArgs($w,-balloon) != ""} {
        balloon_bind_info $w.button $lebArgs($w,-balloon)
    }

    # If no -command is set then bind the button to a
    # file selection dialog.
    if {$lebArgs($w,-command) == ""} {
        $w.button configure -command "
            labelentrybutton::select_file $w $lebArgs($w,-directory)
        "
    }

    pack $w.label  -side left -fill x
    pack $w.entry  -side left -fill both -expand y
    pack $w.button -side left -fill x -padx {5 0}

    rename ::$w $w
    eval {
        proc "::$w" {command args} {
            ::labelentrybutton::lebcmd [lindex [info level 0] 0] $command $args
        }
    }
    return
}

################################################################################
# ParseArguments
#    Command to parse the options for the labelentrybutton.
#
# Parameters:
#    w: Path to the labelentrybytton.
#    parameters: The arguments to parse.
################################################################################
proc ParseArguments {w parameters} {
    variable lebArgs

    upvar $parameters args

    set lebArgs($w,-width)             20
    set lebArgs($w,-labelwidth)        10
    set lebArgs($w,-state)             normal
    set lebArgs($w,-underline)        -1

    set lebArgs($w,-anchor)            w
    set lebArgs($w,-text)              ""
    set lebArgs($w,-variable)          labelentrybutton::${w}.textvariable

    set lebArgs($w,-directory)         0

    set lebArgs($w,-expand)            0
    set lebArgs($w,-padx)              {0 15}

    set lebArgs($w,-balloon)           ""
    set lebArgs($w,-command)           ""

    set lebArgs($w,-save_open)         open
    set lebArgs($w,-defaultextension)  ""
    set lebArgs($w,-extensions)        ""

    for {set i 0;set n [llength $args]} {$i<$n} {} {
        set lebArgs($w,[lindex $args $i]) [lindex $args [incr i]]
    }
    return
}

################################################################################
# lebcmd
#    Invoked when the command associated to the labelentrybutton pseudowidget 
#    is used.
#
# Parameters:
#    w: Path to the labelentrybutton.
#    command: The command used: 'configure', 'cget', 'set' or 'get'.
#    args: The parameters for the command.
################################################################################
proc lebcmd {w command args} {

    set state [lindex [lindex $args 0] 1]
    switch -exact -- $command {
        configure {
            $w.button configure -state $state
            $w.entry  configure -state $state
        }
        cget {
            return [$w.entry cget -state $arg]
        }
        set {
            $w.entry delete 0 end
            $w.entry insert 0 $args
        }
        get {
            set var [$w.entry cget -textvariable]
            return [set $var]
        }
        default {
            puts "We need another command for lebs: $command"
        }
    }
    return
}

################################################################################
# select_file
#    The default action for the button is to choose a file or directory.
#
# Parameters:
#    w: Path to the labelentrybutton.
#    directory: '1' if we want a directory.
################################################################################
proc select_file {w directory} {
    variable lebArgs

    set var [$w.entry get]
    if {$var != ""} {
        set inifile [file tail $var]
        if {$directory && [file isdirectory $var]} {
            set inidir $var
        } else {
            set inidir [file dirname $var]
        }
    } else {
        set inifile ""
        set inidir ""
    }
    if {$directory} {
        Editor&::DirDialog [winfo toplevel $w]                    \
                -title [get_indep String Open]                    \
                -script "$w set"                                  \
                -dir $inidir
    } else {
        Editor&::FileDialog [winfo toplevel $w]                             \
                -title  [get_indep String Open]                             \
                -save_open $lebArgs($w,-save_open)                          \
                -script "$w set"                                            \
                -defaultextension $lebArgs($w,-defaultextension)            \
                -extensions $lebArgs($w,-extensions) -initialdir ${inidir}  \
                -initialfile ${inifile}
    }
    return
}
}

################################################################################
#
# Radiolist a namespace to create a list of related radiobuttons
#
################################################################################
namespace eval radiolist {

proc radiolist {w args} {
    variable rdArgs

    ttk::frame $w
    ParseArguments $w args

    set lb [ttk::label $w.label -text $rdArgs(-text)                    \
            -underline $rdArgs(-underline) -state $rdArgs(-state)       \
            -width $rdArgs(-labelwidth) -anchor $rdArgs(-anchor)]
    pack $lb -side $rdArgs(-side) -fill x -expand n -padx {0 5}

    set i 0
    foreach lab $rdArgs(-labels) val $rdArgs(-contents) bal $rdArgs(-balloons) {
        if {${val} == ""} {
            set val ${i}
        }
        ttk::radiobutton ${w}.radio-${i} -text ${lab}                   \
              -variable $rdArgs(-variable)                              \
              -value ${val} -underline $rdArgs(-underline)
        pack ${w}.radio-${i} -side $rdArgs(-side) -fill x               \
              -expand $rdArgs(-expand) -anchor $rdArgs(-anchor) -padx {0 15}

        if {$rdArgs(-command)!= ""} {
            ${w}.radio-${i} configure -command "eval $rdArgs(-command)"
        }
        if {${bal}!= ""} {
            balloon_bind_info ${w}.radio-${i} ${bal}
        }
        incr i
    }
    rename ::$w $w

    return $w
}

################################################################################
# ParseArguements
#    Command to parse the options for the radiolist.
#
# Parameters:
#    w: Path to the radiolist.
#    parameters: The arguments to parse.
################################################################################
proc ParseArguments {w parameters} {
    variable rdArgs

    upvar $parameters args

    set rdArgs(-width)             20
    set rdArgs(-labelwidth)        20
    set rdArgs(-state)             normal
    set rdArgs(-labelunderline)   -1

    set rdArgs(-anchor)            w
    set rdArgs(-text)              ""
    set rdArgs(-textvariable)      radiolist::${w}.textvariable

    set rdArgs(-side)              left
    set rdArgs(-fill)              both
    set rdArgs(-expand)            0

    set rdArgs(-balloons)          ""

    set rdArgs(-labels)            ""
    set rdArgs(-contents)          ""
    set rdArgs(-underline)         -1

    set rdArgs(-command)           ""

    array set rdArgs $args

    return
}

}

namespace eval tools {

################################################################################
# ComboSelectText
#     Select combobox entry that matches a given string.
#
# Parameters:
#    combo: Path to the combobox.
#    value: Value to select if it exists.
#
# Returns
#    The index of the selected entry.
################################################################################
proc ComboSelectText {combo value} {

    set values [$combo cget -values]
    set index  [lsearch -exact $values $value]
    if {$index!=-1} {
        $combo set [lindex $values $index]
    }
    return $index
}

}
