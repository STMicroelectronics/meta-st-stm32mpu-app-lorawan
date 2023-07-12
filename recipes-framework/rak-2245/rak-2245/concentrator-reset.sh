#!/bin/bash

#echo "Reset GPIO17/PG8 on STM32MP1"
gpioset gpiochip6 8=1
sleep 0.1
#echo "set to 1"
gpioset gpiochip6 8=0
#echo "set to 0"
sleep 0.1
gpioget gpiochip6 8
sleep 0.5



