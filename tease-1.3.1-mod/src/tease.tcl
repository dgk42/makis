#!/bin/sh
# the next line restarts using wish \
exec wish "$0" "$@"

#
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


proc PUT {args} {
   eval puts \"$args\"
}
proc OUT {w args} {
   eval $w.o.txt insert end \"$args\"
   $w.o.txt insert end "\n"
}
proc MSG {args} {
   eval tk_messageBox -message \"$args\"
}


proc Initialize {} {
  # global var
   global mode

  # mode can also be cli, search...?
   set mode(run)     gui



  # viewmode: single-list, single-tabs, joint, separate
   set mode(view) single

  # set mode(view) separate
}


#-------------------------------------------------------------------------------
# REPROCESSARGV:  algorithm for digesting ARGV
#
#    -create an empty "left" list and set all argv into "right" list.
#    -LOOP: examine whole list to see if it's a file.  If so, push onto files
#       list.  if left is empty (it should be), exit loop.
#    -break off leftmost (0th) item, push it onto left list and try the right
#       side again.
#    -repeat above until right side is an existing file, then push onto files
#       list.  set right list to left list then set left to empty, and resume
#       at LOOP.
#    -after loop is complete, left side may have remaining file.  If file
#       exists, add it to the files list.
#-------------------------------------------------------------------------------
proc ReprocessArgv {args} {
   set files {}
   set tmp ""
   set right $args
   set left  {}

   while {[llength $right] > 0} {

     # first, evaluate the whole list.  Need to go through a few odds
     # and ends with the string in question first, though...
      set rightfile "$right"

     # try to offset list evaluation irregularities in "send to"
     # ugly-ass hack, but it works.
      if {[llength $rightfile] == 1} {
         eval set rightfile "$rightfile"
      }

     # okay, now it will evaluate correctly via regular context-menu
     # actions OR through "send to".
      if {[file exists "$rightfile"]} {
          lappend files $rightfile
          set right $left
          set left {}

         # if "right" list is now empty, then nothing left
         # to process and we can bail out here
          if {[llength $right] < 1} {break}
      }

     # whole shmeal isn't a file, so break off the leftmost piece and
     # push it onto the "left" list
      set seg   [lindex $right 0]
      set right [lreplace $right 0 0]
      lappend left $seg
   }

  # if we were opening multiple files on send to or cmd line,
  # there might be (should be) something left in "left"
  # so try to open and include it...
   if {[llength $left] > 0} {
      set leftfile "$left"
      if {[llength $leftfile] == 1} {
         eval set leftfile "$leftfile"
      }
      if {[file exists "$leftfile"]} {
          lappend files $leftfile
      }
   }
   return $files
}


proc Main {args} {
   global argv0
   global mode
   global rootdir
   global tcl_platform

   wm withdraw .
   wm geometry . 195x80+0+0

   Initialize
  # if mode is not gui, call respective modes...
  # switch statement here eventually
   if {$mode(run) == "cli"}    { return }
   if {$mode(run) == "search"} { return }

  # set package GUI routines

   set rootdir /dev/tease
   if {$tcl_platform(platform) == "unix"} {
      set rootdir . 
   }

   source $rootdir/seg-teasegui.txt
   teasegui::InitTeaseGUI $mode(view)

  # if mode is separate, don't go through all the calisthenics below,
  # just call argv0 on args.  :)
#set teasegui::var(mode) separate
   if {$teasegui::var(mode) == "separate"} {
      if {[llength $args] < 1} {
         teasegui::OpenFile
      } elseif {[llength $args] == 1} {
         foreach arg $args {eval teasegui::OpenFile $arg}
      } else {
         foreach arg $args {
            set argvstr ""
            foreach a [string map {\\ /} $argv0] {append argvstr $a}
            eval exec $argvstr $arg &
         }
         exit
      }
      return
   }

  # if single mode, we don't want the server to start
   set serverfound 0
   if {$teasegui::var(mode) == "single"} {
      set serverfound [teasegui::TeaseServerAlreadyRunning]
   }

   if {$serverfound} {
      if {[llength $args] < 1} {
         winsend send tease131 [list teasegui::OpenFile]
      } else {
         foreach arg $args {
            winsend send tease131 [list eval teasegui::OpenFile $arg]
         }
      }
      exit
   } else {
      if {[llength $args] < 1} {
         teasegui::OpenFile
      } else {
         foreach arg $args {eval teasegui::OpenFile $arg}
      }
   }
}


# do not show console if we're in freewrap namespace...
if {[namespace exists ::freewrap]} {console hide}

# context menu action on multiple docs sends separate commands
set args1 {}
foreach a [string map {\\ /} $argv] {
   lappend args1 $a
}

# evaluate file existance to determine new args
set newargs [eval ReprocessArgv $args1]

eval Main $newargs


# end
