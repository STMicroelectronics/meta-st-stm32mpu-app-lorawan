SUMMARY ="RAK5146 Concentrator Module "
DESCRIPTION = "A LoRa packet forwarder is a program running on the host\
of a LoRa gateway that forwards RF packets receive by the concentrator\
to a server through a IP/UDP link, and emits RF packets\
that are sent by the server. "

LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://LICENSE.TXT;md5=d2119120bd616e725f4580070bd9ee19"
SRC_URI = "git://github.com/Lora-net/sx1302_hal;protocol=https;branch=master"

SRC_URI += "file://0001-stm32mp1-rak5146.patch"
SRC_URI += "file://concentrator-reset.sh"
 
SRCREV = "4b42025d1751e04632c0b04160e0d29dbbb222a5"

PV="2.1.0"

S = "${WORKDIR}/git"

EXTRA_OEMAKE  = 'CFLAGS="-O2 -Wall -Wextra -std=c99 -Iinc -I../libtools/inc"'

INSANE_SKIP:${PN} = "ldflags"

do_install () {

        install -d ${D}${prefix}/local/lorawan-gateway
        install -d ${D}${prefix}/local/lorawan-gateway/rak5146
        install -d ${D}${prefix}/local/lorawan-gateway/rak5146/mcu_bin
        install -d ${D}${prefix}/local/lorawan-gateway/rak5146/test
        install -d ${D}${prefix}/local/lorawan-gateway/rak5146/utility

        install -m 0755 ${S}/packet_forwarder/lora_pkt_fwd ${D}${prefix}/local/lorawan-gateway/rak5146
        install -m 0640 ${S}/packet_forwarder/global_conf.json ${D}${prefix}/local/lorawan-gateway/rak5146
        install -m 0640 ${S}/packet_forwarder/local_conf.json ${D}${prefix}/local/lorawan-gateway/rak5146
        install -m 0755 ${S}/packet_forwarder/reset_lgw.sh ${D}${prefix}/local/lorawan-gateway/rak5146
        install -m 0755 ${WORKDIR}/concentrator-reset.sh ${D}${prefix}/local/lorawan-gateway/rak5146
        
        install -m 0755 ${S}/mcu_bin/rlz_010000_CoreCell_USB.bin ${D}${prefix}/local/lorawan-gateway/rak5146/mcu_bin
        
	install -m 0755 ${S}/libloragw/test_loragw_* ${D}${prefix}/local/lorawan-gateway/rak5146/test
        install -m 0755 ${S}/packet_forwarder/reset_lgw.sh ${D}${prefix}/local/lorawan-gateway/rak5146/test

	install -m 0755 ${S}/util_boot/boot ${D}${prefix}/local/lorawan-gateway/rak5146/utility
        install -m 0755 ${S}/util_chip_id/chip_id ${D}${prefix}/local/lorawan-gateway/rak5146/utility
        install -m 0755 ${S}/util_net_downlink/net_downlink ${D}${prefix}/local/lorawan-gateway/rak5146/utility
        install -m 0755 ${S}/util_spectral_scan/spectral_scan ${D}${prefix}/local/lorawan-gateway/rak5146/utility
        install -m 0755 ${S}/packet_forwarder/reset_lgw.sh ${D}${prefix}/local/lorawan-gateway/rak5146/utility


        install -d ${D}${prefix}/local/lorawan-gateway/rak5146/region
        install -m 0640 ${S}/packet_forwarder/region/* ${D}${prefix}/local/lorawan-gateway/rak5146/region


}

RDEPENDS:${PN} += "bash"

FILES:${PN} += "${prefix}/local/lorawan-gateway"
