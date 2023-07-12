## meta-st-stm32mpu-app-lorawan

OpenEmbedded meta layer to install a LoRaWan gateway.<br>
The structure is based on the layer meta-st-stm32mp-addons.

## Installation of the meta layer

* Clone following git repositories into [your STM32MP1 Distribution path]/layers/meta-st/
 > **PC $>** cd [your STM32MP1 Distribution path]/layers/meta-st/<br>
 > **PC $>** git clone "https://github.com/STMicroelectronics/meta-st-stm32mpu-app-lorawan" -b dunfell<br>

* Setup the build environment
 > **PC $>** source [your STM32MP1 Distribution path]/layers/meta-st/scripts/envsetup.sh
 > * Select your DISTRO (ex: openstlinux-weston)
 > * Select the MACHINE: stm32mp1<br>

* Add the meta-st-stm32mpu-app-lorawan layer to build configuration
 > **PC $>** bitbake-layers add-layer ../layers/meta-st/meta-st-stm32mpu-app-lorawan<br>
 
* Build your image
 > **PC $>** bitbake st-image-weston<br>

## Creation of the sd card
* Follow the wiki "How to populate the SD card with dd command"
 > https://wiki.st.com/stm32mpu-ecosystem-v3/wiki/How_to_populate_the_SD_card_with_dd_command<br>

## LoRaWan Gateway Configuration
* Follow the wiki "How to integrate LoRaWAN gateway"
 > https://wiki.st.com/stm32mpu-ecosystem-v3/wiki/How_to_integrate_LoRaWAN_gateway<br>
 
