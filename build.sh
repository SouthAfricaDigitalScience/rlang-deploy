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
SOURCE_FILE=${NAME}-${VERSION}.tar.gz
mkdir -p ${WORKSPACE}
mkdir -p ${SRC_DIR}
mkdir -p ${SOFT_DIR}

#  Download the source file

if [ ! -e ${SRC_DIR}/${SOURCE_FILE}.lock ] && [ ! -s ${SRC_DIR}/${SOURCE_FILE} ] ; then
  touch  ${SRC_DIR}/${SOURCE_FILE}.lock
  echo "seems like this is the first build - let's geet the source"
  wget http://cran.mirror.ac.za/src/base/R-3/${NAME}-${VERSION}.tar.gz -O ${SRC_DIR}/${SOURCE_FILE}
  echo "releasing lock"
  rm -v ${SRC_DIR}/${SOURCE_FILE}.lock
elif [ -e ${SRC_DIR}/${SOURCE_FILE}.lock ] ; then
  # Someone else has the file, wait till it's released
  while [ -e ${SRC_DIR}/${SOURCE_FILE}.lock ] ; do
    echo " There seems to be a download currently under way, will check again in 5 sec"
    sleep 5
  done
else
  echo "continuing from previous builds, using source at " ${SRC_DIR}/${SOURCE_FILE}
fi
tar xfz  ${SRC_DIR}/${SOURCE_FILE} -C ${WORKSPACE} --skip-old-files
mkdir -p ${WORKSPACE}/${NAME}-${VERSION}/build-${BUILD_NUMBER}
cd ${WORKSPACE}/${NAME}-${VERSION}/tools

# HT https://stat.ethz.ch/pipermail/r-devel/2016-May/072777.html
./rsync-recommended
cd ${WORKSPACE}/${NAME}-${VERSION}/build-${BUILD_NUMBER}

export CPPFLAGS="-I${BZLIB_DIR}/include \
-I${XZ_DIR}/include \
-I${PCRE2_DIR}/include \
-I${READLINE_DIR}/include  \
-I${NCURSES_DIR}/include \
-I${ZLIB_DIR}/include \
-I${LIBPNG_DIR}/include  \
-I${JPEG_DIR}/include \
-I${ICU_DIR}/include \
-L${OPENBLAS_DIR}/lib \
-L${LAPACK_DIR}/lib"
export LDFLAGS="-L${JPEG_DIR}/lib \
-L${BZLIB_DIR}/lib \
-L${XZ_DIR}/lib \
-L${READLINE_DIR}/lib \
-L${NCURSES_DIR}/lib \
-L${PCRE2_DIR}/lib \
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
--with-readline \
--with-libpng \
--with-jpeglib \
--with-x=no \
--with-blas \
--with-lapack \
--with-recommended-packages

make
make all
