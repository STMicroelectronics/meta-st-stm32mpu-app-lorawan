#!/bin/bash

export NCURSES_NO_UTF8_ACS=1


SCRIPT_DIR=$(pwd)
STM32MP1_CONFIG=$SCRIPT_DIR/stm32mp1-configuration.json
#CHIRP_DIR=$SCRIPT_DIR/chirpstack-network-server
#CHIRP_AS_DIR=$SCRIPT_DIR/chirpstack-application-server

CHIRP_DIR=/etc/chirpstack-network-server
CHIRP_AS_DIR=/etc/chirpstack-application-server
CHIRPGATEWAYPATH=chirpstack-server
LORAGATEWAYPATH=lora-gateway

service_exists(){
    local n=$1
    if [[ $(systemctl list-units --all -t service --full --no-legend "$n.service" | cut -f1 -d' ') == $n.service ]]; then
        return 0
    else
        return 1
    fi
}

func_reboot(){
  dialog --title " Gateway Restarting  " --msgbox "STM32MP1 will reboot in 5 second." 5 60
  sleep 5
  reboot
}

func_global_conf(){

MODULE_PATH=$(jq .gateway_model.gw_path $STM32MP1_CONFIG)
MODULE_PATH=$(eval echo $MODULE_PATH)

R_FILEPATH=$SCRIPT_DIR/$MODULE_PATH/global_conf.json

nano $R_FILEPATH

stm32mp1_gateway_menu
 
}

func_local_conf(){

MODULE_PATH=$(jq .gateway_model.gw_path $STM32MP1_CONFIG)
MODULE_PATH=$(eval echo $MODULE_PATH)

R_FILEPATH=$SCRIPT_DIR/$MODULE_PATH/local_conf.json

nano $R_FILEPATH

stm32mp1_gateway_menu
 
}

func_application_server(){

R_FILEPATH=$CHIRP_AS_DIR/chirpstack-application-server.toml

nano $R_FILEPATH

stm32mp1_gateway_menu

}

func_network_server(){
 
R_FILEPATH=$CHIRP_DIR/chirpstack-network-server.toml 

nano $R_FILEPATH

stm32mp1_gateway_menu
 
}

func_wifi_config(){

OUTPUT="/tmp/input.txt"
>$OUTPUT
trap "rm $OUTPUT; exit" SIGHUP SIGINT SIGTERM
dialog --title "WIFI SSID" --inputbox "Please enter SSID " 8 40 2>$OUTPUT
RET=$?
SSID=$(<$OUTPUT)
rm $OUTPUT

if [ $RET -eq 1 ]; then 
:
elif [ $RET -eq 0 ]; then

OUTPUT="/tmp/input.txt"
>$OUTPUT
trap "rm $OUTPUT; exit" SIGHUP SIGINT SIGTERM
dialog --title "WIFI PASSWORD " --inputbox "Please enter passphrase " 8 40 2>$OUTPUT
RET=$?
PASSPHRASE=$(<$OUTPUT)
rm $OUTPUT
if [ $RET -eq 1 ]; then 
:
elif [ $RET -eq 0 ]; then 
sed -i".bak" '5,$d' /etc/wpa_supplicant/wpa_supplicant-wlan0.conf
wpa_passphrase "$SSID" "$PASSPHRASE" >> /etc/wpa_supplicant/wpa_supplicant-wlan0.conf
ifconfig wlan0 up
mkdir -p /usr/lib/systemd/network	
cp $SCRIPT_DIR/51-wireless.network /usr/lib/systemd/network/
systemctl enable wpa_supplicant@wlan0.service
systemctl enable systemd-networkd.service
systemctl restart systemd-networkd.service
systemctl restart wpa_supplicant@wlan0.service

dialog --title "Note " --msgbox "In case you made a mistake in your SSID or password you can change them in the file wpa_supplicant-wlan0.conf located at /etc/wpa_supplicant/wpa_supplicant-wlan0.conf " 10 60
fi
fi
stm32mp1_gateway_menu

}

func_read_gateway_ID(){

GATEWAY_PATH=$(jq .gateway_server.server_path  $STM32MP1_CONFIG)
GATEWAY_PATH=$(eval echo $GATEWAY_PATH)

GATEWAY_PATH_VALUE=$(jq .gateway_server.server_path_value  $STM32MP1_CONFIG)
GATEWAY_PATH_VALUE=$(eval echo $GATEWAY_PATH_VALE)

GATEWAYID=$(jq .gateway_conf.gateway_ID $SCRIPT_DIR/$GATEWAY_PATH/global_conf.json)
GATEWAYID=$(eval echo $GATEWAYID) 	

if [ -z "$GATEWAYID" ]; then 
dialog --title "Gateway_EUI  " --msgbox "Gateway EUI is not yet configured " 5 40
else
dialog --title "Gateway_EUI  " --msgbox "Gateway EUI  : $GATEWAYID" 5 40
fi
stm32mp1_gateway_menu
}

func_read_gateway_info(){

source $SCRIPT_DIR/stm32mp1-gateway-info.sh

stm32mp1_gateway_menu

}

clean_gateway_configuration(){

#disable loragateway-ethernet service  
if service_exists stm32mp1-loragateway; then
systemctl disable stm32mp1-loragateway.service
systemctl stop stm32mp1-loragateway.service
rm -rf /lib/systemd/system/stm32mp1-loragateway.service	
fi

#disable loragateway-wifi service  
if service_exists stm32mp1-loragateway-wifi; then
systemctl disable stm32mp1-loragateway-wifi.service
systemctl stop stm32mp1-loragateway-wifi.service
rm -rf /lib/systemd/system/stm32mp1-loragateway-wifi.service	
fi

#disable chirpstack-ethernet service 

if service_exists stm32mp1-chirpstack-server; then

systemctl disable stm32mp1-chirpstack-server.service
systemctl stop stm32mp1-chirpstack-server.service
rm -rf /lib/systemd/system/stm32mp1-chirpstack-server.service	
fi

#disable chirpstack-wifi service 
if service_exists stm32mp1-chirpstack-server-wifi; then
systemctl disable stm32mp1-chirpstack-server-wifi.service
systemctl stop stm32mp1-chirpstack-server-wifi.service
rm -rf /lib/systemd/system/stm32mp1-chirpstack-server-wifi.service	
fi

#stop chirpstack-gateway-bridge service 
if service_exists chirpstack-gateway-bridge; then
systemctl stop chirpstack-gateway-bridge.service
fi

#stop chirpstack-network-server service 
if service_exists chirpstack-network-server; then
systemctl stop chirpstack-network-server.service
fi

#stop chirpstack-application-server service
if service_exists chirpstack-application-server; then
systemctl stop chirpstack-application-server.service
fi

 
file="$SCRIPT_DIR/$CHIRPGATEWAYPATH/local_conf.json"
[ -f $file ] && rm $file
file="$SCRIPT_DIR/$CHIRPGATEWAYPATH/global_conf.json "
[ -f $file ] && rm $file
file="$SCRIPT_DIR/$CHIRPGATEWAYPATH/lora_pkt_fwd "
[ -f $file ] && rm $file
file="$SCRIPT_DIR/$CHIRPGATEWAYPATH/reset_lgw.sh"
[ -f $file ] && rm $file
 
file="$SCRIPT_DIR/$LORAGATEWAYPATH/local_conf.json"
[ -f $file ] && rm $file
file="$SCRIPT_DIR/$LORAGATEWAYPATH/global_conf.json "
[ -f $file ] && rm $file
file="$SCRIPT_DIR/$LORAGATEWAYPATH/lora_pkt_fwd "
[ -f $file ] && rm $file
file="$SCRIPT_DIR/$LORAGATEWAYPATH/reset_lgw.sh"
[ -f $file ] && rm $file

}

