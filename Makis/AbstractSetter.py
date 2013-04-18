#!/usr/bin/env python

import os
from SCons.Script import *

class AbstractSetter:
	"""C builder abstract class
	
	subclasses should implement:
	pre_set_env_vars(self, term, colour)
	post_set_env_vars(self, env, force32)
	set_compiler_flags_debug(self, env)
	set_compiler_flags_release(self, env)
	set_compiler_flags_profile(self, env)
	set_compiler_flags_coverage(self, env)
	"""

	def pre_set_env_vars(self, env0, term = '', colour = False):
		raise NotImplementedError('Should have implemented this')

	def post_set_env_vars(self, env):
		raise NotImplementedError('Should have implemented this')

	def set_compiler_flags_debug(self, env):
		raise NotImplementedError('Should have implemented this')

	def set_compiler_flags_release(self, env):
		raise NotImplementedError('Should have implemented this')

	def set_compiler_flags_profile(self, env):
		raise NotImplementedError('Should have implemented this')

	def set_compiler_flags_coverage(self, env):
		raise NotImplementedError('Should have implemented this')
