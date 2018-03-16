#!/bin/bash

# fips-check.sh
# This script checks the current revision of the code against the
# previous release of the FIPS code. While wolfSSL and wolfCrypt
# may be advancing, they must work correctly with the last tested
# copy of our FIPS approved code.
#
# This should check out all the approved versions. The command line
# option selects the version.
#
#     $ ./fips-check [version] [keep]
#
#     - version: linux (default), ios, android, windows, freertos, linux-ecc
#
#     - keep: (default off) XXX-fips-test temp dir around for inspection
#

function Usage() {
    printf '\n%s\n' "Usage: $0 [platform] [keep]"
    printf '%s\n\n' "Where \"platform\" is one of:"
    printf '\t%s\n' "linux (default)"
    printf '\t%s\n' "ios"
    printf '\t%s\n' "android"
    printf '\t%s\n' "windows"
    printf '\t%s\n' "freertos"
    printf '\t%s\n' "openrtos-3.9.2"
    printf '\t%s\n' "linux-ecc"
    printf '\t%s\n' "netbsd-selftest"
    printf '\t%s\n' "sgx"
    printf '\t%s\n' "netos-7.6"
    printf '\n%s\n\n' "Where \"keep\" means keep (default off) XXX-fips-test temp dir around for inspection"
    printf '%s\n' "EXAMPLE:"
    printf '%s\n' "---------------------------------"
    printf '%s\n' "./fips-check.sh windows keep"
    printf '%s\n\n' "---------------------------------"
}

LINUX_FIPS_VERSION=v3.2.6
LINUX_FIPS_REPO=git@github.com:wolfSSL/fips.git
LINUX_CTAO_VERSION=v3.2.6
LINUX_CTAO_REPO=git@github.com:cyassl/cyassl.git

LINUX_ECC_FIPS_VERSION=v3.10.3
LINUX_ECC_FIPS_REPO=git@github.com:wolfSSL/fips.git
LINUX_ECC_CTAO_VERSION=v3.2.6
LINUX_ECC_CTAO_REPO=git@github.com:cyassl/cyassl.git

IOS_FIPS_VERSION=v3.4.8a
IOS_FIPS_REPO=git@github.com:wolfSSL/fips.git
IOS_CTAO_VERSION=v3.4.8.fips
IOS_CTAO_REPO=git@github.com:cyassl/cyassl.git

ANDROID_FIPS_VERSION=v3.5.0
ANDROID_FIPS_REPO=git@github.com:wolfSSL/fips.git
ANDROID_CTAO_VERSION=v3.5.0
ANDROID_CTAO_REPO=git@github.com:cyassl/cyassl.git

WINDOWS_FIPS_VERSION=v3.6.6
WINDOWS_FIPS_REPO=git@github.com:wolfSSL/fips.git
WINDOWS_CTAO_VERSION=v3.6.6
WINDOWS_CTAO_REPO=git@github.com:cyassl/cyassl.git

FREERTOS_FIPS_VERSION=v3.6.1-FreeRTOS
FREERTOS_FIPS_REPO=git@github.com:wolfSSL/fips.git
FREERTOS_CTAO_VERSION=v3.6.1
FREERTOS_CTAO_REPO=git@github.com:cyassl/cyassl.git

OPENRTOS_3_9_2_FIPS_VERSION=v3.9.2-OpenRTOS
OPENRTOS_3_9_2_FIPS_REPO=git@github.com:wolfSSL/fips.git
OPENRTOS_3_9_2_CTAO_VERSION=v3.6.1
OPENRTOS_3_9_2_CTAO_REPO=git@github.com:cyassl/cyassl.git

#NOTE: Does not include the SGX examples yet, update version once fipsv2 is
#      finished and merge conflicts can be resolved. This will be tagged as
#      v3.12.4.sgx-examples
SGX_FIPS_VERSION=v3.6.6
SGX_FIPS_REPO=git@github.com/wolfSSL/fips.git
#NOTE: Waiting to be merged
#SGX_CTAO_VERSION=3.12.4
SGX_CTAO_REPO=git@github.com:cyassl/cyassl.git

