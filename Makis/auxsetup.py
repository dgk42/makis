#!/usr/bin/env python

import copy
import string
import os
from SCons.Script import *
import auxfun
import AbstractSetter
import gcc
import vc98

def is_not_ms(x):
	ls = ['default', 'mslink', 'msvc', 'masm', 'mslib', 'msvs', 'midl']
	for item in ls:
		if x == item:
			return False
	return True

def get_no_ms_tools_from_env(env, term = ''):
	envtools = filter(is_not_ms, copy.deepcopy(env['TOOLS']))
	envenv = copy.deepcopy(env['ENV'])
	if 'INCLUDE' in envenv:
		del envenv['INCLUDE']
	if 'LIB' in envenv:
		del envenv['LIB']
	if 'LIBPATH' in envenv:
		del envenv['LIBPATH']
	envenv['TERM'] = term
	home = '.'
	if 'HOME' in os.environ:
		home = os.environ['HOME']
	envenv['HOME'] = home
	return envtools, envenv

def setconf(args):
	env = Environment(ENV = os.environ)
	term = ''
	if 'TERM' in os.environ:
		term = os.environ['TERM']

	plat = auxfun.get_plat(env)
	env['VPLAT'] = plat

	colour = 0
	if args.get('colour', '0') == '1':
		colour = 1
	elif args.get('colour') == '2':
		colour = 2

	targetplat = 'l32'
	targetbits = '32'
	if -1 != string.find(auxfun.get_plat(env), 'Linux') and -1 != string.find(auxfun.get_plat(env), 'x86_64'):
		targetplat = 'l64'
		targetbits = '64'
	elif -1 != string.find(env['PLATFORM'], 'darwin'):
		targetplat = 'mac64'
		targetbits = '64'
	elif -1 != string.find(env['PLATFORM'], 'win') and -1 != string.find(env['PLATFORM'], '32'):
		targetplat = 'w32'
		targetbits = '32'
	elif -1 != string.find(env['PLATFORM'], 'win') and -1 != string.find(env['PLATFORM'], '64'):
		targetplat = 'w64'
		targetbits = '64'
	if args.get('vtargetplat') == 'l32':
		targetplat = 'l32'
		targetbits = '32'
	elif args.get('vtargetplat') == 'l64':
		targetplat = 'l64'
		targetbits = '64'
	elif args.get('vtargetplat') == 'mac32':
		targetplat = 'mac32'
		targetbits = '32'
	elif args.get('vtargetplat') == 'mac64':
		targetplat = 'mac64'
		targetbits = '64'
	elif args.get('vtargetplat') == 'w32':
		targetplat = 'w32'
		targetbits = '32'
	elif args.get('vtargetplat') == 'w64':
		targetplat = 'w64'
		targetbits = '64'
	env['VPLAT'] = plat
	env['VTARGETPLAT'] = targetplat
	env['VBITS'] = targetbits

	isllvmgcc = 'no'
	if args.get('vllvmgcc', '0') == '1':
		isllvmgcc = 'yes'
	isvc98 = 'no'
	if args.get('vw32vc98', '0') == '1':
		isvc98 = 'yes'
		targetplat = 'w32'
		targetbits = 32
	env['VPLAT'] = plat
	env['VTARGETPLAT'] = targetplat
	env['VBITS'] = targetbits
	env['VLLVMGCC'] = isllvmgcc
	env['VVC98'] = isvc98

	x = AbstractSetter.AbstractSetter()
	if auxfun.is_llvmgcc_build(env):
		x = gcc.LlvmGccSetter.LlvmGccSetter()
	elif auxfun.is_vc98_build(env):
		x = vc98.Vc98Setter.Vc98Setter()
	elif auxfun.is_linux_plat(env):
		if auxfun.is_windows_targetplat(env) and auxfun.is_32bit_plat(env):
			x = gcc.CrossMingwSetter.CrossMingwSetter()
		elif auxfun.is_windows_targetplat(env) and auxfun.is_64bit_plat(env):
			x = gcc.CrossMingwSetter.CrossMingwSetter(True)
		else:
			x = gcc.GccSetter.GccSetter()
	elif auxfun.is_mac_plat(env):
			x = gcc.MacGccSetter.MacGccSetter()
	elif auxfun.is_windows_plat(env):
		if auxfun.is_windows_targetplat(env) and auxfun.is_32bit_plat(env):
			x = gcc.MingwSetter.MingwSetter()

	env = x.pre_set_env_vars(env, term, 2 == colour)
	targetenvarg = args.get('vconfig', 'debug')
	if targetenvarg == 'debug':
		x.set_compiler_flags_debug(env)
	elif targetenvarg == 'release':
		x.set_compiler_flags_release(env)
	elif targetenvarg == 'profile':
		x.set_compiler_flags_profile(env)
	elif targetenvarg == 'coverage':
		x.set_compiler_flags_coverage(env)
	else:
		targetenvarg = 'debug'
		x.set_compiler_flags_debug(env)
	env['VPLAT'] = plat
	env['VTARGETPLAT'] = targetplat
	env['VBITS'] = targetbits
	env['VLLVMGCC'] = isllvmgcc
	env['VVC98'] = isvc98
	env['VCONFIG'] = targetenvarg
	x.post_set_env_vars(env)

	if 1 == colour:
		try:
			from colorizer import colorizer
			col = colorizer()
			col.colorize(env)
		except:
			pass

	#print env.Dump()
	#Exit(1)

	return env
