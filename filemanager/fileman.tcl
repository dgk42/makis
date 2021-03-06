#!/usr/local/bin/wish4.0 -f
proc doButtons {w args} {
    global oldTK

    set ncol 7
    if ![string match {} $args] {
	frame $w.bot.fr -relief groove -border 4
	pack $w.bot.fr -side left -expand 1 -fill x -padx 5 -pady 5
	focus $w
	set numargs [expr [llength $args]/2]
	for {set i 0} {$i < [expr [llength $args]/2]} {incr i} {
	    set j [expr $i/$ncol]
	    set k [expr $i - $ncol*$j]
	    if !$k {
		frame $w.bot.fr.$j -relief flat
		pack $w.bot.fr.$j -side top -expand 1 -fill x -padx 2 -pady 2
	    }
	    set F_cmd [lindex $args [expr 2*$i + 1]]
	    button $w.bot.fr.$j.$k -text [lindex $args [expr 2*$i]] \
	      -command "$F_cmd" -bg MistyRose -padx 1 -pady 1
	    if {$oldTK} {
		pack $w.bot.fr.$j.$k -side left -expand 1 -fill x \
			-padx 5 -pady 5
	    } else {
		pack $w.bot.fr.$j.$k -side left -expand 1 -fill x \
			-padx 1 -pady 1
	    }
	}
    }
}

proc mkEntryBox {w width ewidth title msgText entries args} {
    if {[info commands $w] != ""} {
	wm deiconify $w
	raise $w
	return
    }
    toplevel $w
    wm title $w "$title"

    frame $w.top -relief raised
    frame $w.bot -relief raised
    pack $w.top -fill both -expand 1
    pack $w.bot -fill x
    label $w.top.message -text $msgText \
	-relief raised -bd 2 -background PowderBlue
    pack $w.top.message -expand 1 -fill both -padx 2m -pady 2m

    set vb 0
    foreach entry $entries {
	if {[lindex $entry 0] != {}} {
	   labelEntry $w.top.v${vb} \
		"-anchor w -width $width -text [lindex $entry 0]" \
		"[lindex $entry 1]" $ewidth "" {}
	   pack $w.top.v${vb} -fill x -padx 5 -pady 5
	   bind $w.top.v${vb}.entry <Return> {set dummy 0}
	   incr vb
	}
    }
    if {$vb == 1} {
	bind $w.top.v0.entry <Return> "$w.bot.fr.0.0 invoke"
    }
    eval doButtons $w $args
    focus $w
}
#
#
# entry dedicated stuff
#
#
proc emacsInsertSelect {ent} {
    if {![catch {selection get} bf] && \
      ![string match ""  $bf]} {
	$ent insert insert $bf
	tk_entrySeeCaret $ent
	focus $ent
    }
}

proc emacsEntry {args} {
    global oldTK

    set name [eval entry $args]
    if {!$oldTK} {return $name}

    bind $name <Control-a> { %W icursor 0 }
    bind $name <Control-b> {
	%W icursor [expr {[%W index insert] - 1}]
    }
    bind $name <Left> {
	%W icursor [expr {[%W index insert] - 1}]
	%W view [%W index insert]
    }
    bind $name <Control-d> { %W delete insert }
    bind $name <Control-e> { %W icursor end }
    bind $name <Control-f> {
	%W icursor [expr {[%W index insert] + 1}]
    }
    bind $name <Right> {
	%W icursor [expr {[%W index insert] + 1}]
	%W view [%W index insert]
    }
    bind $name <Control-k> { %W delete insert end }
    bind $name <Control-u> { %W delete 0 end }
    bind $name <ButtonPress-2> {emacsInsertSelect %W}
    bind $name <Delete> \
      {tk_entryBackspace %W; tk_entrySeeCaret %W}
    bind $name <BackSpace> \
      {tk_entryBackspace %W; tk_entrySeeCaret %W}
    bind $name <Control-h> \
      {tk_entryBackspace %W; tk_entrySeeCaret %W}
    bind $name <Meta-b> \
      { %W insert insert \002 ;tk_entrySeeCaret %W }
    bind $name <Meta-o> \
      { %W insert insert \017 ;tk_entrySeeCaret %W }
    bind $name <Meta-u> \
      { %W insert insert \037 ; tk_entrySeeCaret %W }
    bind $name <Meta-v> \
      { %W insert insert \026 ; tk_entrySeeCaret %W }
    return $name
}

proc entrySet {win val} { ${win} delete 0 end ; ${win} insert end $val }

#
#
# Composed objects
#
#
proc labelEntry {name opts textvar width init code} {
#
#	name	frame name
#	opts	label options
#	textvar	textvariable on entry, may be supplied as {}
#	init	init value of entry
#	code	code for bind <return> on entry
#
    frame $name
    eval label $name.label $opts
    if [string match {} $textvar] {
	emacsEntry $name.entry -relief sunken \
	-bd 3 -bg BlanchedAlmond -width $width
    } else {
	emacsEntry $name.entry -textvariable $textvar -relief sunken \
	-bd 3 -bg BlanchedAlmond -width $width
    }
    if {![string match {} $init]} {
	$name.entry insert end $init
    }
    pack $name.label -side left
    pack $name.entry -side left -expand 1 -fill x
    bind $name.entry <Return> "$code"
}
#
proc makeLB {win args} {
    frame $win -relief raised
    frame $win.f -borderwidth 0
    scrollbar $win.v -command "$win.l yview"
    eval listbox $win.l -xscrollcommand "{$win.h set}" \
      -yscrollcommand "{$win.v set}" $args
    pack $win.l -side left -expand 1 -fill both -in $win.f -padx 2m
    pack $win.v -side left -fill y -in $win.f

    frame $win.g -borderwidth 0
    scrollbar $win.h -command "$win.l xview" -orient horizontal

    frame $win.g.p
    pack $win.h -side left -expand 1 -fill x -in $win.g -padx 2m
    pack $win.g.p -side right -padx 5
    pack $win.g -fill x -side bottom
    pack $win.f -expand 1 -fill both -side top
    return $win
}

proc BrowseFile {filename} {
    global BrowseExt BrowseCmd

    if {$BrowseExt} {
	set stat "[catch {exec $BrowseCmd file $filename &} msg]"
	if {$stat} {
	    dialog .d {Alert} $msg warning -1 OK
	}
    } else {
	Browse file $filename
    }
}

proc BrowseCmd {command} {
    global BrowseExt BrowseCmd

    if {$BrowseExt} {
	set stat "[catch {exec $BrowseCmd command $command &} msg]"
	if {$stat} {
	    dialog .d {Alert} $msg warning -1 OK
	}
    } else {
	Browse command $command
    }
}

proc Browse {mode argum} {
	global filenum fonts browsefont TextTypes

	incr filenum
	set BQFcol MistyRose
	if {$mode == "command"} {
	    set stat "[catch {set f [eval open \"|$argum\" r]} msg]"
	} else {
	    if [file isdirectory $argum] {
		dialog .msg Alert {Can not view a Directory}  warning -1 OK
		return
	    }
	    set stat "[catch {set f [open $argum]} msg]"
	}
	if $stat {
	    catch {close $f}
	    dialog .msg Alert $msg warning -1 OK
	    return
	}
	set w .f$filenum
	toplevel $w
	wm title $w $argum
	frame $w.mbar -relief raised -bd 3
	pack $w.mbar -side top -fill x
	menubutton $w.mbar.fonts -text "Fonts" -menu $w.mbar.fonts.menu
	menubutton $w.mbar.colors -text "Colors" -menu $w.mbar.colors.menu
	pack $w.mbar.fonts $w.mbar.colors -side left -padx 2m
	menu $w.mbar.fonts.menu
	foreach font $fonts {
	    $w.mbar.fonts.menu add radiobutton -label "[lindex $font 0]" \
		-command "ChangeFont $w.fr.text [lindex $font 1]" \
		-variable browsefont -value "[lindex $font 1]"
	}
	menu $w.mbar.colors.menu
	set dumTypes {foreground background}
	eval lappend dumTypes $TextTypes
	foreach TextType $dumTypes {
	    $w.mbar.colors.menu add command -label $TextType \
		-command "ListColor $w.fr.text $TextType"
	}
	MakeST $w 80 30
	ChangeFont $w.fr.text $browsefont
	SetupTags $w.fr.text
	frame $w.butfr -bd 4 -relief groove
	pack $w.butfr -side bottom -padx 2m -pady 2m
	button $w.butfr.but -text Close -bd 3 -bg $BQFcol \
		-command "destroy $w"
	pack $w.butfr.but -side left -padx 2m -pady 2m
	button $w.butfr.search -text Search -bd 3 -bg $BQFcol \
		-command "DoSel $w.fr.text \$search"
	pack $w.butfr.search -side left -padx 2m -pady 2m
	emacsEntry $w.butfr.term -width 20 -relief sunken -bd 2 \
		-textvariable search -bg peachpuff
	bind $w.butfr.term <Return> "DoSel $w.fr.text \$search"
	pack $w.butfr.term -side left -padx 2m -pady 2m
	ResizeST $w
	$w.fr.text configure -cursor {watch red white}
	update

	while {[gets $f line] >= 0} {
		DoLine $w.fr.text $line
	}
	close $f
	$w.fr.text configure -cursor {top_left_arrow red white}
	$w.fr.text configure -state disabled
}

