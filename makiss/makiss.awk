#!/usr/bin/awk -f

# TODO:
# - misleading warnings for annotations

function sh_cat_file(fname)
{
	fname=makiss_path "/" fname
	system (sh_test_file " " fname " " sh_and " " sh_cat " " fname " " sh_or " " sh_echo " '# missing " fname "'")
}

function sh_sed_replace_makis_file(fname)
{
	fname=makiss_path "/" fname
	system (sh_test_file " " fname " " sh_and " " sh_sed " \"s/_makis/" ENVIRON["MAKIS_DIR"] "/\" " fname " " sh_or " " sh_echo " '# missing " fname "'")
}

function raise_err(mesg)
{
	printf ("%d: \"%s\": ERROR: %s.\n", NR, $0, mesg) | sh_redir_to_stderr
	errcnt++
}

function join_ctx_path(ctxarr, ctxarrsiz)
{
	if (0==ctxarrsiz)
		return ""

	res=ctxarr[1]
	for (li=2; li<=ctxarrsiz; li++)
		res=res ctxsep ctxarr[li]

	return res
}

function cmp_ctx_paths(ctx1, ctx2)
{
	n1=split(ctx1, ac1, ctxsep)
	n2=split(ctx2, ac2, ctxsep)
	nn=n1<n2?n1:n2
	for (li2=1; li2<=nn; li2++)
		if (ac1[li2]!=ac2[li2])
			break;

	return li2-1
}

function push_to_ctx(str)
{
	if (rem)
		return

	if (def_mode==mode) {
		raise_err("Annotation outside of element scope")

		return
	}
	ann_cnt++
	isnot=0
	if (index($1, "NOT"))
		isnot=1
	if (1==isnot)
		str=ctxnot str
	if (""!=ctx)
		ctx=ctx ctxsep str
	else
		ctx=str
	if ("{"!=$2||($3&&1!=index($3, "!"))) {
		raise_err("Unexpected identifier(s) after '{'")

		return
	}
}

function pop_from_ctx()
{
	if (""!=ctx) {
		n=split(ctx, arr, ctxsep)
		delete arr[n]
		if (1==n) {
			ctx=""

			return 1
		}
		ctx=join_ctx_path(arr, n-1)

		return 1
	}

	return 0
}

function get_name()
{
	if ($4&&1!=index($4, "!"))
		raise_err("Single value expected")

	return $3
}

function begin_compound(str, arr, ind)
{
	if (rem)
		return 0

	elm_cnt++
	mode=str
	if ("="==$2)
		ind=0
	if ("{"==$3) {
		if (1==index($4, "!"))
			return ind
		else if ($4) {
			raise_err("Unexpected identifier(s) after '{'")

			return ind
		}
	} else if (NF>=3) {
		for (li3=3; li3<=NF; li3++) {
			if (1==index($li3, "!"))
				break;
			li3tmp=$li3
			if (match ($li3, "\\|[[:print:]]+\\|"))
				li3tmp=ENVIRON[substr ($li3, RSTART+1, RLENGTH-2)]
			arr[ind++]=li3tmp
		}
		mode=def_mode
	}

	return ind
}

function do_compound(arr, ind)
{
	s=$0
	sub(/^[ \t]+/, "", s)
	ss=s
	if (match (ss, "\\|[[:print:]]+\\|"))
		ss=ENVIRON[substr (s, RSTART+1, RLENGTH-2)]
	if (""!=ctx)
		ss=ctx ctxsep ss
	arr[ind++]=ss

	return ind
}

function end_compound()
{
	if (rem)
		return

	x=pop_from_ctx()
	if (!x&&def_mode==mode)
		raise_err("Illegal symbol")
	else if (!x)
		mode=def_mode
	if ($2&&1!=index($2, "!"))
		raise_err("Unexpected identifier(s) after '}'")
}

function indent(tabs)
{
	for (li4=1; li4<=tabs; li4++)
		printf ("\t")
}

function print_name(name, str)
{
	if ("None"==name)
		printf ("%s = %s\n", str, name)
	else
		printf ("%s = '%s'\n", str, name)
}

