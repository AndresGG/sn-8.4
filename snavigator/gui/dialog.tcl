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

#
# This procedure creates buttons in a frame.
#
# Arguments:
# w -           Frame for buttons.
# pos -         top, bottom ...
# default -     Index of the button to be displayed with the default ring
#               (-1 means none).
# args -        One or more strings to display in buttons across the
#               bottom of the dialog box.
proc sn_ttk_buttons {frm pos default args} {
    global tcl_platform
    if {${frm} == "."} {
        set w ""
    } else {
        set w ${frm}
    }

    ttk::frame ${w}.button
    if {$tcl_platform(platform) == "windows"} {
        pack ${w}.button -side ${pos} -fill both -padx 5 -pady 5
    } else {
        pack ${w}.button -side ${pos} -fill both
    }

    #expand the width of the buttons
    set len 10
    foreach but ${args} {
        set ll [string length ${but}]
        if {${ll} < 14 && ${len} < ${ll}} {
            set len ${ll}
        }
    }

    set i 0
    foreach but ${args} {
        set cmd [list ttk::button ${w}.button_${i}]
        if {[string index ${but} 0] == "@"} {
            lappend cmd -image [string range ${but} 1 end]
        } else {
            lappend cmd -text ${but}
            set len [string length ${but}]
            if {${len} <= 6 && ${len} != 0} {
                lappend cmd -width 7
            }
        }
        if {${i} == ${default}} {
            lappend cmd -default active
        }
        if {[string length ${but}] < ${len}} {
            lappend cmd -width ${len}
        }

        eval ${cmd}
        pack ${w}.button_${i} -in ${w}.button -side left -expand 1 -padx 3\
          -pady 2 -ipadx 1m

        incr i
    }
}

itcl::class sourcenav::Dialog {
    inherit sourcenav::Window

    constructor { args } {}
    destructor {}

    public method activate {}
    public method deactivate { args }

    # Hide the on_close method so that it can't be invoked!
    private method on_close { {cmd ""} }

    itk_option define -modality modality Modality application {
        if {$_active} {
            error "Cannot change -modality while Dialog is active."
        }

	switch $itk_option(-modality) {
	    none -
	    application -
	    global {
	    }
	    
	    default {
		error "bad modality option \"$itk_option(-modality)\":\
			should be none, application, or global"
	    }
	}
    }

    private common grabstack {}

    private variable _result ""
    private variable _active 0
}

itcl::body sourcenav::Dialog::constructor { args } {
    # Maintain a withdrawn state until activated.  
    $this withdraw

    on_close [itcl::code $this deactivate]

    eval itk_initialize $args
}

itcl::body sourcenav::Dialog::destructor { } {
    # If the dialog is currently being displayed,
    # we need to clean it up before we die.
    if {$_active} {
        sn_log "Dialog was active in dtor, calling deactivate"
        $this deactivate
    }
}

# This method is overloaded here just to make sure that
# nobody calls on_close for a Dialog class.

itcl::body sourcenav::Dialog::on_close { {cmd ""} } {
    sourcenav::Window::on_close $cmd
}

itcl::body sourcenav::Dialog::activate { } {
    if {$_active} {
        error "Called activate method when Dialog was already active."
    }
    if {[winfo ismapped $itk_component(hull)]} {
        error "Called activate method when Dialog window was already mapped."
    }
    set _active 1

    $this PushModalStack $itk_component(hull)

    ${this} centerOnScreen
    ${this} deiconify
    ${this} raise
    tkwait visibility $itk_component(hull)

    ${this} focusmodel active

    if {$grabstack != {}} {
        ::grab release [lindex $grabstack end]
    }

    set err 1

    if {$itk_option(-modality) == "application"} {
        while {$err == 1} {
            set err [catch [list ::grab $itk_component(hull)]]
            if {$err == 1} {
                after 1000 "set pause 1"
                vwait pause
            }
        }

        lappend grabstack [list ::grab $itk_component(hull)]
    } elseif {$itk_option(-modality) == "global" }  {
        while {$err == 1} {
            set err [catch [list ::grab -global $itk_component(hull)]]
            if {$err == 1} {
                after 1000 "set pause 1"
                vwait pause
            }
        }
	    
        lappend grabstack [list ::grab -global $itk_component(hull)]
    }

    sn_log "Dialog::activate waiting for _result"
    vwait [itcl::scope _result]
    sn_log "Dialog::activate returning _result = \"$_result\""
    return $_result
}

itcl::body sourcenav::Dialog::deactivate { args } {
    if {!$_active} {
        error "Called deactivate method when Dialog was not active."
    }
    set _active 0

    if {$itk_option(-modality) == "none"} {
        wm withdraw $itk_component(hull)
    } elseif {$itk_option(-modality) == "application"} {
        ::grab release $itk_component(hull)
        if {$grabstack != {}} {
            if {[set grabstack [lreplace $grabstack end end]] != {}} {
                eval [lindex $grabstack end]
            }
	}

        $this PopModalStack
        wm focusmodel $itk_component(hull) passive
        wm withdraw $itk_component(hull)
        
    } elseif {$itk_option(-modality) == "global"} {
        ::grab release $itk_component(hull)
        if {$grabstack != {}} {
            if {[set grabstack [lreplace $grabstack end end]] != {}} {
                eval [lindex $grabstack end]
            }
        }

        wm withdraw $itk_component(hull)
    }

    # Set the result to what the user passed in.
    # This will release the vwait inside activate.
    set _result $args
    return
}

