DESCRIPTION = "LoRa Gateway App Server"
HOMEPAGE = "https://www.loraserver.io/"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://LICENSE;md5=5301050fd7cd58850085239d559297be"

SRC_URI = "https://artifacts.loraserver.io/downloads/lora-app-server/lora-app-server_3.3.0_linux_armv7.tar.gz"
SRC_URI[md5sum] = "d172250a62550ffdefdfbf4bd2ae0d18"
SRC_URI[sha256sum] = "9a8ef585025e52c627b6bbb39b6802e0247c694a42d6068ae90bc3f3889025bb"
SRC_URI += "file://lora-app-server.service"
SRC_URI += "file://lora-app-server.toml"

INSANE_SKIP_${PN} += "already-stripped"

S = "${WORKDIR}"

do_install_append() {
	install -d ${D}${bindir}
	install -m 0755 lora-app-server ${D}${bindir}

	install -d ${D}/etc/lora-app-server/
	install -m 0640 ${S}/lora-app-server.toml ${D}/etc/lora-app-server/lora-app-server.toml

	install -d ${D}/etc/systemd/system/
	install -m 0755 ${S}/lora-app-server.service ${D}/etc/systemd/system/
}

FILES_${PN} += "${bindir}"
