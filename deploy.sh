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
module add bzip2
module  add xz
module add openssl/1.0.2j
module  add curl
module  add pcre
module add zlib

echo ${SOFT_DIR}
cd ${WORKSPACE}/${NAME}-${VERSION}/build-${BUILD_NUMBER}
echo "tests have passed - building into ${SOFT_DIR}"
rm -rf *
export CPPFLAGS="-I${BZLIB_DIR}/include \
-I${XZ_DIR}/include \
-I${PCRE_DIR}/include \
-I${READLINE_DIR}/include  \
-I${NCURSES_DIR}/include \
-I${ZLIB_DIR}/include \
-I${LIBPNG_DIR}/include  \
-I${JPEG_DIR}/include \
-I${ICU_DIR}/include"
export LDFLAGS="-L${JPEG_DIR}/lib \
-L${BZLIB_DIR}/lib \
-L${XZ_DIR}/lib \
-L${READLINE_DIR}/lib \
-L${NCURSES_DIR}/lib \
-L${PCRE_DIR}/lib \
-L${ZLIB_DIR}/lib \
-L${LIBPNG_DIR}/lib \
-L${JPEG_DIR}/lib \
-L${ICU_DIR}/lib \
-L${OPENBLAS_DIR}/lib \
-L${LAPACK_DIR}/lib \
-lz -lbz2 -llzma -lreadline -lncurses -lpng -ljpeg -licudata -licuio -licui18n -licutu"
export BLAS_LIBS="openblas.so"
export LAPACK_LIBS="lapack.so"
../configure \
--prefix=${SOFT_DIR} \
--enable-static \
--enable-shared \
--with-readline=yes \
--with-libpng=yes \
--with-jpeglib=yes \
--with-x=no \
--with-blas \
--with-lapack \
--with-recommended-packages

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

module-whatis   "$NAME $VERSION : See https://github.com/SouthAfricaDigitalScience/rlang-deploy"
setenv R_LANG_VERSION       $VERSION
setenv R_LANG_DIR           $::env(CVMFS_DIR)/$::env(SITE)/$::env(OS)/$::env(ARCH)/$NAME/$VERSION
prepend-path LD_LIBRARY_PATH   $::env(R_LANG_DIR)/lib
prepend-path LDFLAGS           "-L$::env(R_LANG_DIR)/lib"
MODULE_FILE
) > ${LIBRARIES}/${NAME}/${VERSION}

module  avail ${NAME}

module add ${NAME}/${VERSION}
