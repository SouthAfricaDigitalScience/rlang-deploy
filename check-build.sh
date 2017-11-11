#!/bin/bash -e
. /etc/profile.d/modules.sh
module add ci
module add gcc/5.4.0
module add openblas/0.2.15-gcc-5.4.0
module add lapack/3.6.0-gcc-5.4.0
module add jdk/8u66
module add ncurses
module add readline
module add bzip2
module add xz
module add openssl/1.0.2j
module add curl
module add pcre2
module add zlib
module add icu/59_1-gcc-5.4.0
module add jpeg/9b
module add libpng/1.6.27
cd ${WORKSPACE}/${NAME}-${VERSION}/build-${BUILD_NUMBER}
make check

echo $?

make install
mkdir -p ${REPO_DIR}
mkdir -p modules
(
cat <<MODULE_FILE
#%Module1.0
## $NAME modulefile
##
proc ModulesHelp { } {
    puts stderr "       This module does nothing but alert the user"
    puts stderr "       that the [module-info name] module is not available"
}

module-whatis   "$NAME $VERSION."
setenv       R_LANG_VERSION       $VERSION
setenv       R_LANG_DIR           /data/ci-build/$::env(SITE)/$::env(OS)/$::env(ARCH)/$NAME/$VERSION
prepend-path LD_LIBRARY_PATH   $::env(R_LANG_DIR)/lib
prepend-path PATH              $::ev(R_LANG_DIR)/bin
MODULE_FILE
) > modules/$VERSION

mkdir -p ${LIBRARIES}/${NAME}
cp modules/$VERSION ${LIBRARIES}/${NAME}

# check the module
echo "checking the module"
module add ${NAME}/${VERSION}
which R