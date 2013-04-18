#!/usr/bin/env python

import os
import shutil
from SCons.Script import *
import auxfun

def cp_builder_fun(target, source, env):
	try:
		shutil.copyfile(str(source[0]), str(target[0]))
	except:
		return 1
	return 0

cp_bld = Builder(action = cp_builder_fun)

def fix_env_dirs(env, proj = None):
	env_subdir = auxfun.get_env_subdir(env)
	env_pdfdocdir_intermediate = '.'
	env_pdfdocdir_out = os.path.join(auxfun.dir_doc_out, proj)
	env_bin = os.path.join(auxfun.dir_bin_base, env_subdir)
	env_lib = os.path.join(auxfun.dir_lib_base, env_subdir)
	env_inc = os.path.join(auxfun.dir_inc_base, proj)
	env.AppendUnique(CPPPATH = os.curdir)
	env.AppendUnique(CPPPATH = [auxfun.dir_inc_base])
	env.AppendUnique(LIBPATH = env_bin)
	env.AppendUnique(LIBPATH = [env_lib])
	env.Replace(INCDIR = env_inc)
	env.Replace(LIBDIR = env_lib)
	env.Replace(BINDIR = env_bin)
	env.Replace(PDFDOCDIR = env_pdfdocdir_intermediate)
	env.Replace(PDFDOCDIROUT = env_pdfdocdir_out)
	env['BUILDERS']['Cp_F'] = cp_bld

def append_ld(env, libflags = None, libpaths = None, libs = None):
	if libflags:
		env.AppendUnique(LINKFLAGS = libflags)
	if libpaths:
		env.AppendUnique(LIBPATH = libpaths)
	if libs:
		env.AppendUnique(LIBS = libs)

def strip_if_release(env, target):
	if auxfun.is_release_build(env) and env['STRIP_CMD']:
		 AddPostAction(target, env['STRIP_CMD'] + ' ' + str(target[0]))