function print_compound(arr, ind, str)
{
	if (ind) {
		if (remove_duplicates) {
			for (i in arr)
				arrx[arr[i]]=1
			cnt=0
			for (i=0; i<ind; i++)
				if (1==arrx[arr[i]]) {
					arrx2[cnt++]=arr[i]
					arrx[arr[i]]=0
				}
			for (i=0; i<cnt; i++)
				arr[i]=arrx2[i]
			ind=cnt
		}

		found0=0
		found=0
		for (i=0; i<ind; i++) {
			n=split(arr[i], arr2, ctxsep)
			if (1==n)
				found0++
			else
				found++
		}
		printf ("params['%s'] = \"\"\"\n", str)
		if (found0) {
			for (i=0; i<ind; i++) {
				n=split(arr[i], arr2, ctxsep)
				if (n>1)
					continue
				printf ("\t%s\n", arr[i])
			}
		}
		printf ("\t\"\"\"\n")
		if (!found) {
			printf ("\n")

			return ind
		}

		prev_ctx=""
		curr_ctx=""
		prev_n=0
		for (i=0; i<ind; i++) {
			n=split(arr[i], arr2, ctxsep)
			if (1==n)
				continue
			curr_ctx=join_ctx_path(arr2, n-1)
			if (curr_ctx!=prev_ctx) {
				if (prev_n) {
					indent(prev_n)
					printf ("\"\"\"\n")
					prev_n=0
				}
				xx=cmp_ctx_paths(curr_ctx, prev_ctx)
				for (j=xx+1; j<n; j++) {
					indent(j-1)
					if (1==index(arr2[j], ctxnot)) {
						arr2[j]=substr(arr2[j], 2, length(arr2[j])-1)
						if (isroot)
							printf ("if not auxfun.%s(env):\n", arr2[j])
						else
							printf ("if not auxfun.%s(outenv):\n", arr2[j])
					} else
						if (isroot)
							printf ("if auxfun.%s(env):\n", arr2[j])
						else
							printf ("if auxfun.%s(outenv):\n", arr2[j])
				}
				indent(n-1)
				printf ("params['%s'] += \"\"\"\n", str)
				prev_n=n
			}
			indent(n)
			printf ("%s\n", arr2[n])
			prev_ctx=curr_ctx
		}
		if (prev_n) {
			indent(prev_n)
			printf ("\"\"\"\n")
			prev_n=0
		}
		printf ("\n")
	}

	return ind
}

BEGIN {
	proj_path="."
	parent="None"
	proj="."
	makiss_path="."
	isroot=0
	remove_duplicates=1

	sh_echo="echo"
	sh_cat="cat"
	sh_sed="sed"
	sh_test_file="test -f"
	sh_and="&&"
	sh_or="||"
	sh_redir_to_stderr=sh_cat " 1>&2"

	errcnt=0
	elm_cnt=0
	ann_cnt=0
	def_mode="flat"
	mode=def_mode
	ctx=""
	ctxsep=":"
	ctxnot="!"
	rem=0

	parent_str="parent"
	proj_str="proj"
	sub_proj_str="sub_proj"
	pkg_conf_str="pkg_conf"
	cpp_vars_str="cpp_vars"
	inc_paths_str="inc_paths"
	add_cc_flg_str="add_cc_flg"
	cc_sources_str="cc_sources"
	out_lib_static_str="out_lib_static"
	lib_flags_str="lib_flags"
	lib_paths_str="lib_paths"
	libs_str="libs"
	add_link_flg_str="add_link_flg"
	units_str="units"
	out_lib_shared_str="out_lib_shared"
	out_bin_str="out_bin"
	export_cc_headers_str="export_cc_headers"
	pdf_docs_str="pdfdocs"
	required_libs_str="required_libs"
	required_cc_headers_str="required_cc_headers"
	required_cxx_headers_str="required_cxx_headers"
	required_funcs_str="required_funcs"

	is_posix_plat_str="is_posix_plat"
	is_linux_plat_str="is_linux_plat"
	is_mac_plat_str="is_mac_plat"
	is_windows_plat_str="is_windows_plat"
	is_32bit_plat_str="is_32bit_plat"
	is_64bit_plat_str="is_64bit_plat"
	is_linux_targetplat_str="is_linux_targetplat"
	is_mac_targetplat_str="is_mac_targetplat"
	is_windows_targetplat_str="is_windows_targetplat"
	is_debug_build_str="is_debug_build"
	is_release_build_str="is_release_build"
	is_profile_build_str="is_profile_build"
	is_coverage_build_str="is_coverage_build"
	is_vc98_build_str="is_vc98_build"
	is_llvmgcc_build_str="is_llvmgcc_build"
}