NETOS_7_6_FIPS_VERSION=v3.12.4
NETOS_7_6_FIPS_REPO=git@github.com/wolfSSL/fips.git
#NETOS_7_6_CTAO_VERSION=3.12.4
NETOS_7_6_CTAO_REPO=git@github.com:cyassl/cyassl.git


FIPS_SRCS=( fips.c fips_test.c )
WC_MODS=( aes des3 sha sha256 sha512 rsa hmac random )
TEST_DIR=XXX-fips-test
WC_INC_PATH=cyassl/ctaocrypt
WC_SRC_PATH=ctaocrypt/src
CAVP_SELFTEST_ONLY="no"

# non-FIPS, CAVP only but pull in selftest
# will reset above variables below in platform switch
NETBSD_FIPS_VERSION=v3.14.2
NETBSD_FIPS_REPO=git@github.com:wolfssl/fips.git
NETBSD_CTAO_VERSION=v3.14.2
NETBSD_CTAO_REPO=git@github.com:wolfssl/wolfssl.git


if [ "x$1" == "x" ]; then PLATFORM="linux"; else PLATFORM=$1; fi

if [ "x$2" == "xkeep" ]; then KEEP="yes"; else KEEP="no"; fi

case $PLATFORM in
ios)
  FIPS_VERSION=$IOS_FIPS_VERSION
  FIPS_REPO=$IOS_FIPS_REPO
  CTAO_VERSION=$IOS_CTAO_VERSION
  CTAO_REPO=$IOS_CTAO_REPO
  ;;
android)
  FIPS_VERSION=$ANDROID_FIPS_VERSION
  FIPS_REPO=$ANDROID_FIPS_REPO
  CTAO_VERSION=$ANDROID_CTAO_VERSION
  CTAO_REPO=$ANDROID_CTAO_REPO
  ;;
windows)
  FIPS_VERSION=$WINDOWS_FIPS_VERSION
  FIPS_REPO=$WINDOWS_FIPS_REPO
  CTAO_VERSION=$WINDOWS_CTAO_VERSION
  CTAO_REPO=$WINDOWS_CTAO_REPO
  ;;
freertos)
  FIPS_VERSION=$FREERTOS_FIPS_VERSION
  FIPS_REPO=$FREERTOS_FIPS_REPO
  CTAO_VERSION=$FREERTOS_CTAO_VERSION
  CTAO_REPO=$FREERTOS_CTAO_REPO
  ;;
openrtos-3.9.2)
  FIPS_VERSION=$OPENRTOS_3_9_2_FIPS_VERSION
  FIPS_REPO=$OPENRTOS_3_9_2_FIPS_REPO
  CTAO_VERSION=$OPENRTOS_3_9_2_CTAO_VERSION
  CTAO_REPO=$OPENRTOS_3_9_2_CTAO_REPO
  FIPS_CONFLICTS=( aes hmac random sha256 )
  ;;
linux)
  FIPS_VERSION=$LINUX_FIPS_VERSION
  FIPS_REPO=$LINUX_FIPS_REPO
  CTAO_VERSION=$LINUX_CTAO_VERSION
  CTAO_REPO=$LINUX_CTAO_REPO
  ;;
linux-ecc)
  FIPS_VERSION=$LINUX_ECC_FIPS_VERSION
  FIPS_REPO=$LINUX_ECC_FIPS_REPO
  CTAO_VERSION=$LINUX_ECC_CTAO_VERSION
  CTAO_REPO=$LINUX_ECC_CTAO_REPO
  ;;
