#!/bin/bash

export NCURSES_NO_UTF8_ACS=1


SCRIPT_DIR=$(pwd)
STM32MP1_CONFIG=$SCRIPT_DIR/stm32mp1-configuration.json

MODULE_PATH=$(jq .gateway_model.gw_path $STM32MP1_CONFIG)
MODULE_PATH=$(eval echo $MODULE_PATH)

R_FILEPATH=$SCRIPT_DIR/$MODULE_PATH/global_conf.json

dialog --title " gateway info " --infobox "\n
Please wait .....\n" 5 30

gatewayversion="1.0"
 
gatewayconfig=$(jq .gateway_server.server_path $STM32MP1_CONFIG) 
gatewayconfig=$(eval echo $gatewayconfig)


model=$(jq .gateway_model.gw_path $STM32MP1_CONFIG) 
model=$(eval echo $model)

modelgps=$(jq .gateway_model.gw_com_gps $STM32MP1_CONFIG) 
modelgps=$(eval echo $modelgps)

modellbt=$(jq .gateway_model.gw_com_lbt $STM32MP1_CONFIG) 
modellbt=$(eval echo $modellbt)

modelcom=$(jq .SX130x_conf.com_type  $R_FILEPATH) 
modelcom=$(eval echo $modelcom)
 
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
lanmacid=$(ip link show eth0 | awk '/ether / {print $2}' )
wlanmacid=$(ip link show wlan0 | awk '/ether / {print $2}' )

