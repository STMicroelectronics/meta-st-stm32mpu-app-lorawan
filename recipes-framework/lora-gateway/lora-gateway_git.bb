SUMMARY ="LoRaWan Gateway library"
DESCRIPTION = "Driver/HAL to build a gateway using a concentrator board \
based on Semtech SX1301 multi-channel modem \ 
and SX1257/SX1255 RF transceivers."

LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://LICENSE;md5=a2bdef95625509f821ba00460e3ae0eb"

SRC_URI = "git://github.com/Lora-net/lora_gateway;protocol=https;branch=master \
           file://0001-SPI-speed-modified-by-Olivier-Roffinella-Apprentice-.patch \
           "

SRCREV = "a955619271b5d0a46d32e08150acfbc1eed183b7"

PV="5.0.1"

S = "${WORKDIR}/git"

EXTRA_OEMAKE  = 'CFLAGS="-O2 -Wall -Wextra -std=c99 -Iinc -I."'

do_install(){
      install -d ${D}${libdir}
      install -d ${D}${includedir}

      install -m 0644 ${S}/libloragw/inc/* ${D}${includedir}
      install -m 0644 ${S}/libloragw/libloragw.a ${D}${libdir}
      install -m 0644 ${S}/libloragw/library.cfg ${D}${includedir}

}

FILES_${PN}= " \
    ${includedir} \
    ${libdir} \
"
