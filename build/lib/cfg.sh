#!/bin/sh

# This library takes a set of configuration parameters
# and builds the configuration variables used elsewhere
# in the build system.

# Configuration variables which need to be set

CFGVARS="CFGNAME BUILDNAME TARGET TARGET_ARCH LOCAL_DIRS X_BUILD_BASE_CFG X_PORTBUILD_PLATFORM"
UBNT_VARS="UBNT_ARCH UBNT_VERSION"

# TARGET_CPUTYPE doesn't have to be set for i386, amd64, etc.

DOEXIT="NO"

for i in ${CFGVARS}; do
	eval _value=\$${i}
	if [ "x${_value}" = "x" ]; then
		echo "ERROR: ${i} needs to be set in the configuration file."
		DOEXIT="YES"
	fi
done

for i in ${X_LOCAL_CFGVARS}; do
	eval _value=\$${i}
	if [ "x${_value}" = "x" ]; then
		echo "ERROR: ${i} needs to be set in the configuration file."
		DOEXIT="YES"
	fi
done


if [ "x${DOEXIT}" = "xYES" ]; then
	echo "ERROR: fatal errors found; exiting."
	exit 127
fi

# BUILD_FLAGS is set by the environment
PARALLEL_FLAGS=${PARALLEL_FLAGS:="-j2"}
BUILD_FLAGS=${BUILD_FLAGS:="NO_CLEAN=1 ${PARALLEL_FLAGS}"}

# CFGNAME
# BUILDNAME
# UBNT_ARCH
# UBNT_VERSION
# KERNCONF
# TARGET
# TARGET_ARCH
# TARGET_CPUTYPE
# BUILD_FLAGS
# LOCAL_DIRS

# X_KERNSUFFIX - which suffix to install the kernel file in ${X_TFTPBOOT}
# with.  Defaults to KERNCONF but in some instances we'll want
# to force a different name (eg MALTA for both little and big endian
# is the same kernel name, so it builds and installs under MALTA.)
X_KERNSUFFIX=${X_KERNSUFFIX:="${KERNCONF}"}

# X_MAKEFS_ENDIAN - what endian-ness should the makefs FFS be?
X_MAKEFS_ENDIAN=${X_MAKEFS_ENDIAN:="be"}

# X_MAKEFS_FLAGS - what flags to pass to makefs when building the MFS image
X_MAKEFS_FLAGS="version=1,bsize=4096,fsize=512"
if [ "x" != "x${X_MAKEFS_FLAGS_EXT}" ]; then
	X_MAKEFS_FLAGS="${X_MAKEFS_FLAGS},${X_MAKEFS_FLAGS_EXT}"
fi

# X_MAKEFS_FULL_FLAGS - what flags to pass to makefs when building the full image
X_MAKEFS_FULL_FLAGS="version=2"

# X_FSSIZE - how big to make the makefs?
X_FSSIZE=${X_FSSIZE:="31457280"}

# X_FULL_FSSIZE - how big to make the full image?
X_FULL_FSSIZE=${X_FULL_FSSIZE:="1084741824"}

# X_FULL_FSINODES - how many inodes to have free?
X_FULL_FSINODES=${X_FULL_FSINODES:="1048576"}

# Where to install things for TFTPBOOT.
X_TFTPBOOT=${X_TFTPBOOT:="${BASE_DIR}/tftpboot"}

# Variables defined by this script

# X_MAKEOBJDIRPREFIX - where to place object files
X_MAKEOBJDIRPREFIX="${BASE_DIR}/obj/${BUILDNAME}/" ; export X_MAKEOBJDIRPREFIX

# X_DESTDIR - where to place the install root 
X_DESTDIR="${BASE_DIR}/root/${BUILDNAME}"

# The default list of operations to run when doing a build
# XXX eventually these should be required, not optional
X_BUILD_BUILD_THINGS_DEFAULTS=${X_BUILD_BUILD_THINGS_DEFAULTS:="buildworld buildkernel installworld installkernel distribution"}
X_BUILD_BUILD_IMG_DEFAULTS=${X_BUILD_BUILD_IMG_DEFAULTS:=""}
# .. and for cleaning
X_BUILD_CLEANIMG_DEFAULTS=${X_BUILD_CLEANIMG_DEFAULTS:=""}
X_BUILD_CLEANALL_DEFAULTS=${X_BUILD_CLEANALL_DEFAULTS:="cleanroot cleanobj"}