if [ "$connectmode" = "lan" ]; then 
ipaddress=$(/sbin/ip -o -4 addr list eth0 | awk '{print $4}' | cut -d/ -f1)
else
ipaddress=$(/sbin/ip -o -4 addr list wlan0 | awk '{print $4}' | cut -d/ -f1)
fi

 
{
freq0=$(jq .SX130x_conf.radio_0.freq $R_FILEPATH)
freq0=$(eval echo $freq0)

freq1=$(jq .SX130x_conf.radio_1.freq $R_FILEPATH)
freq1=$(eval echo $freq1)


#SF0
sfenable=$(jq .SX130x_conf.chan_multiSF_0.enable $R_FILEPATH)
sfenable=$(eval echo $sfenable)

if [ "$sfenable" = "true" ]; then

sfradio=$(jq .SX130x_conf.chan_multiSF_0.radio $R_FILEPATH)
sfradio=$(eval echo $sfradio)
BW0="BW125KHZ"
SFACTOR0="SF7/SF12"
COMMENT0="LORA_MULTI_SF"

freqoffset=$(jq .SX130x_conf.chan_multiSF_0.if $R_FILEPATH)
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
sfenable=$(jq .SX130x_conf.chan_multiSF_1.enable $R_FILEPATH)
sfenable=$(eval echo $sfenable)

if [ "$sfenable" = "true" ]; then

sfradio=$(jq .SX130x_conf.chan_multiSF_1.radio $R_FILEPATH)
sfradio=$(eval echo $sfradio)

BW1="BW125KHZ"
SFACTOR1="SF7/SF12"
COMMENT1="LORA_MULTI_SF"

freqoffset=$(jq .SX130x_conf.chan_multiSF_1.if $R_FILEPATH)
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
sfenable=$(jq .SX130x_conf.chan_multiSF_2.enable $R_FILEPATH)
sfenable=$(eval echo $sfenable)

if [ "$sfenable" = "true" ]; then

sfradio=$(jq .SX130x_conf.chan_multiSF_2.radio $R_FILEPATH)
sfradio=$(eval echo $sfradio)

BW2="BW125KHZ"
SFACTOR2="SF7/SF12"
COMMENT2="LORA_MULTI_SF"
 
freqoffset=$(jq .SX130x_conf.chan_multiSF_2.if $R_FILEPATH)
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

sfenable=$(jq .SX130x_conf.chan_multiSF_3.enable $R_FILEPATH)
sfenable=$(eval echo $sfenable)

if [ "$sfenable" = "true" ]; then

sfradio=$(jq .SX130x_conf.chan_multiSF_3.radio $R_FILEPATH)
sfradio=$(eval echo $sfradio)

BW3="BW125KHZ"
SFACTOR3="SF7/SF12"
COMMENT3="LORA_MULTI_SF"

freqoffset=$(jq .SX130x_conf.chan_multiSF_3.if $R_FILEPATH)
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

sfenable=$(jq .SX130x_conf.chan_multiSF_4.enable $R_FILEPATH)
sfenable=$(eval echo $sfenable)

if [ "$sfenable" = "true" ]; then

sfradio=$(jq .SX130x_conf.chan_multiSF_4.radio $R_FILEPATH)
sfradio=$(eval echo $sfradio)


BW4="BW125KHZ" 
SFACTOR4="SF7/SF12"
COMMENT4="LORA_MULTI_SF"

freqoffset=$(jq .SX130x_conf.chan_multiSF_4.if $R_FILEPATH)
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
sfenable=$(jq .SX130x_conf.chan_multiSF_5.enable $R_FILEPATH)
sfenable=$(eval echo $sfenable)

if [ "$sfenable" = "true" ]; then

sfradio=$(jq .SX130x_conf.chan_multiSF_5.radio $R_FILEPATH)
sfradio=$(eval echo $sfradio)

 
BW5="BW125KHZ"
SFACTOR5="SF7/SF12"
COMMENT5="LORA_MULTI_SF"

freqoffset=$(jq .SX130x_conf.chan_multiSF_5.if $R_FILEPATH)
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

sfenable=$(jq .SX130x_conf.chan_multiSF_6.enable $R_FILEPATH)
sfenable=$(eval echo $sfenable)

if [ "$sfenable" = "true" ]; then

sfradio=$(jq .SX130x_conf.chan_multiSF_6.radio $R_FILEPATH)
sfradio=$(eval echo $sfradio)
 
BW6="BW125KHZ"
SFACTOR6="SF7/SF12"
COMMENT6="LORA_MULTI_SF"

freqoffset=$(jq .SX130x_conf.chan_multiSF_6.if $R_FILEPATH)
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
sfenable=$(jq .SX130x_conf.chan_multiSF_7.enable $R_FILEPATH)
sfenable=$(eval echo $sfenable)

if [ "$sfenable" = "true" ]; then

sfradio=$(jq .SX130x_conf.chan_multiSF_7.radio $R_FILEPATH)
sfradio=$(eval echo $sfradio)

BW7="BW125KHZ"
SFACTOR7="SF7/SF12"
COMMENT7="LORA_MULTI_SF"

freqoffset=$(jq .SX130x_conf.chan_multiSF_7.if $R_FILEPATH)
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
sfenable=$(jq .SX130x_conf.chan_FSK.enable $R_FILEPATH)
sfenable=$(eval echo $sfenable)

if [ "$sfenable" = "true" ]; then

sfradio=$(jq .SX130x_conf.chan_FSK.radio $R_FILEPATH)
sfradio=$(eval echo $sfradio)
	
freqoffset=$(jq .SX130x_conf.chan_FSK.if $R_FILEPATH)
freqoffset=$(eval echo $freqoffset)

bandwidth=$(jq .SX130x_conf.chan_FSK.bandwidth $R_FILEPATH)
bandwidth=$(eval echo $bandwidth)

datarate=$(jq .SX130x_conf.chan_FSK.datarate $R_FILEPATH)
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

sfenable=$(jq .SX130x_conf.chan_Lora_std.enable $R_FILEPATH)
sfenable=$(eval echo $sfenable)

if [ "$sfenable" = "true" ]; then

sfradio=$(jq .SX130x_conf.chan_Lora_std.radio $R_FILEPATH)
sfradio=$(eval echo $sfradio)



freqoffset=$(jq .SX130x_conf.chan_Lora_std.if $R_FILEPATH)
freqoffset=$(eval echo $freqoffset)


bandwidth=$(jq .SX130x_conf.chan_Lora_std.bandwidth $R_FILEPATH)
bandwidth=$(eval echo $bandwidth)

spreadfactor=$(jq .SX130x_conf.chan_Lora_std.spread_factor $R_FILEPATH)
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

if [ "$modellbt" = "LBT" ]; then

lbt0=$(jq .SX130x_conf.sx1261_conf.lbt.channels[0].freq_hz $R_FILEPATH)
lbt0=$(eval echo $lbt0)

lbtbw0=$(jq .SX130x_conf.sx1261_conf.lbt.channels[0].bandwidth $R_FILEPATH)
lbtbw0=$(eval echo $lbtbw0)

lbtst0=$(jq .SX130x_conf.sx1261_conf.lbt.channels[0].scan_time_us $R_FILEPATH)
lbtst0=$(eval echo $lbtst0)

lbttt0=$(jq .SX130x_conf.sx1261_conf.lbt.channels[0].transmit_time_ms $R_FILEPATH)
lbttt0=$(eval echo $lbttt0)

lbt1=$(jq .SX130x_conf.sx1261_conf.lbt.channels[1].freq_hz $R_FILEPATH)
lbt1=$(eval echo $lbt1)

lbtbw1=$(jq .SX130x_conf.sx1261_conf.lbt.channels[1].bandwidth $R_FILEPATH)
lbtbw1=$(eval echo $lbtbw1)

lbtst1=$(jq .SX130x_conf.sx1261_conf.lbt.channels[1].scan_time_us $R_FILEPATH)
lbtst1=$(eval echo $lbtst1)

lbttt1=$(jq .SX130x_conf.sx1261_conf.lbt.channels[1].transmit_time_ms $R_FILEPATH)
lbttt1=$(eval echo $lbttt1)

if [ "$lbt1" = "null" ]; then
lbt1="   OFF   "
lbtbw1="        "
lbtst1=" "
lbttt1=" "
fi


#
lbt2=$(jq .SX130x_conf.sx1261_conf.lbt.channels[2].freq_hz $R_FILEPATH)
lbt2=$(eval echo $lbt2)

lbtbw2=$(jq .SX130x_conf.sx1261_conf.lbt.channels[2].bandwidth $R_FILEPATH)
lbtbw2=$(eval echo $lbtbw2)

lbtst2=$(jq .SX130x_conf.sx1261_conf.lbt.channels[2].scan_time_us $R_FILEPATH)
lbtst2=$(eval echo $lbtst2)

lbttt2=$(jq .SX130x_conf.sx1261_conf.lbt.channels[2].transmit_time_ms $R_FILEPATH)
lbttt2=$(eval echo $lbttt2)

if [ "$lbt2" = "null" ]; then
lbt2="   OFF   "
lbtbw2="        "
lbtst2=" "
lbttt2=" "
fi


#3

lbt3=$(jq .SX130x_conf.sx1261_conf.lbt.channels[3].freq_hz $R_FILEPATH)
lbt3=$(eval echo $lbt3)

lbtbw3=$(jq .SX130x_conf.sx1261_conf.lbt.channels[3].bandwidth $R_FILEPATH)
lbtbw3=$(eval echo $lbtbw3)

lbtst3=$(jq .SX130x_conf.sx1261_conf.lbt.channels[3].scan_time_us $R_FILEPATH)
lbtst3=$(eval echo $lbtst3)

lbttt3=$(jq .SX130x_conf.sx1261_conf.lbt.channels[3].transmit_time_ms $R_FILEPATH)
lbttt3=$(eval echo $lbttt3)

if [ "$lbt3" = "null" ]; then
lbt3="   OFF   "
lbtbw3="        "
lbtst3=" "
lbttt3=" "
fi


#4

lbt4=$(jq .SX130x_conf.sx1261_conf.lbt.channels[4].freq_hz $R_FILEPATH)
lbt4=$(eval echo $lbt4)

lbtbw4=$(jq .SX130x_conf.sx1261_conf.lbt.channels[4].bandwidth $R_FILEPATH)
lbtbw4=$(eval echo $lbtbw4)

lbtst4=$(jq .SX130x_conf.sx1261_conf.lbt.channels[4].scan_time_us $R_FILEPATH)
lbtst4=$(eval echo $lbtst4)

lbttt4=$(jq .SX130x_conf.sx1261_conf.lbt.channels[4].transmit_time_ms $R_FILEPATH)
lbttt4=$(eval echo $lbttt4)

if [ "$lbt4" = "null" ]; then
lbt4="   OFF   "
lbtbw4="        "
lbtst4=" "
lbttt4=" "
fi


#4
lbt5=$(jq .SX130x_conf.sx1261_conf.lbt.channels[5].freq_hz $R_FILEPATH)
lbt5=$(eval echo $lbt5)

lbtbw5=$(jq .SX130x_conf.sx1261_conf.lbt.channels[5].bandwidth $R_FILEPATH)
lbtbw5=$(eval echo $lbtbw5)

lbtst5=$(jq .SX130x_conf.sx1261_conf.lbt.channels[5].scan_time_us $R_FILEPATH)
lbtst5=$(eval echo $lbtst5)

lbttt5=$(jq .SX130x_conf.sx1261_conf.lbt.channels[5].transmit_time_ms $R_FILEPATH)
lbttt5=$(eval echo $lbttt5)

if [ "$lbt5" = "null" ]; then
lbt5="   OFF   "
lbtbw5="        "
lbtst5=" "
lbttt5=" "
fi


#6
lbt6=$(jq .SX130x_conf.sx1261_conf.lbt.channels[6].freq_hz $R_FILEPATH)
lbt6=$(eval echo $lbt6)

lbtbw6=$(jq .SX130x_conf.sx1261_conf.lbt.channels[6].bandwidth $R_FILEPATH)
lbtbw6=$(eval echo $lbtbw6)

lbtst6=$(jq .SX130x_conf.sx1261_conf.lbt.channels[6].scan_time_us $R_FILEPATH)
lbtst6=$(eval echo $lbtst6)

lbttt6=$(jq .SX130x_conf.sx1261_conf.lbt.channels[6].transmit_time_ms $R_FILEPATH)
lbttt6=$(eval echo $lbttt6)

if [ "$lbt6" = "null" ]; then
lbt6="   OFF   "
lbtbw6="        "
lbtst6=" "
lbttt6=" "
fi

#7
lbt7=$(jq .SX130x_conf.sx1261_conf.lbt.channels[6].freq_hz $R_FILEPATH)
lbt7=$(eval echo $lbt7)

lbtbw7=$(jq .SX130x_conf.sx1261_conf.lbt.channels[7].bandwidth $R_FILEPATH)
lbtbw7=$(eval echo $lbtbw7)

lbtst7=$(jq .SX130x_conf.sx1261_conf.lbt.channels[7].scan_time_us $R_FILEPATH)
lbtst7=$(eval echo $lbtst7)

lbttt7=$(jq .SX130x_conf.sx1261_conf.lbt.channels[7].transmit_time_ms $R_FILEPATH)
lbttt7=$(eval echo $lbttt7)

if [ "$lbt7" = "null" ]; then
lbt7="   OFF   "
lbtbw7="        "
lbtst7=" "
lbttt7=" "
fi

#8

lbt8=$(jq .SX130x_conf.sx1261_conf.lbt.channels[8].freq_hz $R_FILEPATH)
lbt8=$(eval echo $lbt8)

lbtbw8=$(jq .SX130x_conf.sx1261_conf.lbt.channels[8].bandwidth $R_FILEPATH)
lbtbw8=$(eval echo $lbtbw0)

lbtst8=$(jq .SX130x_conf.sx1261_conf.lbt.channels[8].scan_time_us $R_FILEPATH)
lbtst8="SCANTIME$(eval echo $lbtst8)uS"

lbttt8=$(jq .SX130x_conf.sx1261_conf.lbt.channels[8].transmit_time_ms $R_FILEPATH)
lbttt8="TRANSMITTIME$(eval echo $lbttt8)mS"
 

if [ "$lbt8" = "null" ]; then
lbt8="   OFF   "
lbtbw8="        "
lbtst8=" "
lbttt8=" "
fi

fi


 
dialog --title " $1 Configuration   " --msgbox "\n
GATEWAYVERSION     : [$gatewayversion]\n
GATEWAYCONFIG      : [$gatewayconfig]\n
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


if [ "$modellbt" = "LBT" ]; then

dialog --title " $1 LBT  Configuration   " --msgbox "\n
LBT        : [$frequencyregion]\n
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
 
