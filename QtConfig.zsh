#!/bin/zsh
#

### Cross-Compilation HOST Settings
HOST_DIR=$(realpath $(dirname $0))
HOST_MACHINE=$(uname -m)


### Cross-compilation TARGET Settings
SYSROOT=${HOST_DIR}/rootfs


### Qt sources
QT_PREFIX=qt5
SOURCE_DIR=${HOST_DIR}/${QT_PREFIX}
QT_GIT_VERSION=$(cd $SOURCE_DIR && git status --porcelain=v2 --branch | grep -P "branch.head \K.*" -o)


### Top-level installation directories
#
# -prefix <dir> ...... Deployment directory -- from the target device point of view
#                      [/usr/local/Qt-$QT_VERSION]
# -extprefix <dir> ... Installation directory -- from the host machine point of view
#                      [SYSROOT/PREFIX]
# -hostprefix [dir] .. Installation directory for build tools running on the host machine.
#                      [EXTPREFIX]

HOST_PREFIX=${HOST_DIR}/${QT_PREFIX}-${HOST_MACHINE}-tools-${QT_GIT_VERSION}


### Library type (static or shared)
LIBTYPE=-shared
# LIBTYPE=-static


### Qt Examples

EXAMPLES=(-no-compile-examples)
#EXAMPLES=(-make examples -compile-examples)


### Where to build

BUILD_DIR=${HOST_DIR}/${QT_PREFIX}-build-${QT_GIT_VERSION}

mkdir -p ${BUILD_DIR}
cd ${BUILD_DIR} || exit 1


### Calling `configure`

${SOURCE_DIR}/configure \
\
      -opensource -confirm-license \
      -release \
      ${LIBTYPE} \
      -platform  linux-g++ \
      -device    linux-arm-generic-g++ \
      -device-option CROSS_COMPILE=arm-linux-gnueabi- \
      -c++std    c++14 \
\
      -sysroot   ${SYSROOT} \
      -hostprefix ${HOST_PREFIX} \
\
      -make libs \
\
      ${EXAMPLES} \
\
      -no-feature-concurrent \
      -no-dbus \
      -no-feature-gui \
         -feature-network \
      -no-feature-sql \
      -no-feature-testlib \
      -no-feature-widgets \
      -no-feature-xml \
      -no-opengl \
         -openssl \
      -no-pch \
\
      -skip      qt3d \
      -skip      qtactiveqt \
      -skip      qtandroidextras \
      -skip      qtcharts \
      -skip      qtconnectivity \
      -skip      qtdatavis3d \
      -skip      qtdeclarative \
      -skip      qtdoc \
      -skip      qtgamepad \
      -skip      qtgraphicaleffects \
      -skip      qtimageformats \
      -skip      qtlocation \
      -skip      qtlottie \
      -skip      qtmacextras \
      -skip      qtmultimedia \
      -skip      qtnetworkauth \
      -skip      qtpurchasing \
      -skip      qtquick3d \
      -skip      qtquickcontrols \
      -skip      qtquickcontrols2 \
      -skip      qtquicktimeline \
      -skip      qtremoteobjects \
      -skip      qtscript \
      -skip      qtscxml \
      -skip      qtsensors \
      -skip      qtserialbus \
      -skip      qtserialport \
      -skip      qtspeech \
      -skip      qtsvg \
      -skip      qttools \
      -skip      qttranslations \
      -skip      qtvirtualkeyboard \
      -skip      qtwayland \
      -skip      qtwebchannel \
      -skip      qtwebengine \
      -skip      qtwebglplugin \
      -skip      qtwebsockets \
      -skip      qtwebview \
      -skip      qtwinextras \
      -skip      qtx11extras \
      -skip      qtxmlpatterns \
\
      2> ${QT_PREFIX}_${QT_GIT_VERSION}_cfg_$(date +%Y-%m-%d_%H%M).txt