def do_build_proj(env = None, proj = None, params = None, args = None):
	if params is None:
		return env

	sub_proj = auxfun.list_from_str_dict(params, 'sub_proj')
	cpp_vars = auxfun.list_from_str_dict(params, 'cpp_vars')
	inc_paths = auxfun.list_from_str_dict(params, 'inc_paths')
	add_cc_flg = auxfun.list_from_str_dict(params, 'add_cc_flg')
	cc_sources = auxfun.list_from_str_dict(params, 'cc_sources')
	out_lib_static = auxfun.list_from_str_dict(params, 'out_lib_static')
	lib_flags = auxfun.list_from_str_dict(params, 'lib_flags')
	lib_paths = auxfun.list_from_str_dict(params, 'lib_paths')
	libs = auxfun.list_from_str_dict(params, 'libs')
	add_link_flg = auxfun.list_from_str_dict(params, 'add_link_flg')
	units = auxfun.list_from_str_dict(params, 'units')
	out_lib_shared = auxfun.list_from_str_dict(params, 'out_lib_shared')
	out_bin = auxfun.list_from_str_dict(params, 'out_bin')
	pdfdocs = auxfun.list_from_str_dict(params, 'pdfdocs')
	export_cc_headers = auxfun.list_from_str_dict(params, 'export_cc_headers')

	if env:
		thisenv = env.Clone()
	else:
		thisenv = Environment()
	fix_env_dirs(thisenv, proj)

	if 'pkg_conf' in params:
		for i in params['pkg_conf']:
			thisenv.ParseConfig(params['pkg_conf'])

	if cpp_vars:
		thisenv.AppendUnique(CPPDEFINES = cpp_vars)

	if inc_paths:
		thisenv.AppendUnique(CPPPATH = inc_paths)

	if add_cc_flg:
		thisenv.MergeFlags(thisenv.ParseFlags(add_cc_flg))

	append_ld(thisenv, lib_flags, lib_paths, libs)

	if add_link_flg:
		thisenv.AppendUnique(LINKFLAGS = add_link_flg)

	if args:
		if args.get('projconf', '0') == '1' and auxfun.is_posix_plat(thisenv) and not thisenv.GetOption('clean'):
			conf = Configure(thisenv)
			required_libs = auxfun.list_from_str_dict(params, 'required_libs')
			if required_libs:
				for i in required_libs:
					if not conf.CheckLib(i):
						print 'Did not find library', i, 'exiting!'
						Exit(1)
			required_cc_headers = auxfun.list_from_str_dict(params, 'required_cc_headers')
			if required_cc_headers:
				for i in required_cc_headers:
					if not conf.CheckHeader(i):
						print 'Did not find C header file', i, 'exiting!'
						Exit(1)
			required_cxx_headers = auxfun.list_from_str_dict(params, 'required_cxx_headers')
			if required_cxx_headers:
				for i in required_cxx_headers:
					if not conf.CheckCXXHeader(i):
						print 'Did not find C++ header file', i, 'exiting!'
						Exit(1)
			required_funcs = auxfun.list_from_str_dict(params, 'required_funcs')
			if required_funcs:
				for i in required_funcs:
					if not conf.CheckFunc(i):
						print 'Did not find function', i, 'exiting!'
						Exit(1)
			thisenv = conf.Finish()

	obj = []
	objunit = {}
	objsopic = []
	if cc_sources:
		for i in cc_sources:
			if out_bin or units:
				o = thisenv.Object(i)
				obj.append(o)
				if units and i in units:
					objunit[i] = o
			if out_lib_shared or out_lib_static:
				o2 = thisenv.SharedObject(i)
				objsopic.append(o2)

	if units:
		if auxfun.is_linux_targetplat(thisenv) or auxfun.is_mac_targetplat(thisenv) or auxfun.is_windows_targetplat(thisenv):
			if not cpp_vars:
				cpp_vars_tmp = list()
			else:
				cpp_vars_tmp = list(cpp_vars)
			cpp_vars_tmp.append('T_UTST')
			thisenvtmp = thisenv.Clone()
			thisenvtmp.AppendUnique(CPPDEFINES = cpp_vars_tmp)
			for i in units:
				z = os.path.splitext(i)
				outunit = 'tst_' + proj + '_' + z[0]
				outunit = outunit + auxfun.get_exe_extension(thisenv)
				objnew = list(obj)
				if i in objunit:
					objnew.remove(objunit[i])
				o = thisenvtmp.Object(outunit, i)
				objnew.insert(0, o)
				target = thisenvtmp.Program(os.path.join(thisenv['BINDIR'], outunit), objnew)
				strip_if_release(thisenvtmp, target)

	if out_lib_static:
		for i in out_lib_static:
			target = thisenv.StaticLibrary(os.path.join(thisenv['LIBDIR'], i), objsopic)

	if out_lib_shared:
		for i in out_lib_shared:
			target = thisenv.SharedLibrary(os.path.join(thisenv['BINDIR'], i), cc_sources)
			strip_if_release(thisenv, target)

	if out_bin:
		for i in out_bin:
			target = thisenv.Program(os.path.join(thisenv['BINDIR'], i), obj)
			strip_if_release(thisenv, target)

	if pdfdocs:
		for i in pdfdocs:
			z = os.path.splitext(i)
			#target = thisenv.PDF(os.path.join(thisenv['PDFDOCDIR'], z[0]), i)
			suffix = '.pdf'
			if 'PDFSUFFIX' in env:
				if env['PDFSUFFIX']:
					suffix = env['PDFSUFFIX']
			f = z[0] + suffix
			thisenv.Cp_F(os.path.join(thisenv['PDFDOCDIR'], f), i)
			thisenv.Cp_F(os.path.join(thisenv['PDFDOCDIROUT'], f), f)

	if export_cc_headers:
		for i in export_cc_headers:
			thisenv.Cp_F(os.path.join(thisenv['INCDIR'], i), i)

	return thisenv

def install_dir(env, target_dir, source_dir):
	try:
		for f in os.listdir(source_dir):
			source = os.path.join(source_dir, f)
			target = os.path.join(target_dir, f)

			env.Alias("install", target)
			env.Command(target, source,
			[
			Copy("$TARGET", "$SOURCE"),
			#Chmod("$TARGET", 0664),
			])
	except:
		print 'ERROR: Install failed:', target_dir

def uninstall_dir(env, target_dir, phonyfile):
	try:
		if os.path.isdir(target_dir):
			env.Alias("uninstall", "uninstall-" + phonyfile)
			env.Command("uninstall-" + phonyfile, target_dir,
			[
			Delete("$SOURCE"),
			])
	except:
		print 'ERROR: Uninstall failed:', target_dir

def do_install(env):
	src = Dir(auxfun.get_bin_dir(env)).get_path()
	dst = os.path.join(auxfun.prefix, auxfun.prefix_bin, auxfun.get_env_subdir(env))
	install_dir(env, dst, src)
	src = Dir(auxfun.dir_doc_out).get_path()
	dst = os.path.join(auxfun.prefix, auxfun.prefix_doc)
	install_dir(env, dst, src)

def do_uninstall(env):
	i = 0
	dirname = os.path.join(auxfun.prefix, auxfun.prefix_bin, auxfun.get_env_subdir(env))
	uninstall_dir(env, dirname, '%d' % i)
	dirname = os.path.join(auxfun.prefix, auxfun.prefix_doc)
	if os.path.isdir(dirname):
		for f in os.listdir(dirname):
			i = i + 1
			uninstall_dir(env, os.path.join(dirname, f), '%d' % i)
