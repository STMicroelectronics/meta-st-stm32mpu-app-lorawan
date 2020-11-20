## meta-st-stm32mpu-app-lorawan

OpenEmbedded meta layer to install a LoRaWan gateway.<br>
The structure is based on a CubeMX project on the STM32MP157C-DK2 and the layer meta-st-stm32mp-addons.

## Installation of the meta layer

* Clone following git repositories into [your STM32MP1 Distribution path]/layers/meta-st/
 > **PC $>** cd [your STM32MP1 Distribution path]/layers/meta-st/<br>
 > **PC $>** git clone "https://github.com/STMicroelectronics/meta-st-stm32mpu-app-lorawan" -b thud <br>

* Setup the build environment
 > **PC $>** source [your STM32MP1 Distribution path]/layers/meta-st/scripts/envsetup.sh
 > * Select your DISTRO (ex: openstlinux-weston-extra)
 > * Select the LoRaWan MACHINE: stm32mp1-lorawan-a7 to use only the
 >   Cortex-A7 or stm32mp1-lorawan-m4 to use the Cortex-A7 and the Cortex-M4
 >   in parallel<br>

* Build your image
 > **PC $>** bitbake st-image-lorawan<br>

## Creation of the sd card
* Follow the wiki "How to populate the SD card with dd command"
 > https://wiki.st.com/stm32mpu-ecosystem-v1/wiki/How_to_populate_the_SD_card_with_dd_command<br>

## The software
All the binaries to launch lorawan-gateway are located in /usr/local/lorawan-gateway<br>
do **./LoRaWan_gateway_launcher.sh** or **LoRaWan_gateway_m4_launcher.sh** to launch the process that starts the gateway with the option wifi or ethernet depending which internet connection you use.<br>

* The scripts **LoRaWan_gateway_launcher.sh wifi|ethernet** or **LoRaWan_gateway_m4_launcher.sh wifi|ethernet** depending of your version:<br>
 > * Auto set of the EUI, based on the mac address of the RAK831 shield.<br>
 > * Launch the service that will use the start(_WiFi).sh or the Prepare_M4_firmware(_WiFi).sh script which setup and launch the gateway software (based on the libraries lora-gateway and packet-forwarder)<br>
 > * Allows to setup the network informations (server, up and down ports), the wifi SSID and password is this options was chosen<br>

## The firmware running on the M4
The Cortex-M4 firmware source code used in this application is available:<br>
 > **PC $>** cd [workspace directory]<br>
 > **PC $>** repo init -u https://github.com/STMicroelectronics/STM32MP1_LoRaWAN-manifests -b refs/tags/STM32MP15-Ecosystem-v1.2.0 -m default.xml<br>
 > **PC $>** repo sync
