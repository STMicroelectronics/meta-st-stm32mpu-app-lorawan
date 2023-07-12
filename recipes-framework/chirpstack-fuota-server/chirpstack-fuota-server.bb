DESCRIPTION = "chirpstack fuota Server"
HOMEPAGE = "https://www.chirpstack.io/"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://LICENSE;md5=09fe2246a30dca84af09ac8608093cd7"

SRC_URI = "https://artifacts.chirpstack.io/downloads/chirpstack-fuota-server/chirpstack-fuota-server_3.0.0-test.4_linux_armv7.tar.gz"
SRC_URI[md5sum] = "fe6d572fa574b36536dc5a4ae5710d4c"
SRC_URI[sha256sum] =  "3403f06ce15235b9aec3b14fa3fe0c359012190cf2df603a3b2256ec99925511"

 
SRC_URI += "file://chirpstack-fuota-server.service"
SRC_URI += "file://chirpstack-fuota-server.toml"

INSANE_SKIP_${PN} += "already-stripped"

S = "${WORKDIR}"
 
do_install_append() {
	install -d ${D}${bindir}
	install -m 0755 chirpstack-fuota-server ${D}${bindir}

	install -d ${D}/etc/chirpstack-fuota-server/
	install -m 0640 ${S}/chirpstack-fuota-server.toml ${D}/etc/chirpstack-fuota-server/chirpstack-fuota-server.toml

	install -d ${D}/etc/systemd/system/
	install -m 0644 ${S}/chirpstack-fuota-server.service ${D}/etc/systemd/system/
}

FILES_${PN} += "${bindir}"
