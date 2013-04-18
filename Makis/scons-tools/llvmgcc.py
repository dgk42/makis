"""SCons.Tool.badagcc

Tool-specific initialization for llvm-gcc

There normally shouldn't be any need to import this module directly.
It will usually be imported through the generic SCons.Tool.Tool()
selection method.

"""

#
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
#
# The above copyright notice and this permission notice shall be included
# in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY
# KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE
# WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
# LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
# WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#

__revision__ = "scons-tools/llvmgcc.py 2012/01/02 21:31:03 r00t"

import os

import SCons.Action
import SCons.Builder
import SCons.Defaults
import SCons.Tool
import SCons.Util

def find(env):
    # First search in the SCons path and then the OS path:
    if env.WhereIs('llvm-gcc') or SCons.Util.WhereIs('llvm-gcc'):
        return 'llvm-gcc'

    return ''


def generate(env):
    llvmgcc = find(env)
    if llvmgcc:
        dir = os.path.dirname(llvmgcc)
        env.PrependENVPath('PATH', dir )
        

    # Most of llvm-gcc is the same as gcc and friends...
    gnu_tools = ['gcc', 'g++', 'gnulink', 'ar', 'gas', 'm4']
    for tool in gnu_tools:
        SCons.Tool.Tool(tool)(env)

    #... but a few things differ:
    env['CC'] = 'llvm-gcc'
    env['SHCCFLAGS'] = SCons.Util.CLVar('$CCFLAGS')
    env['CXX'] = 'llvm-g++'
    env['SHCXXFLAGS'] = SCons.Util.CLVar('$CXXFLAGS')
    env['SHLINKFLAGS'] = SCons.Util.CLVar('$LINKFLAGS')
    env['LINK'] = 'llvm-gcc'
    env['AR'] = 'ar'
    env['RANLIB'] = 'ranlib'
    env['AS'] = 'llvm-as'
    env['SHOBJSUFFIX'] = '.o'

    # Some setting from the platform also have to be overridden:
    env['OBJPREFIX']      = ''
    env['OBJSUFFIX']      = '.o'
    env['LIBPREFIX']      = 'lib'
    env['LIBSUFFIX']      = '.a'
    env['SHOBJPREFIX']    = '$OBJPREFIX'
    env['SHOBJSUFFIX']    = '$OBJSUFFIX'
    env['PROGPREFIX']     = ''
    env['PROGSUFFIX']     = ''
    env['SHLIBPREFIX']    = 'lib'
    env['SHLIBSUFFIX']    = '.so'
    env['LIBPREFIXES']    = [ '$LIBPREFIX' ]
    env['LIBSUFFIXES']    = [ '$LIBSUFFIX' ]
    env['SHLIBPREFIXES']    = [ '$SHLIBPREFIX' ]
    env['SHLIBSUFFIXES']    = [ '$SHLIBSUFFIX' ]

def exists(env):
    return find(env)

# Local Variables:
# tab-width:4
# indent-tabs-mode:nil
# End:
# vim: set expandtab tabstop=4 shiftwidth=4:
