DESCRIPTION = "chirpstack gateway bridge"
HOMEPAGE = "https://www.chirpstack.io/"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://LICENSE;md5=99e425257f8a67b7efd81dc0009ed8ff"

SRC_URI = "https://artifacts.chirpstack.io/downloads/chirpstack-gateway-bridge/chirpstack-gateway-bridge_3.14.5_linux_armv7.tar.gz"
SRC_URI[md5sum] = "dda678309cb76c4b8ca3a87ed16434cd"
SRC_URI[sha256sum] = "64763a304b3f960dbf47a679d484cf1d3985e7dbe70ed8eca2ddb60818eb7a14"
SRC_URI += "file://chirpstack-gateway-bridge.service"
SRC_URI += "file://chirpstack-gateway-bridge.toml"

INSANE_SKIP_${PN} += "already-stripped"

S = "${WORKDIR}"

do_install:append() {
	install -d ${D}${bindir}
	install -m 0755 ${S}/chirpstack-gateway-bridge ${D}${bindir}

	install -d ${D}/etc/chirpstack-gateway-bridge
	install -m 0640 ${S}/chirpstack-gateway-bridge.toml ${D}/etc/chirpstack-gateway-bridge/

	install -d ${D}/etc/systemd/system/
	install -m 0644 ${S}/chirpstack-gateway-bridge.service ${D}/etc/systemd/system/
}

FILES_${PN} += "${bindir}"
