#!/usr/bin/env python

import string
import os
from SCons.Script import *

dir_bin_base = '#bin'
dir_lib_base = '#lib'
dir_inc_base0 = '#include'
dir_inc_base = dir_inc_base0
dir_doc_out = '#doc'
dir_obj_base = '.obj-scons'

prefix = ".."
prefix_bin = "bin"
prefix_doc = "doc"

scons_tools_path = os.path.join(os.environ['MAKIS_DIR'], 'Makis', 'scons-tools')

perl_cmd = 'perl -w'
colorgcc = os.path.join(os.environ['MAKIS_PATH_PREFIX'], os.environ['MAKIS_DIR'], 'colorgcc-1.3.2-mod', 'colorgcc.1.3.2.pl')
colorgccrc_arg = '--colorgccrc'
colorgccrc_path = os.path.join(os.environ['MAKIS_PATH_PREFIX'], os.environ['MAKIS_DIR'], 'Makis')

def get_plat(env):
	plat = env['PLATFORM']
	if env['PLATFORM'] == 'posix' or env['PLATFORM'] == 'darwin':
		plat = os.uname()[0] + '-' + os.uname()[4]
	return plat

def is_posix_plat(env):
	if env['PLATFORM'] == 'posix':
		return 1
	return 0

def is_linux_plat(env):
	plat = get_plat(env)
	if -1 != string.find(plat, 'Linux'):
		return 1
	return 0

def is_mac_plat(env):
	plat = get_plat(env)
	if -1 != string.find(plat, 'Darwin'):
		return 1
	return 0

def is_windows_plat(env):
	if -1 != string.find(env['PLATFORM'], 'win'):
		return 1
	return 0

def is_32bit_plat(env):
	if env['VBITS'] == '32':
		return 1
	return 0

def is_64bit_plat(env):
	if env['VBITS'] == '64':
		return 1
	return 0

def is_linux_targetplat(env):
	if env['VTARGETPLAT'] == 'l32' or env['VTARGETPLAT'] == 'l64':
		return 1
	return 0

def is_mac_targetplat(env):
	if env['VTARGETPLAT'] == 'm32' or env['VTARGETPLAT'] == 'm64':
		return 1
	return 0

def is_windows_targetplat(env):
	if env['VTARGETPLAT'] == 'w32' or env['VTARGETPLAT'] == 'w64':
		return 1
	return 0

def is_debug_build(env):
	if env['VCONFIG'] == 'debug':
		return 1
	return 0

def is_release_build(env):
	if env['VCONFIG'] == 'release':
		return 1
	return 0

def is_profile_build(env):
	if env['VCONFIG'] == 'profile':
		return 1
	return 0

def is_coverage_build(env):
	if env['VCONFIG'] == 'coverage':
		return 1
	return 0

def is_vc98_build(env):
	if env['VVC98'] == 'yes':
		return 1
	return 0

def is_llvmgcc_build(env):
	if env['VLLVMGCC'] == 'yes':
		return 1
	return 0

def get_exe_extension(env):
	if is_linux_targetplat(env):
		return ''
	elif is_mac_targetplat(env):
		return ''
	elif is_windows_targetplat(env):
		return '.exe'
	return ''

def get_class(kls):
	parts = kls.split('.')
	module = ".".join(parts[:-1])
	m = __import__(module)
	for comp in parts[1:]:
		m = getattr(m, comp)
	return m

def list_from_str_dict(dicti, val):
	if val in dicti:
		return Split(dicti[val])
	return None

def str_from_str_dict(dicti, val):
	if val in dicti:
		tmp = Split(dicti[val])
		if tmp:
			return tmp[0]
	return None

def int_from_str_dict(dicti, val):
	if val in dicti:
		return dicti[val]
	return 0

def get_intermediate_prefix(env):
	maintool = env['TOOLS'][0]
	if 'MAINTOOL' in env:
		if env['MAINTOOL']:
			maintool = env['MAINTOOL']
	host_str = get_plat(env)
	if 'HOST_ARCH' in env and 'HOST_OS' in env:
		if env['HOST_ARCH'] and env['HOST_OS']:
			host_str = env['HOST_ARCH'] + '-' + env['HOST_OS']
	target_str = env['VTARGETPLAT']
	if 'TARGET_ARCH' in env and 'TARGET_OS' in env:
		if env['TARGET_ARCH'] and env['TARGET_OS']:
			target_str = env['TARGET_ARCH'] + '-' + env['TARGET_OS']
	return maintool + '_' + host_str + '__' + target_str + '_' + env['VCONFIG']

def get_env_subdir(env):
	if 'VPLAT'in env and 'VCONFIG' and 'VTARGETPLAT' in env:
		#return env['VPLAT'] + '-' + env['VTARGETPLAT'] + '-' + env['VCONFIG']
		return get_intermediate_prefix(env)
	return ''

def get_obj_dir(env, subdir):
	if 'VPLAT'in env and 'VCONFIG' and 'VTARGETPLAT' in env:
		return os.path.join(dir_obj_base,
			#env['VCONFIG'] + '-' + env['VPLAT'] + '-' + env['VTARGETPLAT'],
			get_intermediate_prefix(env),
			subdir)
	return os.path.join(dir_obj_base + '-' + subdir)

def get_bin_dir(env):
	return os.path.join(dir_bin_base, get_env_subdir(env))

def set_dir_inc_base(projroot):
	global dir_inc_base
	global dir_inc_base0
	dir_inc_base = os.path.join(dir_inc_base0, projroot)
