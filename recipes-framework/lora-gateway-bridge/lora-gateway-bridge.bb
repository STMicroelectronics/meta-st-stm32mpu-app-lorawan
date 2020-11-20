DESCRIPTION = "LoRa Gateway Bridge"
HOMEPAGE = "https://www.loraserver.io/"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://LICENSE;md5=5301050fd7cd58850085239d559297be"

SRC_URI = "https://artifacts.loraserver.io/downloads/lora-gateway-bridge/lora-gateway-bridge_3.2.1_linux_armv7.tar.gz"
SRC_URI[md5sum] = "e3816c48d7b19ecac5f4f7ea07798429"
SRC_URI[sha256sum] = "7a0ba192b092ee0f92fdb1786c5e8cbf815dcea0dffa20cefd4403cfcc949571"
SRC_URI += "file://lora-gateway-bridge.service"
SRC_URI += "file://lora-gateway-bridge.toml"

INSANE_SKIP_${PN} += "already-stripped"

S = "${WORKDIR}"

do_install_append() {
	install -d ${D}${bindir}
	install -m 0755 ${S}/lora-gateway-bridge ${D}${bindir}

	install -d ${D}/etc/lora-gateway-bridge
	install -m 0640 ${S}/lora-gateway-bridge.toml ${D}/etc/lora-gateway-bridge/

	install -d ${D}/etc/systemd/system/
	install -m 0755 ${S}/lora-gateway-bridge.service ${D}/etc/systemd/system/
}

FILES_${PN} += "${bindir}"
