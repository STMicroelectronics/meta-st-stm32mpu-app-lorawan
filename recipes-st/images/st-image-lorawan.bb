require ../../../meta-st-openstlinux/recipes-st/images/st-image-weston.bb

SUMMARY = "*** Application DEMO : OpenSTLinux LoRaWAN demo"

IMAGE_LORAWAN_PART = " mosquitto jq dpkg sudo apt \
redis mosquitto mosquitto-clients \
postgresql postgresql-client postgresql-pltcl \
postgresql-server-dev postgresql-timezone \
postgresql-contrib libecpg \
libecpg-staticdev \
libpq libpq-dev \
libecpg-compat \
libpgtypes \
"

EXTRA_IMAGE_FEATURES += " package-management "

PACKAGE_INSTALL += " \
chirpstack-network-server \
chirpstack-gateway-bridge \
chirpstack-application-server \
"

#
# INSTALL addons
#
CORE_IMAGE_EXTRA_INSTALL += " \
    packagegroup-framework-tools-network        \
    ${IMAGE_LORAWAN_PART}     \
    "
