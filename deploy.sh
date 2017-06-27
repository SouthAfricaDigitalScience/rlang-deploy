#!/bin/bash -e
# this should be run after check-build finishes.
. /etc/profile.d/modules.sh
echo ${SOFT_DIR}
module add deploy
module add  gcc/5.4.0
module add openblas/0.2.15-gcc-5.4.0
module add lapack/3.6.0-gcc-5.4.0
module add jdk/8u66
module add ncurses
module add readline
module  add  bzip2
module add  xz
echo ${SOFT_DIR}
cd ${WORKSPACE}/${NAME}-${VERSION}/build-${BUILD_NUMBER}
echo "All tests have passed, will now build into ${SOFT_DIR}"
CFLAGS="${CFLAGS} -I${BZLIB_DIR}/include -I${XZ_DIR}/include" \
LDFLAGS="-L${BZLIB_DIR}/lib -L${XZ_DIR}/lib -llzma" \
../configure \
--build=x86_64-pc-linux-gnu \
--host=x86_64-pc-linux-gnu \
--target=x86_64-pc-linux-gnu \
--prefix=${SOFT_DIR} \
--enable-static \
--enable-shared \
--with-readline=no \
--with-x=no \
--with-blas \
--with-lapack \
--without-recommended-packages

make
make install
echo "Creating the modules file directory ${LIBRARIES}"
mkdir -p ${LIBRARIES}/${NAME}
(
cat <<MODULE_FILE
#%Module1.0
## $NAME modulefile
##
proc ModulesHelp { } {
    puts stderr "       This module does nothing but alert the user"
    puts stderr "       that the [module-info name] module is not available"
}

module-whatis   "$NAME $VERSION : See https://github.com/SouthAfricaDigitalScience/R_LANG-deploy"
setenv R_LANG_VERSION       $VERSION
setenv R_LANG_DIR           $::env(CVMFS_DIR)/$::env(SITE)/$::env(OS)/$::env(ARCH)/$NAME/$VERSION
prepend-path LD_LIBRARY_PATH   $::env(R_LANG_DIR)/lib
prepend-path LDFLAGS           "-L$::env(R_LANG_DIR)/lib"
MODULE_FILE
) > ${LIBRARIES}/${NAME}/${VERSION}
