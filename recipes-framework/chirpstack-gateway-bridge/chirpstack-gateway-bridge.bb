DESCRIPTION = "Chirpstack Gateway Bridge"
HOMEPAGE = "https://www.chirpstack.io/"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://LICENSE;md5=99e425257f8a67b7efd81dc0009ed8ff"

SRC_URI = "https://artifacts.chirpstack.io/downloads/chirpstack-gateway-bridge/chirpstack-gateway-bridge_3.10.0_linux_armv7.tar.gz"
SRC_URI[md5sum] = "46b0a4db6e9105d6756e9bb744cd9ad9"
SRC_URI[sha256sum] = "4a486559fbe04f30f6aaad939a4009f457e76e4c0c65613f753a129909a33f7f"

SRC_URI += "file://chirpstack-gateway-bridge.service"
SRC_URI += "file://chirpstack-gateway-bridge.toml"

INSANE_SKIP_${PN} += "already-stripped"

S = "${WORKDIR}"

do_install_append() {
	install -d ${D}${bindir}
	install -m 0755 ${S}/chirpstack-gateway-bridge ${D}${bindir}

	install -d ${D}/etc/chirpstack-gateway-bridge
	install -m 0640 ${S}/chirpstack-gateway-bridge.toml ${D}/etc/chirpstack-gateway-bridge/chirpstack-gateway-bridge.toml

	install -d ${D}/etc/systemd/system/
	install -m 0755 ${S}/chirpstack-gateway-bridge.service ${D}/etc/systemd/system/
}

FILES_${PN} += "${bindir}"