netbsd-selftest)
  FIPS_VERSION=$NETBSD_FIPS_VERSION
  FIPS_REPO=$NETBSD_FIPS_REPO
  CTAO_VERSION=$NETBSD_CTAO_VERSION
  CTAO_REPO=$NETBSD_CTAO_REPO
  FIPS_SRCS=( selftest.c )
  WC_MODS=( dh ecc rsa dsa aes sha sha256 sha512 hmac random )
  WC_INC_PATH=wolfssl/wolfcrypt
  WC_SRC_PATH=wolfcrypt/src
  CAVP_SELFTEST_ONLY="yes"
  ;;
sgx)
  FIPS_VERSION=$SGX_FIPS_VERSION
  FIPS_REPO=$SGX_FIPS_REPO
  CTAO_VERSION=$SGX_CTAO_VERSION
  CTAO_REPO=$SGX_CTAO_REPO
  ;;
netos-7.6)
  FIPS_VERSION=$NETOS_7_6_FIPS_VERSION
  FIPS_REPO=$NETOS_7_6_FIPS_REPO
  CTAO_VERSION=$NETOS_7_6_CTAO_VERSION
  CTAO_REPO=$NETOS_7_6_CTAO_REPO
  ;;
*)
  Usage
  exit 1
esac

git clone . $TEST_DIR
[ $? -ne 0 ] && echo "\n\nCouldn't duplicate current working directory.\n\n" && exit 1

pushd $TEST_DIR

# make a clone of the last FIPS release tag
git clone -b $CTAO_VERSION $CTAO_REPO old-tree
[ $? -ne 0 ] && echo "\n\nCouldn't checkout the FIPS release.\n\n" && exit 1

for MOD in ${WC_MODS[@]}
do
    cp old-tree/$WC_SRC_PATH/${MOD}.c $WC_SRC_PATH
    cp old-tree/$WC_INC_PATH/${MOD}.h $WC_INC_PATH
done

# The following is temporary. We are using random.c from a separate release
if [ "x$CAVP_SELFTEST_ONLY" == "xno" ];
then
    pushd old-tree
    git checkout v3.6.0
    popd
    cp old-tree/$WC_SRC_PATH/random.c $WC_SRC_PATH
    cp old-tree/$WC_INC_PATH/random.h $WC_INC_PATH
fi

# clone the FIPS repository
git clone -b $FIPS_VERSION $FIPS_REPO fips
[ $? -ne 0 ] && echo "\n\nCouldn't checkout the FIPS repository.\n\n" && exit 1

for SRC in ${FIPS_SRCS[@]}
do
    cp fips/$SRC $WC_SRC_PATH
done

# run the make test
./autogen.sh
if [ "x$CAVP_SELFTEST_ONLY" == "xyes" ];
then
    ./configure --enable-selftest
else
    ./configure --enable-fips
fi
make
[ $? -ne 0 ] && echo "\n\nMake failed. Debris left for analysis." && exit 1

if [ "x$CAVP_SELFTEST_ONLY" == "xno" ];
then
    NEWHASH=`./wolfcrypt/test/testwolfcrypt | sed -n 's/hash = \(.*\)/\1/p'`
    if [ -n "$NEWHASH" ]; then
        sed -i.bak "s/^\".*\";/\"${NEWHASH}\";/" $WC_SRC_PATH/fips_test.c
        make clean
    fi
fi

make test
[ $? -ne 0 ] && echo "\n\nTest failed. Debris left for analysis." && exit 1

if [ ${#FIPS_CONFLICTS[@]} -ne 0 ];
then
    echo "Due to the way this package is compiled by the customer duplicate"
    echo "source file names are an issue, renaming:"
    for FNAME in ${FIPS_CONFLICTS[@]}
    do
        echo "wolfcrypt/src/$FNAME.c to wolfcrypt/src/wc_$FNAME.c"
        mv ./wolfcrypt/src/$FNAME.c ./wolfcrypt/src/wc_$FNAME.c
    done
    echo "Confirming files were renamed..."
    ls -la ./wolfcrypt/src/wc_*.c
fi

# Clean up
popd
if [ "x$KEEP" == "xno" ];
then
    rm -rf $TEST_DIR
fi
