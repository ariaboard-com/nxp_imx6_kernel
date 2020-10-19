export ARCH="arm"
export CROSS_COMPILE="arm-linux-gnueabihf-"

if [ x"${CORES}" = x"" ]; then
    CORES=4
fi

KNAME='imx6q-luna-test'
WORKDIR="$(pwd)"

if [ x"$1" = x"mrprober" ]; then
   rm -rf "build/${KNAME}"
fi

if [ ! -d "build/${KNAME}" ]; then
    mkdir -p "build/${KNAME}"
fi

if [ ! -f "build/${KNAME}/.config" ]; then
    cp arch/arm/configs/imx_6q_luna_test_board_defconfig "build/${KNAME}/.config"
fi

make O="build/${KNAME}" -j${CORES} zImage
make O="build/${KNAME}" -j${CORES} modules firmware
make O="build/${KNAME}" imx6q-sabresd-luna-test.dtb

rm -rf "deploy/${KNAME}"
mkdir -p "deploy/${KNAME}"
mkdir -p "deploy/${KNAME}/modules/lib/firmware"
mkdir -p "deploy/${KNAME}/headers/usr/src/linux"

cp "build/${KNAME}/arch/arm/boot/zImage" "deploy/${KNAME}/"
cp "build/${KNAME}/arch/arm/boot/dts/"*.dtb "deploy/${KNAME}/"
make O="build/${KNAME}" modules_install INSTALL_MOD_PATH="${WORKDIR}/deploy/${KNAME}/modules"
make O="build/${KNAME}" firmware_install INSTALL_MOD_PATH="${WORKDIR}/deploy/${KNAME}/modules"
make O="build/${KNAME}" headers_install INSTALL_HDR_PATH="${WORKDIR}/deploy/${KNAME}/headers/usr/src/linux"

cd "${WORKDIR}/deploy/${KNAME}/modules"
tar -czf ../modules.tar.gz ./

cd "${WORKDIR}/deploy/${KNAME}/headers"
tar -czf ../headers.tar.gz ./
cd ../../..
