DESCRIPTION ="Configuration Script for LoRaWan Gateway and Chiprstack"
HOMEPAGE = "wiki.st.com"
LICENSE = "BSD-3-Clause"
LIC_FILES_CHKSUM = "file://${COREBASE}/meta/files/common-licenses/BSD-3-Clause;md5=550794465ba0ec5312d6919e203a55f9"


SRC_URI += "file://chirpstack-server/chirpstack-disable.sh"
SRC_URI += "file://chirpstack-server/chirpstack-enable.sh"
SRC_URI += "file://chirpstack-server/postgresql-conf.sh"
SRC_URI += "file://chirpstack-server/stm32mp1-chirpstack-server.service"
SRC_URI += "file://chirpstack-server/stm32mp1-chirpstack-server.sh"
SRC_URI += "file://chirpstack-server/stm32mp1-chirpstack-server-wifi.service"
SRC_URI += "file://chirpstack-server/stm32mp1-chirpstack-server-wifi.sh"
SRC_URI += "file://chirpstack-server/fuota-postgresql-conf.sh"
  
SRC_URI += "file://lora-gateway/stm32mp1-loragateway.service"
SRC_URI += "file://lora-gateway/stm32mp1-loragateway.sh"
SRC_URI += "file://lora-gateway/stm32mp1-loragateway-disable.sh"
SRC_URI += "file://lora-gateway/stm32mp1-loragateway-wifi.service"
SRC_URI += "file://lora-gateway/stm32mp1-loragateway-wifi.sh"
 
SRC_URI += "file://wifi-connection-setup.sh"
SRC_URI += "file://stm32mp1-configuration.json"
SRC_URI += "file://stm32mp1-config.sh"
SRC_URI += "file://stm32wl-dashboard.json"
SRC_URI += "file://stm32mp1-gateway-info.sh"
SRC_URI += "file://wpa_supplicant-wlan0.conf"
SRC_URI += "file://51-wireless.network"
SRC_URI += "file://51-wireless.network.sample"
 
do_install () {

        install -d ${D}${prefix}/local/lorawan-gateway

        install -m 0755 ${WORKDIR}/wifi-connection-setup.sh ${D}${prefix}/local/lorawan-gateway  
        install -m 0755 ${WORKDIR}/stm32mp1-config.sh ${D}${prefix}/local/lorawan-gateway 
        install -m 0640 ${WORKDIR}/stm32mp1-configuration.json ${D}${prefix}/local/lorawan-gateway 
        install -m 0640 ${WORKDIR}/stm32wl-dashboard.json ${D}${prefix}/local/lorawan-gateway
        install -m 0755 ${WORKDIR}/stm32mp1-gateway-info.sh ${D}${prefix}/local/lorawan-gateway
        install -m 0644 ${WORKDIR}/wpa_supplicant-wlan0.conf ${D}${prefix}/local/lorawan-gateway
        install -m 0644 ${WORKDIR}/51-wireless.network ${D}${prefix}/local/lorawan-gateway
 
        install -d ${D}${prefix}/local/lorawan-gateway/chirpstack-server

        install -m 0755 ${WORKDIR}/chirpstack-server/chirpstack-disable.sh ${D}${prefix}/local/lorawan-gateway/chirpstack-server
        install -m 0755 ${WORKDIR}/chirpstack-server/chirpstack-enable.sh ${D}${prefix}/local/lorawan-gateway/chirpstack-server
        install -m 0755 ${WORKDIR}/chirpstack-server/postgresql-conf.sh ${D}${prefix}/local/lorawan-gateway/chirpstack-server
        install -m 0644 ${WORKDIR}/chirpstack-server/stm32mp1-chirpstack-server.service ${D}${prefix}/local/lorawan-gateway/chirpstack-server
        install -m 0755 ${WORKDIR}/chirpstack-server/stm32mp1-chirpstack-server.sh ${D}${prefix}/local/lorawan-gateway/chirpstack-server
        install -m 0644 ${WORKDIR}/chirpstack-server/stm32mp1-chirpstack-server-wifi.service ${D}${prefix}/local/lorawan-gateway/chirpstack-server
        install -m 0755 ${WORKDIR}/chirpstack-server/stm32mp1-chirpstack-server-wifi.sh ${D}${prefix}/local/lorawan-gateway/chirpstack-server
        install -m 0755 ${WORKDIR}/chirpstack-server/fuota-postgresql-conf.sh ${D}${prefix}/local/lorawan-gateway/chirpstack-server
 

        install -d ${D}${prefix}/local/lorawan-gateway/lora-gateway
        install -m 0644 ${WORKDIR}/lora-gateway/stm32mp1-loragateway.service ${D}${prefix}/local/lorawan-gateway/lora-gateway
        install -m 0755 ${WORKDIR}/lora-gateway/stm32mp1-loragateway.sh ${D}${prefix}/local/lorawan-gateway/lora-gateway
        install -m 0755 ${WORKDIR}/lora-gateway/stm32mp1-loragateway-disable.sh ${D}${prefix}/local/lorawan-gateway/lora-gateway
        install -m 0644 ${WORKDIR}/lora-gateway/stm32mp1-loragateway-wifi.service ${D}${prefix}/local/lorawan-gateway/lora-gateway
        install -m 0755 ${WORKDIR}/lora-gateway/stm32mp1-loragateway-wifi.sh ${D}${prefix}/local/lorawan-gateway/lora-gateway 
        
      	install -d ${D}/etc
      	install -d ${D}/etc/wpa_supplicant
      	install -m 0644 ${WORKDIR}/wpa_supplicant-wlan0.conf ${D}/etc/wpa_supplicant/ 
      	  	
      	  
}

RDEPENDS_${PN} += "bash"
FILES_${PN} += "${prefix}/local/lorawan-gateway"