func_gateway_start(){

dialog --title " gateway configuration " --infobox "\n
Please wait .....\n" 5 30


FUNCTIONCALLER=$2

MODULE_PATH=$(jq .gateway_model.gw_path $STM32MP1_CONFIG)
MODULE_PATH=$(eval echo $MODULE_PATH)

R_FILEPATH=$SCRIPT_DIR/$MODULE_PATH/global_conf.json


#verify chirpstack configuration 

#model=$(jq .SX130x_conf.com_type  $R_FILEPATH)
#model=$(eval echo $model)

model=$(jq .gateway_model.gw_path $STM32MP1_CONFIG) 
model=$(eval echo $model)

modelgps=$(jq .gateway_model.gw_com_gps $STM32MP1_CONFIG) 
modelgps=$(eval echo $modelgps)

modellbt=$(jq .gateway_model.gw_com_lbt $STM32MP1_CONFIG) 
modellbt=$(eval echo $modellbt) 

if [ "$model" = "rak2245" ]; then
SX130X="SX1301_conf"
modelcom="SPI"
modelcom=$(eval echo $modelcom)

else
SX130X="SX130x_conf"
modelcom=$(jq .SX130x_conf.com_type  $R_FILEPATH) 
modelcom=$(eval echo $modelcom)
fi

serveripvalue=$(jq .gateway_conf.server_address $R_FILEPATH) 
serveripvalue=$(eval echo $serveripvalue)

serverportup=$(jq .gateway_conf.serv_port_up $R_FILEPATH)
serverportup=$(eval echo $serverportup)

serverportdown=$(jq .gateway_conf.serv_port_down $R_FILEPATH)
serverportdown=$(eval echo $serverportdown)

frequencyregion=$(jq .gateway_server.server_freq_channel $STM32MP1_CONFIG) 
frequencyregion=$(eval echo $frequencyregion)

connectmode=$(jq .gateway_conn.conn_mode  $STM32MP1_CONFIG) 
connectmode=$(eval echo $connectmode)

gatewayeui=$(jq .gateway_conf.gateway_ID $R_FILEPATH)
gatewayeui=$(eval echo $gatewayeui)

#enp0s31f6
#wlp2s0

if [ "$connectmode" = "wlan" ]; then 

ifconfig wlan0 up
mkdir -p /usr/lib/systemd/network	
cp $SCRIPT_DIR/51-wireless.network /usr/lib/systemd/network/
systemctl enable wpa_supplicant@wlan0.service
systemctl enable systemd-networkd.service
systemctl restart systemd-networkd.service
systemctl restart wpa_supplicant@wlan0.service

else

if service_exists wpa_supplicant@wlan0; then
systemctl disable wpa_supplicant@wlan0.service
systemctl stop wpa_supplicant@wlan0.service
rm -rf /usr/lib/systemd/network/51-wireless.network
fi

ifconfig wlan0 down 

fi


{
freq0=$(jq .$SX130X.radio_0.freq $R_FILEPATH)
freq0=$(eval echo $freq0)

freq1=$(jq .$SX130X.radio_1.freq $R_FILEPATH)
freq1=$(eval echo $freq1)


#SF0
sfenable=$(jq .$SX130X.chan_multiSF_0.enable $R_FILEPATH)
sfenable=$(eval echo $sfenable)

if [ "$sfenable" = "true" ]; then

sfradio=$(jq .$SX130X.chan_multiSF_0.radio $R_FILEPATH)
sfradio=$(eval echo $sfradio)
BW0="BW125KHZ"
SFACTOR0="SF7/SF12"
COMMENT0="LORA_MULTI_SF"

freqoffset=$(jq .$SX130X.chan_multiSF_0.if $R_FILEPATH)
freqoffset=$(eval echo $freqoffset)
 
if [ "$sfradio" = "0" ]; then
CHFREQ0=$(( $freq0 + $freqoffset ))
RADIO0=A
else
CHFREQ0=$(( $freq1 + $freqoffset ))
RADIO0=B
fi
else
CHFREQ0="   OFF   "
SFACTOR0="        "
RADIO0=" "
COMMENT0=" "
BW0="        "

fi 

#SF1
sfenable=$(jq .$SX130X.chan_multiSF_1.enable $R_FILEPATH)
sfenable=$(eval echo $sfenable)

if [ "$sfenable" = "true" ]; then

sfradio=$(jq .$SX130X.chan_multiSF_1.radio $R_FILEPATH)
sfradio=$(eval echo $sfradio)

BW1="BW125KHZ"
SFACTOR1="SF7/SF12"
COMMENT1="LORA_MULTI_SF"

freqoffset=$(jq .$SX130X.chan_multiSF_1.if $R_FILEPATH)
freqoffset=$(eval echo $freqoffset)
 
if [ "$sfradio" = "0" ]; then
CHFREQ1=$(( $freq0 + $freqoffset ))
RADIO1=A
else
CHFREQ1=$(( $freq1 + $freqoffset ))
RADIO1=B
fi
else
CHFREQ1="   OFF   "
SFACTOR1="        "
RADIO1=" "
COMMENT1=" "
BW1="        "
fi 

#SF2
sfenable=$(jq .$SX130X.chan_multiSF_2.enable $R_FILEPATH)
sfenable=$(eval echo $sfenable)

if [ "$sfenable" = "true" ]; then

sfradio=$(jq .$SX130X.chan_multiSF_2.radio $R_FILEPATH)
sfradio=$(eval echo $sfradio)

BW2="BW125KHZ"
SFACTOR2="SF7/SF12"
COMMENT2="LORA_MULTI_SF"
 
freqoffset=$(jq .$SX130X.chan_multiSF_2.if $R_FILEPATH)
freqoffset=$(eval echo $freqoffset)
 
if [ "$sfradio" = "0" ]; then
CHFREQ2=$(( $freq0 + $freqoffset ))
RADIO2=A
else
CHFREQ2=$(( $freq1 + $freqoffset ))
RADIO2=B
fi
else
CHFREQ2="   OFF   "
SFACTOR2="        "
RADIO2=" "
COMMENT2=" "
BW2="        "
fi 


#SF3

sfenable=$(jq .$SX130X.chan_multiSF_3.enable $R_FILEPATH)
sfenable=$(eval echo $sfenable)

if [ "$sfenable" = "true" ]; then

sfradio=$(jq .$SX130X.chan_multiSF_3.radio $R_FILEPATH)
sfradio=$(eval echo $sfradio)

BW3="BW125KHZ"
SFACTOR3="SF7/SF12"
COMMENT3="LORA_MULTI_SF"

freqoffset=$(jq .$SX130X.chan_multiSF_3.if $R_FILEPATH)
freqoffset=$(eval echo $freqoffset)
 
if [ "$sfradio" = "0" ]; then
CHFREQ3=$(( $freq0 + $freqoffset ))
RADIO3=A
else
CHFREQ3=$(( $freq1 + $freqoffset ))
RADIO3=B
fi
else
CHFREQ3="   OFF   "
SFACTOR3="        "
RADIO3=" "
COMMENT3=" "
BW3="        "
fi 

#SF4

sfenable=$(jq .$SX130X.chan_multiSF_4.enable $R_FILEPATH)
sfenable=$(eval echo $sfenable)

if [ "$sfenable" = "true" ]; then

sfradio=$(jq .$SX130X.chan_multiSF_4.radio $R_FILEPATH)
sfradio=$(eval echo $sfradio)


BW4="BW125KHZ" 
SFACTOR4="SF7/SF12"
COMMENT4="LORA_MULTI_SF"

freqoffset=$(jq .$SX130X.chan_multiSF_4.if $R_FILEPATH)
freqoffset=$(eval echo $freqoffset)
 
if [ "$sfradio" = "0" ]; then
CHFREQ4=$(( $freq0 + $freqoffset ))
RADIO4=A
else
CHFREQ4=$(( $freq1 + $freqoffset ))
RADIO4=B
fi
else
CHFREQ4="   OFF   "
SFACTOR4="        "
RADIO4=" "
COMMENT4=" "
BW4="        "
fi 


#SF5
sfenable=$(jq .$SX130X.chan_multiSF_5.enable $R_FILEPATH)
sfenable=$(eval echo $sfenable)

if [ "$sfenable" = "true" ]; then

sfradio=$(jq .$SX130X.chan_multiSF_5.radio $R_FILEPATH)
sfradio=$(eval echo $sfradio)

 
BW5="BW125KHZ"
SFACTOR5="SF7/SF12"
COMMENT5="LORA_MULTI_SF"

freqoffset=$(jq .$SX130X.chan_multiSF_5.if $R_FILEPATH)
freqoffset=$(eval echo $freqoffset)
 
if [ "$sfradio" = "0" ]; then
CHFREQ5=$(( $freq0 + $freqoffset ))
RADIO5=A
else
CHFREQ5=$(( $freq1 + $freqoffset ))
RADIO5=B
fi
else
CHFREQ5="   OFF   "
SFACTOR5="        "
RADIO5=" "
COMMENT5=" "
BW5="        "
fi 

#SF6

sfenable=$(jq .$SX130X.chan_multiSF_6.enable $R_FILEPATH)
sfenable=$(eval echo $sfenable)

if [ "$sfenable" = "true" ]; then

sfradio=$(jq .$SX130X.chan_multiSF_6.radio $R_FILEPATH)
sfradio=$(eval echo $sfradio)
 
BW6="BW125KHZ"
SFACTOR6="SF7/SF12"
COMMENT6="LORA_MULTI_SF"

freqoffset=$(jq .$SX130X.chan_multiSF_6.if $R_FILEPATH)
freqoffset=$(eval echo $freqoffset)
 
if [ "$sfradio" = "0" ]; then
CHFREQ6=$(( $freq0 + $freqoffset ))
RADIO6=A
else
CHFREQ6=$(( $freq1 + $freqoffset ))
RADIO6=B
fi
else
CHFREQ6="   OFF   "
SFACTOR6="        "
RADIO6=" "
COMMENT6=" "
BW6="        "
fi 


#SF7
sfenable=$(jq .$SX130X.chan_multiSF_7.enable $R_FILEPATH)
sfenable=$(eval echo $sfenable)

if [ "$sfenable" = "true" ]; then

sfradio=$(jq .$SX130X.chan_multiSF_7.radio $R_FILEPATH)
sfradio=$(eval echo $sfradio)

BW7="BW125KHZ"
SFACTOR7="SF7/SF12"
COMMENT7="LORA_MULTI_SF"

freqoffset=$(jq .$SX130X.chan_multiSF_7.if $R_FILEPATH)
freqoffset=$(eval echo $freqoffset)
 
if [ "$sfradio" = "0" ]; then
CHFREQ7=$(( $freq0 + $freqoffset ))
RADIO7=A
else
CHFREQ7=$(( $freq1 + $freqoffset ))
RADIO7=B
fi
else
CHFREQ7="   OFF   "
SFACTOR7="        "
RADIO7=" "
COMMENT7=" "
BW7="        "
fi 


#chan_FSK
sfenable=$(jq .$SX130X.chan_FSK.enable $R_FILEPATH)
sfenable=$(eval echo $sfenable)

if [ "$sfenable" = "true" ]; then

sfradio=$(jq .$SX130X.chan_FSK.radio $R_FILEPATH)
sfradio=$(eval echo $sfradio)
	
freqoffset=$(jq .$SX130X.chan_FSK.if $R_FILEPATH)
freqoffset=$(eval echo $freqoffset)

bandwidth=$(jq .$SX130X.chan_FSK.bandwidth $R_FILEPATH)
bandwidth=$(eval echo $bandwidth)

datarate=$(jq .$SX130X.chan_FSK.datarate $R_FILEPATH)
datarate=$(eval echo $datarate)

num="1000"
BW8="BW$(($bandwidth / $num))KHz"
COMMENT8="FSK"
SFACTOR8="$datarate   "
 
if [ "$sfradio" = "0" ]; then
CHFREQ8=$(( $freq0 + $freqoffset ))
RADIO8=A
else
CHFREQ8=$(( $freq1 + $freqoffset ))
RADIO8=B
fi
else
CHFREQ8="   OFF   "
SFACTOR8="        "
RADIO8=" "
COMMENT8=" "
BW8="        "
fi 


#chan_Lora_std

sfenable=$(jq .$SX130X.chan_Lora_std.enable $R_FILEPATH)
sfenable=$(eval echo $sfenable)

if [ "$sfenable" = "true" ]; then

sfradio=$(jq .$SX130X.chan_Lora_std.radio $R_FILEPATH)
sfradio=$(eval echo $sfradio)



freqoffset=$(jq .$SX130X.chan_Lora_std.if $R_FILEPATH)
freqoffset=$(eval echo $freqoffset)


bandwidth=$(jq .$SX130X.chan_Lora_std.bandwidth $R_FILEPATH)
bandwidth=$(eval echo $bandwidth)

spreadfactor=$(jq .$SX130X.chan_Lora_std.spread_factor $R_FILEPATH)
spreadfactor=$(eval echo $spreadfactor)

num="1000"
BW9="BW$(($bandwidth / $num))KHz"
COMMENT9="LORA_STD"
SFACTOR9="SF$spreadfactor     "
 
if [ "$sfradio" = "0" ]; then
CHFREQ9=$(( $freq0 + $freqoffset ))
RADIO9=A
else
CHFREQ9=$(( $freq1 + $freqoffset ))
RADIO9=A
fi
else
CHFREQ9="   OFF   "
SFACTOR9="        "
RADIO9=" "
COMMENT9=" "
BW9="        "

fi 
}

if [ "$MODULELBT" = "LBT" ]; then

lbt0=$(jq .$SX130X.sx1261_conf.lbt.channels[0].freq_hz $R_FILEPATH)
lbt0=$(eval echo $lbt0)

lbtbw0=$(jq .$SX130X.sx1261_conf.lbt.channels[0].bandwidth $R_FILEPATH)
lbtbw0=$(eval echo $lbtbw0)

lbtst0=$(jq .$SX130X.sx1261_conf.lbt.channels[0].scan_time_us $R_FILEPATH)
lbtst0=$(eval echo $lbtst0)

lbttt0=$(jq .$SX130X.sx1261_conf.lbt.channels[0].transmit_time_ms $R_FILEPATH)
lbttt0=$(eval echo $lbttt0)

lbt1=$(jq .$SX130X.sx1261_conf.lbt.channels[1].freq_hz $R_FILEPATH)
lbt1=$(eval echo $lbt1)

lbtbw1=$(jq .$SX130X.sx1261_conf.lbt.channels[1].bandwidth $R_FILEPATH)
lbtbw1=$(eval echo $lbtbw1)

lbtst1=$(jq .$SX130X.sx1261_conf.lbt.channels[1].scan_time_us $R_FILEPATH)
lbtst1=$(eval echo $lbtst1)

lbttt1=$(jq .$SX130X.sx1261_conf.lbt.channels[1].transmit_time_ms $R_FILEPATH)
lbttt1=$(eval echo $lbttt1)

if [ "$lbt1" = "null" ]; then
lbt1="   OFF   "
lbtbw1="        "
lbtst1=" "
lbttt1=" "
fi


#
lbt2=$(jq .$SX130X.sx1261_conf.lbt.channels[2].freq_hz $R_FILEPATH)
lbt2=$(eval echo $lbt2)

lbtbw2=$(jq .$SX130X.sx1261_conf.lbt.channels[2].bandwidth $R_FILEPATH)
lbtbw2=$(eval echo $lbtbw2)

lbtst2=$(jq .$SX130X.sx1261_conf.lbt.channels[2].scan_time_us $R_FILEPATH)
lbtst2=$(eval echo $lbtst2)

lbttt2=$(jq .$SX130X.sx1261_conf.lbt.channels[2].transmit_time_ms $R_FILEPATH)
lbttt2=$(eval echo $lbttt2)

if [ "$lbt2" = "null" ]; then
lbt2="   OFF   "
lbtbw2="        "
lbtst2=" "
lbttt2=" "
fi


#3

lbt3=$(jq .$SX130X.sx1261_conf.lbt.channels[3].freq_hz $R_FILEPATH)
lbt3=$(eval echo $lbt3)

lbtbw3=$(jq .$SX130X.sx1261_conf.lbt.channels[3].bandwidth $R_FILEPATH)
lbtbw3=$(eval echo $lbtbw3)

lbtst3=$(jq .$SX130X.sx1261_conf.lbt.channels[3].scan_time_us $R_FILEPATH)
lbtst3=$(eval echo $lbtst3)

lbttt3=$(jq .$SX130X.sx1261_conf.lbt.channels[3].transmit_time_ms $R_FILEPATH)
lbttt3=$(eval echo $lbttt3)

if [ "$lbt3" = "null" ]; then
lbt3="   OFF   "
lbtbw3="        "
lbtst3=" "
lbttt3=" "
fi


#4

lbt4=$(jq .$SX130X.sx1261_conf.lbt.channels[4].freq_hz $R_FILEPATH)
lbt4=$(eval echo $lbt4)

lbtbw4=$(jq .$SX130X.sx1261_conf.lbt.channels[4].bandwidth $R_FILEPATH)
lbtbw4=$(eval echo $lbtbw4)

lbtst4=$(jq .$SX130X.sx1261_conf.lbt.channels[4].scan_time_us $R_FILEPATH)
lbtst4=$(eval echo $lbtst4)

lbttt4=$(jq .$SX130X.sx1261_conf.lbt.channels[4].transmit_time_ms $R_FILEPATH)
lbttt4=$(eval echo $lbttt4)

if [ "$lbt4" = "null" ]; then
lbt4="   OFF   "
lbtbw4="        "
lbtst4=" "
lbttt4=" "
fi


#4
lbt5=$(jq .$SX130X.sx1261_conf.lbt.channels[5].freq_hz $R_FILEPATH)
lbt5=$(eval echo $lbt5)

lbtbw5=$(jq .$SX130X.sx1261_conf.lbt.channels[5].bandwidth $R_FILEPATH)
lbtbw5=$(eval echo $lbtbw5)

lbtst5=$(jq .$SX130X.sx1261_conf.lbt.channels[5].scan_time_us $R_FILEPATH)
lbtst5=$(eval echo $lbtst5)

lbttt5=$(jq .$SX130X.sx1261_conf.lbt.channels[5].transmit_time_ms $R_FILEPATH)
lbttt5=$(eval echo $lbttt5)

if [ "$lbt5" = "null" ]; then
lbt5="   OFF   "
lbtbw5="        "
lbtst5=" "
lbttt5=" "
fi


#6
lbt6=$(jq .$SX130X.sx1261_conf.lbt.channels[6].freq_hz $R_FILEPATH)
lbt6=$(eval echo $lbt6)

lbtbw6=$(jq .$SX130X.sx1261_conf.lbt.channels[6].bandwidth $R_FILEPATH)
lbtbw6=$(eval echo $lbtbw6)

lbtst6=$(jq .$SX130X.sx1261_conf.lbt.channels[6].scan_time_us $R_FILEPATH)
lbtst6=$(eval echo $lbtst6)

lbttt6=$(jq .$SX130X.sx1261_conf.lbt.channels[6].transmit_time_ms $R_FILEPATH)
lbttt6=$(eval echo $lbttt6)

if [ "$lbt6" = "null" ]; then
lbt6="   OFF   "
lbtbw6="        "
lbtst6=" "
lbttt6=" "
fi

#7
lbt7=$(jq .$SX130X.sx1261_conf.lbt.channels[7].freq_hz $R_FILEPATH)
lbt7=$(eval echo $lbt7)

lbtbw7=$(jq .$SX130X.sx1261_conf.lbt.channels[7].bandwidth $R_FILEPATH)
lbtbw7=$(eval echo $lbtbw7)

lbtst7=$(jq .$SX130X.sx1261_conf.lbt.channels[7].scan_time_us $R_FILEPATH)
lbtst7=$(eval echo $lbtst7)

lbttt7=$(jq .$SX130X.sx1261_conf.lbt.channels[7].transmit_time_ms $R_FILEPATH)
lbttt7=$(eval echo $lbttt7)

if [ "$lbt7" = "null" ]; then
lbt7="   OFF   "
lbtbw7="        "
lbtst7=" "
lbttt7=" "
fi

#8

lbt8=$(jq .$SX130X.sx1261_conf.lbt.channels[8].freq_hz $R_FILEPATH)
lbt8=$(eval echo $lbt8)

lbtbw8=$(jq .$SX130X.sx1261_conf.lbt.channels[8].bandwidth $R_FILEPATH)
lbtbw8=$(eval echo $lbtbw0)

lbtst8=$(jq .$SX130X.sx1261_conf.lbt.channels[8].scan_time_us $R_FILEPATH)
lbtst8="SCANTIME$(eval echo $lbtst8)uS"

lbttt8=$(jq .$SX130X.sx1261_conf.lbt.channels[8].transmit_time_ms $R_FILEPATH)
lbttt8="TRANSMITTIME$(eval echo $lbttt8)mS"
 

if [ "$lbt8" = "null" ]; then
lbt8="   OFF   "
lbtbw8="        "
lbtst8=" "
lbttt8=" "
fi

fi

lanmacid=$(ip link show eth0 | awk '/ether / {print $2}' )
wlanmacid=$(ip link show wlan0 | awk '/ether / {print $2}' )

if [ "$connectmode" = "lan" ]; then 
ipaddress=$(/sbin/ip -o -4 addr list eth0 | awk '{print $4}' | cut -d/ -f1)
else
ipaddress=$(/sbin/ip -o -4 addr list wlan0 | awk '{print $4}' | cut -d/ -f1)
fi



gatewayversion="1.0"

 
dialog --title " $1 Configuration   " --msgbox "\n
GATEWAYVERSION     : [$gatewayversion]\n
GATEWAY_EUI        : [$gatewayeui]\n
IPADDRESS          : [$ipaddress]\n
LAN MAC_ID         : [$lanmacid]\n
WLAN MAC_ID        : [$wlanmacid]\n
MODULE SELECTED    : [$model]\n
MODULE COM         : [$modelcom]\n
MODULE GPS         : [$modelgps]\n
MODULE LBT         : [$modellbt]\n
SERVER ADDRESS     : [$serveripvalue]\n
SERVER PORT UP     : [$serverportup]\n
SERVER PORT DOWN   : [$serverportdown]\n
COMMUNICATION MODE : [$connectmode]\n
REGION ISM BAND    : [$frequencyregion]\n
CHANNEL0           : $CHFREQ0  $RADIO0  $SFACTOR0  ${BW0}  $COMMENT0\n 
CHANNEL1           : $CHFREQ1  $RADIO1  $SFACTOR1  ${BW1}  $COMMENT1\n
CHANNEL2           : $CHFREQ2  $RADIO2  $SFACTOR2  ${BW2}  $COMMENT2\n
CHANNEL3           : $CHFREQ3  $RADIO3  $SFACTOR3  ${BW3}  $COMMENT3\n
CHANNEL4           : $CHFREQ4  $RADIO4  $SFACTOR4  ${BW4}  $COMMENT4\n
CHANNEL5           : $CHFREQ5  $RADIO5  $SFACTOR5  ${BW5}  $COMMENT5\n
CHANNEL6           : $CHFREQ6  $RADIO6  $SFACTOR6  ${BW6}  $COMMENT6\n
CHANNEL7           : $CHFREQ7  $RADIO7  $SFACTOR7  ${BW7}  $COMMENT7\n
CHANNEL8           : $CHFREQ8  $RADIO8  $SFACTOR8  ${BW8}  $COMMENT8\n
CHANNEL9           : $CHFREQ9  $RADIO9  $SFACTOR9  ${BW9}  $COMMENT9\n
" 28 80


if [ "$MODULELBT" = "LBT" ]; then

dialog --title " $1 LBT  Configuration   " --msgbox "\n
LBT        : [$REGIONFREQNUMBER]\n
LBTCHANNEL : FREQ[HZ]   BW[HZ]  SCAN[uS]  TRANSMIT[ms]\n   
CHANNEL0   : $lbt0  $lbtbw0    $lbtst0       $lbttt0\n 
CHANNEL1   : $lbt1  $lbtbw1    $lbtst1       $lbttt1\n
CHANNEL2   : $lbt2  $lbtbw2    $lbtst2       $lbttt2\n
CHANNEL3   : $lbt3  $lbtbw3    $lbtst3       $lbttt3\n
CHANNEL4   : $lbt4  $lbtbw4    $lbtst4       $lbttt4\n
CHANNEL5   : $lbt5  $lbtbw5    $lbtst5       $lbttt5\n
CHANNEL6   : $lbt6  $lbtbw6    $lbtst6       $lbttt6\n
CHANNEL7   : $lbt7  $lbtbw7    $lbtst7       $lbttt7\n
CHANNEL8   : $lbt8  $lbtbw8    $lbtst8       $lbttt8\n 
" 18 70

fi

dialog --title "Confirmation " --yesno "Are you sure you want to proceed with configuration " 7 60
RET=$?
if [ $RET -eq 1 ]; then

if [ $FUNCTIONCALLER -eq 2 ]; then
func_chirpstackserver
else
func_loRagateway
fi
elif [ $RET -eq 0 ]; then

dialog --title " gateway configuration " --infobox "\n
Please wait .....\n" 5 30

clean_gateway_configuration

GATEWAY_PATH=$(jq .gateway_server.server_path  $STM32MP1_CONFIG)
GATEWAY_PATH=$(eval echo $GATEWAY_PATH)

GATEWAY_PATH_VALUE=$(jq .gateway_server.server_path_value  $STM32MP1_CONFIG)
GATEWAY_PATH_VALUE=$(eval echo $GATEWAY_PATH_VALE)

MODULE_PATH=$(jq .gateway_model.gw_path $STM32MP1_CONFIG)
MODULE_PATH=$(eval echo $MODULE_PATH)

cp $SCRIPT_DIR/$MODULE_PATH/local_conf.json  $SCRIPT_DIR/$GATEWAY_PATH/         
cp $SCRIPT_DIR/$MODULE_PATH/global_conf.json $SCRIPT_DIR/$GATEWAY_PATH/   
cp $SCRIPT_DIR/$MODULE_PATH/lora_pkt_fwd     $SCRIPT_DIR/$GATEWAY_PATH/
cp $SCRIPT_DIR/$MODULE_PATH/concentrator-reset.sh     $SCRIPT_DIR/$GATEWAY_PATH/
cp $SCRIPT_DIR/$MODULE_PATH/reset_lgw.sh     $SCRIPT_DIR/$GATEWAY_PATH/

default_comvalue=$(jq .gateway_conn.conn_value  $STM32MP1_CONFIG) 
default_comvalue=$(eval echo $default_comvalue)

if [ "$default_comvalue" = "1" ]; then
	#lan selected for communication 
	
	if [ $2 -eq 1 ]; then
	cp $SCRIPT_DIR/$GATEWAY_PATH/stm32mp1-loragateway.service /lib/systemd/system/
	systemctl enable stm32mp1-loragateway.service
	else
	cp $SCRIPT_DIR/$GATEWAY_PATH/stm32mp1-chirpstack-server.service /lib/systemd/system/
	systemctl enable stm32mp1-chirpstack-server.service

	fi
else 
	if [ $2 -eq 1 ]; then
	#wlan selected  for communication 
	cp $SCRIPT_DIR/$GATEWAY_PATH/stm32mp1-loragateway-wifi.service /lib/systemd/system/
	systemctl enable stm32mp1-loragateway-wifi.service
	else
	#wlan selected  for communication 
	cp $SCRIPT_DIR/$GATEWAY_PATH/stm32mp1-chirpstack-server-wifi.service /lib/systemd/system/ 
	systemctl enable stm32mp1-chirpstack-server-wifi.service

	
	fi

fi

if [ $2 -eq 2 ]; then
#Configure post gress

systemctl enable chirpstack-gateway-bridge.service
systemctl enable chirpstack-network-server.service
systemctl enable chirpstack-application-server.service
#systemctl enable chirpstack-fuota-server.service

chirpaspwd=$(jq .database_conf.chirpstack_as_pwd  $STM32MP1_CONFIG) 
chirpaspwd=$(eval echo $chirpaspwd)

chirpnspwd=$(jq .database_conf.chirpstack_ns_pwd  $STM32MP1_CONFIG) 
chirpnspwd=$(eval echo $chirpnspwd)

source $SCRIPT_DIR/$GATEWAY_PATH/postgresql-conf.sh 

fi
 
fi


dialog   --msgbox "STM32MP1 will reboot in 5 second." 5 50
sleep 5
reboot


}

