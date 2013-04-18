#!/usr/bin/env python

import os
from SCons.Script import *
import AbstractSetter
from gccaux import *
import auxfun

class CrossMingwSetter(AbstractSetter.AbstractSetter):
	"""Crossmingw windows target"""

	_default_build_flags = '-std=c99 -Wall -Wextra -Wl,--enable-auto-import '
	_isw64 = False

	def __init__(self, isw64 = False):
		self._isw64 = isw64

	def pre_set_env_vars(self, env0, term = '', colour = False):
		env = env0.Clone()
		env['MAINTOOL'] = 'crossmingw'
		env['LAUNCHDIR'] = GetLaunchDir()
		env['ENV']['PATH'] = os.environ['PATH']
		env['ENV']['TERM'] = term
		env['ENV']['HOME'] = os.environ['HOME']
		if self._isw64:
			env.Tool('crossmingw64', toolpath = [auxfun.scons_tools_path])
			from crossmingw64 import find
			colorgccrc = 'colorgccrc.crossmingw64'
		else:
			env.Tool('crossmingw32', toolpath = [auxfun.scons_tools_path])
			from crossmingw32 import find
			colorgccrc = 'colorgccrc.crossmingw32'

		if colour:
			colorgcc_arg = auxfun.colorgccrc_arg + ' ' + os.path.join(auxfun.colorgccrc_path, 'gcc', colorgccrc)
			colorgcc_cmd = auxfun.perl_cmd + ' ' + auxfun.colorgcc + ' ' + colorgcc_arg
			env['CC'] = colorgcc_cmd
			env['LINK'] = colorgcc_cmd

		set_buildflg(env, self._default_build_flags)
		env['STRIP_CMD'] = find(env) + 'strip -s'

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
		set_default_compiler_flags_profile(env)

	def set_compiler_flags_coverage(self, env):
		set_default_compiler_flags_coverage(env)
