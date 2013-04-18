#!/usr/bin/env python

import os
from SCons.Script import *
import AbstractSetter
from gccaux import *
import auxfun

class LlvmGccSetter(AbstractSetter.AbstractSetter):
	"""Linux llvm-gcc"""

	_default_build_flags = '-Wall -Wextra '

	def pre_set_env_vars(self, env0, term = '', colour = False):
		env = env0.Clone()
		env['MAINTOOL'] = 'llvmgcc'
		env['LAUNCHDIR'] = GetLaunchDir()
		env['ENV']['PATH'] = os.environ['PATH']
		env['ENV']['TERM'] = term
		env['ENV']['HOME'] = os.environ['HOME']
		env['ENV']['dragonegg_disable_version_check'] = '1'
		env.Tool('llvmgcc', toolpath = [auxfun.scons_tools_path])

		if colour:
			colorgccrc = 'colorgccrc.llvmgcc'
			colorgcc_arg = auxfun.colorgccrc_arg + ' ' + os.path.join(auxfun.colorgccrc_path, 'gcc', colorgccrc)
			colorgcc_cmd = auxfun.perl_cmd + ' ' + auxfun.colorgcc + ' ' + colorgcc_arg
			env['CC'] = colorgcc_cmd
			env['LINK'] = colorgcc_cmd

		env.AppendUnique(LINKFLAGS = r"-Wl,-rpath=\$$ORIGIN")
		env.AppendUnique(LINKFLAGS = Split('-z origin'))

		set_buildflg(env, self._default_build_flags)
		env['STRIP_CMD'] = 'strip -s'

		return env

	def post_set_env_vars(self, env):
		if auxfun.is_linux_targetplat(env):
			env.AppendUnique(CPPDEFINES = ['BUILD_LINUX'])
		elif auxfun.is_windows_targetplat(env):
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