proc DoSel {w term} {

	if {$term == ""} {return}
	$w tag remove Search 1.0 end 
	forAllMatches $w $term "$w tag add Search first last" 
	gotoFirstMatch $w $term
}

proc DoLine {Text line} {
   global TextTypes oldTK

   if {$line == ""} {
	$Text insert end "\n"
	return
   }
   if {$oldTK} {
	set endind end
   } else {
	set endind "end -1 chars"
   }
   regsub -all "\017" $line {} line
   regsub -all "\033\\\[\[0-7\]?m" $line {} dummy
   $Text insert end $dummy
   set lastl [lindex [split [$Text index $endind] .] 0]
   $Text insert end "\n"
   while {[regexp -indices "\033\\\[(\[1-7\])m(\[^\033\]*)\033\\\[0?m" $line dummy typeid matchid]} {
	set type [string index $line [lindex $typeid 0]]
	switch $type {
		1	{set TextType bold}	
		4	{set TextType underline}	
		5	{set TextType blink}	
		7	{set TextType reverse}	
		default	{set TextType default}
	}
	if {$TextType != "default"} {
	    eval set match \[string range \$line $matchid\]
	    set ind1 [lindex $dummy 0]
	    set line "[string range $line 0 [expr $ind1 - 1]]$match[string range $line [expr [lindex $dummy 1] + 1] end]"
	    set ind2 [expr $ind1 + [string length $match]]
	    $Text mark set first $lastl.$ind1
	    $Text mark set last $lastl.$ind2
	    $Text tag add $TextType first last
	}
   }
}

proc ChangeFont {w font} {
    global TextTypes
    eval global $TextTypes

    $w configure -font $font
    foreach TextType $TextTypes {
	if {$TextType == "bold" && [regexp {[0-9]x[0-9]} $font]} {
	    $w tag configure $TextType -font "${font}bold"
	} else {
	    $w tag configure $TextType -font $font
	}
    }
}

proc SetupTags {Text} {
   global TextTypes Tags
   eval global $TextTypes

   foreach TextType $TextTypes {
	eval $Text tag configure $TextType $Tags($TextType)
   }
}

proc InitTags {} {
   global TextTypes Tags TextBGColor TextFGColor

   set TextTypes {bold underline blink reverse Search}
   eval global $TextTypes

   set Tags(bold) "-foreground \$bold"
   set Tags(underline) "-foreground \$underline -underline 1"
   set Tags(blink) "-foreground \$blink"
   set Tags(reverse) "-foreground \$reverse"
   set Tags(Search) \
    "-background \$Search -borderwidth 2 -relief flat -font -Adobe-Helvetica-Medium-R-Normal--*-120-*"
}