# Variables that need to be defined by one of the build scripts
# but I haven't decided whether they're configured by the user
# or automatically generated.

X_IMGBASE="${BASE_DIR}/img/"

# X_FSIMAGE
X_FSIMAGE="${X_IMGBASE}/mfsroot-${CFGNAME}.img"

# X_FULL_FSIMAGE
X_FULL_FSIMAGE="${X_IMGBASE}/fullroot-${CFGNAME}.img"

# X_FSIMAGE_SUFFIX
X_FSIMAGE_SUFFIX=${X_FSIMAGE_SUFFIX:=".uzip"}

# X_FSIMAGE_CMD
X_FSIMAGE_CMD=${X_FSIMAGE_CMD:="mkuzip"}

# X_FSIMAGE_ARGS
X_FSIMAGE_ARGS=${X_FSIMAGE_ARGS:="-s 16384"}

# X_STAGING_FSROOT
X_STAGING_FSROOT="${BASE_DIR}/mfsroot/${CFGNAME}"

# X_STAGING_METALOG
X_STAGING_METALOG="${BASE_DIR}/mfsroot/METALOG.${CFGNAME}"
X_STAGING_METALOG_MFSROOT="${BASE_DIR}/mfsroot/METALOG.${CFGNAME}.mfsroot"
X_STAGING_METALOG_TMP="${BASE_DIR}/mfsroot/METALOG.${CFGNAME}.tmp"

# X_STAGING_TMPDIR
X_STAGING_TMPDIR="${BASE_DIR}/tmp/${CFGNAME}"

# X_KERNEL
X_TFTPBOOT_KERNEL="${X_TFTPBOOT}/kernel.${KERNCONF}"
X_KERNEL="${X_DESTDIR}/boot/kernel.${KERNCONF}/kernel"

# Configuration filesystem image
X_CFGFS="${BASE_DIR}/cfgfs-${CFGNAME}.img"

X_UBOOT_KERNROOTIMG=${X_UBOOT_KERNROOTIMG:="NO"}
TPLINK_SKIP_ROOTFS=${TPLINK_SKIP_ROOTFS:="NO"}
X_UBOOT_AIRSTATION_PREAMBLE=${X_UBOOT_AIRSTATION_PREAMBLE:="NO"}

# Defaults!
X_FSIMAGE_CMD=${X_FSIMAGE_CMD:="mkuzip"}
X_FSIMAGE_ARGS=${X_FSIMAGE_ARGS:="-s 16384"}
X_FSIMAGE_SUFFIX=${X_FSIMAGE_SUFFIX:=".uzip"}
X_ROOTFS_DEV=${X_ROOTFS_DEV:="/dev/da0"}

# Configuration file template defaults
X_CFG_DEFAULT_ETHER=${X_CFG_DEFAULT_ETHER:="arge0"}
X_CFG_DEFAULT_HOSTNAME=${X_CFG_DEFAULT_HOSTNAME:="freebsd-wifi"}
X_CFG_DEFAULT_TTY=${X_CFG_DEFAULT_TTY:="ttyu0"}

#
# Package building
#
# Package building location
X_PACKAGE_BUILD_DIR="${BASE_DIR}/pkgroot/${CFGNAME}"
X_PACKAGE_DISTFILE_DIR="${BASE_DIR}/distfiles/"

# Port-build base
#X_PORTBUILD_DIR=${SCRIPT_DIR}/../../port-build/ ; export X_PORTBUILD_DIR
X_PACKAGE_ROOTDIR="${X_DESTDIR}"
X_PACKAGE_SUBDIR="${TARGET}.${TARGET_ARCH}"
X_PACKAGE_BUILDROOT_DIR="${BASE_DIR}/pkgbuild/${X_BUILD_BASE_CFG}/${X_PACKAGE_SUBDIR}"
X_PACKAGE_PKGDIR="${BASE_DIR}/pkgdir/${X_BUILD_BASE_CFG}"
X_PACKAGE_ARCHSTR=""
