#!/bin/bash

# in Pictures/

# custom wallpaper to copy
# to hyprland install dir
PIC_WALLPAPER='wallpaper.png'

HOOK_SCRIPT_DIR='/etc/portage/hook'
HOOK_PKG_DIR='/etc/portage/package.hook'

# in Downloads/
# in Scripts/

# returns true if wrappper and hooks
# enabled, false if overriden or disabled
ewrap_hook_enabled() {
	# ensure wrapper enabled
	if ! [ "${EWRAP_ENABLE}" = '1' ]
	then
		# wrapper not enabled
		return 1
	fi	
	# check if this packages hooks
	# are disabled by the user
	if echo "${EWRAP_DISABLE_HOOKS}" | grep -qE "${CATEGORY}/${PN}|${PN}"
	then
		# hook disabled for this package
		return 1
	fi
	# hooks are enabled
	return 0
}

# ensures hook files/directories exist
ewrap_hook_setup() {
	if [ -d "${HOOK_SCRIPT_DIR}" ] && [ -d "${HOOK_PKG_DIR}" ]
	then
		# hook files/directories already created
		return 0
	fi
	# hooks cannot be used, directories not found
	return 1
}

# prototype custom hook function,
# takes 'portage hook function' as
# an argument (e.g. pre_pkg_setup)
ewrap_hook_discover() {
	# ensure hook setup defined
	if ! ewrap_hook_setup
	then
		 # hook directories not set up,
		 # disable for full run
		 EWRAP_ENABLE=
		 return
	fi
	# ensure header value is provided
	if [ $# -eq 0 ]; then return; fi
	local hdr="#$1"
	local hooks=()
	local pkgmatch="${CATEGORY}/${PN}|${PN}" 
	
	# find all hooks!
	for pkghook in $(find "${HOOK_PKG_DIR}" -type f)
	do
		# parse each line in package.hook/ file
		while read -r line
		do
			# check if line applies to this pkg
			if [ -z "$line" ] || ! echo "$line" | grep -qE "$pkgmatch"
			then
				# does not apply, next line
				continue
			fi
			# trim package name from line as well as
			# sanitize input, no shell injection allowed >:(
			local h=(${line##*${PN} })
			# if echo "${h[@]}" | grep -qE '\)|\$'; then continue; fi
			# verify all hooks
			for hookscript in ${h[@]}
			do
				# add .sh and ensure it exists
				hookscript="${hookscript%%.sh}.sh"
				if ! [ -f "${HOOK_SCRIPT_DIR}/$hookscript" ]
				then
					# hook script not found!
					ewarn "Could not find $hookname required by ${CATEGORY}/${PN}."
					continue
				elif ! [ "$(cat "${HOOK_SCRIPT_DIR}/$hookscript" | head -n1)" = "$hdr" ]
				    then continue; fi
				hooks=("${HOOK_SCRIPT_DIR}/$hookscript" ${hooks[@]})
			done
		done <<< "$(cat $pkghook)"
	done

	echo ${hooks[@]}
}

ewrap_hook() {
	# find all hooks for this pkg
	local hooks=($(ewrap_hook_discover $1))
	if [ -z "${hooks[@]}" ]
	then
		# nothing to do
		return
	fi	
	for h in ${hooks[@]}
	do
		echo ">>> Executing hook \"$h\""
		. "$h"
	done
}

#
# Portage HOOK definitions:
#   * See: 'https://wiki.gentoo.org/wiki//etc/portage/bashrc#Phase_names'
#     for more details regarding portage hooks
#

pre_pkg_setup() { ewrap_hook pre_pkg_setup ; }
post_pkg_setup() { ewrap_hook post_pkg_setup ; }

pre_src_unpack() { ewrap_hook pre_src_unpack ; }
post_src_unpack() { ewrap_hook post_src_unpack ; }

pre_src_prepare() { ewrap_hook pre_src_prepare ; }
post_src_prepare() { ewrap_hook post_src_prepare ; }

pre_src_configure() { ewrap_hook pre_src_configure ; }
post_src_configure() { ewrap_hook post_src_configure ; }

pre_src_compile() { ewrap_hook pre_src_compile ; }
post_src_compile() { ewrap_hook post_src_compile ; }

pre_src_install() { ewrap_hook pre_src_install ; }
post_src_install() { ewrap_hook post_src_install ; }

pre_pkg_preinst() { ewrap_hook pre_pkg_preinst ; }
post_pkg_preinst() { ewrap_hook post_pkg_preinst ; }

pre_pkg_prerm() { ewrap_hook pre_pkg_prerm ; }
post_pkg_prerm() { ewrap_hook post_pkg_prerm ; }

pre_pkg_postrm() { ewrap_hook pre_pkg_postrm ; }
post_pkg_postrm() { ewrap_hook post_pkg_postrm ; }

pre_pkg_postinst() { ewrap_hook pre_pkg_postinst ; }
post_pkg_postinst() { ewrap_hook post_pkg_postinst ; }