namespace eval TtkDialog {

################################################################################
# Callback
#     Ttk dialogs require a callback to process the pressed button, this is it.
#
# Parameter
#     button: The pressed button.
#
# Side effect
#     Puts in TtkDialog::pressedButton the right value
################################################################################
proc Callback {button} {
    variable pressedButton
    variable buttonList

    if {$buttonList==""} {
        set pressedButton $button
    } else {
        set pressedButton [lsearch $buttonList $button]
    }

    return
}

################################################################################
# MessageBox
#     Invokes the ttk::dialog proc in Unix, and Tk's one in Mac and Win.
#     It tries to be an "almost" drop-in replacement for tk_messageBox.
#
# Parameters
#     args: The pameters to pass to the real dialog command.
#
# Returns:
#     The pressed button.
################################################################################
proc MessageBox {args} {
    variable pressedButton
    variable buttonList

    if {[tk windowingsystem] ne "x11"} {
        return [eval tk_messageBox [lrange $args 1 end]]
    }
    set path [lindex $args 0]
    if {[regsub {\.\.} $path {.} path]} {
        lappend args "-parent {}"
    }

    set buttonList ""
    eval ttk::dialog $path [lrange $args 1 end]   \
            -command TtkDialog::Callback

    CenterDialog $path

    grab $path
    tkwait variable TtkDialog::pressedButton
    grab release $path

    return $pressedButton
}

################################################################################
# ttk_dialog
#
# This procedure displays a dialog box, waits for a button in the dialog
# to be invoked, then returns the index of the selected button.
#
# Parameters:
# w -           Window to use for dialog top-level.
# title -       Title to display in dialog's decorative frame.
# text -        Message to display in dialog.
# icon -        Icon to display in dialog (empty string means none).
# default -     Symbolic name of the button that is to display the default ring
#               ("" means none).
# cancel -      Symbolic name of the button to be invoked when the user 
#               hits the Esc key
# buttons -     Symbolic names for the buttons.
# labels -      One or more strings to display in buttons across the
#               bottom of the dialog box.
################################################################################
proc ttk_dialog {w title text icon default cancel buttons labels} {
    global tkeWinNumber
    variable buttonList
    variable pressedButton

    if {[sn_batch_mode]} {
        if {${title} != ""} {
            set msg "${title}: ${text}"
        } else {
            set msg ${text}
        }
        puts stderr "WARNING: ${msg} <[lindex ${args} 0]>"
        return 0
    }

    if {${w} == "auto"} {
        incr tkeWinNumber
        set w ".info-${tkeWinNumber}"
    }
    set buttonList $buttons

    set mix ""
    foreach name $buttons string $labels {
        lappend mix $name $string
    }
    ttk::dialog $w -title $title -message $text -icon $icon              \
            -default $default -cancel $cancel                            \
            -buttons $buttons -labels $mix                               \
            -command TtkDialog::Callback -parent ""

    if {![winfo viewable $w]} {
        tkwait visibility $w
    }

    if {[regexp {^(\.)([^\.]*)$} $w]} {
        CenterDialog $w
    }

    grab $w
    tkwait variable TtkDialog::pressedButton
    grab release $w

    return $pressedButton
}

################################################################################
# ttk_dialog_with_widgets:
#
# This procedure displays a dialog box, with some extra widgets, waits for
# a button in the dialog to be invoked, then returns the index of the
# selected button.
#
# Arguments:
# w             -       Window to use for dialog top-level.
# title         -       Title to display in dialog's decorative.
# text          -       Message to display in dialog.
# icon          -       Bitmap to display in dialog (empty string means none).
# default       -       Name of the button that is to display the default ring
#                       ("" means none).
# cancel        -       Name of the button whose index will be returned if the
#               -       user hits the Esc key.
# createWidgetsCmd -    Command to be called, to create new addional widgets or
#                       to manipulate existing behavior.
# buttons       -       Symbolic names for the buttons.
# labels        -       One or more strings to display in buttons across the
#                       bottom of the dialog box.
################################################################################
proc ttk_dialog_with_widgets {w title text icon default cancel createWidgetsCmd buttons labels} {
    variable buttonList
    variable pressedButton

    set buttonList $buttons

    set mix ""
    foreach name $buttons string $labels {
        lappend mix $name $string
    }

    ttk::dialog $w -title $title -message $text -icon $icon  -parent ""       \
            -default $default -cancel $cancel  -buttons $buttons -labels $mix \
            -command TtkDialog::Callback

    set widgetFrame [ttk::dialog::clientframe $w]

    eval $createWidgetsCmd $widgetFrame

    if {![winfo viewable $w]} {
      tkwait visibility $w
    }

    CenterDialog $w

    grab $w
    tkwait variable TtkDialog::pressedButton
    grab release $w

    return $pressedButton
}

#################################################################################
# CenterDialog
#    Centers the given toplevel in the screen.
#
# Parameter
#    top: Toplevel to center.
#################################################################################
proc CenterDialog {top} {

    wm withdraw $top
    update idletasks

    set width  [winfo reqwidth  $top]
    set height [winfo reqheight $top]

    set screenWidth  [winfo screenwidth  .]
    set screenHeight [winfo screenheight .]

    set x [expr ($screenWidth  / 2) - ($width /2)]
    set y [expr ($screenHeight / 2) - ($height /2)]

    wm deiconify $top
    wm geometry $top +$x+$y
    update idletasks

    return
}

}