chirpstacknetworkpwd(){
   
CHIRPNSPWD=$(jq .database_conf.chirpstack_ns_pwd $STM32MP1_CONFIG)
CHIRPNSPWD=$(eval echo $CHIRPNSPWD)

OUTPUT="/tmp/input.txt"
>$OUTPUT
trap "rm $OUTPUT; exit" SIGHUP SIGINT SIGTERM
dialog --title "CHIRPSTACK_NETWORK_SERVER PASSWORD" --cancel-label "back" --inputbox "[default : dbpassword] " 8 40 2>$OUTPUT
RET=$? 

if [ $RET -eq 1 ]; then
:
elif [ $RET -eq 0 ]; then

dialog --title "Confirmation " --yesno "Are you sure you want to change chirpstack_network_server password " 7 60
RET=$?
if [ $RET -eq 1 ]; then
:
elif [ $RET -eq 0 ]; then
CHIRPNSPWD=$(<$OUTPUT)
tmp=$(mktemp)

jq -r --arg CHIRPNSPWD "$CHIRPNSPWD" '.database_conf.chirpstack_ns_pwd = $CHIRPNSPWD' $STM32MP1_CONFIG > "$tmp" && mv "$tmp" $STM32MP1_CONFIG

 

sed -i "s/chirpstack\_ns:[[:alnum:]]*[^@]*/chirpstack\_ns:$CHIRPNSPWD/g" $CHIRP_DIR/chirpstack-network-server.toml

dialog --title "chirpstack network server password " --msgbox " Password Configured Successfully " 5 60
fi
fi

rm $OUTPUT

func_chirp_database
  
}

chirpstackapplicationpwd(){
   
CHIRPASPWD=$(jq .database_conf.chirpstack_as_pwd $STM32MP1_CONFIG)
CHIRPASPWD=$(eval echo $CHIRPASPWD)

OUTPUT="/tmp/input.txt"
>$OUTPUT
trap "rm $OUTPUT; exit" SIGHUP SIGINT SIGTERM
dialog --title "CHIRPSTACK_APPLICATION_SERVER PASSWORD" --cancel-label "back" --inputbox "[default : dbpassword] " 8 40 2>$OUTPUT
RET=$? 
if [ $RET -eq 1 ]; then
:
elif [ $RET -eq 0 ]; then
dialog --title "Confirmation " --yesno "Are you sure you want to change chirpstack_application_server password " 7 60
RET=$?
if [ $RET -eq 1 ]; then
:
elif [ $RET -eq 0 ]; then
CHIRPASPWD=$(<$OUTPUT) 

 

tmp=$(mktemp)
jq -r --arg CHIRPASPWD "$CHIRPASPWD" '.database_conf.chirpstack_as_pwd = $CHIRPASPWD' $STM32MP1_CONFIG > "$tmp" && mv "$tmp" $STM32MP1_CONFIG

sed -i "s/chirpstack\_as:[[:alnum:]]*[^@]*/chirpstack\_as:$CHIRPASPWD/g" $CHIRP_AS_DIR/chirpstack-application-server.toml

dialog --title "chirpstack application server password " --msgbox " Password Configured Successfully $CHIRPASPWD " 5 60
fi
fi

rm $OUTPUT

func_chirp_database
  
}

func_chirp_database(){

FUN=$(dialog --title "Database Password Configuration " --cancel-label "back" --menu " CHIRPSTACK DATABASE" 11 50 18 \
1 "Chirpstack Application Server   " \
2 "Chirpstack Network Server  " \
3>&1 1>&2 2>&3)
RET=$?
if [ $RET -eq 1 ]; then
func_chirpstackserver
elif [ $RET -eq 0 ]; then
  case "$FUN" in
    1) chirpstackapplicationpwd;;
    2) chirpstacknetworkpwd;;
esac
fi

}

wifi_mode(){

CONNECTION_MODE="wlan"
CONNECTION_VAL=2

tmp=$(mktemp)

jq -r --arg CONNECTION_MODE "$CONNECTION_MODE" '.gateway_conn.conn_mode = $CONNECTION_MODE' $STM32MP1_CONFIG > "$tmp" && mv "$tmp"  $STM32MP1_CONFIG 

jq -r --arg CONNECTION_VAL "$CONNECTION_VAL" '.gateway_conn.conn_value = $CONNECTION_VAL' $STM32MP1_CONFIG > "$tmp" && mv "$tmp" $STM32MP1_CONFIG 


OUTPUT="/tmp/input.txt"
>$OUTPUT
trap "rm $OUTPUT; exit" SIGHUP SIGINT SIGTERM
dialog --title "WIFI SSID" --inputbox "Please enter SSID " 8 40 2>$OUTPUT
RET=$?
SSID=$(<$OUTPUT)
rm $OUTPUT 
if [ $RET -eq 1 ]; then
func_comm_mode "$1" "$2"
elif [ $RET -eq 0 ]; then

OUTPUT="/tmp/input.txt"
>$OUTPUT
trap "rm $OUTPUT; exit" SIGHUP SIGINT SIGTERM
dialog --title "WIFI PASSWORD " --inputbox "Please enter passphrase " 8 40 2>$OUTPUT
RET=$?
PASSPHRASE=$(<$OUTPUT)
rm $OUTPUT

if [ $RET -eq 1 ]; then
func_comm_mode "$1" "$2"

elif [ $RET -eq 0 ]; then

sed -i".bak" '5,$d' /etc/wpa_supplicant/wpa_supplicant-wlan0.conf
wpa_passphrase "$SSID" "$PASSPHRASE" >> /etc/wpa_supplicant/wpa_supplicant-wlan0.conf


          
dialog --title "Note " --msgbox "In case you made a mistake in your SSID or password you can change them in the file wpa_supplicant-wlan0.conf located at /etc/wpa_supplicant/wpa_supplicant-wlan0.conf " 10 60

dialog --title "Connection Mode Selection " --msgbox "Wifi Selected ." 5 60
fi
fi


	
if [ $2 -eq 2 ]; then
func_chirpstackserver
else
func_loRagateway
fi
 

}

ethernet_mode(){

CONNECTION_MODE="lan"
CONNECTION_VAL=1

RETURNPATH=$2

tmp=$(mktemp)

jq -r --arg CONNECTION_MODE "$CONNECTION_MODE" '.gateway_conn.conn_mode = $CONNECTION_MODE' $STM32MP1_CONFIG > "$tmp" && mv "$tmp"  $STM32MP1_CONFIG 

jq -r --arg CONNECTION_VAL "$CONNECTION_VAL" '.gateway_conn.conn_value = $CONNECTION_VAL' $STM32MP1_CONFIG > "$tmp" && mv "$tmp" $STM32MP1_CONFIG 

dialog --title "Connection Mode Selection " --msgbox " lan selected for communication  " 5 60

dhclient eth0

if [ $RETURNPATH -eq 2 ]; then
func_chirpstackserver
else
func_loRagateway
fi
 
}
   
func_comm_mode(){
RETURNPATH=$2

default_item=$(jq .gateway_conn.conn_value  $STM32MP1_CONFIG) 
default_item=$(eval echo $default_item)

FUN=$(dialog --title "Communication Mode  " --cancel-label "back" --default-item "$default_item" --menu "wifi/lan selection" 11 50 18 \
1 "lan  " \
2 "wlan  " \
3>&1 1>&2 2>&3)
RET=$?
if [ $RET -eq 1 ]; then
if [ $RETURNPATH -eq 2 ]; then
func_chirpstackserver
else
func_loRagateway
fi

elif [ $RET -eq 0 ]; then	
  case "$FUN" in
    1) ethernet_mode "$1" "$2";;
    2) wifi_mode "$1" "$2";;
