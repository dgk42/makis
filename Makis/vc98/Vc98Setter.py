#!/usr/bin/env python

import os
from SCons.Script import *
import AbstractSetter
import auxfun

class Vc98Setter(AbstractSetter.AbstractSetter):
	"""m$ win32 vc98"""

	_default_compiler_flags = ['/W3', '/GX']
	_default_debug_compiler_flags = ['/Od', '/GZ']
	_default_release_compiler_flags = ['/O2']

	def pre_set_env_vars(self, env0, term = '', colour = False):
		home = '.'
		if 'HOME' in os.environ:
			home = os.environ['HOME']
		env = Environment(
			MAINTOOL = 'vc98',
			LAUNCHDIR = GetLaunchDir(),
			ENV = {
			'PATH' : os.environ['PATH'],
			'TERM' : term,
			'HOME' : os.environ['HOME']})

		env.AppendUnique(CCFLAGS = self._default_compiler_flags)
		env['STRIP_CMD'] = None

		return env

	def post_set_env_vars(self, env):
		env.AppendUnique(CPPDEFINES = ['WIN32', '_MBCS', 'BUILD_WINDOWS', 'BUILD_VC98'])

	def set_compiler_flags_debug(self, env):
		env.AppendUnique(CCFLAGS = self._default_debug_compiler_flags)
		env.AppendUnique(CPPDEFINES = ['_DEBUG'])

	def set_compiler_flags_release(self, env):
		env.AppendUnique(CCFLAGS = self._default_release_compiler_flags)
		env.AppendUnique(CPPDEFINES = ['NDEBUG'])

	def set_compiler_flags_profile(self, env):
		raise NotImplementedError('Unimplimented for vc98')

	def set_compiler_flags_coverage(self, env):
		raise NotImplementedError('Unimplimented for vc98')
