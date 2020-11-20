SUMMARY = "Linux kernel customization for adding GPIOs"
FILESEXTRAPATHS_prepend := "${THISDIR}/files:"

KERNEL_CONFIG_FRAGMENTS_append += " ${WORKDIR}/fragments/linux-stm32mp/4.19/spi_gpio.config"
SRC_URI_append = " file://spi_gpio.config;subdir=fragments/linux-stm32mp/4.19 "


# Configure recipe for CubeMX
inherit cubemx-stm32mp

CUBEMX_DTB_PATH_LINUX ?= ""
CUBEMX_DTB_PATH = "${CUBEMX_DTB_PATH_LINUX}"

CUBEMX_DTB_SRC_PATH ?= "arch/arm/boot/dts"