esac
fi
 
 
}

server_address(){

MODULE_DIR=$(jq .gateway_model.gw_path $STM32MP1_CONFIG)
MODULE_DIR=$(eval echo $MODULE_DIR)

OUTPUT="/tmp/input.txt"
>$OUTPUT
trap "rm $OUTPUT; exit" SIGHUP SIGINT SIGTERM
dialog --title "SERVER IP ADDRESS" --cancel-label "back" --inputbox "Please enter server address " 8 40 2>$OUTPUT
RET=$?
if [ $RET -eq 1 ]; then
:
elif [ $RET -eq 0 ]; then

SERVER_ADDRESS=$(<$OUTPUT)
dialog --title "Confirmation " --yesno "Are you sure you want to change Server address to "$SERVER_ADDRESS"" 7 60
RET=$?
if [ $RET -eq 1 ]; then
:
elif [ $RET -eq 0 ]; then
tmp=$(mktemp) 

#writing data to "global_conf.json"
#writing data from "stm32mpu-configuration.json"

jq -r --arg SERVER_ADDRESS "$SERVER_ADDRESS" '.gateway_conf.server_address = $SERVER_ADDRESS' $SCRIPT_DIR/$MODULE_DIR/global_conf.json > "$tmp" && mv "$tmp" $SCRIPT_DIR/$MODULE_DIR/global_conf.json 

jq -r --arg SERVER_ADDRESS "$SERVER_ADDRESS" '.gateway_server.server_ip = $SERVER_ADDRESS' $STM32MP1_CONFIG > "$tmp" && mv "$tmp" $STM32MP1_CONFIG

dialog --title "SERVER IP ADDRESS" --msgbox " SERVER IP : $SERVER_ADDRESS  Configured " 7 60

fi
fi
rm $OUTPUT

func_server_config "$1" "$2"

}
	
server_port_up(){

MODULE_DIR=$(jq .gateway_model.gw_path $STM32MP1_CONFIG)
MODULE_DIR=$(eval echo $MODULE_DIR)

OUTPUT="/tmp/input.txt"
>$OUTPUT
trap "rm $OUTPUT; exit" SIGHUP SIGINT SIGTERM
dialog --title "SERVER PORT UP " --cancel-label "back" --inputbox "Please enter port up number " 8 40 2>$OUTPUT

RET=$?
if [ $RET -eq 1 ]; then
:
elif [ $RET -eq 0 ]; then
SERVER_PORT_UP=$(<$OUTPUT)
dialog --title "Confirmation " --yesno "Are you sure you want to change Server port up to "$SERVER_PORT_UP"" 7 60
RET=$?
if [ $RET -eq 1 ]; then
:
elif [ $RET -eq 0 ]; then
tmp=$(mktemp) 

#writing data to "global_conf.json"
#writing data from "stm32mpu-configuration.json"

tmp=$(mktemp) 

jq -r --arg SERVER_PORT_UP "$SERVER_PORT_UP" '.gateway_conf.serv_port_up = ( $SERVER_PORT_UP | tonumber )' $SCRIPT_DIR/$MODULE_DIR/global_conf.json > "$tmp" && mv "$tmp" $SCRIPT_DIR/$MODULE_DIR/global_conf.json

jq -r --arg SERVER_PORT_UP "$SERVER_PORT_UP" '.gateway_server.server_port_up = ( $SERVER_PORT_UP | tonumber )' $STM32MP1_CONFIG > "$tmp" && mv "$tmp" $STM32MP1_CONFIG

dialog --title "SERVER PORT UP " --msgbox " SERVER PORT UP : $SERVER_PORT_UP  Configured " 5 40

fi
fi
rm $OUTPUT

func_server_config "$1" "$2"

}

server_port_down(){



MODULE_DIR=$(jq .gateway_model.gw_path $STM32MP1_CONFIG)
MODULE_DIR=$(eval echo $MODULE_DIR)

  

OUTPUT="/tmp/input.txt"
>$OUTPUT
trap "rm $OUTPUT; exit" SIGHUP SIGINT SIGTERM
dialog --title "SERVER PORT DOWN " --cancel-label "back" --inputbox "Please enter port down number " 8 40 2>$OUTPUT
RET=$?
if [ $RET -eq 1 ]; then
func_server_config
elif [ $RET -eq 0 ]; then
SERVER_PORT_DOWN=$(<$OUTPUT)


dialog --title "Confirmation " --yesno "Are you sure you want to change Server port number to "$SERVER_PORT_DOWN"" 7 60
RET=$?
if [ $RET -eq 1 ]; then
:
elif [ $RET -eq 0 ]; then

tmp=$(mktemp) 
#writing data to "global_conf.json"
jq -r --arg SERVER_PORT_DOWN "$SERVER_PORT_DOWN" '.gateway_conf.serv_port_down = ($SERVER_PORT_DOWN | tonumber) ' $SCRIPT_DIR/$MODULE_DIR/global_conf.json > "$tmp" && mv "$tmp"   $SCRIPT_DIR/$MODULE_DIR/global_conf.json

#writing data from "stm32mpu-configuration.json"
jq -r --arg SERVER_PORT_DOWN "$SERVER_PORT_DOWN" '.gateway_server.server_port_down = ($SERVER_PORT_DOWN | tonumber )' $STM32MP1_CONFIG > "$tmp" && mv "$tmp" $STM32MP1_CONFIG
dialog --title "SERVER PORT DOWN " --msgbox " SERVER PORT DOWN : $SERVER_PORT_DOWN  Configured " 5 40
fi
fi
rm $OUTPUT
 
func_server_config "$1" "$2"

}

func_server_config(){

MODULE_DIR=$(jq .gateway_model.gw_path $STM32MP1_CONFIG)
MODULE_DIR=$(eval echo $MODULE_DIR)

RETCALLINGFUNC=$2

#reading data from "global_conf.json"
default1=$(jq .gateway_conf.server_address $SCRIPT_DIR/$MODULE_DIR/global_conf.json) 
default1=$(eval echo $default1)

default2=$(jq .gateway_conf.serv_port_up $SCRIPT_DIR/$MODULE_DIR/global_conf.json)
default2=$(eval echo $default2)

default3=$(jq .gateway_conf.serv_port_down $SCRIPT_DIR/$MODULE_DIR/global_conf.json)
default3=$(eval echo $default3)

FUN=$(dialog --title "Server Configuration Details " --cancel-label "back" --menu "Server Configuration :" 11 60 18 \
1 "Server address   : [$default1]  " \
2 "Server port up   : [$default2] " \
3 "Server port down : [$default3] " \
3>&1 1>&2 2>&3)
RET=$?
if [ $RET -eq 1 ]; then
if [ $RETCALLINGFUNC -eq 2 ]; then
func_chirpstackserver
else
func_loRagateway  
fi

elif [ $RET -eq 0 ]; then
  case "$FUN" in	
    1) server_address "$1" "$2";;
    2) server_port_up "$1" "$2";;
    3) server_port_down "$1" "$2";;
esac
fi
 
} 

gateway_frequency_config(){

#"chirpstack-server" "2"
#"$1" "$2" "rak2287" "1"  "SPI" "GPS" "LBT" "/dev/spidev0.0" "as923" "bandvalue" 
#"$1" "$2" "$3"      "$4" "$5"  "$6"   "$7"    "$8"           "$9"    "$10"
#"$1" "$2" "$3"      "$4" "$5"  "$6"   "$7"    "$8"           "$9"    "$10"        "freqchannel" "freqchannel value"
#"$1" "$2" "$3"      "$4" "$5"  "$6"   "$7"    "$8"           "$9"    "$10"        "$11"         "$12"  
 
dialog --title " frequency configuration " --infobox "\n
Please wait .....\n" 5 30
 
 
GATEWAY=$1
GATEWAY=$(eval echo $GATEWAY)

GATEWAYVALUE=$2
GATEWAYVALUE=$(eval echo $GATEWAYVALUE)


MODULEPATH=$3    
MODULEPATH=$(eval echo $MODULEPATH)

MODULEPATHVALUE=$4
MODULEPATHVALUE=$(eval echo $MODULEPATHVALUE)

MODULECOMTYPE=$5
MODULECOMTYPE=$(eval echo $MODULECOMTYPE)

MODULEGPS=$6
MODULEGPS=$(eval echo $MODULEGPS)

MODULELBT=$7
MODULELBT=$(eval echo $MODULELBT)

MODULECOMDIR=$8
MODULECOMDIR=$(eval echo $MODULECOMDIR)

#as923
REGIONFREQ=$9
REGIONFREQ=$(eval echo $REGIONFREQ)

#1
REGIONGFREQCHANNEL=${10}
REGIONGFREQCHANNEL=$(eval echo $REGIONGFREQCHANNEL)

#as923-1

REGIONFREQNUMBER=${11}
REGIONFREQNUMBER=$(eval echo $REGIONFREQNUMBER)

#subbandValue

REGIONFREQVALUE=${12}
REGIONFREQVALUE=$(eval echo $REGIONFREQVALUE)

#============================================================================

#dialog   --msgbox " FILEPATH: $GATEWAY $GATEWAYVALUE $MODULEPATH $MODULEPATHVALUE $MODULECOMTYPE  $GPS $LBT  $MODULECOMDIR $REGIONFREQ  $REGIONFREQNUMBER  $REGIONFREQVALUE  Configured " 8 80

#dialog   --msgbox " FILEPATH: $MODULEPATH $REGIONFREQNUMBER   Configured " 8 80
 
R_FILEPATH=$SCRIPT_DIR/$MODULEPATH/region/global_conf.$REGIONFREQNUMBER.json    

if [ "$MODULEPATH" = "rak2245" ]; then
SX130X="SX1301_conf"
 
else
SX130X="SX130x_conf"
 
fi

 

freq0=$(jq .$SX130X.radio_0.freq $R_FILEPATH)
freq0=$(eval echo $freq0)

freq1=$(jq .$SX130X.radio_1.freq $R_FILEPATH)
freq1=$(eval echo $freq1)



if [ "$MODULELBT" = "LBT" ]; then

lbt0=$(jq .$SX130X.sx1261_conf.lbt.channels[0].freq_hz $R_FILEPATH)
lbt0=$(eval echo $lbt0)

lbtbw0=$(jq .$SX130X.sx1261_conf.lbt.channels[0].bandwidth $R_FILEPATH)
lbtbw0=$(eval echo $lbtbw0)

lbtst0=$(jq .$SX130X.sx1261_conf.lbt.channels[0].scan_time_us $R_FILEPATH)
lbtst0=$(eval echo $lbtst0)

lbttt0=$(jq .$SX130X.sx1261_conf.lbt.channels[0].transmit_time_ms $R_FILEPATH)
lbttt0=$(eval echo $lbttt0)

lbt1=$(jq .$SX130X.sx1261_conf.lbt.channels[1].freq_hz $R_FILEPATH)
lbt1=$(eval echo $lbt1)

lbtbw1=$(jq .$SX130X.sx1261_conf.lbt.channels[1].bandwidth $R_FILEPATH)
lbtbw1=$(eval echo $lbtbw1)

lbtst1=$(jq .$SX130X.sx1261_conf.lbt.channels[1].scan_time_us $R_FILEPATH)
lbtst1=$(eval echo $lbtst1)

lbttt1=$(jq .$SX130X.sx1261_conf.lbt.channels[1].transmit_time_ms $R_FILEPATH)
lbttt1=$(eval echo $lbttt1)

if [ "$lbt1" = "null" ]; then
lbt1="   OFF   "
lbtbw1="        "
lbtst1=" "
lbttt1=" "
fi


#
lbt2=$(jq .$SX130X.sx1261_conf.lbt.channels[2].freq_hz $R_FILEPATH)
lbt2=$(eval echo $lbt2)

lbtbw2=$(jq .$SX130X.sx1261_conf.lbt.channels[2].bandwidth $R_FILEPATH)
lbtbw2=$(eval echo $lbtbw2)

lbtst2=$(jq .$SX130X.sx1261_conf.lbt.channels[2].scan_time_us $R_FILEPATH)
lbtst2=$(eval echo $lbtst2)

lbttt2=$(jq .$SX130X.sx1261_conf.lbt.channels[2].transmit_time_ms $R_FILEPATH)
lbttt2=$(eval echo $lbttt2)

if [ "$lbt2" = "null" ]; then
lbt2="   OFF   "
lbtbw2="        "
lbtst2=" "
lbttt2=" "
fi


#3

lbt3=$(jq .$SX130X.sx1261_conf.lbt.channels[3].freq_hz $R_FILEPATH)
lbt3=$(eval echo $lbt3)

lbtbw3=$(jq .$SX130X.sx1261_conf.lbt.channels[3].bandwidth $R_FILEPATH)
lbtbw3=$(eval echo $lbtbw3)

lbtst3=$(jq .$SX130X.sx1261_conf.lbt.channels[3].scan_time_us $R_FILEPATH)
lbtst3=$(eval echo $lbtst3)

lbttt3=$(jq .$SX130X.sx1261_conf.lbt.channels[3].transmit_time_ms $R_FILEPATH)
lbttt3=$(eval echo $lbttt3)

if [ "$lbt3" = "null" ]; then
lbt3="   OFF   "
lbtbw3="        "
lbtst3=" "
lbttt3=" "
fi


#4

lbt4=$(jq .$SX130X.sx1261_conf.lbt.channels[4].freq_hz $R_FILEPATH)
lbt4=$(eval echo $lbt4)

lbtbw4=$(jq .$SX130X.sx1261_conf.lbt.channels[4].bandwidth $R_FILEPATH)
lbtbw4=$(eval echo $lbtbw4)

lbtst4=$(jq .$SX130X.sx1261_conf.lbt.channels[4].scan_time_us $R_FILEPATH)
lbtst4=$(eval echo $lbtst4)

lbttt4=$(jq .$SX130X.sx1261_conf.lbt.channels[4].transmit_time_ms $R_FILEPATH)
lbttt4=$(eval echo $lbttt4)

if [ "$lbt4" = "null" ]; then
lbt4="   OFF   "
lbtbw4="        "
lbtst4=" "
lbttt4=" "
fi


#4
lbt5=$(jq .$SX130X.sx1261_conf.lbt.channels[5].freq_hz $R_FILEPATH)
lbt5=$(eval echo $lbt5)

lbtbw5=$(jq .$SX130X.sx1261_conf.lbt.channels[5].bandwidth $R_FILEPATH)
lbtbw5=$(eval echo $lbtbw5)

lbtst5=$(jq .$SX130X.sx1261_conf.lbt.channels[5].scan_time_us $R_FILEPATH)
lbtst5=$(eval echo $lbtst5)

lbttt5=$(jq .$SX130X.sx1261_conf.lbt.channels[5].transmit_time_ms $R_FILEPATH)
lbttt5=$(eval echo $lbttt5)

if [ "$lbt5" = "null" ]; then
lbt5="   OFF   "
lbtbw5="        "
lbtst5=" "
lbttt5=" "
fi


#6
lbt6=$(jq .$SX130X.sx1261_conf.lbt.channels[6].freq_hz $R_FILEPATH)
lbt6=$(eval echo $lbt6)

lbtbw6=$(jq .$SX130X.sx1261_conf.lbt.channels[6].bandwidth $R_FILEPATH)
lbtbw6=$(eval echo $lbtbw6)

lbtst6=$(jq .$SX130X.sx1261_conf.lbt.channels[6].scan_time_us $R_FILEPATH)
lbtst6=$(eval echo $lbtst6)

lbttt6=$(jq .$SX130X.sx1261_conf.lbt.channels[6].transmit_time_ms $R_FILEPATH)
lbttt6=$(eval echo $lbttt6)

if [ "$lbt6" = "null" ]; then
lbt6="   OFF   "
lbtbw6="        "
lbtst6=" "
lbttt6=" "
fi

#7
lbt7=$(jq .$SX130X.sx1261_conf.lbt.channels[7].freq_hz $R_FILEPATH)
lbt7=$(eval echo $lbt7)

lbtbw7=$(jq .$SX130X.sx1261_conf.lbt.channels[7].bandwidth $R_FILEPATH)
lbtbw7=$(eval echo $lbtbw7)

lbtst7=$(jq .$SX130X.sx1261_conf.lbt.channels[7].scan_time_us $R_FILEPATH)
lbtst7=$(eval echo $lbtst7)

lbttt7=$(jq .$SX130X.sx1261_conf.lbt.channels[7].transmit_time_ms $R_FILEPATH)
lbttt7=$(eval echo $lbttt7)

if [ "$lbt7" = "null" ]; then
lbt7="   OFF   "
lbtbw7="        "
lbtst7=" "
lbttt7=" "
fi

#8

lbt8=$(jq .$SX130X.sx1261_conf.lbt.channels[8].freq_hz $R_FILEPATH)
lbt8=$(eval echo $lbt8)

lbtbw8=$(jq .$SX130X.sx1261_conf.lbt.channels[8].bandwidth $R_FILEPATH)
lbtbw8=$(eval echo $lbtbw0)

lbtst8=$(jq .$SX130X.sx1261_conf.lbt.channels[8].scan_time_us $R_FILEPATH)
lbtst8="SCANTIME$(eval echo $lbtst8)uS"

lbttt8=$(jq .$SX130X.sx1261_conf.lbt.channels[8].transmit_time_ms $R_FILEPATH)
lbttt8="TRANSMITTIME$(eval echo $lbttt8)mS"
 

if [ "$lbt8" = "null" ]; then
lbt8="   OFF   "
lbtbw8="        "
lbtst8=" "
lbttt8=" "
fi

fi


{ 
#SF0
sfenable=$(jq .$SX130X.chan_multiSF_0.enable $R_FILEPATH)
sfenable=$(eval echo $sfenable)

if [ "$sfenable" = "true" ]; then

sfradio=$(jq .$SX130X.chan_multiSF_0.radio $R_FILEPATH)
sfradio=$(eval echo $sfradio)
BW0="BW125KHZ"
SFACTOR0="SF7/SF12"
COMMENT0="LORA_MULTI_SF"

freqoffset=$(jq .$SX130X.chan_multiSF_0.if $R_FILEPATH)
freqoffset=$(eval echo $freqoffset)
 
if [ "$sfradio" = "0" ]; then
CHFREQ0=$(( $freq0 + $freqoffset ))
RADIO0=A
else
CHFREQ0=$(( $freq1 + $freqoffset ))
RADIO0=B
fi
else
CHFREQ0="   OFF   "
SFACTOR0="        "
RADIO0=" "
COMMENT0=" "
BW0="        "
fi 

#SF1
sfenable=$(jq .$SX130X.chan_multiSF_1.enable $R_FILEPATH)
sfenable=$(eval echo $sfenable)

if [ "$sfenable" = "true" ]; then

sfradio=$(jq .$SX130X.chan_multiSF_1.radio $R_FILEPATH)
sfradio=$(eval echo $sfradio)

BW1="BW125KHZ"
SFACTOR1="SF7/SF12"
COMMENT1="LORA_MULTI_SF"

freqoffset=$(jq .$SX130X.chan_multiSF_1.if $R_FILEPATH)
freqoffset=$(eval echo $freqoffset)
 
if [ "$sfradio" = "0" ]; then
CHFREQ1=$(( $freq0 + $freqoffset ))
RADIO1=A
else
CHFREQ1=$(( $freq1 + $freqoffset ))
RADIO1=B
fi
else
CHFREQ1="   OFF   "
SFACTOR1="        "
RADIO1=" "
COMMENT1=" "
BW1="        "
fi 

#SF2
sfenable=$(jq .$SX130X.chan_multiSF_2.enable $R_FILEPATH)
sfenable=$(eval echo $sfenable)

if [ "$sfenable" = "true" ]; then

sfradio=$(jq .$SX130X.chan_multiSF_2.radio $R_FILEPATH)
sfradio=$(eval echo $sfradio)

BW2="BW125KHZ"
SFACTOR2="SF7/SF12"
COMMENT2="LORA_MULTI_SF"
 
freqoffset=$(jq .$SX130X.chan_multiSF_2.if $R_FILEPATH)
freqoffset=$(eval echo $freqoffset)
 
if [ "$sfradio" = "0" ]; then
CHFREQ2=$(( $freq0 + $freqoffset ))
RADIO2=A
else
CHFREQ2=$(( $freq1 + $freqoffset ))
RADIO2=B
fi
else
CHFREQ2="   OFF   "
SFACTOR2="        "
RADIO2=" "
COMMENT2=" "
BW2="        "
fi 


#SF3

sfenable=$(jq .$SX130X.chan_multiSF_3.enable $R_FILEPATH)
sfenable=$(eval echo $sfenable)

if [ "$sfenable" = "true" ]; then

sfradio=$(jq .$SX130X.chan_multiSF_3.radio $R_FILEPATH)
sfradio=$(eval echo $sfradio)


BW3="BW125KHZ"
SFACTOR3="SF7/SF12"
COMMENT3="LORA_MULTI_SF"

freqoffset=$(jq .$SX130X.chan_multiSF_3.if $R_FILEPATH)
freqoffset=$(eval echo $freqoffset)
 
if [ "$sfradio" = "0" ]; then
CHFREQ3=$(( $freq0 + $freqoffset ))
RADIO3=A
else
CHFREQ3=$(( $freq1 + $freqoffset ))
RADIO3=B
fi
else
CHFREQ3="   OFF   "
SFACTOR3="        "
RADIO3=" "
COMMENT3=" "
BW3="        "
fi 

#SF4

sfenable=$(jq .$SX130X.chan_multiSF_4.enable $R_FILEPATH)
sfenable=$(eval echo $sfenable)

if [ "$sfenable" = "true" ]; then

sfradio=$(jq .$SX130X.chan_multiSF_4.radio $R_FILEPATH)
sfradio=$(eval echo $sfradio)


BW4="BW125KHZ" 
SFACTOR4="SF7/SF12"
COMMENT4="LORA_MULTI_SF"

freqoffset=$(jq .$SX130X.chan_multiSF_4.if $R_FILEPATH)
freqoffset=$(eval echo $freqoffset)
 
if [ "$sfradio" = "0" ]; then
CHFREQ4=$(( $freq0 + $freqoffset ))
RADIO4=A
else
CHFREQ4=$(( $freq1 + $freqoffset ))
RADIO4=B
fi
else
CHFREQ4="   OFF   "
SFACTOR4="        "
RADIO4=" "
COMMENT4=" "
BW4="        "
fi 


#SF5
sfenable=$(jq .$SX130X.chan_multiSF_5.enable $R_FILEPATH)
sfenable=$(eval echo $sfenable)

if [ "$sfenable" = "true" ]; then

sfradio=$(jq .$SX130X.chan_multiSF_5.radio $R_FILEPATH)
sfradio=$(eval echo $sfradio)

 
BW5="BW125KHZ"
SFACTOR5="SF7/SF12"
COMMENT5="LORA_MULTI_SF"

freqoffset=$(jq .$SX130X.chan_multiSF_5.if $R_FILEPATH)
freqoffset=$(eval echo $freqoffset)
 
if [ "$sfradio" = "0" ]; then
CHFREQ5=$(( $freq0 + $freqoffset ))
RADIO5=A
else
CHFREQ5=$(( $freq1 + $freqoffset ))
RADIO5=B
fi
else
CHFREQ5="   OFF   "
SFACTOR5="        "
RADIO5=" "
COMMENT5=" "
BW5="        "
fi 

#SF6

sfenable=$(jq .$SX130X.chan_multiSF_6.enable $R_FILEPATH)
sfenable=$(eval echo $sfenable)

if [ "$sfenable" = "true" ]; then

sfradio=$(jq .$SX130X.chan_multiSF_6.radio $R_FILEPATH)
sfradio=$(eval echo $sfradio)
 
BW6="BW125KHZ"
SFACTOR6="SF7/SF12"
COMMENT6="LORA_MULTI_SF"

freqoffset=$(jq .$SX130X.chan_multiSF_6.if $R_FILEPATH)
freqoffset=$(eval echo $freqoffset)
 
if [ "$sfradio" = "0" ]; then
CHFREQ6=$(( $freq0 + $freqoffset ))
RADIO6=A
else
CHFREQ6=$(( $freq1 + $freqoffset ))
RADIO6=B
fi
else
CHFREQ6="   OFF   "
SFACTOR6="        "
RADIO6=" "
COMMENT6=" "
BW6="        "
fi 


sfenable=$(jq .$SX130X.chan_multiSF_7.enable $R_FILEPATH)
sfenable=$(eval echo $sfenable)

if [ "$sfenable" = "true" ]; then

sfradio=$(jq .$SX130X.chan_multiSF_7.radio $R_FILEPATH)
sfradio=$(eval echo $sfradio)


BW7="BW125KHZ"
SFACTOR7="SF7/SF12"
COMMENT7="LORA_MULTI_SF"

freqoffset=$(jq .$SX130X.chan_multiSF_7.if $R_FILEPATH)
freqoffset=$(eval echo $freqoffset)
 
if [ "$sfradio" = "0" ]; then
CHFREQ7=$(( $freq0 + $freqoffset ))
RADIO7=A
else
CHFREQ7=$(( $freq1 + $freqoffset ))
RADIO7=B
fi
else
CHFREQ7="   OFF   "
SFACTOR7="        "
RADIO7=" "
COMMENT7=" "
BW7="        "
fi 


#chan_FSK
sfenable=$(jq .$SX130X.chan_FSK.enable $R_FILEPATH)
sfenable=$(eval echo $sfenable)

if [ "$sfenable" = "true" ]; then

sfradio=$(jq .$SX130X.chan_FSK.radio $R_FILEPATH)
sfradio=$(eval echo $sfradio)


	
freqoffset=$(jq .$SX130X.chan_FSK.if $R_FILEPATH)
freqoffset=$(eval echo $freqoffset)

bandwidth=$(jq .$SX130X.chan_FSK.bandwidth $R_FILEPATH)
bandwidth=$(eval echo $bandwidth)

datarate=$(jq .$SX130X.chan_FSK.datarate $R_FILEPATH)
datarate=$(eval echo $datarate)

num="1000"
BW8="BW$(($bandwidth / $num))KHz"
COMMENT8="FSK"
SFACTOR8="$datarate   "
 
if [ "$sfradio" = "0" ]; then
CHFREQ8=$(( $freq0 + $freqoffset ))
RADIO8=A
else
CHFREQ8=$(( $freq1 + $freqoffset ))
RADIO8=B
fi
else
CHFREQ8="   OFF   "
SFACTOR8="        "
RADIO8=" "
COMMENT8=" "
BW8="        "

fi 


#chan_Lora_std

sfenable=$(jq .$SX130X.chan_Lora_std.enable $R_FILEPATH)
sfenable=$(eval echo $sfenable)

if [ "$sfenable" = "true" ]; then

sfradio=$(jq .$SX130X.chan_Lora_std.radio $R_FILEPATH)
sfradio=$(eval echo $sfradio)

freqoffset=$(jq .$SX130X.chan_Lora_std.if $R_FILEPATH)
freqoffset=$(eval echo $freqoffset)

bandwidth=$(jq .$SX130X.chan_Lora_std.bandwidth $R_FILEPATH)
bandwidth=$(eval echo $bandwidth)

spreadfactor=$(jq .$SX130X.chan_Lora_std.spread_factor $R_FILEPATH)
spreadfactor=$(eval echo $spreadfactor)

num="1000"
BW9="BW$(($bandwidth / $num))KHz"
COMMENT9="LORA_STD"
SFACTOR9="SF$spreadfactor     "
 
if [ "$sfradio" = "0" ]; then
CHFREQ9=$(( $freq0 + $freqoffset ))
RADIO9=A
else
CHFREQ9=$(( $freq1 + $freqoffset ))
RADIO9=B
fi
else 

CHFREQ9="   OFF   "
SFACTOR9="        "
RADIO9=" "
COMMENT9=" "
BW9="        "


fi 

}

dialog --title " $1 Configuration   " --msgbox "\n
ISM BAND   : [$REGIONFREQNUMBER]\n
CHANNEL0   : $CHFREQ0  $RADIO0  $SFACTOR0  ${BW0}  $COMMENT0\n 
CHANNEL1   : $CHFREQ1  $RADIO1  $SFACTOR1  ${BW1}  $COMMENT1\n
CHANNEL2   : $CHFREQ2  $RADIO2  $SFACTOR2  ${BW2}  $COMMENT2\n
CHANNEL3   : $CHFREQ3  $RADIO3  $SFACTOR3  ${BW3}  $COMMENT3\n
CHANNEL4   : $CHFREQ4  $RADIO4  $SFACTOR4  ${BW4}  $COMMENT4\n
CHANNEL5   : $CHFREQ5  $RADIO5  $SFACTOR5  ${BW5}  $COMMENT5\n
CHANNEL6   : $CHFREQ6  $RADIO6  $SFACTOR6  ${BW6}  $COMMENT6\n
CHANNEL7   : $CHFREQ7  $RADIO7  $SFACTOR7  ${BW7}  $COMMENT7\n
CHANNEL8   : $CHFREQ8  $RADIO8  $SFACTOR8  ${BW8}  $COMMENT8\n
CHANNEL9   : $CHFREQ9  $RADIO9  $SFACTOR9  ${BW9}  $COMMENT9\n
" 18 70

if [ "$MODULELBT" = "LBT" ]; then

dialog --title " $1 LBT  Configuration   " --msgbox "\n
LBT        : [$REGIONFREQNUMBER]\n
LBTCHANNEL : FREQ[HZ]   BW[HZ]  SCAN[uS]  TRANSMIT[ms]\n   
CHANNEL0   : $lbt0  $lbtbw0    $lbtst0       $lbttt0\n 
CHANNEL1   : $lbt1  $lbtbw1    $lbtst1       $lbttt1\n
CHANNEL2   : $lbt2  $lbtbw2    $lbtst2       $lbttt2\n
CHANNEL3   : $lbt3  $lbtbw3    $lbtst3       $lbttt3\n
CHANNEL4   : $lbt4  $lbtbw4    $lbtst4       $lbttt4\n
CHANNEL5   : $lbt5  $lbtbw5    $lbtst5       $lbttt5\n
CHANNEL6   : $lbt6  $lbtbw6    $lbtst6       $lbttt6\n
CHANNEL7   : $lbt7  $lbtbw7    $lbtst7       $lbttt7\n
CHANNEL8   : $lbt8  $lbtbw8    $lbtst8       $lbttt8\n 
" 18 70

fi

dialog --title "Confirmation " --yesno "Are you sure you want to modify ISM Band:[$REGIONFREQNUMBER] " 5 70
RET=$?

if [ $RET -eq 1 ]; then

if [ "$MODULELBT" = "LBT" ]; then
freq_module_setup_lbt "$1" "$2" "$3" "$4" "$5" "$6" "$7" "$8" "$9" "$10"
else
freq_module_setup "$1" "$2" "$3" "$4" "$5" "$6" "$7" "$8" "$9" "$10"
fi

fi

if  [ $RET -eq 0 ]; then

dialog --title " frequency configuration " --infobox "\n
Please wait .....\n" 5 30

tmp=$(mktemp)

#writing data to stm32mp1-configuration.json
   
jq -r --arg MODULEPATH "$MODULEPATH" '.gateway_model.gw_path = $MODULEPATH' $STM32MP1_CONFIG > "$tmp" && mv "$tmp"  $STM32MP1_CONFIG

jq -r --arg MODULEPATHVALUE "$MODULEPATHVALUE" '.gateway_model.gw_path_value = $MODULEPATHVALUE' $STM32MP1_CONFIG > "$tmp" && mv "$tmp"  $STM32MP1_CONFIG

jq -r --arg MODULECOMTYPE "$MODULECOMTYPE" '.gateway_model.gw_com_typ = $MODULECOMTYPE' $STM32MP1_CONFIG > "$tmp" && mv "$tmp"  $STM32MP1_CONFIG 

jq -r --arg MODULEGPS "$MODULEGPS" '.gateway_model.gw_com_gps = $MODULEGPS' $STM32MP1_CONFIG > "$tmp" && mv "$tmp"  $STM32MP1_CONFIG

jq -r --arg MODULELBT "$MODULELBT" '.gateway_model.gw_com_lbt = $MODULELBT' $STM32MP1_CONFIG > "$tmp" && mv "$tmp"  $STM32MP1_CONFIG

jq -r --arg MODULECOMDIR "$MODULECOMDIR" '.gateway_model.gw_com_path = $MODULECOMDIR' $STM32MP1_CONFIG > "$tmp" && mv "$tmp" $STM32MP1_CONFIG 

#region_frequency - IN865 
jq -r --arg REGIONFREQ "$REGIONFREQ" '.gateway_server.server_freq_region = $REGIONFREQ' $STM32MP1_CONFIG > "$tmp" && mv "$tmp" $STM32MP1_CONFIG

#region_frequency - 7
jq -r --arg REGIONGFREQCHANNEL "$REGIONGFREQCHANNEL" '.gateway_server.server_freq_region_value = $REGIONGFREQCHANNEL' $STM32MP1_CONFIG > "$tmp" && mv "$tmp" $STM32MP1_CONFIG

# IN865_867_1
jq -r --arg REGIONFREQNUMBER "$REGIONFREQNUMBER" '.gateway_server.server_freq_channel = $REGIONFREQNUMBER' $STM32MP1_CONFIG > "$tmp" && mv "$tmp" $STM32MP1_CONFIG

# subband =1
jq -r --arg REGIONFREQVALUE "$REGIONFREQVALUE" '.gateway_server.server_freq_channel_value = $REGIONFREQVALUE' $STM32MP1_CONFIG > "$tmp" && mv "$tmp" $STM32MP1_CONFIG

jq -r --arg GATEWAY "$GATEWAY" '.gateway_server.server_path = $GATEWAY' $STM32MP1_CONFIG > "$tmp" && mv "$tmp" $STM32MP1_CONFIG

jq -r --arg GATEWAYVALUE "$GATEWAYVALUE" '.gateway_server.server_path_value = $GATEWAYVALUE' $STM32MP1_CONFIG > "$tmp" && mv "$tmp" $STM32MP1_CONFIG

#writing data to global_conf.json

sudo cp $SCRIPT_DIR/$MODULEPATH/region/global_conf.$REGIONFREQNUMBER.json $SCRIPT_DIR/$MODULEPATH/global_conf.json


if [ "$GATEWAY" = "chirpstack-server" ]; then

sudo cp $CHIRP_DIR/config/chirpstack-network-server.$REGIONFREQNUMBER.toml $CHIRP_DIR/chirpstack-network-server.toml

fi

if [ "$MODULEPATH" = "rak2245" ]; then

FILEPATH=$SCRIPT_DIR/$MODULEPATH/global_conf.json

else 

FILEPATH=$SCRIPT_DIR/$MODULEPATH/global_conf.json
 
jq -r --arg MODULECOMTYPE "$MODULECOMTYPE" '.SX130x_conf.com_type = $MODULECOMTYPE' $FILEPATH > "$tmp" && mv "$tmp" $FILEPATH 

jq -r --arg MODULECOMDIR "$MODULECOMDIR" '.SX130x_conf.com_path = $MODULECOMDIR' $FILEPATH > "$tmp" && mv "$tmp" $FILEPATH

fi

# verify the configuration
dialog --title " Gateway Configuration " --msgbox " MODULE[$MODULEPATH,$MODULECOMTYPE],Frequency channel["$REGIONFREQNUMBER"] Configured " 5 70

if [ "$1" = "chirpstack-server" ]; then
func_chirpstackserver
else
func_loRagateway
fi

fi

}

