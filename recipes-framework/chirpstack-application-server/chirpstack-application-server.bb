DESCRIPTION = "ChirpStack Application Server"
HOMEPAGE = "https://www.chirpstack.io/"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://LICENSE;md5=5301050fd7cd58850085239d559297be"

SRC_URI = "https://artifacts.chirpstack.io/downloads/chirpstack-application-server/chirpstack-application-server_3.14.0_linux_armv7.tar.gz"
SRC_URI[md5sum] = "2c68fe3b399f806930b6e1c311e537b6"
SRC_URI[sha256sum] = "89a046658ea16752610a2011e9072eb543eca0ecbc1dc59f6b167e8a4ec012b1"

SRC_URI += "file://chirpstack-application-server.service"
SRC_URI += "file://chirpstack-application-server.toml"

INSANE_SKIP_${PN} += "already-stripped"

S = "${WORKDIR}"

do_install_append() {
	install -d ${D}${bindir}
	install -m 0755 chirpstack-application-server ${D}${bindir}

	install -d ${D}/etc/chirpstack-application-server/
	install -m 0640 ${S}/chirpstack-application-server.toml ${D}/etc/chirpstack-application-server/chirpstack-application-server.toml

	install -d ${D}/etc/systemd/system/
	install -m 0755 ${S}/chirpstack-application-server.service ${D}/etc/systemd/system/
}

FILES_${PN} += "${bindir}"
