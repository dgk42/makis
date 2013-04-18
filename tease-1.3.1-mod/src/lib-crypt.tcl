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
# text encryption algorithm:
#
# key provides starting cipher configuration
#   (unicode values of letters in key match beginning cipher numbers)
# with 12 different 95-char cipher maps, number of ciphers ~ 540 sestillion
# ...kind of tough to crack for your everyday cryptogrammer

namespace eval crypt {

namespace export Init Encrypt Decrypt SetKey
variable cipher

proc Init { } {
  variable cipher

  SetCiphers
  set cipher(total) 12
  InitCiphers
  set cipher(key) ""
}

proc SetKey {str} {
  variable cipher
  set cipher(key) "$str"
}

proc InitCiphers { } {
  variable cipher

  for {set i 1} {$i <= $cipher(total)} {incr i} {
    set tmpInit [lindex $cipher(root) $i]
    set tmp [lindex $cipher($i) 0]
    while {$tmp != $tmpInit} {
      AdvanceOneCipher $i
      set tmp [lindex $cipher($i) 0]
    }
  set cipher(start$i) [lindex $cipher($i) 0]
  }
}


proc SetCiphersToKey { } {
  variable cipher
  InitCiphers
  for {set i 1} {$i <= [string length cipher(key)]} {incr i} {
    set c [string index $cipher(key) [expr $i - 1]]
    scan $c %c cipher(start$i)
  }
  ResetCiphers
}


proc EncodeChar { c } {
  variable cipher

  scan $c %c tmpStr

  for {set i 1} {$i <= $cipher(total)} {incr i} {
    set rootIndex [lsearch -exact $cipher(root) $tmpStr]
    set tmpStr [lindex $cipher($i) $rootIndex]
  }
  AdvanceCiphers
  return [format %c $tmpStr]
}

proc DecodeChar { c } {
  variable cipher

  scan $c %c tmpStr
  for {set i $cipher(total)} {$i >= 1} {incr i -1} {
    set rootIndex [lsearch -exact $cipher($i) $tmpStr]
    set tmpStr [lindex $cipher(root) $rootIndex]
  }
  AdvanceCiphers
  return [format %c $tmpStr]
}


proc Encrypt { data } {
  variable cipher
  SetCiphersToKey

  set crypt ""
  for {set i 0} {$i < [string length $data]} {incr i} {
    set tmp [EncodeChar [string index $data $i]]
    append crypt $tmp
  }
  return $crypt
}


proc Decrypt { data } {
  variable cipher
  SetCiphersToKey

  set crypt ""
  for {set i 0} {$i < [string length $data]} {incr i} {
    set tmp [DecodeChar [string index $data $i]]
    append crypt $tmp
  }
  return $crypt
}


proc ResetCiphers { } {
  variable cipher
  for {set i 1} {$i <= $cipher(total)} {incr i} {
    set tmp [lindex $cipher($i) 0]
    while {$tmp != $cipher(start$i)} {
      AdvanceOneCipher $i
      set tmp [lindex $cipher($i) 0]
    }
  }
}

proc AdvanceCiphers { } {
  variable cipher
  AdvanceOneCipher 1

  for {set i 1} {$i <= $cipher(total)} {incr i} {
    if {[lindex $cipher($i) 0] == "$cipher(start$i)"} {
      AdvanceOneCipher [expr $i + 1]
    } else {
      break
    }
  }
}

proc AdvanceOneCipher { n } {
  variable cipher
  set x [lindex $cipher($n) 0]
  set cipher($n) [lreplace $cipher($n) 0 0]
  lappend cipher($n) $x
}


proc SetCiphers { } {
  variable cipher
  set cipher(root) [list 96 126 49 33 50 9 64 51 35 52 36 53 37 54 94 55 38 56 42 57 40 48 41 45 95 61 43 113 81 119 87 101 69 114 82 116 84 121 89 117 85 105 73 111 79 112 80 91 123 93 125 92 124 97 65 115 83 100 68 102 70 103 71 104 72 106 74 107 75 108 76 59 58 39 34 10 122 90 120 88 99 67 118 86 98 66 110 78 109 77 44 60 46 62 47 63 32]
  set cipher(1)  [list 103 55 126 74 117 49 33 61 43 113 119 123 38 93 125 65 115 83 100 68 102 72 71 106 50 64 51 69 114 46 116 84 99 121 89 79 85 105 73 112 80 53 36 94 56 42 57 40 48 41 37 54 45 95 75 108 76 59 58 39 34 10 122 90 120 9 88 67 118 86 98 66 78 52 109 111 35 77 44 60 62 47 63 104 32 82 70 96 107 92 124 97 87 101 91 81 110]
  set cipher(2)  [list 49 33 50 45 95 61 43 113 64 51 35 52 36 53 37 54 94 56 42 57 40 48 41 81 119 55 38 87 101 69 114 82 116 84 121 89 117 85 105 73 111 79 112 80 91 123 93 125 92 124 97 65 115 83 100 68 102 70 103 71 104 72 106 74 107 75 108 76 59 58 44 39 34 10 122 90 96 126 120 88 99 67 118 86 98 66 110 78 109 77 60 46 62 47 63 32 9]
  set cipher(3)  [list 51 50 35 52 37 54 94 55 38 42 33 57 40 48 36 53 41 45 95 56 61 43 113 119 87 101 81 69 114 82 116 84 121 47 63 32 96 49 126 89 117 85 105 73 111 79 112 80 91 123 93 125 92 124 97 65 115 83 62 100 68 102 70 103 71 104 72 106 74 9 107 75 108 76 59 58 39 34 10 122 90 120 88 99 67 118 86 98 66 110 78 109 77 44 60 46 64]
  set cipher(4)  [list 96 89 117 85 105 73 111 79 112 80 91 123 93 125 92 124 97 65 115 83 9 100 68 102 70 103 71 104 72 106 82 116 74 33 51 63 32 107 75 108 76 59 58 39 34 10 122 90 120 88 99 67 118 86 98 66 110 78 109 77 44 60 46 35 52 36 53 37 94 55 41 38 56 42 57 40 48 45 95 61 43 113 81 119 87 101 69 114 84 121 47 62 64 50 49 54 126]
  set cipher(5)  [list 87 63 96 126 82 49 43 113 81 69 119 101 54 94 114 116 42 84 121 89 50 64 117 85 10 105 73 112 79 91 123 9 93 125 124 97 65 115 83 68 102 53 70 103 71 104 72 106 74 107 75 100 108 76 58 39 34 122 111 90 120 88 78 99 67 118 86 98 66 110 109 77 44 46 62 47 32 92 52 33 35 37 51 55 80 60 40 38 56 57 48 41 45 95 61 36 59]
  set cipher(6)  [list 94 114 123 93 125 121 89 50 64 49 43 113 81 69 119 65 115 83 68 101 124 116 117 97 10 53 105 9 42 84 87 54 63 96 126 82 73 112 79 91 34 122 90 70 103 71 104 72 106 47 85 32 102 74 33 107 75 100 120 88 37 99 67 45 95 56 61 36 59 98 55 80 66 78 109 111 46 62 118 110 92 52 60 35 51 38 57 48 41 44 108 76 58 39 40 86 77]
  set cipher(7)  [list 42 57 40 48 36 9 53 41 45 95 61 43 113 119 87 101 81 69 114 82 116 84 121 47 63 32 96 49 126 89 117 85 105 73 111 79 112 80 91 123 93 125 92 124 97 65 115 83 62 100 68 102 70 103 71 104 110 72 106 74 107 75 108 76 59 58 39 34 10 122 90 120 88 99 67 118 109 86 98 66 78 77 51 44 60 46 64 33 50 35 52 37 54 94 55 38 56]
  set cipher(8)  [list 117 49 33 61 123 93 125 9 65 115 83 100 68 102 72 71 106 50 64 51 69 114 46 116 84 121 89 79 85 105 73 112 80 52 36 53 94 55 38 56 42 57 40 48 41 37 54 45 95 75 108 76 59 58 39 34 10 122 90 120 88 99 103 126 74 67 118 86 98 66 78 109 111 35 77 44 60 62 47 63 104 32 82 70 96 107 92 124 97 87 101 91 81 110 43 113 119]
  set cipher(9)  [list 63 9 96 126 82 49 43 113 81 69 54 119 101 94 114 116 42 84 121 89 50 64 117 85 10 105 73 112 79 91 123 93 125 83 68 102 53 70 103 71 104 72 106 74 107 75 100 108 76 58 39 34 122 111 90 120 88 99 67 118 86 98 66 110 78 109 77 44 46 62 47 32 92 52 33 35 37 51 55 80 60 40 38 56 57 48 41 45 95 61 36 59 87 124 97 65 115]
  set cipher(10) [list 114 126 82 43 113 81 69 54 119 101 94 116 79 42 84 121 89 50 64 117 49 85 10 77 105 73 112 91 123 93 125 83 68 102 53 70 103 71 104 72 106 74 107 75 100 108 76 58 39 34 122 111 90 120 88 99 67 118 86 98 66 110 78 109 44 62 47 32 92 52 35 37 51 55 80 60 40 38 56 57 48 41 95 61 36 46 59 87 124 97 65 115 63 9 45 33 96]
  set cipher(11) [list 125 59 87 63 96 126 82 43 113 81 69 119 54 94 114 116 42 84 121 101 89 50 64 117 85 10 105 73 112 79 49 91 123 9 93 124 78 97 65 115 83 41 68 102 53 70 103 35 71 104 74 107 75 100 108 76 58 39 95 56 34 122 111 90 120 88 99 67 106 118 86 98 66 110 109 77 44 46 62 47 72 32 92 52 33 48 37 51 55 80 60 40 38 57 45 61 36]
  set cipher(12)  [list 74 62 111 50 97 33 45 95 61 39 43 113 64 51 35 52 102 36 53 37 54 94 56 42 57 40 48 41 81 119 55 38 87 101 69 114 82 116 84 106 121 89 117 85 105 73 79 112 80 91 123 93 125 92 124 65 115 83 100 68 46 70 103 71 104 72 75 108 76 59 58 34 10 49 122 90 96 126 120 88 44 99 67 118 86 98 66 110 78 109 77 60 47 63 32 9 107]
  }
}


crypt::Init

# end