gateway_freq_kr920(){

#"chirpstack-server" "2"
#"$1" "$2" "rak2287"  "1"  "SPI" "/dev/spidev0.0"  "GPS" "LBT"  "kr920" "<band Value>"
# $1   $2   $3        $4    $5    $6                $7    $8      $9      $10       
# $1   $2   $3        $4    $5    $6  		        $7    $8      $9      $10          "freqchannel" "freqchannel value"

default_item=$(jq .gateway_server.server_freq_channel_value $STM32MP1_CONFIG) 
default_item=$(eval echo $default_item)

parameter10=${10}

FUN=$(dialog --title "  configuration " --default-item $default_item --cancel-label "back" --menu "Please Select frequency Channel  :" 19 50 18 \
1  "KR920_923_1" \
3>&1 1>&2 2>&3)
    RET=$?
if [ $RET -eq 1 ]; then 
:
elif [ $RET -eq 0 ]; then
  case "$FUN" in
	1) gateway_frequency_config  "$1" "$2" "$3" "$4" "$5" "$6" "$7" "$8" "$9" "$parameter10" "kr920-923-1" "1" ;;
esac
fi

freq_module_setup "$1" "$2" "$3" "$4" "$5" "$6" "$7" "$8" "$9" "$parameter10"  


}

gateway_freq_as923(){

#"chirpstack-server" "2"
#"$1" "$2" "rak2287"  "1"  "SPI" "/dev/spidev0.0"  "GPS" "LBT"  "as923" "<band Value>"
# $1   $2   $3        $4    $5    $6                $7    $8      $9      $10       
# $1   $2   $3        $4    $5    $6  		        $7    $8      $9      $10          "freqchannel" "freqchannel value"

default_item=$(jq .gateway_server.server_freq_channel_value $STM32MP1_CONFIG) 
default_item=$(eval echo $default_item)

parameter10=${10}

FUN=$(dialog --title "  configuration " --default-item $default_item --cancel-label "back" --menu "Please Select frequency Channel  :" 19 50 18 \
1  "AS923_1" \
2  "AS923_2" \
3  "AS923_3" \
4  "AS923_4" \
3>&1 1>&2 2>&3)
    RET=$?
if [ $RET -eq 1 ]; then 
:
elif [ $RET -eq 0 ]; then
  case "$FUN" in
	1) gateway_frequency_config  "$1" "$2" "$3" "$4" "$5" "$6" "$7" "$8" "$9" "$parameter10" "as923-1" "1" ;;
	2) gateway_frequency_config  "$1" "$2" "$3" "$4" "$5" "$6" "$7" "$8" "$9" "$parameter10" "as923-2" "2" ;;
	3) gateway_frequency_config  "$1" "$2" "$3" "$4" "$5" "$6" "$7" "$8" "$9" "$parameter10" "as923-3" "3" ;;
	4) gateway_frequency_config  "$1" "$2" "$3" "$4" "$5" "$6" "$7" "$8" "$9" "$parameter10" "as923-4" "4" ;; 
esac
fi

freq_module_setup "$1" "$2" "$3" "$4" "$5" "$6" "$7" "$8" "$9" "$parameter10"  

}

gateway_freq_as923_lbt(){
#"chirpstack-server" "2"
#"$1" "$2" "rak2287"  "1"  "SPI" "/dev/spidev0.0"  "GPS" "LBT"  "as923" "<band Value>"
# $1   $2   $3        $4    $5    $6                $7    $8      $9      $10       
# $1   $2   $3        $4    $5    $6  		        $7    $8      $9      $10          "freqchannel" "freqchannel value"



default_item=$(jq .gateway_server.server_freq_channel_value $STM32MP1_CONFIG) 
default_item=$(eval echo $default_item)

parameter10=${10}
 
FUN=$(dialog --title "  configuration " --default-item $default_item --cancel-label "back" --menu "Please Select frequency Channel  :" 19 50 18 \
1  "AS923_1_LBT" \
2  "AS923_2_LBT" \
3  "AS923_3_LBT" \
4  "AS923_4_LBT" \
3>&1 1>&2 2>&3)
    RET=$?
if [ $RET -eq 1 ]; then 
:
elif [ $RET -eq 0 ]; then
  case "$FUN" in
	1) gateway_frequency_config  "$1" "$2" "$3" "$4" "$5" "$6" "$7" "$8" "$9" "$parameter10" "as923-1-lbt" "1" ;;
	2) gateway_frequency_config  "$1" "$2" "$3" "$4" "$5" "$6" "$7" "$8" "$9" "$parameter10" "as923-2-lbt" "2" ;;
	3) gateway_frequency_config  "$1" "$2" "$3" "$4" "$5" "$6" "$7" "$8" "$9" "$parameter10" "as923-3-lbt" "3" ;;
	4) gateway_frequency_config  "$1" "$2" "$3" "$4" "$5" "$6" "$7" "$8" "$9" "$parameter10" "as923-4-lbt" "4" ;;
esac
fi

freq_module_setup "$1" "$2" "$3" "$4" "$5" "$6" "$7" "$8" "$9" "$parameter10"  


}

gateway_freq_kr920_lbt(){

#"chirpstack-server" "2"
#"$1" "$2" "rak2287"  "1"  "SPI" "/dev/spidev0.0"  "GPS" "LBT"  "as923" "<band Value>"
# $1   $2   $3        $4    $5    $6                $7    $8      $9      $10       
# $1   $2   $3        $4    $5    $6  		        $7    $8      $9      $10          "freqchannel" "freqchannel value"

default_item=$(jq .gateway_server.server_freq_channel_value $STM32MP1_CONFIG) 
default_item=$(eval echo $default_item)

parameter10=${10}

FUN=$(dialog --title "  configuration " --default-item $default_item --cancel-label "back" --menu "Please Select frequency Channel  :" 19 50 18 \
1  "KR_920_923_LBT" \
3>&1 1>&2 2>&3)
    RET=$?
if [ $RET -eq 1 ]; then 
:
elif [ $RET -eq 0 ]; then
  case "$FUN" in
	1) gateway_frequency_config  "$1" "$2" "$3" "$4" "$5" "$6" "$7" "$8" "$9" "$parameter10" "kr920-923-lbt" "1" ;; 
esac
fi

freq_module_setup "$1" "$2" "$3" "$4" "$5" "$6" "$7" "$8" "$9" "$parameter10"  

}


