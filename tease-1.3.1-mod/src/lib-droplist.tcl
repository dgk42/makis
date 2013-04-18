# TEASE : text editing and scripting environment
#    version 1.3.1
#    by chess hazlett
#    http://tease.sourceforge.net
# copyright (C) 2003-2005, Chess Hazlett
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA
# 02110-1301, USA.
#--------------------------------------------------------------------


#
#  NOTE: this is far from complete.  But it's working.
#
#

namespace eval droplist {

   namespace export droplist Get Clear Set SetDefaultBinding Configure ClearBindings
   variable var

   proc ProcessArgs {path args} {
      variable var
      for {set i 0} {$i < [llength $args]} {incr i 2} {
         set att [lindex $args $i]
         set val [lindex $args [expr $i + 1]]
         switch -- $att {
            default {set var(${path},${att}) "$val"}
         }
      }
   }

   proc SetDefaultValues {path} {
      variable var
     # set var(${path},-bg) "#ffffff"
      set var(${path},-framebd) 1
      set var(${path},-framerelief) sunken
      set var(${path},-entrybd) 0
      set var(${path},-buttonbd) 2
      set var(${path},-buttonrelief) raised
      set var(${path},-width) 25
      set var(${path},-img) DROPLIST:DOWNARROW
     # set var(${path},-selectbg) "#ccffee"
      set var(${path},-listvariable) ""
      set var(${path},-textvariable) ""
      set var(${path},-selectcommand) ""
      set var(${path},-keycommand) ""
   }


   proc droplist {path args} {
      variable var

     # set defaults
      eval SetDefaultValues $path

     # set specific selections
      eval ProcessArgs $path $args

      upvar #0 $var(${path},-listvariable) glist
      upvar #0 $var(${path},-textvariable) txtvar

      frame $path -bd $var(${path},-framebd) -relief $var(${path},-framerelief)

      pack [
         entry $path.e                 \
            -textvariable txtvar       \
            -bd $var(${path},-entrybd) \
            -width $var(${path},-width)
     ] -side left -fill x -expand 1


     # button is currently hardcoded to takefocus 0,
     # however, it should be an option
      pack [
         button $path.dn -takefocus 0 \
            -image $var(${path},-img) \
            -bd $var(${path},-buttonbd) \
            -relief $var(${path},-buttonrelief) \
            -command "droplist::DroplistShow $path.drop $path.e"
      ] -side right -ipady 2 -ipadx 2 -fill y
   


      toplevel $path.drop
      wm withdraw $path.drop
      wm overrideredirect $path.drop 1
   
      pack [
         scrollbar $path.drop.vsb -command "$path.drop.lb yview" -bd 1
      ] -side right -fill y
   
      pack [
         listbox $path.drop.lb \
            -bd 1         \
            -width 1      \
            -listvariable $glist \
            -highlightthickness 0 \
            -yscrollcommand "$path.drop.vsb set"
      ] -side left -fill both -expand 1

   
      bind [winfo toplevel $path] <Button>    "+ wm withdraw $path.drop"
      bind [winfo toplevel $path] <Configure> "+ wm withdraw $path.drop"
      bind $path.e <Key> "+after 0 ::droplist::TextBinding %K $path.e"

      return $path
   }

   proc TextBinding {key tgt} {
      variable var

      set path [winfo parent $tgt]

      if {($key == "Left") || ($key == "Right")} {return}

      if {$var(${path},-keycommand) != ""} {
         eval $var(${path},-keycommand)
      }

     # if {($key == "Left") || ($key == "Right")} {return}
      after 0 ::droplist::CompleteText $key $tgt
   }

   proc Configure {path option {script {}}} {
      variable var
      set var(${path},$option) $script
   }


   proc SetDefaultBinding {path} {
      bind $path.e <Key> "+after 0 ::droplist::CompleteText %K $path.e"
   }

   proc ClearBindings {path} {
      bind $path.e <Key> ""
   }


   proc Clear {path} {
      $path.e delete 0 end
   }


   proc Get {path} {
      set str ""
      set str [$path.e get]
      return $str
   }


   proc Set {path {txt ""}} {
      $path.e delete 0 end
      $path.e insert 0 $txt
   }


   proc EncodeImages { } {
      image create photo DROPLIST:DOWNARROW -data {
         R0lGODlhBQADAPcAAAAAANTQyAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
         AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
         AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
         AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
         AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
         AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
         AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
         AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
         AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
         AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
         AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
         AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
         AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
         AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
         AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
         AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
         AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
         AAAAAAAAAAAAAAAAAAAAACH5BAEAAAEALAAAAAAFAAMAAAgNAAEIFBhgYICD
         AA4GBAA7
      }
   }


