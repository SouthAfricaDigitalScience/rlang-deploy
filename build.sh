#!/bin/bash -e
. /etc/profile.d/modules.sh

module add ci
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
cd ${WORKSPACE}/${NAME}-${VERSION}/build-${BUILD_NUMBER}
export CFLAGS="-I${BZLIB_DIR}/include -I${XZ_DIR}/include -I${PCRE_DIR}/include -I${READLINE_DIR}/include  -I${NCURSES_DIR}/include"
export CPPFLAGS="-I${BZLIB_DIR}/include -I${XZ_DIR}/include -I${PCRE_DIR}/include -I${READLINE_DIR}/include  -I${NCURSES_DIR}/include"
export LDFLAGS="-L${BZLIB_DIR}/lib -L${XZ_DIR}/lib -L${READLINE_DIR}/lib -L${NCURSES_DIR}/lib -L${PCRE_DIR}/lib -lbz2 -llzma -lreadline -lncurses"
export BLAS_LIBS="-L${OPENBLAS_DIR}/lib -lblas"
export LAPACK_LIBS="-L${LAPACK_DIR}/lib -llapack.so.3"
../configure \
--prefix=${SOFT_DIR} \
--enable-static \
--enable-shared \
--with-readline=yes \
--with-x=no \
--with-blas \
--with-lapack \
--without-recommended-packages

make
make all