# comments
/^\#/ {
	next
}

/^[ \t]*!/ {
	next
}

/^[ \t]*@REM \{/ {
	rem=1
	next
}

/^[ \t]*@MER \}/ {
	if (!rem)
		raise_err("Unexpected end of multi-line comment")

	rem=0
	next
}

# exit
/^[ \t]*END / {
	exit 0
}

# elements
/^[ \t]*PROJ = / {
	proj=get_name()
	next
}

/^[ \t]*REQUIRED_LIBS (=|\+=) / {
	required_libs_i=begin_compound(required_libs_str, required_libs, required_libs_i)
	next
}

/^[ \t]*REQUIRED_CC_HEADERS (=|\+=) / {
	required_cc_headers_i=begin_compound(required_cc_headers_str, required_cc_headers, required_cc_headers_i)
	next
}

/^[ \t]*REQUIRED_CXX_HEADERS (=|\+=) / {
	required_cxx_headers_i=begin_compound(required_cxx_headers_str, required_cxx_headers, required_cxx_headers_i)
	next
}

/^[ \t]*REQUIRED_FUNCS (=|\+=) / {
	required_funcs_i=begin_compound(required_funcs_str, required_funcs, required_funcs_i)
	next
}

/^[ \t]*SUB_PROJ (=|\+=) / {
	sub_proj_i=begin_compound(sub_proj_str, sub_proj, sub_proj_i)
	next
}

/^[ \t]*CC_SOURCES (=|\+=) / {
	cc_sources_i=begin_compound(cc_sources_str, cc_sources, cc_sources_i)
	next
}

/^[ \t]*PKG_CONF (=|\+=) / {
	pkg_conf_i=begin_compound(pkg_conf_str, pkg_conf, pkg_conf_i)
	next
}

/^[ \t]*ADD_CC_FLG (=|\+=) / {
	add_cc_flg_i=begin_compound(add_cc_flg_str, add_cc_flg, add_cc_flg_i)
	next
}

/^[ \t]*CPP_VARS (=|\+=) / {
	cpp_vars_i=begin_compound(cpp_vars_str, cpp_vars, cpp_vars_i)
	next
}

/^[ \t]*INC_PATHS (=|\+=) / {
	inc_paths_i=begin_compound(inc_paths_str, inc_paths, inc_paths_i)
	next
}

/^[ \t]*UNITS (=|\+=) / {
	units_i=begin_compound(units_str, units, units_i)
	next
}

/^[ \t]*OUT_LIB_STATIC (=|\+=) / {
	out_lib_static_i=begin_compound(out_lib_static_str, out_lib_static, out_lib_static_i)
	next
}

/^[ \t]*OUT_LIB_SHARED (=|\+=) / {
	out_lib_shared_i=begin_compound(out_lib_shared_str, out_lib_shared, out_lib_shared_i)
	next
}

/^[ \t]*OUT_BIN (=|\+=) / {
	out_bin_i=begin_compound(out_bin_str, out_bin, out_bin_i)
	next
}

/^[ \t]*ADD_LINK_FLG (=|\+=) / {
	add_link_flg_i=begin_compound(add_link_flg_str, add_link_flg, add_link_flg_i)
	next
}

/^[ \t]*LIB_FLAGS (=|\+=) / {
	lib_flags_i=begin_compound(lib_flags_str, lib_flags, lib_flags_i)
	next
}

