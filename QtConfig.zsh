#!/bin/zsh
#

### Define Qt library variable
QT_PREFIX=qt5

### Choose library type (static or shared)
LIBTYPE=-shared
# LIBTYPE=-static

### Choose whether to compile and install the examples
#EXAMPLES=(-no-compile-examples)
EXAMPLES=(-make examples -compile-examples)


### Some internal variables
ROOTFS=$(realpath $(dirname $0))/rootfs
SOURCE_DIR=${QT_PREFIX}

QT_VERSION=$(cd $SOURCE_DIR && git status --porcelain=v2 --branch | grep -P "branch.head \K.*" -o)

BUILD_DIR=${QT_PREFIX}-build-${QT_VERSION}

mkdir -p ${BUILD_DIR}

cd ${BUILD_DIR} || exit 1

../${SOURCE_DIR}/configure \
\
      -opensource -confirm-license \
      -release \
      ${LIBTYPE} \
      -platform  linux-g++ \
      -device    linux-arm-generic-g++ \
      -device-option CROSS_COMPILE=arm-linux-gnueabi- \
      -c++std    c++14 \
\
      -sysroot   ${ROOTFS} \
\
      -make libs \
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
      2> ${QT_PREFIX}_${QT_VERSION}_cfg_$(date +%Y-%m-%d_%H%M).txt