proc ListColor {win ColType} {
   global X11PATH oldTK

   set w .color
   if {[info commands $w] == ""} {
	if {![file readable $X11PATH/rgb.txt]} {
	    dialog .msg Alert {Couldn't locate the Color Database} error -1 OK
	    return
	}
	toplevel $w
	wm title $w "Color Select"
	message $w.msg -text "Select $ColType Color" -aspect 800 \
		-relief raised -bg PowderBlue
	pack $w.msg -side top -expand 1 -fill both
	makeLB $w.colors -relief sunken
	pack $w.colors -expand 1 -fill both
	if {$oldTK} {tk_listboxSingleSelect $w.colors.l}

	set Colors {}
	set f [open $X11PATH/rgb.txt]
	while {[gets $f line] >= 0} {
	    if {[llength $line] == 4} {
		lappend Colors "[lrange $line 3 end]"
	    }
	}
	close $f
	set Colors [lsort $Colors]
	foreach color $Colors {
	    $w.colors.l insert end $color
	}
	button $w.but -text Cancel -command "destroy $w" -bg MistyRose
	pack $w.but -side top -expand 1 -fill x -padx 5 -pady 5
   } else {
	wm deiconify $w
	raise $w
   }
   $w.msg configure -text "Select $ColType Color"
   if {$ColType == "background"} {
	bind $w.colors.l <Double-Button-1> \
	"set TextBGColor \"\[selection get\]\";$win configure -bg \$TextBGColor"
   } elseif {$ColType == "foreground"} {
	bind $w.colors.l <Double-Button-1> \
	"set TextFGColor \"\[selection get\]\";$win configure -fg \$TextFGColor"
   } elseif {$ColType == "Search"} {
	bind $w.colors.l <Double-Button-1> \
	"set $ColType \"\[selection get\]\"; \
	$win tag configure $ColType -background \$$ColType"
   } else {
	bind $w.colors.l <Double-Button-1> \
	"set $ColType \"\[selection get\]\"; \
	$win tag configure $ColType -foreground \$$ColType"
   }
}
#
# Make Scrolled Text
#
proc MakeST {w width height} {
	global TextBGColor TextFGColor 
	frame $w.fr
	pack $w.fr -side top -padx 2m -pady 2m \
		-expand 1 -fill both
	text $w.fr.text -relief sunken -bd 3 -fg $TextFGColor -bg $TextBGColor \
		-yscrollcommand "$w.fr.scroll set" \
		-cursor {top_left_arrow red white} \
		-width $width -height $height
	scrollbar $w.fr.scroll -command "$w.fr.text yview"
	pack $w.fr.scroll -side right -fill y
	pack $w.fr.text -side left -expand 1 -fill both
	$w.fr.text delete 1.0 end
}
#
# Enable Resizing of Text
#
proc ResizeST {w} {
	update idletasks
        $w.fr.text configure -setgrid 1
	wm minsize $w [lindex [wm grid $w] 0] \
		[lindex [wm grid $w] 1]
}

#
proc dialog {w title text bitmap default args} {
    global button

    # 1. Create the top-level window and divide it into top
    # and bottom parts.

    toplevel $w -class Dialog
    wm title $w $title
    wm iconname $w Dialog
    frame $w.top -relief raised -bd 1
    pack $w.top -side top -fill both
    frame $w.bot -relief raised -bd 1
    pack $w.bot -side bottom -fill both

    # 2. Fill the top part with bitmap and message.

    if {[string length $text] > 300} {
	set text "[string range $text 0 300]"
    }
    message $w.top.msg -width 3i -text $text -relief raised \
	    -font -Adobe-Helvetica-Bold-R-Normal--*-120-* -bg peachpuff
    pack $w.top.msg -side right -expand 1 -fill both -padx 3m -pady 3m
    if {$bitmap != ""} {
	label $w.top.bitmap -bitmap $bitmap
	pack $w.top.bitmap -side left -padx 3m -pady 3m
    }

    # 3. Create a row of buttons at the bottom of the dialog.

    set i 0
    foreach but $args {
	button $w.bot.button$i -text $but -bg MistyRose -command "set button $i"
	if {$i == $default} {
	    frame $w.bot.default -relief sunken -bd 1
	    raise $w.bot.button$i
	    pack $w.bot.default -side left -expand 1 -padx 3m -pady 2m
	    pack $w.bot.button$i -in $w.bot.default -side left \
			-padx 2m -pady 2m -ipadx 2m -ipady 1m
	} else {
	    pack $w.bot.button$i -side left -expand 1 \
		    -padx 3m -pady 3m -ipadx 2m -ipady 1m
	}
	incr i
    }

    # 4. Set up a binding for <Return>, if there's a default,
    # set a grab, and claim the focus too.

    if {$default >= 0} {
	bind $w <Return> $w.bot.button$default flash; \
		set button $default
    }

    set oldFocus [focus]
    tkwait visibility $w
    grab set $w
    focus $w

    # 5. Wait for the user to respond, then restore the focus and
    # return the index of the selected button.

    tkwait variable button
    destroy $w
    focus $oldFocus
    return $button
}

#
# text scan dedicated routines
#

proc forAllMatches {w pattern script} {
	scan [$w index end] %d numLines
	for {set i 1} {$i < $numLines} {incr i} {
		$w mark set last $i.0
		while {[regexp -nocase -indices $pattern \
			[$w get last "last lineend"] indices]} {
			$w mark set first \
				"last + [lindex $indices 0] chars"
			$w mark set last "last + 1 chars \
				+ [lindex $indices 1] chars"
			uplevel $script
		}
	}
}

proc gotoFirstMatch {w pattern} {

	scan [$w index end] %d numLines
	for {set i 1} {$i < $numLines} {incr i} {
		$w mark set last $i.0
		if {[regexp -nocase -indices $pattern \
			[$w get last "last lineend"] indices]} {
			if {$i > 0} {
			    $w yview -pickplace [expr $i -1]
			} else {
			    $w yview -pickplace 0
			}
			break
		}
	}
}

#
# File selector dedicated
#
#
proc setFilter {win} {
   global FBFilter

   set w [winfo toplevel $win]
   set FBFilter [$win get]
   DoDirectory $w.mid.flist.l . 1
}
#
proc setFile {w y} {
    global FileExt

    set x [$w nearest $y]
    set fn [lindex [$w get $x] 0]
    if [file isdirectory $fn] {
	DoDirectory $w $fn 1
    } else {
	set extens [file extension $fn]
	if {$extens != ""} {
	    if {[info exists FileExt($extens)]} {
		DoAction "$FileExt($extens)"
	    } else {
		DoAction "$FileExt(Default)"
	    }
	} else {
	    if [file readable $fn] {
		if {$FileExt(NoExtension) != "" && \
		    $FileExt(NoExtension) != "none"} {
		    DoAction "$FileExt(NoExtension)"
		}
	    }
	}
    }
}
#
proc DoDirectory {w fn DoUpdate} {
    global RegexpStyle SortStyle ListStyle DotFiles

    if [file isdirectory $fn] {
	global FBFilter
	set win [winfo toplevel $w]
	set pos [$win.mid.flist.l nearest 1]
	set filter $FBFilter
	if $RegexpStyle {
	    regsub -all -- {\.} $filter {\.} filter
	    regsub -all -- {^} $filter {^} filter
	    regsub -all -- {\?} $filter {.} filter
	    regsub -all -- {\*} $filter {.*} filter
	    regsub -all -- {$} $filter {$} filter
	}
	$win configure -cursor {watch red white}
	if $DoUpdate {update}
	cd $fn
	entrySet $win.mid.fr.dir.entry [pwd]
	$win.mid.flist.l delete 0 end
	$win.mid.flist.l insert end ../
	if {$DotFiles} {
	    set FileExpr ".* *"
	} else {
	    set FileExpr "*"
	}
	if ![catch {set fls [eval glob $FileExpr]}] {
	    set dirs {}
	    set files {}
	    foreach fl [eval lsort $SortStyle \$fls] {
		if {$fl == "." || $fl == ".."} { continue }
		if {[regexp -- $filter $fl] || $fl == ".."} {
		} else { continue }
		if [file isdirectory $fl] { 
		    append fl / 
		    lappend dirs $fl
		} else {
		    lappend files $fl
		}
	    }
	    foreach dir $dirs {
		if {$ListStyle} {
		    $win.mid.flist.l insert end $dir
		} else {
		    $win.mid.flist.l insert end [PermAndSize $dir]
		}
	    }
	    foreach fl $files {
		if {$ListStyle} {
		    $win.mid.flist.l insert end $fl
		} else {
		    $win.mid.flist.l insert end [PermAndSize $fl]
		}
	    }
	}
	set size [$win.mid.flist.l size]
	set window [lindex [$win.mid.flist.v get] 1]
	if {$size < $window || $size < $pos} {
	    $win.mid.flist.l yview 0
	} else {
	    $win.mid.flist.l yview $pos
	}
	$win configure -cursor {top_left_arrow red white}
	if $DoUpdate {update}
    } else {
	dialog .d Alert "$fn is not a Directory \!" warning -1 OK
    }
}

proc mkFileBox {w title msgText init} {
    global FBFilter F_cmd ShortFont LongFont RegexpStyle oldTK hotlist

    FBInit $w

    if $RegexpStyle {
	set FBFilter "*"
    } else {
	set FBFilter ".*"
    }
    toplevel $w 
    wm title $w "$title"

    frame $w.mbar -relief raised -bd 2
    frame $w.top -relief raised
    frame $w.mid -borderwidth 0
    frame $w.bot -relief raised
    pack $w.mbar -side top -fill x
    pack $w.top $w.mid -fill both -expand 1
    pack $w.bot -fill x -side bottom
    if {[option get $w.mbar background Background] == ""} {
	$w.mbar configure  -bg gray76
	option add *[string trimleft $w.mbar*background .] gray76
	option add *[string trimleft $w.mbar*activeBackground .] gray85
    }
    button $w.mbar.exit -text Exit -relief flat -command "fm_Quit" \
	-padx 1 -pady 1
    if {[option get $w.mbar.exit font Font] == ""} {
	$w.mbar.exit configure -font -adobe-helvetica-bold-o-normal--14-*
	option add *[string trimleft $w.mbar*font .] -adobe-helvetica-bold-o-normal--14-*
    }
    menubutton $w.mbar.sort -text "Sort Type" -menu $w.mbar.sort.menu
    menubutton $w.mbar.list -text "List Type" -menu $w.mbar.list.menu
    menubutton $w.mbar.usr -text "User Commands"  -menu $w.mbar.usr.menu
    menubutton $w.mbar.hot -text "Hotlist" -menu $w.mbar.hot.menu
    menubutton $w.mbar.set -text Configure -menu $w.mbar.set.menu
    pack $w.mbar.exit $w.mbar.sort $w.mbar.list $w.mbar.usr $w.mbar.hot \
		$w.mbar.set -side left -padx 2m -pady 1m

    menu $w.mbar.set.menu
    $w.mbar.set.menu add cascade -label "Configure Buttons" \
	-menu $w.mbar.set.menu.buts
    menu $w.mbar.set.menu.buts
    $w.mbar.set.menu.buts add command -label "Edit Buttons" \
	-command EditRC
    $w.mbar.set.menu.buts add command -label "Add Button" \
	-command "AddRC $w"
    $w.mbar.set.menu.buts add command -label "Delete Button" \
	-command "DeleteRC $w"

    $w.mbar.set.menu add command -label "Configure User Commands" \
	-command "EditUSR $w"

    $w.mbar.set.menu add cascade -label "Configure File Ext." \
	-menu $w.mbar.set.menu.exts
    menu $w.mbar.set.menu.exts
    $w.mbar.set.menu.exts add command -label "Edit Ext." \
	-command "SelITEM dummy dummy extension edit"
    $w.mbar.set.menu.exts add command -label "Add Ext." \
	-command "AddITEM dummy dummy extension"
    $w.mbar.set.menu.exts add command -label "Delete Ext." \
	-command "SelITEM dummy dummy extension delete"

    $w.mbar.set.menu add command -label "Save Configuration" -command "WriteRC"
    $w.mbar.set.menu add command -label "Restore Defaults" \
	-command "RestoreDefaults $w"
    $w.mbar.set.menu add separator
    $w.mbar.set.menu add cascade -label "Filter Style" \
	-menu $w.mbar.set.menu.filter
    $w.mbar.set.menu add checkbutton -label "External Browse" -variable BrowseExt
    menu $w.mbar.set.menu.filter
    $w.mbar.set.menu.filter add radiobutton -label "tcl regexp" \
	-variable RegexpStyle -value 0
    $w.mbar.set.menu.filter add radiobutton -label "csh regexp" \
	-variable RegexpStyle -value 1

    menu $w.mbar.usr.menu
    MakeUSR $w

    menu $w.mbar.sort.menu
    $w.mbar.sort.menu add radiobutton -label "Ascii" \
	-command "DoDirectory $w.mid.flist.l . 1"\
	-variable SortStyle -value "-ascii"
    $w.mbar.sort.menu add radiobutton -label "Time" \
	-command "DoDirectory $w.mid.flist.l . 1"\
	-variable SortStyle -value "-command \"StatSort mtime\""
    $w.mbar.sort.menu add radiobutton -label "Size" \
	-command "DoDirectory $w.mid.flist.l . 1"\
	-variable SortStyle -value "-command \"StatSort size\""

    menu $w.mbar.list.menu
    $w.mbar.list.menu add radiobutton -label "Short" -command \
	"DoDirectory $w.mid.flist.l . 1;$w.mid.flist.l configure -font $ShortFont"\
	-variable ListStyle -value 1
    $w.mbar.list.menu add radiobutton -label "Long" \
	-command "DoLong $w $LongFont" -variable ListStyle -value 0
    $w.mbar.list.menu add separator
    $w.mbar.list.menu add checkbutton -label "Dot Files" -variable DotFiles \
	-command "DoDirectory $w.mid.flist.l . 1"

    menu $w.mbar.hot.menu
    $w.mbar.hot.menu add command -label "Edit Hotlist" \
	-command "EditHOT $w"
    $w.mbar.hot.menu add command -label "Add current to Hotlist" \
	-command "AddHOT $w"
    $w.mbar.hot.menu add separator

    UpdateHOTMenu $w

    button $w.mbar.small -text Small -relief raised -command "Small $w" \
	-padx 1 -pady 1
    pack $w.mbar.small -side right

    button $w.mbar.hlp -text Help -relief raised -command DoHlp \
	-padx 1 -pady 1
    pack $w.mbar.hlp -side right

    if ![string match {} $msgText] {
	message $w.top.message -text $msgText -aspect 800 -bg PowderBlue \
		-relief raised -bd 2
	pack $w.top.message -expand 1 -fill both -padx 2m
    }
    frame $w.mid.fr -bd 4 -relief groove
    pack $w.mid.fr -side top -expand 1 -fill x -padx 2m -pady 2m
    if {$oldTK} {
	makeLB $w.mid.flist -setgrid 1 -relief sunken -bd 3 -bg peachpuff \
	-font $ShortFont 
    } else {
	makeLB $w.mid.flist -setgrid 1 -relief sunken -bd 3 -bg peachpuff \
	-font $ShortFont -selectmode extended
    }
    labelEntry $w.mid.fr.filter {-text "Filter: " -anchor w -width 12} \
	FBFilter 12 {} {setFilter %W}
    bind $w.mid.fr.filter.entry <3> "FilterPopup $w.mid.fr.filter.entry"
    bind $w.mid.fr.filter.label <1> "FilterPopup $w.mid.fr.filter.entry"
    labelEntry $w.mid.fr.fn {-text "Filename:" -anchor w -width 12} \
	FM_files 12 $init "set dummy 0"
    labelEntry $w.mid.fr.dir {-text "Directory:" -anchor w -width 12} \
	{} 12 [pwd] "DoDirectory $w.mid.flist.l \[%W get\] 1"
    pack $w.mid.fr.filter $w.mid.fr.fn $w.mid.fr.dir -expand 1 -fill x
    pack $w.mid.flist -expand 1 -fill both
    $w.mid.flist.l insert end ../
    DoDirectory $w.mid.flist.l . 0
    if {$oldTK} {
	bind $w.mid.flist.l <B1-Motion> {
	    set F_near [%W nearest %y]
	    %W select to $F_near
	    set F_SB [winfo parent %W].v
	    set F_SBlist [$F_SB get]
	    set F_SBL [expr [lindex $F_SBlist 0] - 1]
	    if {$F_SBL == -1} {incr F_SBL}
	    set F_SBf [lindex $F_SBlist 2]
	    set F_SBl [lindex $F_SBlist 3]
	    if {$F_near == $F_SBl && $F_near != $F_SBL} {
		%W yview [expr $F_SBf + 1]
	    }
	    if {$F_near == $F_SBf && $F_near != 0} {
		%W yview [expr $F_SBf - 1]
	    }
	}
    }
    bind $w.mid.flist.l <ButtonRelease-1> "DoSelect $w 0"
    if {$oldTK} {
	bind $w.mid.flist.l <Control-ButtonPress-1> [bind Listbox <ButtonPress-1>]
	bind $w.mid.flist.l <Control-B1-Motion> [bind $w.mid.flist.l <B1-Motion>]
	bind $w.mid.flist.l <Control-ButtonRelease-1> "DoSelect $w 1"
    } else {
	bind $w.mid.flist.l <Control-ButtonRelease-1> "DoSelect $w 0"
    }
    bind $w.mid.flist.l <Shift-ButtonRelease-1> "DoSelect $w 0"
    bind $w.mid.flist.l <Double-1> "setFile %W %y"
    FillButtons $w
}

proc DoLong {w LongFont} {

    DoDirectory $w.mid.flist.l . 1
    if {[catch {$w.mid.flist.l configure -font $LongFont} msg]} {
	puts stderr $msg
	$w.mid.flist.l configure -font fixed
    }
}

proc CheckFont {fontname} {

    toplevel .testje
    if {[catch {listbox .testje.l -font $fontname }]} {
	set fontname fixed
    } else {
    }
    destroy .testje
    return $fontname
   
}

proc FillButtons {w} {
    global F_cmd

    if {[info commands $w.bot.fr] != ""} {
	foreach child [winfo children $w.bot.fr] {
	    destroy $child
	}
	destroy $w.bot.fr
    }
    set args {}
    foreach name [array names F_cmd] {
	   lappend args $name "DoAction \$F_cmd($name)"
    }
    eval doButtons $w $args
}

proc GetListFileName {w check} {
    set sel "[$w.mid.fr.fn.entry get]"
    if {$check} {
	set result [dialog .d {Alert} \
	"Selected File/Directory: \n\n$sel\n\n Are You sure ?" warning -1 \
	OK Cancel]
	if {$result} {
	    return ""
	} else {
	    return $sel
	}
    } else {
	return $sel
    }
}

proc GetPopFileName {msg label globvar title} {
    global $globvar
    set dum {}; lappend dum $label $globvar
    set dummy {}; lappend dummy $dum
    mkEntryBox .cp 12 25 $title $msg $dummy \
	OK "destroy .cp" Clear "set $globvar \{\}" Cancel "set $globvar \"\";destroy .cp"
    bind .cp.top.v0.entry <3> "HOTPopup .cp.top.v0.entry"
    tkwait window .cp
    eval return \$$globvar
}

proc ReadRC {} {
    global env F_cmd FileExt grp itcmd itgrp
    global browsefont TextTypes TextFGColor TextBGColor
    eval global $TextTypes

    set file $env(HOME)/.filemanrc
    if {[file readable $file]} {
	set stat [catch {set f [open $file r]} msg]
	if {$stat} {
	    dialog .d {Alert} $msg warning -1 OK
	    return
	}
	set mode 0
	while {[gets $f line] >= 0} {
	    if {![regexp {^#} $line]} {
		switch $line {
			{[BUTTONS]} {set mode 1;continue}
			{[GROUPS]} {set mode 2;continue}
			{[ITEMS]} {set mode 3;continue}
			{[BROWSEFONT]} {set mode 4;continue}
			{[BROWSECOLORS]} {set mode 5;continue}
			{[EXTCOMMANDS]} {set mode 6;continue}
		}
		switch $mode {
			1   {set linelist [split $line \t]
			     set F_cmd([lindex $linelist 0]) \
			     "[string trimleft [join [lrange $linelist 1 end]] " "]"
			     }
			2   {if {[lsearch -exact $grp $line] == -1} {
				lappend grp $line
				}
			    }
			3   {set linelist [split $line \t]
			     set item "[lindex $linelist 0]"
			     set itgrp($item) "[lindex $linelist 1]"
			     set itcmd($item) \
			     "[string trimleft [join [lrange $linelist 2 end]] " "]"
			     }
			4   {set browsefont $line}
			5   {set TextFGColor $line
			     gets $f TextBGColor
			     foreach color $TextTypes {
				gets $f $color
			     }
			    }
			6   {set linelist [split $line \t]
			     set FileExt([lindex $linelist 0]) \
			     "[string trimleft [join [lrange $linelist 1 end]] " "]"
			     }
		}
	    }
	}
	catch {close $f}
    }
}

proc WriteRC {} {
    global env F_cmd FileExt macros grp itcmd itgrp
    global browsefont TextTypes TextFGColor TextBGColor
    eval global $TextTypes

    set file $env(HOME)/.filemanrc
    set stat [catch {set f [open $file w]} msg]
    if {$stat} {
	    dialog .d {Alert} $msg warning -1 OK
	    return
    }
    puts $f "# use TABs to separate the command name and the command body"
    puts $f "# You can use the macros: $macros"
    puts $f {[BUTTONS]}
    foreach name [array names F_cmd] {
	puts $f "$name\t$F_cmd($name)"
    }
    puts $f {[GROUPS]}
    foreach group $grp {
	puts $f "$group"
    }
    puts $f {[ITEMS]}
    if {[array size itgrp] != 0 } {
	foreach item [array names itgrp] {
	    if {$item != ""} {
		puts $f "$item\t$itgrp($item)\t$itcmd($item)"
	    }
	}
    }
    puts $f {[EXTCOMMANDS]}
    foreach name [array names FileExt] {
	puts $f "$name\t$FileExt($name)"
    }
    puts $f {[BROWSEFONT]}
    puts $f $browsefont
    puts $f {[BROWSECOLORS]}
    puts $f $TextFGColor
    puts $f $TextBGColor
    foreach color $TextTypes {
	eval puts $f \"\$$color\"
    }

    catch {close $f}
}

proc EditRC {} {
    global F_cmd

    set CmdName {}
    foreach name [array names F_cmd] {
	set dummy {}
	lappend dummy \"$name\" F_cmd($name)
	lappend CmdName $dummy
    }
    mkEntryBox .conf 10 40 Configure "Configure Button commands" $CmdName \
	Apply "destroy .conf" Save "WriteRC"
}

proc AddRC {w} {
    global F_cmd addcmd addname

    mkEntryBox .add 10 40 Add "Add Button command" \
	{{{Name:} addname} {{Command:} addcmd}} \
	Apply "set F_cmd(\$addname) \$addcmd; destroy .add; FillButtons $w" \
	Clear "set addcmd \{\};set addname \{\}" Cancel {destroy .add}
}

proc DeleteRC {win} {
    global F_cmd oldTK

    set w .delete
    if {[info commands $w] != ""} {
	wm deiconify $w
	raise $w
	return
    }
    toplevel $w
    wm title $w Delete
    frame $w.top -relief raised
    frame $w.mid -borderwidth 0
    frame $w.bot -relief groove -bd 3
    pack $w.top $w.mid $w.bot -fill both -expand 1
    message $w.top.message -text "Delete Button" -aspect 800 -relief raised \
	-bg PowderBlue
    pack $w.top.message -expand 1 -fill both
    makeLB $w.mid.blist -setgrid 1 -relief sunken -bd 3 -bg peachpuff
    if {$oldTK} {tk_listboxSingleSelect $w.mid.blist.l}
    pack $w.mid.blist -expand 1 -fill both -pady 3
    foreach name [array names F_cmd] {
	$w.mid.blist.l insert end $name
    }
    bind $w.mid.blist.l <Double-Button-1> \
	"unset F_cmd(\[$w.mid.blist.l get \[$w.mid.blist.l curselection\]\]);FillButtons $win;destroy $w"
    button $w.bot.0 -text Apply -bg MistyRose \
	-command "unset F_cmd(\[$w.mid.blist.l get \[$w.mid.blist.l curselection\]\]);FillButtons $win;destroy $w"
    button $w.bot.1 -text Close -command "destroy $w" -bg MistyRose
    pack $w.bot.0 $w.bot.1 -side left -expand 1 -fill x -padx 5 -pady 5
}

proc RestoreDefaults {w} {
    if {![dialog .d {Alert} {Are You sure ?} warning -1 OK Cancel]} {
	DefaultRC
	MakeUSR $w
    } 
}

proc DefaultRC {} {
    global F_cmd FileExt grp itcmd itgrp
    global fonts browsefont TextTypes TextBGColor TextFGColor
    eval global $TextTypes

    set F_cmd(Home\ Dir)		{INTERNAL DoDirectory $FileMWin.mid.flist.l $env(HOME) 1}
    set F_cmd(Up)			{INTERNAL DoDirectory $FileMWin.mid.flist.l .. 1}
    set F_cmd(Update\ List)	{INTERNAL DoDirectory $FileMWin.mid.flist.l . 1}
    set F_cmd(Select\ All)	{INTERNAL SelectAll $FileMWin}
    set F_cmd(Create\ Dir)	"mkdir NEWDIR UPDATELIST"
    set F_cmd(New\ File)		"mxterm -tn vt100 -tm {intr ^C} -e vi NEWFILE &"
    set F_cmd(Edit)		"mxterm -tn vt100 -tm {intr ^C} -e vi OLDFILE &"
    set F_cmd(View)		{INTERNAL BrowseFile OLDFILE}
    set F_cmd(Delete\ File)	"rm -f OLDFILECHECK UPDATELIST"
    set F_cmd(Delete\ Directory)	"rmdir OLDFILECHECK UPDATELIST"
    set F_cmd(Rename)		"mv OLDFILECHECK NEWFILE UPDATELIST"
    set F_cmd(Copy)		"cp OLDFILE NEWFILE UPDATELIST"
    set F_cmd(Permissions)	{INTERNAL DoStats $FileMWin OLDFILE}
    set F_cmd(Execute)		{OLDFILE &}

    set FileExt(NoExtension)	"INTERNAL BrowseFile OLDFILE"
    set FileExt(Default)	"INTERNAL BrowseFile OLDFILE"
    set FileExt(.gif)		"xv OLDFILE &"
    set FileExt(.GIF)		"xv OLDFILE &"
    set FileExt(.jpg)		"xv OLDFILE &"
    set FileExt(.JPG)		"xv OLDFILE &"
    set FileExt(.mpg)		"mpeg_play OLDFILE &"
    set FileExt(.au)		"sfplay OLDFILE &"
    set FileExt(.wav)		"sfplay OLDFILE &"
    set FileExt(.ps)		"ghostview OLDFILE &"
    set FileExt(.Z)		"uncompress OLDFILECHECK UPDATELIST"
    set FileExt(.z)		"gunzip OLDFILECHECK UPDATELIST"
    set FileExt(.gz)		"gunzip OLDFILECHECK UPDATELIST"
    set FileExt(.ZIP)		"unzip OLDFILECHECK UPDATELIST"
    set FileExt(.tar)		"tar -xf OLDFILECHECK UPDATELIST"
    set FileExt(.shar)		"sh OLDFILECHECK UPDATELIST"
    set FileExt(.f)		"INTERNAL BrowseFile OLDFILE"
    set FileExt(.c)		"INTERNAL BrowseFile OLDFILE"

    set grp {system {Internet Tools}}
    set itcmd(Manual\ Page)	{INTERNAL BrowseCmd "man ADDARGS | ul"}
    set itgrp(Manual\ Page)	system
    set itcmd(Show\ Processes)	{INTERNAL BrowseCmd "ps -ef"}
    set itgrp(Show\ Processes)	system
    set itcmd(Search\ in\ file)	{INTERNAL BrowseCmd "grep -i ADDARGS OLDFILE"}
    set itgrp(Search\ in\ file)	system
    set itcmd(Xarchie)		{xarchie &}
    set itgrp(Xarchie)		{Internet Tools}
    set itcmd(Xgopher)		{xgopher &}
    set itgrp(Xgopher)		{Internet Tools}
    set itcmd(WWW)		{xmosaic &}
    set itgrp(WWW)		{Internet Tools}

    set browsefont "[lindex [lindex $fonts 0] 1]"

    set TextBGColor gray41
    set TextFGColor white
    set bold yellow
    set underline green
    set blink red
    set reverse turquoise
    set Search OrangeRed

}

proc ReadHOT {} {
    global env hotlist

    set file $env(HOME)/.filemanhot
    set hotlist {}
    lappend hotlist $env(HOME)
    if {[file readable $file]} {
	set stat [catch {set f [open $file r]} msg]
	if {$stat} {
	    dialog .d {Alert} $msg warning -1 OK
	    return
	}
	while {[gets $f line] >= 0} {
	    if {![regexp {^#} $line]} {
		lappend hotlist $line
	    }
	}
	catch {close $f}
    }
}

proc WriteHOT {} {
    global env hotlist

    set file $env(HOME)/.filemanhot
    set stat [catch {set f [open $file w]} msg]
    if {$stat} {
	    dialog .d {Alert} $msg warning -1 OK
	    return
    }
    foreach name [lrange $hotlist 1 end] {
	puts $f "$name"
    }
    catch {close $f}
}

proc AddHOT {w} {
    global hotlist

    lappend hotlist [$w.mid.fr.dir.entry get]
    WriteHOT
    UpdateHOT
    UpdateHOTMenu $w
}

proc DeleteHOT {w} {
    global hotlist

    set ind [$w.mid.blist.l curselection]
    if {$ind >= 0 } {
	set item [$w.mid.blist.l get $ind]
	set element [lsearch -exact $hotlist $item]
	set hotlist [lreplace $hotlist $element $element]
	$w.mid.blist.l delete $ind
	WriteHOT
    }
}

proc UpdateHOT {} {
    global hotlist

    set w .hot
    if {[info commands $w] == ""} {return}
    $w.mid.blist.l delete 0 end
    foreach name $hotlist {
	$w.mid.blist.l insert end $name
    }
}

proc EditHOT {win} {
    global hotlist oldTK

    set w .hot
    if {[info commands $w] != ""} {
	wm deiconify $w
	raise $w
	return
    } else {
	toplevel $w
	wm title $w HotList
	frame $w.top -relief raised
	frame $w.mid -borderwidth 0
	frame $w.bot -relief groove -bd 3
	pack $w.top $w.mid $w.bot -fill both -expand 1
	message $w.top.message -text "HotList" -aspect 3200 -relief raised \
		-bg PowderBlue
	pack $w.top.message -expand 1 -fill both
	if {$oldTK} {
	    makeLB $w.mid.blist -geometry 40x10 -setgrid 1 -relief sunken \
	    -bd 3 -bg peachpuff
	    tk_listboxSingleSelect $w.mid.blist.l
	} else {
	    makeLB $w.mid.blist -width 40 -height 10 -setgrid 1 \
		-relief sunken -bd 3 -bg peachpuff
	}
	pack $w.mid.blist -expand 1 -fill both -pady 3m
	bind $w.mid.blist.l <Double-Button-1> \
		"DoDirectory $win \[$w.mid.blist.l get \[$w.mid.blist.l curselection\]\] 1"
	button $w.bot.0 -text Apply -bg MistyRose -bd 3 -command \
		"DoDirectory $win \[$w.mid.blist.l get \[$w.mid.blist.l curselection\]\] 1"
	button $w.bot.1 -text Delete -bg MistyRose -bd 3 -command \
		"DeleteHOT $w; UpdateHOTMenu $win"
	button $w.bot.2 -text "Add Current" -bd 3 -bg MistyRose \
		-command "AddHOT $win"
	button $w.bot.3 -text Cancel -bd 3  -bg MistyRose -command "destroy $w"
	pack $w.bot.0 $w.bot.1 $w.bot.2 $w.bot.3 -side left -expand 1 -fill x -padx 5 -pady 5
    }
    UpdateHOT
}

proc UpdateHOTMenu {win} {
    global hotlist

    $win.mbar.hot.menu delete 3 end
    $win.mbar.hot.menu add separator
    foreach name [lrange $hotlist 1 end] {
	$win.mbar.hot.menu add command -label $name \
	-command "DoDirectory $win $name 1"
    }

}

proc HOTPopup {w} {
    global hotlist


    set win [winfo toplevel $w]
    if {[info commands .hotmenu] != ""} {destroy .hotmenu}
    menu  .hotmenu
    .hotmenu add command -label Cancel -command {.hotmenu unpost}
    .hotmenu add separator
    foreach name [lrange $hotlist 1 end] {
	    .hotmenu add command -label "$name" -command \
	    "set fname $name; .hotmenu unpost"
    }
    set W [winfo width $w]
    .hotmenu post [expr [winfo rootx $w] + $W/2] [winfo rooty $w]
}

proc EditUSR {win} {
    global grp newgrp oldTK

    set newgrp {}
    set w .usr
    if {[info commands $w] != ""} {
	wm deiconify $w
	raise $w
    } else {
	toplevel $w
	wm title $w "Edit User"
	frame $w.top -relief raised
	frame $w.mid -borderwidth 0
	frame $w.bot -relief groove -bd 3
	pack $w.top $w.mid $w.bot -fill both -expand 1
	message $w.top.message -text "Select Group" -aspect 1600 \
		-relief raised -bg PowderBlue
	pack $w.top.message -expand 1 -fill both
	if {$oldTK} {
	    makeLB $w.mid.blist -geometry 40x10 -setgrid 1 -relief sunken \
		-bd 3 -bg peachpuff
	} else {
	    makeLB $w.mid.blist -width 40 -height 10 -setgrid 1 -relief sunken \
		-bd 3 -bg peachpuff
	}
	pack $w.mid.blist -expand 1 -fill both -pady 3
	if {$oldTK} {tk_listboxSingleSelect $w.mid.blist.l}
	labelEntry $w.mid.grp {-text "New Group: " -anchor w -width 11} \
		newgrp 20 {} "AddGRP $win $w"
	pack $w.mid.grp -side top -expand 1 -fill x -padx 5 -pady 5
	frame $w.bot.fr1 -relief flat -bd 3
	frame $w.bot.fr2 -relief flat -bd 3
	pack $w.bot.fr1 $w.bot.fr2 -fill both -expand 1
	button $w.bot.fr1.0 -text "Add Group" -bg MistyRose \
		-command "AddGRP $win $w"
	button $w.bot.fr1.1 -text "Delete Group" -bg MistyRose \
		-command "DeleteGRP $win $w"
	button $w.bot.fr1.2 -text Close -command "destroy $w" -bg MistyRose
	pack $w.bot.fr1.0 $w.bot.fr1.1 $w.bot.fr1.2 \
		-side left -expand 1 -fill x -padx 5 -pady 5
	button $w.bot.fr2.0 -text "Add Item to group" -bg MistyRose \
		-command "AddITEM $win $w group"
	button $w.bot.fr2.1 -text "Delete Item from group" -bg MistyRose \
		-command "SelITEM $win $w group delete"
	button $w.bot.fr2.2 -text "Edit Item from group" -bg MistyRose \
		-command "SelITEM $win $w group edit"
	pack $w.bot.fr2.0 $w.bot.fr2.1 $w.bot.fr2.2 -side left -expand 1 \
		-fill x -padx 5 -pady 5
    }
    $w.mid.blist.l delete 0 end
    foreach name $grp {
	$w.mid.blist.l insert end $name
    }
}

proc DeleteGRP {win w} {
    global grp

    set indices [$w.mid.blist.l curselection]
    if {$indices != {} } {
	foreach ind $indices {
	   set item [$w.mid.blist.l get $ind]
	   set element [lsearch -exact $grp $item]
	   set grp [lreplace $grp $element $element]
	}
	eval $w.mid.blist.l delete $indices
	MakeUSR $win
    } else {
	dialog .d {Alert} "No group Selected !" warning -1 OK
    }
}

proc AddGRP {win w} {
    global newgrp grp

    if {$newgrp != {} && [lsearch -exact $grp $newgrp] == -1} {
	lappend grp $newgrp
	$w.mid.blist.l insert end $newgrp
	MakeUSR $win
    } else {
	if {$newgrp == {}} {
	    dialog .d {Alert} "No group entered !" warning -1 OK
	}
	if {[lsearch -exact $grp $newgrp] != -1} {
	    dialog .d {Alert} "Group exists !" warning -1 OK
	}
    }
}

proc AddITEM {win w variable} {

    if {$variable == "group"} {
	set indices [$w.mid.blist.l curselection]
	if {$indices != {} } {
	    global grp itcmd itgrp tmpcmd tmpname
	    set item [$w.mid.blist.l get [lindex $indices 0]]
	    if {[lsearch -exact $grp $item] != -1} {
		mkEntryBox .addit 10 40 Add "Add Item to group $item" \
		{{{Name:} tmpname} {{Command:} tmpcmd}} \
		Apply "set itgrp(\$tmpname) \"$item\"; set itcmd(\$tmpname) \$tmpcmd; destroy .addit;MakeUSR $win" \
		Clear "set tmpcmd \{\};set tmpname \{\}" Cancel {destroy .addit}
	    }
	} else {
	    dialog .d {Alert} "No group Selected !" warning -1 OK
	}
    } else {
        global Ftmpcmd Ftmpname FileExt
	mkEntryBox .addext 10 40 Add "Add FileExtension" \
	    {{{Name:} Ftmpname} {{Command:} Ftmpcmd}} \
	    Apply {set FileExt($Ftmpname) "$Ftmpcmd"; destroy .addext} \
	    Clear {set Ftmpcmd {};set Ftmpname {}} Cancel {destroy .addext}
    }
}

proc EditITEM {win w variable} {
    global grp itcmd itgrp tmpcmd Ftmpcmd FileExt

    set indices [$w.mid.blist.l curselection]
    if {$indices != {} } {
	set item [$w.mid.blist.l get [lindex $indices 0]]
	if {$variable == "group"} {
	    set tmpcmd $itcmd($item)
	    mkEntryBox .editit 10 40 Add "Edit Item $item" \
	    {{{Command:} tmpcmd}} \
	    Apply "set dum \"$item\";set itcmd(\$dum) \"\$tmpcmd\"; destroy .editit;MakeUSR $win" \
	    Clear "set tmpcmd \{\}" Cancel {destroy .editit}
	} else {
	    set Ftmpcmd $FileExt($item)
	    mkEntryBox .editext 10 40 Edit "Edit Extension $item" \
	    {{{Command:} Ftmpcmd}} \
	    Apply "set dum \"$item\";set FileExt(\$dum) \"\$Ftmpcmd\"; destroy .editext" \
	    Clear "set Ftmpcmd \{\}" Cancel {destroy .editext}
	}
    } else {
	dialog .d {Alert} "No group Selected !" warning -1 OK
    }
}

proc SelITEM {win w variable mode} {
    global grp itcmd itgrp FileExt oldTK

    if {$variable == "group"} {
	set indices [$w.mid.blist.l curselection]
	if {$indices != {} } {
	    set group [$w.mid.blist.l get [lindex $indices 0]]
	} else {
	    dialog .d {Alert} "No group Selected !" warning -1 OK
	    return
	}
	if {$mode == "delete"} {
	    set w .deleteit
	    set msg "Delete Item from group $group"
	    set comm "DeleteITEM $win $w group"
	} else {
	    set w .edititem
	    set msg "Edit Item from group $group"
	    set comm "EditITEM $win $w group"
	}
    } else {
	if {$mode == "delete"} {
	    set w .deleteext
	    set msg "Delete File Extension"
	    set comm "DeleteITEM dummy $w extension"
	} else {
	    set w .editexten
	    set msg "Edit File Extension"
	    set comm "EditITEM dummy $w extension"
	}
    }
    if {[info commands $w] != ""} {
	wm deiconify $w
	raise $w
    } else {
	toplevel $w
	wm title $w $msg
	frame $w.top -relief raised
	frame $w.mid -borderwidth 0
	frame $w.bot -relief groove -bd 3
	pack $w.top $w.mid $w.bot -fill both -expand 1
	message $w.top.message -text $msg \
		-aspect 1600 -relief raised -bg PowderBlue
	pack $w.top.message -expand 1 -fill both
	if {$oldTK} {
	    makeLB $w.mid.blist -geometry 25x10 -setgrid 1 -relief sunken \
		-bd 3 -bg peachpuff
	    tk_listboxSingleSelect $w.mid.blist.l
	} else {
	    makeLB $w.mid.blist -width 25 -height 10 -setgrid 1 -relief sunken \
		-bd 3 -bg peachpuff
	}
	pack $w.mid.blist -expand 1 -fill both -pady 3
	bind $w.mid.blist.l <Double-Button-1> $comm
	button $w.bot.0 -text Apply -bg MistyRose \
		-command $comm
	button $w.bot.1 -text Close -command "destroy $w" -bg MistyRose
	pack $w.bot.0 $w.bot.1 -side left -expand 1 -fill x -padx 5 -pady 5
    }
    $w.top.message configure -text $msg
    $w.mid.blist.l delete 0 end
    if {$variable == "group"} {
	foreach name [array names itgrp] {
	    if {$itgrp($name) ==  $group} {
		$w.mid.blist.l insert end $name
	    }
	}
    } else {
	foreach name [array names FileExt] {
	    $w.mid.blist.l insert end $name
	}
    }
}

proc DeleteITEM {win w variable} {
    global grp itcmd itgrp FileExt

    set indices [$w.mid.blist.l curselection]
    if {$indices != {} } {
	foreach ind $indices {
	   set item [$w.mid.blist.l get $ind]
	   if {$variable == "group"} {
		unset itcmd($item); unset itgrp($item)
	   } else {
		unset FileExt($item)
	   }
	}
	eval $w.mid.blist.l delete $indices
	if {$variable == "group"} {
	   MakeUSR $win
	}
    } else {
	dialog .d {Alert} "No Item Selected !" warning -1 OK
    }
    
}

proc MakeUSR {w} {
    global grp itcmd itgrp

    if {[info commands $w.mbar.usr.menu] != ""} {
	$w.mbar.usr.menu delete 0 last
	foreach child [winfo children $w.mbar.usr.menu] {
	    destroy $child
	}
    }
    set numgrp 0
    foreach group $grp {
	$w.mbar.usr.menu add cascade -label "$group" \
		-menu $w.mbar.usr.menu.g$numgrp
	menu $w.mbar.usr.menu.g$numgrp
        if {[array size itgrp] != 0 } {
	    foreach item [array names itgrp] {
		if {$itgrp($item) == $group} {
		    $w.mbar.usr.menu.g$numgrp add command -label $item \
			-command "DoAction \{$itcmd($item)\}"
		}
	    }
	}
	incr numgrp
    }
}

proc SelectAll {w} {
    global oldTK

    if {$oldTK} {
	$w.mid.flist.l select from 1
	$w.mid.flist.l select to end
    } else {
	$w.mid.flist.l selection set 1 end
    }
    set indices [$w.mid.flist.l curselection]
    if {$indices != {}} {
	set f [lindex [$w.mid.flist.l get [lindex $indices 0]] 0]
	foreach ind [lrange $indices 1 end] {
		set f "$f [lindex [$w.mid.flist.l get $ind] 0]"
	}
	entrySet $w.mid.fr.fn.entry $f
    }
}

proc DoSelect {w doadd} {
	set indices [$w.mid.flist.l curselection]
	if {$indices != {}} {
	    if {$doadd} { 
		set f "[$w.mid.fr.fn.entry get] [lindex [$w.mid.flist.l get [lindex $indices 0]] 0]"
	    } else {
	        set f [lindex [$w.mid.flist.l get [lindex $indices 0]] 0]
	    }
	    foreach ind [lrange $indices 1 end] {
		set f "$f [lindex [$w.mid.flist.l get $ind] 0]"
	    }
	    entrySet $w.mid.fr.fn.entry $f
	}
}

proc StatSort {element file1 file2} {
    file lstat $file1 stat1
    file lstat $file2 stat2
    return [expr $stat2($element) - $stat1($element)]
}

proc PermAndSize {filename} {
	global PArray FArray

	set out ""
	file lstat $filename stats
	set mode $stats(mode)
	foreach field $PArray {
	    if {[expr $mode&$field]} {
		append out $FArray($field)
	    } else {
		append out "-"
	    }
	}
	return [format "%-40s %s %9d" $filename $out $stats(size)]
    
}

proc DoStats {win args} {
    global user group other perm unum gnum onum

    set nargs [llength $args]
    if {$nargs == 1} {
	set filename [lindex $args 0]
	file lstat $filename stats
	set mode $stats(mode)

	foreach field $perm {
	    set user($field) 0
	    if {[expr $mode&$unum($field)]} {
		incr user($field)
	    }
	}
	foreach field $perm {
	    set group($field) 0
	    if {[expr $mode&$gnum($field)]} {
		incr group($field)
	    }
	}
	foreach field $perm {
	    set other($field) 0
	    if {[expr $mode&$onum($field)]} {
		incr other($field)
	    }
	}
    } elseif {$nargs > 1} {
	foreach field $perm {
	    set user($field) 0
	    set group($field) 0
	    set other($field) 0
	}
    } else {
	dialog .d {Alert} {No file(s) selected} warning -1 OK
	return
    }

    set w .stat
    if {[info commands $w] != ""} {
	wm deiconify $w
	raise $w
	return
    } else {
	toplevel $w
	frame $w.top -relief raised
        frame $w.mid -borderwidth 0
        frame $w.bot -relief groove -bd 3
        pack $w.top $w.mid $w.bot -fill both -expand 1
	message $w.top.message -text "File Permissions" -aspect 800 \
		-relief raised -bg PowderBlue
	pack $w.top.message -expand 1 -fill both
	frame $w.mid.user -relief groove -bd 4
	frame $w.mid.group -relief groove -bd 4
	frame $w.mid.other -relief groove -bd 4
	pack $w.mid.user $w.mid.group $w.mid.other -side left -padx 2m -pady 2m

	label $w.mid.user.label -text "User:" -relief raised -bg PowderBlue
	checkbutton $w.mid.user.read -text Read -variable user(read) \
		-relief flat
	checkbutton $w.mid.user.write -text Write -variable user(write) \
		-relief flat
	checkbutton $w.mid.user.execute -text Execute -variable user(execute) \
		-relief flat
	pack $w.mid.user.label $w.mid.user.read $w.mid.user.write \
		$w.mid.user.execute -side top -padx 2m -pady 2m -anchor w 

	label $w.mid.group.label -text "Group:" -relief raised -bg PowderBlue
	checkbutton $w.mid.group.read -text Read -variable group(read) \
		-relief flat
	checkbutton $w.mid.group.write -text Write -variable group(write) \
		-relief flat
	checkbutton $w.mid.group.execute -text Execute \
		-variable group(execute) -relief flat
	pack $w.mid.group.label $w.mid.group.read $w.mid.group.write \
		$w.mid.group.execute -side top -padx 2m -pady 2m -anchor w

	label $w.mid.other.label -text "Other:" -relief raised -bg PowderBlue
	checkbutton $w.mid.other.read -text Read -variable other(read) \
		-relief flat
	checkbutton $w.mid.other.write -text Write -variable other(write) \
		-relief flat
	checkbutton $w.mid.other.execute -text Execute \
		-variable other(execute) -relief flat
	pack $w.mid.other.label $w.mid.other.read $w.mid.other.write \
		$w.mid.other.execute -side top -padx 2m -pady 2m -anchor w
	
	button $w.bot.apply -text Apply -bg MistyRose 
	button $w.bot.cancel -text Cancel -bg MistyRose -command "destroy .stat"
	pack $w.bot.apply $w.bot.cancel -side left -pady 2m -padx 2m -fill x \
		-expand 1
    }
    wm title $w $args
    $w.bot.apply configure -command "ChMod $win $args;destroy .stat"
    
}

proc ChMod {w args} {
    global user group other perm onum

    set umode 0
    foreach field $perm {
	if {$user($field)} {
	    set umode [expr $umode + $onum($field)]
	}
    }
    set gmode 0
    foreach field $perm {
	if {$group($field)} {
	    set gmode [expr $gmode + $onum($field)]
	}
    }
    set omode 0
    foreach field $perm {
	if {$other($field)} {
	    set omode [expr $omode + $onum($field)]
	}
    }
    set mode "$umode$gmode$omode"
    set stat "[catch {eval exec chmod $mode $args} msg]"
    if {$stat} {
	dialog .d {Alert} $msg warning -1 OK
    }
    DoDirectory $w.mid.flist.l . 1
 
}

proc DoAction {command} {
    global FileMWin env F_cmd macros
    eval global $macros

    set doupdate 0
    foreach macro $macros {
	if {[regexp $macro $command]} {
	    if {$macro == "UPDATELIST"} {
		incr doupdate
		regsub $macro $command {} command
	    } else {
		eval set dummy \$$macro
		eval set result \"$dummy\"
		if {$result == ""} {
		    return
		} else {
	            regsub $macro $command $result command
		}
	    }
	}
    }

    if {[regexp {INTERNAL} $command]} {
	regsub {INTERNAL\ *} $command {} cmdline
    } else { 
	set cmdline "exec $command"
    }
    $FileMWin configure -cursor {watch red white}
    update
    set stat "[catch {eval $cmdline} msg]"
		  
    if $stat {
	dialog .msg Alert $msg warning -1 OK
    } 
    $FileMWin configure -cursor {top_left_arrow red white}
    update
    if {$doupdate} {
	DoDirectory $FileMWin.mid.flist.l . 1
    }
}

proc FBInit {FileMWin} {
    global fonts browsefont ShortFont LongFont macros 
    global RegexpStyle SortStyle ListStyle DotFiles filenum
    global perm unum gnum onum PArray FArray
    global X11PATH BrowseExt BrowseCmd

    set fonts { \
	{default *-Courier-Medium-R-Normal-*-120-*} {fixed fixed} \
	{6x10 6x10} {7x13 7x13} {7x14 7x14} {8x13 8x13} {9x15 9x15} \
	{times8 *times*-r-*-80*} {times12 *times*-r-*-120*} \
	{times14 *times*-r-*-140*} {times18 *times*-r-*-180*} \
	{times24 *times*-r-*-240*}
	}

    set ShortFont [CheckFont "-Adobe-Helvetica-Bold-R-Normal--*-140-75-75-*"]
    set LongFont [CheckFont "-Misc-Fixed-Bold-R-Normal--*-130-75-75-*"]

    set macros {OLDFILECHECK OLDFILE OLDDIR NEWFILE NEWDIR ADDARGS UPDATELIST}
    eval global $macros
    set NEWFILE "\[GetPopFileName {Enter the Filename of the new File} Filename: fname Filename\]"
    set NEWDIR "\[GetPopFileName {Enter the name of the new Directory} Directory: dname Directory\]"
    set OLDFILE "\[GetListFileName $FileMWin 0\]"
    set OLDFILECHECK "\[GetListFileName $FileMWin 1\]"
    set OLDDIR "\[GetListFileName $FileMWin 0\]"
    set ADDARGS "\[GetPopFileName {Enter Argument} Argument: cmdarg Arguments\]"
    set UPDATELIST ""


    set BrowseExt 1
    set BrowseCmd FMbrowse
    set RegexpStyle 1
    set ListStyle 1
    set DotFiles 0
    set SortStyle "-ascii"
    set filenum 0

    set perm {read write execute}
    set unum(read) 256;set unum(write) 128; set unum(execute) 64
    set gnum(read) 32;set gnum(write) 16; set gnum(execute) 8
    set onum(read) 4;set onum(write) 2; set onum(execute) 1
    set PArray {256 128 64 32 16 8 4 2 1}
    set FArray(256) "r"
    set FArray(128) "w"
    set FArray(64)  "x"
    set FArray(32)  "r"
    set FArray(16)  "w"
    set FArray(8)   "x"
    set FArray(4)   "r"
    set FArray(2)   "w"
    set FArray(1)   "x"

    set X11PATH {/usr/lib/X11}

    InitTags
    DefaultRC
    ReadRC
    ReadHOT
    
}

proc FilterPopup {w} {
    global FileExt


    set win [winfo toplevel $w]
    if {[info commands .filtermenu] != ""} {destroy .filtermenu}
    menu  .filtermenu
    .filtermenu add command -label Cancel -command {.filtermenu unpost}
    .filtermenu add separator
    .filtermenu add command -label "*" \
	-command "set FBFilter *; .filtermenu unpost; setFilter $w"
    foreach extension [array names FileExt] {
	if {$extension != "Default" && $extension != "NoExtension"} {
	    .filtermenu add command -label "*$extension" -command \
	    "set FBFilter *$extension; .filtermenu unpost; setFilter $w"
	}
    }
    set W [winfo width $w]
    .filtermenu post [expr [winfo rootx $w] + $W/2] [winfo rooty $w]
}

proc Small {w} {
    global F_small

    if {$F_small} {
	raise $w
	pack $w.top $w.mid -fill both -expand 1
	pack $w.bot -fill x -side bottom
	$w.mbar.small configure -text Small
	set F_small 0
    } else {
	pack forget $w.top
	pack forget $w.mid
	pack forget $w.bot
	$w.mbar.small configure -text Big
	if {[info commands .hot] != ""} {destroy .hot}
	set F_small 1
    }
}

proc DoHlp {} {
    global env help_url

    if {[info exists env(NEWS_READER)]} {
	catch {exec "$NEWS_READER $help_url &"}
    } else {
	set stat [catch {exec netscape -remote openUrl($help_url)}]
	if {$stat} {
	    catch {exec netscape $help_url &}
	}
    }
}

set help_url {http://www.caos.kun.nl/~gms/mdf/utilities/FileMan/fileman.html}

set oldTK 1
set TK_MAYOR [lindex [split $tk_version .] 0]
set TK_MINOR [lindex [split $tk_version .] 1]
if {$TK_MAYOR >= 4 && $TK_MINOR >= 0} {
    set oldTK 0
}
if {!$oldTK} {
    bind Entry <Return> {set dum 0}
}

proc fm_Quit {} {
  global FileMWin

  if {$FileMWin == ".file"} {
    exit
  } else {
    destroy $FileMWin
  }
}

if {![info exists FileMWin]} {
  wm withdraw .
  set FileMWin ".file"
}

set F_small 0
mkFileBox $FileMWin FileManager FileManager {}
