#!/usr/bin/env python

import os
from SCons.Script import *
import AbstractSetter
from gccaux import *
import auxfun
import auxsetup

class MingwSetter(AbstractSetter.AbstractSetter):
	"""Windows mingw"""

	_default_build_flags = '-std=c99 -Wall -Wextra -Wl,--enable-auto-import '

	def pre_set_env_vars(self, env0, term = '', colour = False):
		envtools, envenv = auxsetup.get_no_ms_tools_from_env(env0, term)
		env = Environment(
			tools = envtools,
			MAINTOOL = 'mingw',
			LAUNCHDIR = GetLaunchDir(),
			ENV = envenv)
		env.Tool('mingw')

		env['LIBPREFIX'] = ''
		env['LIBSUFFIX'] = '.lib'
		env['LIBPREFIX'] = 'lib'
		env['LIBSUFFIX'] = '.a'
		env['SHLIBPREFIX'] = ''
		env['SHLIBSUFFIX'] = '.dll'
		env['LIBPREFIXES'] = [ '$LIBPREFIX' ]
		env['LIBSUFFIXES'] = [ '$LIBSUFFIX' ]

		if colour:
			colorgcc_arg = auxfun.colorgccrc_arg + ' ' + os.path.join(auxfun.colorgccrc_path, 'gcc', 'colorgccrc.mingw')
			colorgcc_cmd = auxfun.perl_cmd + ' ' + auxfun.colorgcc + ' ' + colorgcc_arg
			env['CC'] = colorgcc_cmd
			env['LINK'] = colorgcc_cmd

		env.AppendUnique(LINKFLAGS = '--no-undefined')
		env.AppendUnique(LINKFLAGS = '--enable-runtime-pseudo-reloc')

		set_buildflg(env, self._default_build_flags)
		env['STRIP_CMD'] = 'strip -s'

		return env

	def post_set_env_vars(self, env):
		env.AppendUnique(CPPDEFINES = ['BUILD_WINDOWS'])
		apply_32bit(env)
		finalize_buildflg(env)

	def set_compiler_flags_debug(self, env):
		set_default_compiler_flags_debug(env)

	def set_compiler_flags_release(self, env):
		set_default_compiler_flags_release(env)

	def set_compiler_flags_profile(self, env):
		raise NotImplementedError('Unimplimented for MinGW')

	def set_compiler_flags_coverage(self, env):
		set_default_compiler_flags_coverage(env)