   proc CompleteText {key tgt} {
      variable var
      if {! [regexp {^([A-Za-z0-9_]|space|period|Up|Down|Next|Prior){1}$} $key]} {return}

      set path [winfo parent $tgt]
      upvar #0 $var(${path},-listvariable) lvar
      set ipoint [$tgt index insert]
   
     # funky problem with contents containing spaces...
      $tgt selection clear
      set typed [$tgt get]
      set s [lsearch -regexp $lvar ^${typed}.*]
   
     # handle listup/down
      if {($key == "Up") || ($key == "Down") || ($key == "Next") || ($key == "Prior")} {
         if {$s < 0} {set s 0}
         if {$key == "Up"} {incr s -1}
         if {$key == "Down"} {incr s 1}
         if {$key == "Next"} {incr s 10}
         if {$key == "Prior"} {incr s -10}
         if {$s < 0} {set s [expr [llength $lvar] - 1]}
         if {$s >= [llength $lvar]} {set s 0}
         $tgt delete 0 end
         $tgt insert end [lindex $lvar $s]
         $tgt selection from end
         $tgt selection adjust end

         EvalSelectCommand $path

         return
      }
   
$tgt icursor $ipoint
     # don't continue if no match in list
      if {$s < 0} {return}
      set full [lindex $lvar $s]

     # bail out if everything's equal
      if {[string equal "$full" "$typed"]} {return}
   
      set comp [string range $full [string length $typed] end]
      $tgt selection from end
      $tgt insert end $comp
      $tgt selection adjust end
$tgt icursor $ipoint
   }


   proc DroplistShow {base tgt} {
   
      variable var
      set tmp [$tgt get]
   

      $base.lb delete 0 end
      set path [winfo parent $base]

      upvar #0 $var(${path},-listvariable) lvar

      foreach x $lvar {
         $base.lb insert end $x
         if {$tmp == $x} {
            $base.lb activate end
            $base.lb selection clear 0 end
            $base.lb selection set end
            $base.lb see end
         }
      }

     # we don't need listbox to be size 10 all the time
      set lbsize [$base.lb size]
      if {$lbsize < 10} {
         $base.lb configure -height $lbsize
         pack forget $base.vsb
      } else {
         $base.lb configure -height 10
         pack $base.vsb -side right -fill y
      }
   
     # re-bind droplist
      bind $base.lb <ButtonRelease-1>   "::droplist::DropListSelection $tgt %W %y mouse"
      bind $base.lb <Key-Return> "::droplist::DropListSelection $tgt %W %y key"
      bind $base.lb <space>      "::droplist::DropListSelection $tgt %W %y key"
      bind $base.lb <Key-Escape> "focus $tgt; wm withdraw $base"
      
      bind [winfo toplevel $tgt] <Button> "wm withdraw $base"
   
     # set geometry of list
      set x [expr [winfo rootx $tgt] - 1]
      set y [expr [winfo rooty $tgt] + [winfo height $tgt]]
      set w [winfo width [winfo parent $tgt]]
      set h [winfo reqheight $base.lb]
   
      wm geometry $base =${w}x${h}+${x}+${y}
   
      wm deiconify $base
      raise $base
      focus $base.lb
   
    # # make dropdown go from green to white when dropped
    #  set var(timedelay) 0
    #  foreach s [list 00 11 22 33 44 55 66 77 88 99 00 aa bb cc dd ee ff] {
    #     incr var(timedelay) 10
    #     after $var(timedelay) "$base.lb configure -bg \"#${s}ff${s}\""
    #  }
   }
   
   proc EvalSelectCommand {path} {
      variable var
      if {$var(${path},-selectcommand) != ""} {
         eval $var(${path},-selectcommand)
      }
   }

   proc DropListSelection {tgt w y type} {
   
     # unmap the droplist window after any event
      wm withdraw [winfo toplevel $w]
   
     # if mouse event, get y value; if key, get 'active' index
      if {$type == "mouse"} {
         set tmp1 [$w nearest $y]
         set tmp2 [$w get $tmp1]
      } else {
         set tmp1 [$w index active]
         set tmp2 [$w get $tmp1]
      }
   
     # replace entry widget contents
      $tgt delete 0 end
      $tgt insert end $tmp2

      set path [winfo parent $tgt]
      EvalSelectCommand $path

      focus $tgt
   }

   EncodeImages

}

