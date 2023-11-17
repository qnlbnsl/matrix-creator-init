#!/bin/bash

cd /usr/share/matrixlabs/matrixio-devices

function detect_device(){
  MATRIX_DEVICE=$(./fpga_info | grep IDENTIFY | cut -f 4 -d ' ')
}

function read_voice_config(){
  ESP32_RESET=$(cat /etc/matrixio-devices/matrix_voice.config | grep ESP32_BOOT_ON_RESET| cut -f 3 -d ' ')
}

echo "Programmning FPGA"
./fpga-program.bash
echo "done"
sleep 5
detect_device

case "${MATRIX_DEVICE}" in
  "5c344e8")  
     echo "*** MATRIX Creator initial process has been launched"
     echo "Programmning EM358"
    sudo ./em358-program.bash
    echo "enabling radio"
    sudo ./radio-init.bash
    echo "programming sam3"
    sudo ./sam3-program.bash
    echo "done"
    ;;
  "6032bad2")
    echo "*** MATRIX Voice initial process has been launched"
    voice_esp32_reset
    read_voice_config
    if [ "${ESP32_RESET}" == "FALSE" ]; then
      echo 1 > /sys/class/gpio/gpio25/value
    else 
      echo 0 > /sys/class/gpio/gpio25/value
    fi
    ;;
esac

exit 0