gateway_freq_au915(){
#"chirpstack-server" "2"
#"$1" "$2" "rak2287"  "1"  "SPI" "/dev/spidev0.0"  "GPS" "LBT"  "us915" "<band Value>"
# $1   $2   $3        $4    $5    $6                $7    $8      $9      $10       
# $1   $2   $3        $4    $5    $6  		        $7    $8      $9      $10          "freqchannel" "freqchannel value"


default_item=$(jq .gateway_server.server_freq_channel_value $STM32MP1_CONFIG) 
default_item=$(eval echo $default_item)

parameter10=${10}

FUN=$(dialog --title "  configuration " --default-item $default_item --cancel-label "back" --menu "Please Select frequency Channel  :" 19 50 18 \
1  "AU915_928_1" \
2  "AU915_928_2" \
3  "AU915_928_3" \
4  "AU915_928_4" \
5  "AU915_928_5" \
6  "AU915_928_6" \
7  "AU915_928_7" \
8  "AU915_928_8" \
3>&1 1>&2 2>&3)
    RET=$?
if [ $RET -eq 1 ]; then 
:
elif [ $RET -eq 0 ]; then
  case "$FUN" in
	1) gateway_frequency_config  "$1" "$2" "$3" "$4" "$5" "$6" "$7" "$8" "$9" "$parameter10" "au915-928-1" "1" ;;
	2) gateway_frequency_config  "$1" "$2" "$3" "$4" "$5" "$6" "$7" "$8" "$9" "$parameter10" "au915-928-2" "2" ;;
	3) gateway_frequency_config  "$1" "$2" "$3" "$4" "$5" "$6" "$7" "$8" "$9" "$parameter10" "au915-928-3" "3" ;;
	4) gateway_frequency_config  "$1" "$2" "$3" "$4" "$5" "$6" "$7" "$8" "$9" "$parameter10" "au915-928-4" "4" ;;
	5) gateway_frequency_config  "$1" "$2" "$3" "$4" "$5" "$6" "$7" "$8" "$9" "$parameter10" "au915-928-5" "5" ;;
	6) gateway_frequency_config  "$1" "$2" "$3" "$4" "$5" "$6" "$7" "$8" "$9" "$parameter10" "au915-928-6" "6" ;;
	7) gateway_frequency_config  "$1" "$2" "$3" "$4" "$5" "$6" "$7" "$8" "$9" "$parameter10" "au915-928-7" "7" ;;
	8) gateway_frequency_config  "$1" "$2" "$3" "$4" "$5" "$6" "$7" "$8" "$9" "$parameter10" "au915-928-8" "8" ;; 
esac
fi

freq_module_setup "$1" "$2" "$3" "$4" "$5" "$6" "$7" "$8" "$9" "$parameter10"
}

gateway_freq_cn470(){
#"chirpstack-server" "2"
#"$1" "$2" "rak2287"  "1"  "SPI" "/dev/spidev0.0"  "GPS" "LBT"  "cn470" "<band Value>"
# $1   $2   $3        $4    $5    $6                $7    $8      $9      $10       
# $1   $2   $3        $4    $5    $6  		        $7    $8      $9      $10          "freqchannel" "freqchannel value"


default_item=$(jq .gateway_server.server_freq_channel_value $STM32MP1_CONFIG) 
default_item=$(eval echo $default_item)

parameter10=${10}

FUN=$(dialog --title "  configuration " --default-item $default_item --cancel-label "back" --menu "Please Select frequency Channel  :" 19 50 18 \
1   "CN470_510_1" \
2   "CN470_510_2" \
3   "CN470_510_3" \
4   "CN470_510_4" \
5   "CN470_510_5" \
6   "CN470_510_6" \
7   "CN470_510_7" \
8   "CN470_510_8" \
9   "CN470_510_9" \
10  "CN470_510_10" \
11  "CN470_510_11" \
12  "CN470_510_12" \
3>&1 1>&2 2>&3)
    RET=$?
if [ $RET -eq 1 ]; then 
:
elif [ $RET -eq 0 ]; then
  case "$FUN" in
	1) gateway_frequency_config  "$1" "$2" "$3" "$4" "$5" "$6" "$7" "$8" "$9" "$parameter10" "cn470-510-1" "1" ;;
	2) gateway_frequency_config  "$1" "$2" "$3" "$4" "$5" "$6" "$7" "$8" "$9" "$parameter10" "cn470-510-2" "2" ;;
	3) gateway_frequency_config  "$1" "$2" "$3" "$4" "$5" "$6" "$7" "$8" "$9" "$parameter10" "cn470-510-3" "3" ;;
	4) gateway_frequency_config  "$1" "$2" "$3" "$4" "$5" "$6" "$7" "$8" "$9" "$parameter10" "cn470-510-4" "4" ;;
	5) gateway_frequency_config  "$1" "$2" "$3" "$4" "$5" "$6" "$7" "$8" "$9" "$parameter10" "cn470-510-5" "5" ;;
	6) gateway_frequency_config  "$1" "$2" "$3" "$4" "$5" "$6" "$7" "$8" "$9" "$parameter10" "cn470-510-6" "6" ;;
	7) gateway_frequency_config  "$1" "$2" "$3" "$4" "$5" "$6" "$7" "$8" "$9" "$parameter10" "cn470-510-7" "7" ;;
	8) gateway_frequency_config  "$1" "$2" "$3" "$4" "$5" "$6" "$7" "$8" "$9" "$parameter10" "cn470-510-8" "8" ;;
	9) gateway_frequency_config  "$1" "$2" "$3" "$4" "$5" "$6" "$7" "$8" "$9" "$parameter10" "cn470-510-9" "9" ;; 
	10) gateway_frequency_config  "$1" "$2" "$3" "$4" "$5" "$6" "$7" "$8" "$9" "$parameter10" "cn470-510-10" "10" ;; 
	11) gateway_frequency_config  "$1" "$2" "$3" "$4" "$5" "$6" "$7" "$8" "$9" "$parameter10" "cn470-510-11" "11" ;; 
	12) gateway_frequency_config  "$1" "$2" "$3" "$4" "$5" "$6" "$7" "$8" "$9" "$parameter10" "cn470-510-12" "12" ;; 
esac
fi

freq_module_setup "$1" "$2" "$3" "$4" "$5" "$6" "$7" "$8" "$9" "$parameter10"
}

gateway_freq_cn779(){

#"chirpstack-server" "2"
#"$1" "$2" "rak2287"  "1"  "SPI" "/dev/spidev0.0"  "GPS" "LBT"  "cn779" "<band Value>"
# $1   $2   $3        $4    $5    $6                $7    $8      $9      $10       
# $1   $2   $3        $4    $5    $6  		        $7    $8      $9      $10          "freqchannel" "freqchannel value"


default_item=$(jq .gateway_server.server_freq_channel_value $STM32MP1_CONFIG) 
default_item=$(eval echo $default_item)

$parameter10=${10}

FUN=$(dialog --title "  configuration " --default-item $default_item --cancel-label "back" --menu "Please Select frequency Channel  :" 19 50 18 \
1  "CN779_787_1" \
3>&1 1>&2 2>&3)
    RET=$?
if [ $RET -eq 1 ]; then 
:
elif [ $RET -eq 0 ]; then
  case "$FUN" in
	1) gateway_frequency_config  "$1" "$2" "$3" "$4" "$5" "$6" "$7" "$8" "$9" "$parameter10" "cn779-787-1" "1" ;;
esac
fi

freq_module_setup "$1" "$2" "$3" "$4" "$5" "$6" "$7" "$8" "$9" "$parameter10"


}

gateway_freq_eu433(){

#"chirpstack-server" "2"
#"$1" "$2" "rak2287"  "1"  "SPI" "/dev/spidev0.0"  "GPS" "LBT"  "eu433" "<band Value>"
# $1   $2   $3        $4    $5    $6                $7    $8      $9      $10       
# $1   $2   $3        $4    $5    $6  		        $7    $8      $9      $10          "freqchannel" "freqchannel value"

default_item=$(jq .gateway_server.server_freq_channel_value $STM32MP1_CONFIG) 
default_item=$(eval echo $default_item)

parameter10=${10}

FUN=$(dialog --title "  configuration " --default-item $default_item --cancel-label "back" --menu "Please Select frequency Channel  :" 19 50 18 \
1  "EU433_1" \
3>&1 1>&2 2>&3)
    RET=$?
if [ $RET -eq 1 ]; then 
:
elif [ $RET -eq 0 ]; then
  case "$FUN" in
	1) gateway_frequency_config  "$1" "$2" "$3" "$4" "$5" "$6" "$7" "$8" "$9" "$parameter10" "eu433-434-1" "1" ;;
esac
fi

freq_module_setup "$1" "$2" "$3" "$4" "$5" "$6" "$7" "$8" "$9" "$parameter10"



}

gateway_freq_eu868(){

#"chirpstack-server" "2"
#"$1" "$2" "rak2287"  "1"  "SPI" "/dev/spidev0.0"  "GPS" "LBT"  "eu868" "<band Value>"
# $1   $2   $3        $4    $5    $6                $7    $8      $9      $10       
# $1   $2   $3        $4    $5    $6  		        $7    $8      $9      $10          "freqchannel" "freqchannel value"


default_item=$(jq .gateway_server.server_freq_channel_value $STM32MP1_CONFIG) 
default_item=$(eval echo $default_item)

parameter10=${10}

FUN=$(dialog --title "  configuration " --default-item $default_item --cancel-label "back" --menu "Please Select frequency Channel  :" 19 50 18 \
1  "EU863_870_1" \
3>&1 1>&2 2>&3)
    RET=$?
if [ $RET -eq 1 ]; then 
:
elif [ $RET -eq 0 ]; then
  case "$FUN" in
	1) gateway_frequency_config  "$1" "$2" "$3" "$4" "$5" "$6" "$7" "$8" "$9" "$parameter10" "eu863-870-1" "1" ;;
esac
fi

freq_module_setup "$1" "$2" "$3" "$4" "$5" "$6" "$7" "$8" "$9" "$parameter10"


}

gateway_freq_in865(){

#"chirpstack-server" "2"
#"$1" "$2" "rak2287"  "1"  "SPI" "/dev/spidev0.0"  "GPS" "LBT"  "in865" "<band Value>"
# $1   $2   $3        $4    $5    $6                $7    $8      $9      $10       
# $1   $2   $3        $4    $5    $6  		        $7    $8      $9      $10          "freqchannel" "freqchannel value"


default_item=$(jq .gateway_server.server_freq_channel_value $STM32MP1_CONFIG) 
default_item=$(eval echo $default_item)

parameter10=${10}

FUN=$(dialog --title "  configuration " --default-item $default_item --cancel-label "back" --menu "Please Select frequency Channel  :" 19 50 18 \
1  "IN865_867_1" \
3>&1 1>&2 2>&3)
    RET=$?
if [ $RET -eq 1 ]; then 
:
elif [ $RET -eq 0 ]; then
  case "$FUN" in
	1) gateway_frequency_config  "$1" "$2" "$3" "$4" "$5" "$6" "$7" "$8" "$9" "$parameter10" "in865-867-1" "1" ;;
esac
fi

freq_module_setup "$1" "$2" "$3" "$4" "$5" "$6" "$7" "$8" "$9" "$parameter10"


}

gateway_freq_ru864(){

#"chirpstack-server" "2"
#"$1" "$2" "rak2287"  "1"  "SPI" "/dev/spidev0.0"  "GPS" "LBT"  "ru864" "<band Value>"
# $1   $2   $3        $4    $5    $6                $7    $8      $9      $10       
# $1   $2   $3        $4    $5    $6  		        $7    $8      $9      $10          "freqchannel" "freqchannel value"

default_item=$(jq .gateway_server.server_freq_channel_value $STM32MP1_CONFIG) 
default_item=$(eval echo $default_item)

parameter10=${10}

FUN=$(dialog --title "  configuration " --default-item $default_item --cancel-label "back" --menu "Please Select frequency Channel  :" 19 50 18 \
1  "RU864_870_1" \
3>&1 1>&2 2>&3)
    RET=$?
if [ $RET -eq 1 ]; then 
:
elif [ $RET -eq 0 ]; then
  case "$FUN" in
	1) gateway_frequency_config  "$1" "$2" "$3" "$4" "$5" "$6" "$7" "$8" "$9" "$parameter10" "ru864-870-1" "1" ;;
esac
fi

freq_module_setup "$1" "$2" "$3" "$4" "$5" "$6" "$7" "$8" "$9" "$parameter10"

}

gateway_freq_us915(){

#"chirpstack-server" "2" 
#"$1" "$2" "rak2287"  "1"  "SPI" "/dev/spidev0.0"  "GPS" "LBT"  "us915" "<band Value>"
# $1   $2   $3        $4    $5    $6                $7    $8      $9      $10       
# $1   $2   $3        $4    $5    $6  		        $7    $8      $9      $10          "freqchannel" "freqchannel value"


default_item=$(jq .gateway_server.server_freq_channel_value $STM32MP1_CONFIG) 
default_item=$(eval echo $default_item)

parameter10=${10}


FUN=$(dialog --title "  configuration " --default-item $default_item --cancel-label "back" --menu "Please Select frequency Channel  :" 19 50 18 \
1  "US902_928_1" \
2  "US902_928_2" \
3  "US902_928_3" \
4  "US902_928_4" \
5  "US902_928_5" \
6  "US902_928_6" \
7  "US902_928_7" \
8  "US902_928_8" \
3>&1 1>&2 2>&3)
    RET=$?
if [ $RET -eq 1 ]; then 
:
elif [ $RET -eq 0 ]; then
  case "$FUN" in
	1) gateway_frequency_config  "$1" "$2" "$3" "$4" "$5" "$6" "$7" "$8" "$9" "$parameter10" "us902-928-1" "1" ;;
	2) gateway_frequency_config  "$1" "$2" "$3" "$4" "$5" "$6" "$7" "$8" "$9" "$parameter10" "us902-928-2" "2" ;;
	3) gateway_frequency_config  "$1" "$2" "$3" "$4" "$5" "$6" "$7" "$8" "$9" "$parameter10" "us902-928-3" "3" ;;
	4) gateway_frequency_config  "$1" "$2" "$3" "$4" "$5" "$6" "$7" "$8" "$9" "$parameter10" "us902-928-4" "4" ;;
	5) gateway_frequency_config  "$1" "$2" "$3" "$4" "$5" "$6" "$7" "$8" "$9" "$parameter10" "us902-928-5" "5" ;;
	6) gateway_frequency_config  "$1" "$2" "$3" "$4" "$5" "$6" "$7" "$8" "$9" "$parameter10" "us902-928-6" "6" ;;
	7) gateway_frequency_config  "$1" "$2" "$3" "$4" "$5" "$6" "$7" "$8" "$9" "$parameter10" "us902-928-7" "7" ;;
	8) gateway_frequency_config  "$1" "$2" "$3" "$4" "$5" "$6" "$7" "$8" "$9" "$parameter10" "us902-928-8" "8" ;; 
esac
fi

freq_module_setup "$1" "$2" "$3" "$4" "$5" "$6" "$7" "$8" "$9" "$parameter10"

}

