SUMMARY ="RAK2245 Concentrator Module "
DESCRIPTION = "A LoRa packet forwarder is a program running on the host\
of a LoRa gateway that forwards RF packets receive by the concentrator\
to a server through a IP/UDP link, and emits RF packets\
that are sent by the server. "

LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://LICENSE;md5=a2bdef95625509f821ba00460e3ae0eb"
SRC_URI = "git://github.com/Lora-net/lora_gateway;protocol=https;branch=master"
SRC_URI += "file://0001-stm32mp1-rak2245.patch"
SRC_URI += "file://concentrator-reset.sh"
 
SRCREV = "a955619271b5d0a46d32e08150acfbc1eed183b7"

PV="5.0.1"

S = "${WORKDIR}/git"

EXTRA_OEMAKE  = 'CFLAGS="-O2 -Wall -Wextra -std=c99 -Iinc -I../libtools/inc"'

INSANE_SKIP_${PN} = "ldflags"

do_install () {

        install -d ${D}${prefix}/local/lorawan-gateway
        install -d ${D}${prefix}/local/lorawan-gateway/rak2245
        install -d ${D}${prefix}/local/lorawan-gateway/rak2245/test
        install -d ${D}${prefix}/local/lorawan-gateway/rak2245/utility

        install -m 0755 ${S}/packet_forwarder/lora_pkt_fwd ${D}${prefix}/local/lorawan-gateway/rak2245
        install -m 0640 ${S}/packet_forwarder/global_conf.json ${D}${prefix}/local/lorawan-gateway/rak2245
        install -m 0640 ${S}/packet_forwarder/local_conf.json ${D}${prefix}/local/lorawan-gateway/rak2245
        install -m 0755 ${S}/packet_forwarder/reset_lgw.sh ${D}${prefix}/local/lorawan-gateway/rak2245
        install -m 0755 ${WORKDIR}/concentrator-reset.sh ${D}${prefix}/local/lorawan-gateway/rak2245 

        install -m 0755 ${S}/packet_forwarder/reset_lgw.sh ${D}${prefix}/local/lorawan-gateway/rak2245/test
 	install -m 0755 ${S}/libloragw/test_loragw_* ${D}${prefix}/local/lorawan-gateway/rak2245/test 

        install -m 0755 ${S}/packet_forwarder/reset_lgw.sh ${D}${prefix}/local/lorawan-gateway/rak2245/utility
 	install -m 0755 ${S}/util_ack/util_ack ${D}${prefix}/local/lorawan-gateway/rak2245/utility
	install -m 0755 ${S}/util_lbt_test/util_lbt_test ${D}${prefix}/local/lorawan-gateway/rak2245/utility   
  	install -m 0755 ${S}/util_pkt_logger/util_pkt_logger ${D}${prefix}/local/lorawan-gateway/rak2245/utility
	install -m 0755 ${S}/util_pkt_logger/print_lora_log.sh ${D}${prefix}/local/lorawan-gateway/rak2245/utility  
 	install -m 0755 ${S}/util_sink/util_sink ${D}${prefix}/local/lorawan-gateway/rak2245/utility  
 	install -m 0755 ${S}/util_spectral_scan/util_spectral_scan ${D}${prefix}/local/lorawan-gateway/rak2245/utility  
 	install -m 0755 ${S}/util_spi_stress/util_spi_stress ${D}${prefix}/local/lorawan-gateway/rak2245/utility  
 	install -m 0755 ${S}/util_tx_continuous/util_tx_continuous ${D}${prefix}/local/lorawan-gateway/rak2245/utility  
 	install -m 0755 ${S}/util_tx_test/util_tx_test ${D}${prefix}/local/lorawan-gateway/rak2245/utility  

        install -d ${D}${prefix}/local/lorawan-gateway/rak2245/region
        install -m 0640 ${S}/packet_forwarder/region/* ${D}${prefix}/local/lorawan-gateway/rak2245/region


}

RDEPENDS_${PN} += "bash"

FILES_${PN} += "${prefix}/local/lorawan-gateway"
