DESCRIPTION = "LoRa Gateway Server"
HOMEPAGE = "https://www.loraserver"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://LICENSE;md5=e3a340e43ab9867d3e5d0ea79a54b0e1"
LICENSE_PATH += "file://LICENSE"

SRC_URI = "https://artifacts.loraserver.io/downloads/loraserver/loraserver_3.2.1_linux_armv7.tar.gz"
SRC_URI[md5sum] = "dab6100be12f40be1be991047796afff"
SRC_URI[sha256sum] = "b7d760c981af9267a2ac9c3b07bb50efdc378c9b52c05f405781be0517758ddc"
SRC_URI += " \
    file://loraserver.service \
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
	install -m 0755 loraserver ${D}${bindir}/

	install -d ${D}/etc/loraserver/
	install -d ${D}/etc/loraserver/config
	install -m 0640 ${S}/config/* ${D}/etc/loraserver/config

	install -d ${D}/etc/systemd/system/
	install -m 0755 ${S}/loraserver.service ${D}/etc/systemd/system/
}

FILES_${PN} += "${bindir}"
