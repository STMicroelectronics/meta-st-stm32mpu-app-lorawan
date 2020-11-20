SUMMARY ="LoRaWan Gateway Packet Forwarder"
DESCRIPTION = "A LoRa packet forwarder is a program running on the host\
of a LoRa gateway that forwards RF packets receive by the concentrator\
to a server through a IP/UDP link, and emits RF packets\
that are sent by the server. "
DEPENDS += "lora-gateway"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://LICENSE;md5=22af7693d7b76ef0fc76161c4be76c45"

SRC_URI = "git://github.com/Lora-net/packet_forwarder.git;protocol=https;branch=master"
SRC_URI += "file://set_network_server_infos.sh"
SRC_URI += "file://Setup_WiFi_connection.sh"
SRC_URI += "file://connect_to_wifi.sh"
SRC_URI_append_stm32mp1-lorawan-a7 += "file://0001-lora-gateway-a7.patch"
SRC_URI_append_stm32mp1-lorawan-a7 += "file://launch_a7.sh"
SRC_URI_append_stm32mp1-lorawan-a7 += "file://launch_a7_wifi.sh"
SRC_URI_append_stm32mp1-lorawan-a7 += "file://LoRaWAN_gateway_a7_launcher.sh"
SRC_URI_append_stm32mp1-lorawan-a7 += "file://lorawan-gateway-a7.service"
SRC_URI_append_stm32mp1-lorawan-a7 += "file://lorawan-gateway-a7-wifi.service"
SRC_URI_append_stm32mp1-lorawan-m4 += "file://0001-lora-gateway-m4.patch"
SRC_URI_append_stm32mp1-lorawan-m4 += "file://launch_m4_firmware.sh"
SRC_URI_append_stm32mp1-lorawan-m4 += "file://LoRaWAN_gateway_m4_launcher.sh"
SRC_URI_append_stm32mp1-lorawan-m4 += "file://lorawan-gateway-m4.service"
SRC_URI_append_stm32mp1-lorawan-m4 += "file://lorawan-gateway-m4-wifi.service"
SRC_URI_append_stm32mp1-lorawan-m4 += "file://launch_m4.sh"
SRC_URI_append_stm32mp1-lorawan-m4 += "file://launch_m4_wifi.sh"


SRCREV = "d0226eae6e7b6bbaec6117d0d2372bf17819c438"

PV="4.0.1"

S = "${WORKDIR}/git"

EXTRA_OEMAKE  = 'CFLAGS="-O2 -Wall -Wextra -std=c99 -Iinc -I."'

INSANE_SKIP_${PN} = "ldflags"

do_install_append_stm32mp1-lorawan-a7() {
	install -d ${D}${STM32MP_USERFS_MOUNTPOINT_IMAGE}/lorawan-gateway
	install -m 0755 ${S}/lora_pkt_fwd/lora_pkt_fwd ${D}${STM32MP_USERFS_MOUNTPOINT_IMAGE}/lorawan-gateway
	install -m 0755 ${S}/lora_pkt_fwd/global_conf.json ${D}${STM32MP_USERFS_MOUNTPOINT_IMAGE}/lorawan-gateway
	install -m 0755 ${S}/lora_pkt_fwd/local_conf.json ${D}${STM32MP_USERFS_MOUNTPOINT_IMAGE}/lorawan-gateway
	install -m 0755 ${S}/lora_pkt_fwd/update_gwid.sh ${D}${STM32MP_USERFS_MOUNTPOINT_IMAGE}/lorawan-gateway
	cp ${WORKDIR}/launch_a7.sh ${D}${STM32MP_USERFS_MOUNTPOINT_IMAGE}/lorawan-gateway
	cp ${WORKDIR}/launch_a7_wifi.sh ${D}${STM32MP_USERFS_MOUNTPOINT_IMAGE}/lorawan-gateway
	cp ${WORKDIR}/LoRaWAN_gateway_a7_launcher.sh ${D}${STM32MP_USERFS_MOUNTPOINT_IMAGE}/lorawan-gateway
	cp ${WORKDIR}/set_network_server_infos.sh ${D}${STM32MP_USERFS_MOUNTPOINT_IMAGE}/lorawan-gateway
	cp ${WORKDIR}/lorawan-gateway-a7.service ${D}${STM32MP_USERFS_MOUNTPOINT_IMAGE}/lorawan-gateway
	cp ${WORKDIR}/lorawan-gateway-a7-wifi.service ${D}${STM32MP_USERFS_MOUNTPOINT_IMAGE}/lorawan-gateway
	cp ${WORKDIR}/Setup_WiFi_connection.sh ${D}${STM32MP_USERFS_MOUNTPOINT_IMAGE}/lorawan-gateway
	cp ${WORKDIR}/connect_to_wifi.sh ${D}${STM32MP_USERFS_MOUNTPOINT_IMAGE}/lorawan-gateway
	ln -s -f -r ${D}${STM32MP_USERFS_MOUNTPOINT_IMAGE}/lorawan-gateway/LoRaWAN_gateway_a7_launcher.sh  ${D}${STM32MP_USERFS_MOUNTPOINT_IMAGE}/lorawan-gateway/LoRaWAN_gateway_launcher.sh

}

