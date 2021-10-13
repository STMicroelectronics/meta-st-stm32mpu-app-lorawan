DESCRIPTION = "Chirpstack Network Server"
HOMEPAGE = "https://www.chirpstack.io/"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://LICENSE;md5=e3a340e43ab9867d3e5d0ea79a54b0e1"
LICENSE_PATH += "file://LICENSE"

SRC_URI = "https://artifacts.chirpstack.io/downloads/chirpstack-network-server/chirpstack-network-server_3.12.3_linux_armv7.tar.gz"
SRC_URI[md5sum] = "31394bd818e0846cb99ce3d8979f1ba3"
SRC_URI[sha256sum] = "bb52c86dae48ae14ab9a33ee0636a0c95b64316db961cc39cd395c2053d24847"

SRC_URI += " \
    file://chirpstack-network-server.service \
    file://config/au915_0.toml \
    file://config/au915_1.toml \
    file://config/au915_2.toml \
    file://config/au915_3.toml \
    file://config/au915_4.toml \
    file://config/au915_5.toml \
    file://config/au915_6.toml \
    file://config/au915_7.toml \
    file://config/eu868.toml \
    file://config/us915_0.toml \
    file://config/us915_1.toml \
    file://config/us915_2.toml \
    file://config/us915_3.toml \
    file://config/us915_4.toml \
    file://config/us915_5.toml \
    file://config/us915_6.toml \
    file://config/us915_7.toml \
"

INSANE_SKIP_${PN} += "already-stripped"

S = "${WORKDIR}"

do_install_append() {
	install -d ${D}${bindir}
	install -m 0755 chirpstack-network-server ${D}${bindir}/

	install -d ${D}/etc/chirpstack-network-server/
	install -d ${D}/etc/chirpstack-network-server/config
	install -m 0640 ${S}/config/* ${D}/etc/chirpstack-network-server/config

	install -d ${D}/etc/systemd/system/
	install -m 0755 ${S}/chirpstack-network-server.service ${D}/etc/systemd/system/
}

FILES_${PN} += "${bindir}"
