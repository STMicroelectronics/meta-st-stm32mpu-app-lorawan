DESCRIPTION = "chirpstack application Server"
HOMEPAGE = "https://www.chirpstack.io/"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://LICENSE;md5=5301050fd7cd58850085239d559297be"

SRC_URI = "https://artifacts.chirpstack.io/downloads/chirpstack-application-server/chirpstack-application-server_3.17.8_linux_armv7.tar.gz"
SRC_URI[md5sum] = "628749dc4ca5814fbb3dfaf4ea8d8f23"
SRC_URI[sha256sum] = "2567ffb19e898fa0b66da8f63dd254e8b337eb5d3605d9b62f4f95010937d406"
SRC_URI += "file://chirpstack-application-server.service"
SRC_URI += "file://chirpstack-application-server.toml"

INSANE_SKIP:${PN} += "already-stripped"

S = "${WORKDIR}"

do_install:append() {
	install -d ${D}${bindir}
	install -m 0755 chirpstack-application-server ${D}${bindir}

	install -d ${D}/etc/chirpstack-application-server/
	install -m 0640 ${S}/chirpstack-application-server.toml ${D}/etc/chirpstack-application-server/chirpstack-application-server.toml

	install -d ${D}/etc/systemd/system/
	install -m 0644 ${S}/chirpstack-application-server.service ${D}/etc/systemd/system/
}

FILES:${PN} += "${bindir}"