freq_module_setup(){

#"chirpstack-server" "2"
#"$1" "$2" "rak2287" "1" "SPI" "/dev/spidev0.0" "GPS" "LBT" "as923" "<band Value>
# $1   $2  $3        $4   $5   $6                $7    $8   $9      $10

default_item=$(jq .gateway_server.server_freq_region_value $STM32MP1_CONFIG) 
default_item=$(eval echo $default_item)
 

FUN=$(dialog --title "  configuration " --default-item $default_item --cancel-label "back" --menu "Please Select ISM BAND  :" 19 50 18 \
1  "AS923" \
2  "AU915" \
3  "CN470" \
4  "CN779" \
5  "EU433" \
6  "EU868" \
7  "IN865" \
8  "KR920" \
9  "RU864" \
10 "US915" \
3>&1 1>&2 2>&3)
RET=$?
if [ $RET -eq 1 ]; then 
:
elif [ $RET -eq 0 ]; then
  case "${FUN}" in
	1) gateway_freq_as923  "$1" "$2" "$3" "$4" "$5" "$6" "$7" "$8" "as923" "1" ;;
	2) gateway_freq_au915  "$1" "$2" "$3" "$4" "$5" "$6" "$7" "$8" "au915" "2" ;;
	3) gateway_freq_cn470  "$1" "$2" "$3" "$4" "$5" "$6" "$7" "$8" "cn470" "3" ;;
	4) gateway_freq_cn779  "$1" "$2" "$3" "$4" "$5" "$6" "$7" "$8" "cn779" "4" ;;
	5) gateway_freq_eu433  "$1" "$2" "$3" "$4" "$5" "$6" "$7" "$8" "eu433" "5" ;;
	6) gateway_freq_eu868  "$1" "$2" "$3" "$4" "$5" "$6" "$7" "$8" "eu868" "6" ;;
	7) gateway_freq_in865  "$1" "$2" "$3" "$4" "$5" "$6" "$7" "$8" "in865" "7" ;;
	8) gateway_freq_kr920  "$1" "$2" "$3" "$4" "$5" "$6" "$7" "$8" "kr920" "8" ;;
	9) gateway_freq_ru864  "$1" "$2" "$3" "$4" "$5" "$6" "$7" "$8" "ru864" "9" ;;
	10) gateway_freq_us915 "$1" "$2" "$3" "$4" "$5" "$6" "$7" "$8" "us915" "10" ;;
 
  esac
fi

func_concentrator_module "$1" "$2"

}

freq_module_setup_lbt(){

#"chirpstack-server" "2"
#"$1" "$2" "rak2287" "1" "SPI" "/dev/spidev0.0" "GPS" "LBT" "as923" "<band Value>
# $1   $2  $3        $4   $5   $6                $7    $8   $9      $10

default_item=$(jq .gateway_server.server_freq_region_value $STM32MP1_CONFIG) 
default_item=$(eval echo $default_item)
 

FUN=$(dialog --title "  configuration " --default-item $default_item --cancel-label "back" --menu "Please Select ISM BAND  :" 19 50 18 \
1  "AS923" \
2  "KR920" \
3>&1 1>&2 2>&3)
RET=$?
if [ $RET -eq 1 ]; then 
:
elif [ $RET -eq 0 ]; then
  case "${FUN}" in
	1) gateway_freq_as923_lbt  "$1" "$2" "$3" "$4" "$5" "$6" "$7" "$8" "as923" "1" ;;
	2) gateway_freq_kr920_lbt  "$1" "$2" "$3" "$4" "$5" "$6" "$7" "$8" "kr920" "2" ;;
  esac
fi

func_concentrator_module "$1" "$2"




}

 
func_concentrator_module(){

default_item=$(jq .gateway_model.gw_path_value  $STM32MP1_CONFIG) 
default_item=$(eval echo $default_item)

 FUN=$(dialog --title " ( RAK Model Selection ) " --default-item $default_item  --cancel-label "back" --menu "RAK Module Variant :  " 15 50 18 \
1 "RAK2287 SPI with GPS " \
2 "RAK2287 USB with GPS " \
3 "RAK2245 SPI with GPS " \
4 "RAK5146 SPI with GPS " \
5 "RAK5146 USB with GPS " \
6 "RAK5146 USB with GPS LBT " \
3>&1 1>&2 2>&3)
RET=$?
if [ $RET -eq 1 ]; then

if [ $2 -eq 2 ]; then
func_chirpstackserver
else
func_loRagateway
fi

elif [ $RET -eq 0 ]; then
case "$FUN" in
    1) freq_module_setup "$1" "$2" "rak2287" "1" "SPI" "GPS" "NONE" "/dev/spidev0.0"  ;;
    2) freq_module_setup "$1" "$2" "rak2287" "2" "USB" "GPS" "NONE" "/dev/ttyACM0" ;;
    3) freq_module_setup "$1" "$2" "rak2245" "3" "SPI" "GPS" "NONE" "/dev/spidev0.0" ;;
    4) freq_module_setup "$1" "$2" "rak5146" "4" "SPI" "GPS" "NONE" "/dev/spidev0.0" ;;
    5) freq_module_setup "$1" "$2" "rak5146" "5" "USB" "GPS" "NONE" "/dev/ttyACM0" ;;
    6) freq_module_setup_lbt "$1" "$2" "rak5146" "6" "USB" "GPS" "LBT" "/dev/ttyACM0" ;;
    esac
fi
} 	 

func_auto_gatewayid(){

GATEWAYEUI=$(jq .gateway_conf.gateway_ID  $SCRIPT_DIR/$MODULEPATH/global_conf.json)
GATEWAYEUI=$(eval echo $GATEWAYEUI) 

FUN=$(dialog --title " ( Gateway-eui configuration ) "  --cancel-label "back" --menu "Gateway-eui : [$GATEWAYEUI]  " 10 50 18 \
1 "ethernet mac address" \
2 "wifi mac address" \
3>&1 1>&2 2>&3)
RET=$?
if [ $RET -eq 1 ]; then

if [ $2 -eq 2 ]; then
func_chirpstackserver
else
func_loRagateway
fi

elif [ $RET -eq 0 ]; then
case "$FUN" in
    1) func_mac_id "$1" "$2" "lan"  ;;
    2) func_mac_id "$1" "$2" "wlan" ;;
  esac
fi

}

func_mac_id(){

MODULEPATH=$(jq .gateway_model.gw_path  $STM32MP1_CONFIG)
MODULEPATH=$(eval echo $MODULEPATH) 

FILEPATH=$SCRIPT_DIR/$MODULEPATH/local_conf.json

#enp0s31f6
#wlp2s0
if [ "$3" = "lan" ]; then
MACADD=eth0
#MACADD=enp0s31f6
else
MACADD=wlan0
#MACADD=wlp2s0
fi

# get gateway EUI from its MAC address to generate an EUI-64 address
GWID_MIDFIX="FFFF"
GWID_BEGIN=$(ip link show $MACADD | awk '/ether / {print $2}' | awk -F\: '{print $1$2$3}')
GWID_END=$(ip link show $MACADD | awk '/ether/ {print $2}' | awk -F\: '{print $4$5$6}')

sed -i 's/\(^\s*"gateway_ID":\s*"\).\{16\}"\s*\(,\?\).*$/\1'${GWID_BEGIN}${GWID_MIDFIX}${GWID_END}'"\2/' $FILEPATH

FILEPATH=$SCRIPT_DIR/$MODULEPATH/global_conf.json

# get gateway EUI from its MAC address to generate an EUI-64 address
GWID_MIDFIX="FFFF"
GWID_BEGIN=$(ip link show $MACADD | awk '/ether / {print $2}' | awk -F\: '{print $1$2$3}')
GWID_END=$(ip link show $MACADD | awk '/ether/ {print $2}' | awk -F\: '{print $4$5$6}')

sed -i 's/\(^\s*"gateway_ID":\s*"\).\{16\}"\s*\(,\?\).*$/\1'${GWID_BEGIN}${GWID_MIDFIX}${GWID_END}'"\2/' $FILEPATH
 
GATEWAYEUI=$(jq .gateway_conf.gateway_ID  $SCRIPT_DIR/$MODULEPATH/global_conf.json)
GATEWAYEUI=$(eval echo $GATEWAYEUI) 
 
tmp=$(mktemp)

jq -r --arg GATEWAYEUI "$GATEWAYEUI" '.gateway_server.server_eui = $GATEWAYEUI' $STM32MP1_CONFIG > "$tmp" && mv "$tmp" $STM32MP1_CONFIG

dialog --title " Gateway-eui Configuration " --msgbox "Gateway-eui : $GATEWAYEUI Configured " 5 70


if [ "$1" = "chirpstack-server" ]; then
func_chirpstackserver
else
func_loRagateway
fi

}

func_manual_gatewayid(){

GATEWAYEUI=$(jq .gateway_conf.gateway_ID  $SCRIPT_DIR/$MODULEPATH/global_conf.json)
GATEWAYEUI=$(eval echo $GATEWAYEUI) 

MODULEPATH=$(jq .gateway_model.gw_path  $STM32MP1_CONFIG)
MODULEPATH=$(eval echo $MODULEPATH) 
 
OUTPUT="/tmp/input.txt"
>$OUTPUT
trap "rm $OUTPUT; exit" SIGHUP SIGINT SIGTERM
dialog --title "Gateway EUI" --cancel-label "back" --inputbox "Please enter Gateway EUI " 8 40 2>$OUTPUT
RET=$?
if [ $RET -eq 1 ]; then
:
elif [ $RET -eq 0 ]; then

GATEWAYADDRESS=$(<$OUTPUT)

dialog --title "Confirmation " --yesno "Are you sure you want to change Gateway-eui to $GATEWAYADDRESS" 7 60
RET=$?
if [ $RET -eq 1 ]; then
:
elif [ $RET -eq 0 ]; then

tmp=$(mktemp)

#writing data to "local_conf.json"
FILEPATH=$SCRIPT_DIR/$MODULEPATH/local_conf.json

jq -r --arg GATEWAYADDRESS "$GATEWAYADDRESS" '.gateway_conf.gateway_ID = $GATEWAYADDRESS' $FILEPATH > "$tmp" && mv "$tmp" $FILEPATH

 
#writing data to "global_conf.json"
FILEPATH=$SCRIPT_DIR/$MODULEPATH/global_conf.json 
 
jq -r --arg GATEWAYADDRESS "$GATEWAYADDRESS" '.gateway_conf.gateway_ID = $GATEWAYADDRESS' $FILEPATH > "$tmp" && mv "$tmp" $FILEPATH


#writing data from "stm32mpu-configuration.json"



jq -r --arg GATEWAYADDRESS "$GATEWAYADDRESS" '.gateway_server.server_eui = $GATEWAYADDRESS' $STM32MP1_CONFIG > "$tmp" && mv "$tmp" $STM32MP1_CONFIG


dialog --title "Gateway-eui Configuration" --msgbox " GATEWAY EUI : $GATEWAYADDRESS  Configured " 7 60

fi
fi
rm $OUTPUT

if [ "$1" = "chirpstack-server" ]; then
func_chirpstackserver
else
func_loRagateway
fi


}

func_gatewayid_config(){

MODULEPATH=$(jq .gateway_model.gw_path  $STM32MP1_CONFIG)
MODULEPATH=$(eval echo $MODULEPATH) 


GATEWAYEUI=$(jq .gateway_conf.gateway_ID  $SCRIPT_DIR/$MODULEPATH/global_conf.json)
GATEWAYEUI=$(eval echo $GATEWAYEUI) 


FUN=$(dialog --title " ( Gateway-eui configuration ) "  --cancel-label "back" --menu "Gateway-eui : [$GATEWAYEUI]  " 10 50 18 \
1 "Auto configuration " \
2 "Manual configuration " \
3>&1 1>&2 2>&3)
RET=$?
if [ $RET -eq 1 ]; then

if [ $2 -eq 2 ]; then
func_chirpstackserver
else
func_loRagateway
fi

elif [ $RET -eq 0 ]; then
case "$FUN" in
    1) func_auto_gatewayid "$1" "$2";;
    2) func_manual_gatewayid "$1" "$2";;
  esac
fi



 
}
  
func_chirpstackserver(){
FUN=$(dialog --title " ( Chirpstack Configuration ) "  --cancel-label "back" --menu "Chirpstack  Configuration  " 15 50 18 \
1 "Concentrator selection " \
2 "GatewayEUI configuraion" \
3 "Server configuration"  \
4 "Communication mode " \
5 "Database configuration " \
6 "Start chirpstack " \
3>&1 1>&2 2>&3)
RET=$?
if [ $RET -eq 1 ]; then
stm32mp1_gateway_menu
elif [ $RET -eq 0 ]; then
case "$FUN" in
    1) func_concentrator_module "chirpstack-server" "2";;
    2) func_gatewayid_config "chirpstack-server" "2";;
    3) func_server_config "chirpstack-server" "2";;
    4) func_comm_mode "chirpstack-server" "2" ;; 
    5) func_chirp_database;;
    6) func_gateway_start "chirpstack-server" "2";;
  esac
fi

}
  
func_loRagateway(){

FUN=$(dialog --title " ( LoRagateway Configuration ) " --cancel-label "back" --menu "Lora Gateway Configuration  " 15 50 18 \
1 "Concentrator selection " \
2 "GatewayEUI configuraion" \
3 "Server configuration"  \
4 "Communication mode " \
5 "Start loragateway " \
3>&1 1>&2 2>&3) 
RET=$?
if [ $RET -eq 1 ]; then
stm32mp1_gateway_menu	
elif [ $RET -eq 0 ]; then
case "$FUN" in	
    1) func_concentrator_module "lora-gateway" "1";;
    2) func_gatewayid_config "lora-gateway" "1";;
    3) func_server_config "lora-gateway" "1";;
    4) func_comm_mode "lora-gateway" "1";;
    5) func_gateway_start "lora-gateway" "1";;
  esac
fi

}

stm32mp1_gateway_menu(){

FUN=$(dialog --title " (STM32MP1 Gateway)" --cancel-label "Quit" --menu "stm32mp1 gateway Configuration " 16 50 18 \
1 "loRagateway " \
2 "chirpstack"  \
3 "wifi config" \
4 "gateway_info " \
5 "Modify global_conf" \
6 "Modify local_conf" \
7 "Modify network_server" \
8 "Modify application_server" \
9 "stm32mp1 restart " \
3>&1 1>&2 2>&3)
RET=$?
if [ $RET -eq 1 ]; then 
clear
exit 
elif [ $RET -eq 0 ]; then
case "$FUN" in
    1) func_loRagateway;;
    2) func_chirpstackserver;;
    3) func_wifi_config;;
    4) func_read_gateway_info;;
    5) func_global_conf;;
    6) func_local_conf;;
    7) func_network_server;;
    8) func_application_server;;
    9) func_reboot;; 
  esac
fi   

}

if [ $(id -u) -ne 0 ]; then
printf "Run script as root. Try 'sudo stm32mp1-config'\n"
exit 1
fi

stm32mp1_gateway_menu

exit