do_install_append_stm32mp1-lorawan-m4() {
	install -d ${D}${STM32MP_USERFS_MOUNTPOINT_IMAGE}/lorawan-gateway
	install -m 0755 ${S}/lora_pkt_fwd/lora_pkt_fwd ${D}${STM32MP_USERFS_MOUNTPOINT_IMAGE}/lorawan-gateway
	install -m 0755 ${S}/lora_pkt_fwd/global_conf.json ${D}${STM32MP_USERFS_MOUNTPOINT_IMAGE}/lorawan-gateway
	install -m 0755 ${S}/lora_pkt_fwd/local_conf.json ${D}${STM32MP_USERFS_MOUNTPOINT_IMAGE}/lorawan-gateway
	install -m 0755 ${S}/lora_pkt_fwd/update_gwid.sh ${D}${STM32MP_USERFS_MOUNTPOINT_IMAGE}/lorawan-gateway
	cp ${WORKDIR}/launch_m4_firmware.sh ${D}${STM32MP_USERFS_MOUNTPOINT_IMAGE}/lorawan-gateway
	cp ${WORKDIR}/LoRaWAN_gateway_m4_launcher.sh ${D}${STM32MP_USERFS_MOUNTPOINT_IMAGE}/lorawan-gateway
	cp ${WORKDIR}/set_network_server_infos.sh ${D}${STM32MP_USERFS_MOUNTPOINT_IMAGE}/lorawan-gateway
	cp ${WORKDIR}/launch_m4.sh ${D}${STM32MP_USERFS_MOUNTPOINT_IMAGE}/lorawan-gateway
	cp ${WORKDIR}/launch_m4_wifi.sh ${D}${STM32MP_USERFS_MOUNTPOINT_IMAGE}/lorawan-gateway
	cp ${WORKDIR}/lorawan-gateway-m4.service ${D}${STM32MP_USERFS_MOUNTPOINT_IMAGE}/lorawan-gateway
	cp ${WORKDIR}/lorawan-gateway-m4-wifi.service ${D}${STM32MP_USERFS_MOUNTPOINT_IMAGE}/lorawan-gateway
	cp ${STM32MP_LORAWAN_BASE}/mx/STM32MP157C-DK2/lorawan-m4/firmware/lorawan-m4.elf ${D}${STM32MP_USERFS_MOUNTPOINT_IMAGE}/lorawan-gateway
	cp ${WORKDIR}/Setup_WiFi_connection.sh ${D}${STM32MP_USERFS_MOUNTPOINT_IMAGE}/lorawan-gateway
	cp ${WORKDIR}/connect_to_wifi.sh ${D}${STM32MP_USERFS_MOUNTPOINT_IMAGE}/lorawan-gateway
	ln -s -f -r ${D}${STM32MP_USERFS_MOUNTPOINT_IMAGE}/lorawan-gateway/LoRaWAN_gateway_m4_launcher.sh  ${D}${STM32MP_USERFS_MOUNTPOINT_IMAGE}/lorawan-gateway/LoRaWAN_gateway_launcher.sh
}

RDEPENDS_${PN} += "bash"

FILES_${PN} += "${STM32MP_USERFS_MOUNTPOINT_IMAGE}/lorawan-gateway"
