#!/usr/bin/env python

import os
from SCons.Script import *
import auxfun

def apply_32bit(env):
	if auxfun.is_32bit_plat(env):
		env.Replace(VBITS = '32')
		env.AppendUnique(BUILDFLG = ' -m32 -msse2')
		env.AppendUnique(LINKFLAGS = ['-m32', '-msse2'])

def set_buildflg(env, build_flags):
	env['BUILDFLG'] = build_flags

def finalize_buildflg(env):
	if 'BUILDFLG' in env:
		env.MergeFlags(env.ParseFlags(env['BUILDFLG']))

def set_default_compiler_flags_debug(env):
	env.PrependUnique(BUILDFLG = '-g ')
	#env.AppendUnique(CPPDEFINES = ['MEM_DEBUG'])
	finalize_buildflg(env)

def set_default_compiler_flags_release(env):
	env.PrependUnique(BUILDFLG = '-O3 ')
	env.AppendUnique(BUILDFLG = '-ffast-math')
	env.AppendUnique(CPPDEFINES = ['NDEBUG'])
	finalize_buildflg(env)

def set_default_compiler_flags_profile(env):
	env.PrependUnique(BUILDFLG = '-g -pg ')
	finalize_buildflg(env)

def set_default_compiler_flags_coverage(env):
	env.PrependUnique(BUILDFLG = '-ggdb ')
	env.AppendUnique(BUILDFLG = '-fprofile-arcs -ftest-coverage -lgcov')
	finalize_buildflg(env)