/^[ \t]*LIB_PATHS (=|\+=) / {
	lib_paths_i=begin_compound(lib_paths_str, lib_paths, lib_paths_i)
	next
}

/^[ \t]*LIBS (=|\+=) / {
	libs_i=begin_compound(libs_str, libs, libs_i)
	next
}

/^[ \t]*EXPORT_CC_HEADERS (=|\+=) / {
	export_cc_headers_i=begin_compound(export_cc_headers_str, export_cc_headers, export_cc_headers_i)
	next
}

/^[ \t]*PDF_DOCS (=|\+=) / {
	pdf_docs_i=begin_compound(pdf_docs_str, pdf_docs, pdf_docs_i)
	next
}

# annotations
/^[ \t]*@(NOT_)?ON_POSIX_PLAT \{/ {
	push_to_ctx(is_posix_plat_str)
	next
}

/^[ \t]*@(NOT_)?ON_LINUX_PLAT \{/ {
	push_to_ctx(is_linux_plat_str)
	next
}

/^[ \t]*@(NOT_)?ON_MAC_PLAT \{/ {
	push_to_ctx(is_mac_plat_str)
	next
}

/^[ \t]*@(NOT_)?ON_WINDOWS_PLAT \{/ {
	push_to_ctx(is_windows_plat_str)
	next
}

/^[ \t]*@(NOT_)?ON_32BIT_ARCH \{/ {
	push_to_ctx(is_32bit_plat_str)
	next
}

/^[ \t]*@(NOT_)?ON_64BIT_ARCH \{/ {
	push_to_ctx(is_64bit_plat_str)
	next
}

/^[ \t]*@(NOT_)?ON_LINUX_TARGET \{/ {
	push_to_ctx(is_linux_targetplat_str)
	next
}

/^[ \t]*@(NOT_)?ON_MAC_TARGET \{/ {
	push_to_ctx(is_mac_targetplat_str)
	next
}

/^[ \t]*@(NOT_)?ON_WINDOWS_TARGET \{/ {
	push_to_ctx(is_windows_targetplat_str)
	next
}

/^[ \t]*@(NOT_)?ON_DEBUG_CONF \{/ {
	push_to_ctx(is_debug_build_str)
	next
}

/^[ \t]*@(NOT_)?ON_RELEASE_CONF \{/ {
	push_to_ctx(is_release_build_str)
	next
}

/^[ \t]*@(NOT_)?ON_PROFILE_CONF \{/ {
	push_to_ctx(is_profile_build_str)
	next
}

/^[ \t]*@(NOT_)?ON_COVERAGE_CONF \{/ {
	push_to_ctx(is_coverage_build_str)
	next
}

/^[ \t]*@(NOT_)?ON_VC98_BUILD \{/ {
	push_to_ctx(is_vc98_build_str)
	next
}

/^[ \t]*@(NOT_)?ON_LLVMGCC_BUILD \{/ {
	push_to_ctx(is_llvmgcc_build_str)
	next
}

# closing brace
/^[ \t]*\}/ {
	end_compound()
	next
}

# rest non-empty
NF {
	if (rem)
		next
	else if (required_libs_str==mode)
		required_libs_i=do_compound(required_libs, required_libs_i)
	else if (required_cc_headers_str==mode)
		required_cc_headers_i=do_compound(required_cc_headers, required_cc_headers_i)
	else if (required_cxx_headers_str==mode)
		required_cxx_headers_i=do_compound(required_cxx_headers, required_cxx_headers_i)
	else if (required_funcs_str==mode)
		required_funcs_i=do_compound(required_funcs, required_funcs_i)
	else if (sub_proj_str==mode)
		sub_proj_i=do_compound(sub_proj, sub_proj_i)
	else if (cc_sources_str==mode)
		cc_sources_i=do_compound(cc_sources, cc_sources_i)
	else if (pkg_conf_str==mode)
		pkg_conf_i=do_compound(pkg_conf, pkg_conf_i)
	else if (add_cc_flg_str==mode)
		add_cc_flg_i=do_compound(add_cc_flg, add_cc_flg_i)
	else if (cpp_vars_str==mode)
		cpp_vars_i=do_compound(cpp_vars, cpp_vars_i)
	else if (inc_paths_str==mode)
		inc_paths_i=do_compound(inc_paths, inc_paths_i)
	else if (units_str==mode)
		units_i=do_compound(units, units_i)
	else if (out_lib_static_str==mode)
		out_lib_static_i=do_compound(out_lib_static, out_lib_static_i)
	else if (out_lib_shared_str==mode)
		out_lib_shared_i=do_compound(out_lib_shared, out_lib_shared_i)
	else if (out_bin_str==mode)
		out_bin_i=do_compound(out_bin, out_bin_i)
	else if (add_link_flg_str==mode)
		add_link_flg_i=do_compound(add_link_flg, add_link_flg_i)
	else if (lib_flags_str==mode)
		lib_flags_i=do_compound(lib_flags, lib_flags_i)
	else if (lib_paths_str==mode)
		lib_paths_i=do_compound(lib_paths, lib_paths_i)
	else if (libs_str==mode)
		libs_i=do_compound(libs, libs_i)
	else if (export_cc_headers_str==mode)
		export_cc_headers_i=do_compound(export_cc_headers, export_cc_headers_i)
	else if (pdf_docs_str==mode)
		pdf_docs_i=do_compound(pdf_docs, pdf_docs_i)
	else
		raise_err("Unknown identifier")
}

END {
	if (errcnt) {
		printf ("%d errors.\n", errcnt) | sh_redir_to_stderr
		exit 1
	}

	printf ("#!/usr/bin/env python\n")
	printf ("\n")
	print "#", proj_path, " (from: " FILENAME " )"
	printf ("\n\n")
	print_name(parent, parent_str)
	print_name(proj, proj_str)
	printf ("\n\n")

	if (!elm_cnt)
		exit 0

	if (isroot)
		sh_sed_replace_makis_file("cons.txt")
	else
		sh_sed_replace_makis_file("prologue.txt")
	printf ("\n")
	print "params = {}\n"
	required_libs_i=print_compound(required_libs, required_libs_i, required_libs_str)
	required_cc_headers_i=print_compound(required_cc_headers, required_cc_headers_i, required_cc_headers_str)
	required_cxx_headers_i=print_compound(required_cxx_headers, required_cxx_headers_i, required_cxx_headers_str)
	required_funcs_i=print_compound(required_funcs, required_funcs_i, required_funcs_str)
	sub_proj_i=print_compound(sub_proj, sub_proj_i, sub_proj_str)
	cc_sources_i=print_compound(cc_sources, cc_sources_i, cc_sources_str)
	pkg_conf_i=print_compound(pkg_conf, pkg_conf_i, pkg_conf_str)
	add_cc_flg_i=print_compound(add_cc_flg, add_cc_flg_i, add_cc_flg_str)
	cpp_vars_i=print_compound(cpp_vars, cpp_vars_i, cpp_vars_str)
	inc_paths_i=print_compound(inc_paths, inc_paths_i, inc_paths_str)
	units_i=print_compound(units, units_i, units_str)
	out_lib_static_i=print_compound(out_lib_static, out_lib_static_i, out_lib_static_str)
	out_lib_shared_i=print_compound(out_lib_shared, out_lib_shared_i, out_lib_shared_str)
	out_bin_i=print_compound(out_bin, out_bin_i, out_bin_str)
	add_link_flg_i=print_compound(add_link_flg, add_link_flg_i, add_link_flg_str)
	lib_flags_i=print_compound(lib_flags, lib_flags_i, lib_flags_str)
	lib_paths_i=print_compound(lib_paths, lib_paths_i, lib_paths_str)
	libs_i=print_compound(libs, libs_i, libs_str)
	export_cc_headers_i=print_compound(export_cc_headers, export_cc_headers_i, export_cc_headers_str)
	pdf_docs_i=print_compound(pdf_docs, pdf_docs_i, pdf_docs_str)
	if (isroot)
		sh_sed_replace_makis_file("dest.txt")
	else
		sh_sed_replace_makis_file("epilogue.txt")
}
